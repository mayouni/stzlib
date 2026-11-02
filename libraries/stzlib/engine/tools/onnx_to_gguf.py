#!/usr/bin/env python3
"""onnx_to_gguf.py -- an ONNX graph as a GGUF file the engine's ocr_graph.zig runs on ggml.

    python onnx_to_gguf.py <model.onnx> <out.gguf> [--kind det|rec|cls] [--direction=rtl] [--classifier=off]

The GGUF carries the weights as F32 tensors (c0, c1, ...; ne = the ONNX shape reversed, which is the same
memory) and a PROGRAM: one string per op, in order, over a small op set that maps one-to-one onto ggml:

    out=op(in1,in2;key=v1,v2;...;r=<rank of out>)

    conv(x,w;s=sx,sy;p=px,py;dw=0|1)   convt(x,w;s=n)   pad(x;r=n;b=n)     pool(x;k=k0,k1;s=s0,s1;kind=max|avg)
    gap(x)   up(x;f=n)   concat(a,b,..;d=ggml dim)   add/sub/mul/div(a,b)   sb(x;s=scale;b=bias)   clamp(x;lo;hi)
    relu/sigmoid/gelu/sqr/sqrt/mean/softmax(x)   linear(x,wT)   matmul(a,b)   permute(x;p=onnx perm)
    reshape(x;d=dims)  with each dim an int, -1, or @name:j (ONNX dim j of a tensor)     heads(x;h;d;i)

Ops the ONNX graph writes as several nodes are matched and emitted as one (GELU through Erf; the attention
head split reshape/transpose/slice/squeeze; a BatchNormalization becomes a per-channel mul and add); a shape
computed by Shape/Slice/Concat/Cast is traced symbolically into a reshape spec. Anything outside the set stops
the conversion with the node named -- the converter never guesses.

VISION (IM3 of SOFTANZA_IMAGE_INTELLIGENCE.md): the same file shape carries the image plane's models.

    --kind=classify --labels=<config.json with id2label> --input=224     MobileNetV3 (timm)
    --kind=yunet                                                          YuNet: its 12 heads fused into ONE
                                                                          output [1, 8400, 16] (see fuse_yunet)
    --kind=yolox --labels=coco                                            YOLOX: one output [1, N, 85]

and adds Flatten, Gemm, symmetric MaxPool padding, and step2(x;a;o) -- every second row or column from
offset o -- for the four Slices of YOLOX's Focus layer. Labels go in stz.graph.labels, the input size in
stz.graph.input_w / input_h.

Run it in an environment with onnx and numpy (the Docling venv has both). Written for the PP-OCR family:
PP-OCRv6 det/rec small and the ch_ppocr_mobile_v2.0 angle classifier, whose exports (Paddle2ONNX, opset 11)
are the graphs it was checked against.
"""
import os
import struct
import sys

import numpy as np
import onnx
from onnx import numpy_helper

U8, I8, U16, I16, U32, I32, F32, BOOL, STRING, ARRAY = range(10)
ALIGN = 32


def _s(v):
    b = v.encode("utf-8")
    return struct.pack("<Q", len(b)) + b


def kv_str(k, v):
    return _s(k) + struct.pack("<I", STRING) + _s(v)


def kv_u32(k, v):
    return _s(k) + struct.pack("<II", U32, v)


def kv_strarr(k, vals):
    # one join, not a += per string: the tokenizer's 580,604 merges made the += form quadratic (hours)
    return _s(k) + struct.pack("<I", ARRAY) + struct.pack("<IQ", STRING, len(vals)) + b"".join(_s(v) for v in vals)


class Refused(Exception):
    pass


class Converter:
    def __init__(self, path):
        m = onnx.load(path)
        self.model = m
        self.vshape = {}  # --static: onnx name -> its full shape, every dim a number (onnx shape inference)
        g = m.graph
        self.meta = {p.key: p.value for p in m.metadata_props}
        self.C = {t.name: numpy_helper.to_array(t) for t in g.initializer}
        self.alias = {}
        self.nodes = []
        for n in g.node:
            if n.op_type == "Constant":
                self.C[n.output[0]] = numpy_helper.to_array(n.attribute[0].t)
            elif n.op_type == "Identity":
                self.alias[n.output[0]] = n.input[0]
            else:
                self.nodes.append(n)
        ins = [i.name for i in g.input if i.name not in self.C]
        if len(ins) != 1:
            raise Refused("expected one graph input, found %r" % ins)
        self.input = ins[0]
        self.output = g.output[0].name
        self.outputs = [o.name for o in g.output]
        self.rank = {self.input: 4}
        self.pname = {self.input: "x"}  # onnx name -> program name
        self.shape = {}  # onnx name -> shape-domain list (ints or ('dim', onnxname, j))
        self.prog = []
        self.consts = []  # (pname, array)
        self.flushed = 0  # subnormal weights set to zero (add_const)
        self.nt = 0
        self.skip = set()
        self.users = {}
        for i, n in enumerate(self.nodes):
            for x in n.input:
                self.users.setdefault(self.r(x), []).append(i)
        self.producer = {}
        for i, n in enumerate(self.nodes):
            for o in n.output:
                self.producer[o] = i

    def use_static_input(self, dims):
        """--static (IM6): the input's dims are fixed, so ONNX shape inference (with data propagation) knows every
        tensor's shape, and a Shape of any fully known tensor folds to numbers -- DINOv2's patch-grid arithmetic
        (Depth-Anything) becomes constants instead of a shape program the runner cannot run."""
        from onnx import shape_inference
        m = onnx.ModelProto()
        m.CopyFrom(self.model)
        for i in m.graph.input:
            if i.name == self.input:
                dd = i.type.tensor_type.shape.dim
                for k, v in enumerate(dims):
                    dd[k].ClearField("dim_param")
                    dd[k].dim_value = int(v)
        m = shape_inference.infer_shapes(m, data_prop=True)
        for vi in list(m.graph.value_info) + list(m.graph.output):
            d = vi.type.tensor_type.shape.dim
            if len(d) and all(x.HasField("dim_value") for x in d):
                self.vshape[vi.name] = [int(x.dim_value) for x in d]
        self.static_input = list(dims)
        self.rank[self.input] = len(dims)

    # -- names -----------------------------------------------------------------------------------------------
    def r(self, n):
        while n in self.alias:
            n = self.alias[n]
        return n

    def is_const(self, n):
        return self.r(n) in self.C

    def const(self, n):
        return self.C[self.r(n)]

    def new(self, onnx_name, rank):
        self.nt += 1
        p = "t%d" % self.nt
        self.pname[onnx_name] = p
        self.rank[onnx_name] = rank
        return p

    def p(self, n):
        n = self.r(n)
        if n in self.pname:
            return self.pname[n]
        if n in self.C:
            return self.add_const(n, self.C[n])
        raise Refused("tensor %s is not produced by anything the converter handled" % n)

    def add_const(self, onnx_name, arr):
        arr = np.array(arr, dtype=np.float32)  # a copy: the flush below must not write into the ONNX initialiser
        # SUBNORMAL WEIGHTS ARE FLUSHED TO ZERO. A float32 below 1.2e-38 is multiplied in microcode on x86, a
        # hundred times slower than a normal one: two 1x1 convolutions of PP-OCRv6's detector hold 24% and 63%
        # subnormal weights, and they alone cost seconds per page. Their contribution is below 1e-38 per term.
        sub = (arr != 0) & (np.abs(arr) < np.finfo(np.float32).tiny)
        self.flushed += int(sub.sum())
        arr[sub] = 0.0
        p = "c%d" % len(self.consts)
        self.consts.append((p, arr))
        if onnx_name is not None:
            self.pname[onnx_name] = p
            self.rank[onnx_name] = arr.ndim
        return p

    def emit(self, out, op, inputs, rank, **kw):
        pn = self.new(out, rank)
        parts = [",".join(inputs)]
        for k, v in kw.items():
            if isinstance(v, (list, tuple)):
                parts.append("%s=%s" % (k, ",".join(str(x) for x in v)))
            else:
                parts.append("%s=%s" % (k, v))
        parts.append("r=%d" % rank)
        self.prog.append("%s=%s(%s)" % (pn, op, ";".join(parts)))
        return pn

    def attrs(self, n):
        a = {}
        for x in n.attribute:
            if x.type == onnx.AttributeProto.INTS:
                a[x.name] = list(x.ints)
            elif x.type == onnx.AttributeProto.INT:
                a[x.name] = x.i
            elif x.type == onnx.AttributeProto.FLOAT:
                a[x.name] = x.f
            elif x.type == onnx.AttributeProto.STRING:
                a[x.name] = x.s.decode()
        return a

    # -- the shape domain: a value that is a list of dims, some of them symbolic ---------------------------------
    def shape_of(self, n):
        n = self.r(n)
        if n in self.shape:
            return self.shape[n]
        if n in self.C:
            return [int(v) for v in np.asarray(self.C[n]).flatten()]
        return None

    def in_shape_domain(self, node):
        if node.op_type == "Shape":
            return True
        if node.op_type in ("Reshape", "Tile", "Resize"):
            # these read a shape as a PARAMETER (Resize's sizes): they are in the shape domain only when their data is
            return self.r(node.input[0]) in self.shape
        return any(self.r(x) in self.shape for x in node.input)

    def do_shape_node(self, node):
        t = node.op_type
        if t == "Shape" and getattr(self, "static_input", None) and self.r(node.input[0]) == self.input:
            self.shape[node.output[0]] = list(self.static_input)
            return
        if t == "Shape" and self.r(node.input[0]) in self.vshape:
            v = self.vshape[self.r(node.input[0])]
            a = self.attrs(node)
            self.shape[node.output[0]] = v[a.get("start", 0):a["end"]] if "end" in a else v[a.get("start", 0):]
            return
        if t == "Shape":
            src = self.r(node.input[0])
            if src not in self.rank:
                raise Refused("Shape of %s whose rank is unknown" % src)
            self.shape[node.output[0]] = [("dim", src, j) for j in range(self.rank[src])]
            return
        if t == "Gather":
            v = self.shape_of(node.input[0])
            idx = np.asarray(self.const(node.input[1])).flatten()
            picked = [v[int(k)] for k in idx]
            self.shape[node.output[0]] = picked if np.asarray(self.const(node.input[1])).ndim > 0 else picked[:1]
            return
        if t == "Slice":
            v = self.shape_of(node.input[0])
            starts = int(self.const(node.input[1]).flatten()[0])
            ends = int(self.const(node.input[2]).flatten()[0])
            if len(node.input) > 3 and self.is_const(node.input[3]):
                if int(self.const(node.input[3]).flatten()[0]) != 0:
                    raise Refused("Slice of a shape on an axis other than 0")
            step = 1
            if len(node.input) > 4:
                step = int(self.const(node.input[4]).flatten()[0])
            self.shape[node.output[0]] = v[starts:ends:step]
            return
        if t in ("Squeeze", "Unsqueeze", "Cast", "Reshape"):
            self.shape[node.output[0]] = list(self.shape_of(node.input[0]))
            return
        if t == "Concat":
            out = []
            for x in node.input:
                out += self.shape_of(x)
            self.shape[node.output[0]] = out
            return
        raise Refused("op %s (%s) on a shape value" % (t, node.name))

    def spec_from(self, items):
        out = []
        for it in items:
            if isinstance(it, tuple):
                out.append("@%s:%d" % (self.p(it[1]), it[2]))
            else:
                out.append(str(int(it)))
        return out

    # -- constant folding over constants only ---------------------------------------------------------------------
    def fold(self, node):
        t = node.op_type
        a = self.attrs(node)
        ins = [self.const(x) if x else None for x in node.input]  # "" = an optional input left out
        if t == "Reshape":
            shp = [int(v) for v in ins[1].flatten()]
            shp = [ins[0].shape[i] if v == 0 else v for i, v in enumerate(shp)]
            return ins[0].reshape(shp)
        if t == "Unsqueeze":
            v = ins[0]
            for ax in sorted(self.axes_of(node, a)):
                v = np.expand_dims(v, ax)
            return v
        if t == "Squeeze":
            return np.squeeze(ins[0], axis=tuple(self.axes_of(node, a))) if self.axes_of(node, a) else np.squeeze(ins[0])
        if t == "Cast":
            # the target type matters once shapes are numbers (--static): an int64 Div truncates, a float one does not
            return ins[0].astype(onnx.helper.tensor_dtype_to_np_dtype(a["to"])) if "to" in a else ins[0]
        if t == "Concat":
            return np.concatenate(ins, axis=a.get("axis", 0))
        if t == "Transpose":
            return np.transpose(ins[0], a["perm"])
        if t == "Gather":
            return np.take(ins[0], ins[1].astype(np.int64), axis=a.get("axis", 0))
        if t == "Slice":
            v = ins[0]
            st = [int(x) for x in ins[1].flatten()]
            en = [int(x) for x in ins[2].flatten()]
            ax = [int(x) for x in ins[3].flatten()] if len(ins) > 3 else list(range(len(st)))
            sp = [int(x) for x in ins[4].flatten()] if len(ins) > 4 else [1] * len(st)
            sl = [slice(None)] * v.ndim
            for k in range(len(st)):
                sl[ax[k] % v.ndim] = slice(st[k], en[k], sp[k])
            return v[tuple(sl)]
        if t == "Mul":
            return ins[0] * ins[1]
        if t == "Add":
            return ins[0] + ins[1]
        # IM6 (--static): the shape arithmetic of a ViT, now that every shape is a number
        if t == "Sub":
            return ins[0] - ins[1]
        if t == "Div":
            if np.issubdtype(ins[0].dtype, np.integer) and np.issubdtype(ins[1].dtype, np.integer):
                return np.trunc(ins[0] / ins[1]).astype(ins[0].dtype)  # ONNX integer division truncates
            return ins[0] / ins[1]
        if t == "Neg":
            return -ins[0]
        if t in ("Floor", "Ceil", "Sqrt", "Abs"):
            return {"Floor": np.floor, "Ceil": np.ceil, "Sqrt": np.sqrt, "Abs": np.abs}[t](ins[0])
        if t == "Pow":
            return np.power(ins[0], ins[1])
        if t in ("Equal", "Less", "Greater", "LessOrEqual", "GreaterOrEqual"):
            return {"Equal": np.equal, "Less": np.less, "Greater": np.greater, "LessOrEqual": np.less_equal,
                    "GreaterOrEqual": np.greater_equal}[t](ins[0], ins[1])
        if t == "Not":
            return np.logical_not(ins[0])
        if t == "Where":
            return np.where(ins[0], ins[1], ins[2])
        if t in ("Min", "Max"):
            return (np.minimum if t == "Min" else np.maximum).reduce(ins)
        if t == "Range":
            return np.arange(ins[0].item(), ins[1].item(), ins[2].item()).astype(ins[0].dtype)
        if t == "Expand":
            return ins[0] * np.ones([int(v) for v in ins[1].flatten()], dtype=ins[0].dtype)
        if t == "ConstantOfShape":
            va = [x for x in node.attribute if x.name == "value"]
            val = numpy_helper.to_array(va[0].t) if va else np.array([0.0], np.float32)
            return np.full([int(v) for v in ins[0].flatten()], val.flatten()[0], dtype=val.dtype)
        if t == "Shape":
            return np.array(ins[0].shape, dtype=np.int64)
        if t == "Resize":
            return self._fold_resize(node, a, ins)
        raise Refused("cannot fold constant op %s (%s)" % (t, node.name))

    def _fold_resize(self, node, a, ins):
        # a Resize of a CONSTANT (DINOv2's position embeddings interpolated to the patch grid): computed here, as
        # ONNX defines it for half-pixel coordinates -- cubic (a = cubic_coeff_a, borders clamped, as PyTorch's
        # bicubic) or linear
        x = ins[0].astype(np.float64)
        if len(ins) > 3 and ins[3] is not None and ins[3].size:
            size = [int(v) for v in ins[3].flatten()]
        else:
            size = [int(np.floor(n * f)) for n, f in zip(x.shape, ins[2].flatten())]
        mode = a.get("mode", "nearest")
        if a.get("coordinate_transformation_mode", "half_pixel") not in ("half_pixel", "pytorch_half_pixel") or                 mode not in ("cubic", "linear") or a.get("exclude_outside", 0):
            raise Refused("cannot fold Resize %s (%s, %s)" % (node.name, mode, a.get("coordinate_transformation_mode")))
        ca = a.get("cubic_coeff_a", -0.75)

        def kern(t):
            t = abs(t)
            if mode == "linear":
                return max(0.0, 1.0 - t)
            if t <= 1:
                return (ca + 2) * t ** 3 - (ca + 3) * t ** 2 + 1
            if t < 2:
                return ca * t ** 3 - 5 * ca * t ** 2 + 8 * ca * t - 4 * ca
            return 0.0

        for ax, m in enumerate(size):
            n = x.shape[ax]
            if m == n:
                continue
            w = np.zeros((m, n))
            for i in range(m):
                c = (i + 0.5) * n / m - 0.5
                f = int(np.floor(c))
                for k in range(f - 1, f + 3):
                    w[i, min(max(k, 0), n - 1)] += kern(c - k)
            x = np.moveaxis(np.tensordot(w, np.moveaxis(x, ax, 0), axes=1), 0, ax)
        return x.astype(ins[0].dtype)

    # -- the walk ---------------------------------------------------------------------------------------------------
    def convert(self):
        for i, node in enumerate(self.nodes):
            if i in self.skip:
                continue
            if all(self.is_const(x) for x in node.input) and node.op_type != "Shape":
                self.C[node.output[0]] = self.fold(node)
                continue
            # with a static input shape (--seq), a node fed only by constants and FULLY KNOWN shape values folds too
            # (SigLIP2's position ids: a slice of a constant ended by the input's length)
            if node.op_type != "Shape" and all(self.is_const(x) or self._static(x) for x in node.input if x):
                for x in node.input:
                    if x and not self.is_const(x):
                        self.C[self.r(x)] = np.array(self.shape[self.r(x)], dtype=np.int64)
                self.C[node.output[0]] = self.fold(node)
                continue
            if self.in_shape_domain(node):
                self.do_shape_node(node)
                continue
            fn = getattr(self, "op_" + node.op_type, None)
            if fn is None:
                raise Refused("op %s (%s) is not in the set" % (node.op_type, node.name))
            fn(i, node)
        out = self.r(self.output)
        if out not in self.pname:
            raise Refused("the graph output %s was never produced" % out)
        return self.pname[out], self.rank[out]

    def _static(self, n):
        v = self.shape.get(self.r(n))
        return v is not None and all(isinstance(q, (int, np.integer)) for q in v)

    # -- ops -----------------------------------------------------------------------------------------------------
    def rank_of(self, n):
        n = self.r(n)
        if n in self.rank:
            return self.rank[n]
        if n in self.C:
            return self.C[n].ndim
        raise Refused("rank of %s unknown" % n)

    def op_Conv(self, i, node):
        a = self.attrs(node)
        x = node.input[0]
        w = self.const(node.input[1])
        bias = None
        if len(node.input) > 2 and node.input[2]:
            # the vision exports (timm, YuNet, YOLOX) fold the bias into the Conv; the runner adds it as a
            # per-channel constant shaped [1, C, 1, 1] (PP-OCR's exports write the same Add themselves)
            bias = np.asarray(self.const(node.input[2]), dtype=np.float32).reshape(1, -1, 1, 1)
        dil = a.get("dilations", [1, 1])
        kh, kw = a["kernel_shape"]
        sh, sw = a.get("strides", [1, 1])
        group = a.get("group", 1)
        cin = w.shape[1] * group
        cout = w.shape[0]
        if group == 1:
            dw = 0
        elif group == cin == cout and w.shape[1] == 1:
            dw = 1
        else:
            raise Refused("Conv %s has groups the engine cannot express (%d groups, %d->%d)" % (node.name, group, cin, cout))
        if dil != [1, 1] and dw:
            raise Refused("Conv %s is depthwise AND dilated" % node.name)
        # a dilation (IM6: U2-Net's RSU-4F blocks dilate by 2, 4 and 8) travels as d=[w, h]; absent means 1
        dkw = {"d": [dil[1], dil[0]]} if dil != [1, 1] else {}
        xp = self.p(x)
        if a.get("auto_pad", "NOTSET") == "SAME_UPPER":
            if (kh, kw, sh, sw) != (2, 2, 1, 1):
                raise Refused("Conv %s: SAME_UPPER only handled for 2x2 stride 1" % node.name)
            xp = self.emit(node.output[0] + "/pad", "pad", [xp], 4, r=1, b=1)
            ph = pw = 0
        else:
            t, l, b, rr = a.get("pads", [0, 0, 0, 0])
            if t != b or l != rr:
                raise Refused("Conv %s has asymmetric pads %r" % (node.name, a["pads"]))
            ph, pw = t, l
        wp = self.add_const(None, w)
        if bias is None:
            self.emit(node.output[0], "conv", [xp, wp], 4, s=[sw, sh], p=[pw, ph], dw=dw, **dkw)
            return
        t = self.emit(node.output[0] + "/conv", "conv", [xp, wp], 4, s=[sw, sh], p=[pw, ph], dw=dw, **dkw)
        self.emit(node.output[0], "add", [t, self.add_const(None, bias)], 4)

    def op_ConvTranspose(self, i, node):
        a = self.attrs(node)
        w = self.const(node.input[1])
        bias = None
        if len(node.input) > 2 and node.input[2]:
            # DPT's resize layers (Depth-Anything): a per-channel bias, added as Conv's is
            bias = np.asarray(self.const(node.input[2]), dtype=np.float32).reshape(1, -1, 1, 1)
        kh, kw = a["kernel_shape"]
        sh, sw = a.get("strides", [1, 1])
        if a.get("pads", [0, 0, 0, 0]) != [0, 0, 0, 0] or a.get("group", 1) != 1 or kh != sh or kw != sw or kh != kw:
            raise Refused("ConvTranspose %s is not the kernel==stride, no-pad shape" % node.name)
        wp = self.add_const(None, w)
        if bias is None:
            self.emit(node.output[0], "convt", [self.p(node.input[0]), wp], 4, s=sh)
            return
        t = self.emit(node.output[0] + "/convt", "convt", [self.p(node.input[0]), wp], 4, s=sh)
        self.emit(node.output[0], "add", [t, self.add_const(None, bias)], 4)

    def op_BatchNormalization(self, i, node):
        a = self.attrs(node)
        eps = a.get("epsilon", 1e-5)
        scale, offset, mean, var = [self.const(x) for x in node.input[1:5]]
        s = (scale / np.sqrt(var + eps)).astype(np.float32)
        b = (offset - mean * s).astype(np.float32)
        c = s.shape[0]
        sp = self.add_const(None, s.reshape(1, c, 1, 1))
        bp = self.add_const(None, b.reshape(1, c, 1, 1))
        xp = self.p(node.input[0])
        m = self.emit(node.output[0] + "/scale", "mul", [xp, sp], 4)
        self.emit(node.output[0], "add", [m, bp], 4)

    def _binary(self, i, node, op):
        a_, b_ = node.input[0], node.input[1]
        ca, cb = self.is_const(a_), self.is_const(b_)
        if ca and not cb and op in ("add", "mul"):
            a_, b_ = b_, a_
            ca, cb = cb, ca
        if ca:
            raise Refused("%s %s has a constant first operand" % (node.op_type, node.name))
        rank = self.rank_of(a_)
        if cb:
            v = self.const(b_)
            if v.size == 1:
                f = float(v.flatten()[0])
                if op == "add":
                    self.emit(node.output[0], "sb", [self.p(a_)], rank, s=1.0, b=f)
                elif op == "sub":
                    self.emit(node.output[0], "sb", [self.p(a_)], rank, s=1.0, b=-f)
                elif op == "mul":
                    self.emit(node.output[0], "sb", [self.p(a_)], rank, s=f, b=0.0)
                else:
                    self.emit(node.output[0], "sb", [self.p(a_)], rank, s=1.0 / f, b=0.0)
                return
            self.emit(node.output[0], op, [self.p(a_), self.p(b_)], rank)
            return
        ra, rb = self.rank_of(a_), self.rank_of(b_)
        self.emit(node.output[0], op, [self.p(a_), self.p(b_)], max(ra, rb))

    def op_Add(self, i, node):
        self._binary(i, node, "add")

    def op_Sub(self, i, node):
        self._binary(i, node, "sub")

    def op_Mul(self, i, node):
        self._binary(i, node, "mul")

    def op_Div(self, i, node):
        # GELU, as Paddle2ONNX writes it: x/sqrt2 -> Erf -> +1 -> *x -> *0.5
        if self.is_const(node.input[1]) and self.const(node.input[1]).size == 1 and abs(float(self.const(node.input[1]).flatten()[0]) - 1.4142135) < 1e-5:
            x = self.r(node.input[0])
            u1 = self.users.get(self.r(node.output[0]), [])
            if len(u1) == 1 and self.nodes[u1[0]].op_type == "Erf":
                erf = self.nodes[u1[0]]
                u2 = self.users.get(self.r(erf.output[0]), [])
                if len(u2) == 1 and self.nodes[u2[0]].op_type == "Add":
                    add = self.nodes[u2[0]]
                    other = [y for y in add.input if self.r(y) != self.r(erf.output[0])]
                    if other and self.is_const(other[0]) and float(self.const(other[0]).flatten()[0]) == 1.0:
                        u3 = self.users.get(self.r(add.output[0]), [])
                        if len(u3) == 1 and self.nodes[u3[0]].op_type == "Mul":
                            mul1 = self.nodes[u3[0]]
                            if set(self.r(y) for y in mul1.input) == {x, self.r(add.output[0])}:
                                u4 = self.users.get(self.r(mul1.output[0]), [])
                                if len(u4) == 1 and self.nodes[u4[0]].op_type == "Mul":
                                    mul2 = self.nodes[u4[0]]
                                    other2 = [y for y in mul2.input if self.r(y) != self.r(mul1.output[0])]
                                    if other2 and self.is_const(other2[0]) and float(self.const(other2[0]).flatten()[0]) == 0.5:
                                        self.skip.update([u1[0], u2[0], u3[0], u4[0]])
                                        self.emit(mul2.output[0], "gelu", [self.p(x)], self.rank_of(x))
                                        return
            raise Refused("Div by sqrt(2) at %s that is not the GELU shape" % node.name)
        self._binary(i, node, "div")

    def op_Relu(self, i, node):
        self.emit(node.output[0], "relu", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_HardSwish(self, i, node):
        # x * max(0, min(1, x/6 + 0.5)) -- ggml_hardswish computes exactly this
        self.emit(node.output[0], "hswish", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_Tanh(self, i, node):
        self.emit(node.output[0], "tanh", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_Sigmoid(self, i, node):
        self.emit(node.output[0], "sigmoid", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_Sqrt(self, i, node):
        self.emit(node.output[0], "sqrt", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_Pow(self, i, node):
        if not (self.is_const(node.input[1]) and float(self.const(node.input[1]).flatten()[0]) == 2.0):
            raise Refused("Pow %s with an exponent other than 2" % node.name)
        self.emit(node.output[0], "sqr", [self.p(node.input[0])], self.rank_of(node.input[0]))

    def op_Clip(self, i, node):
        lo = float(self.const(node.input[1]).flatten()[0])
        hi = float(self.const(node.input[2]).flatten()[0])
        self.emit(node.output[0], "clamp", [self.p(node.input[0])], self.rank_of(node.input[0]), lo=lo, hi=hi)

    def op_HardSigmoid(self, i, node):
        a = self.attrs(node)
        rank = self.rank_of(node.input[0])
        t = self.emit(node.output[0] + "/lin", "sb", [self.p(node.input[0])], rank, s=a.get("alpha", 0.2), b=a.get("beta", 0.5))
        self.emit(node.output[0], "clamp", [t], rank, lo=0.0, hi=1.0)

    def op_ReduceMean(self, i, node):
        a = self.attrs(node)
        rank = self.rank_of(node.input[0])
        axes = [ax % rank for ax in a["axes"]]
        if axes == [2, 3] and rank == 4 and a.get("keepdims", 1) == 1:
            self.emit(node.output[0], "gap", [self.p(node.input[0])], 4)
            return
        if axes == [rank - 1] and a.get("keepdims", 1) == 1:
            self.emit(node.output[0], "mean", [self.p(node.input[0])], rank)
            return
        raise Refused("ReduceMean %s over axes %r" % (node.name, a["axes"]))

    def op_GlobalAveragePool(self, i, node):
        self.emit(node.output[0], "gap", [self.p(node.input[0])], 4)

    def _pool(self, node, op):
        a = self.attrs(node)
        kh, kw = a["kernel_shape"]
        sh, sw = a.get("strides", [1, 1])
        xp = self.p(node.input[0])
        if a.get("auto_pad", "NOTSET") == "SAME_UPPER":
            if (kh, kw, sh, sw) != (2, 2, 1, 1):
                raise Refused("%s %s: SAME_UPPER only handled for 2x2 stride 1" % (node.op_type, node.name))
            if op == "max":
                src = self.producer.get(self.r(node.input[0]))
                if src is None or self.nodes[src].op_type != "Relu":
                    raise Refused("MaxPool %s zero-pads an input that is not a Relu output" % node.name)
            xp = self.emit(node.output[0] + "/pad", "pad", [xp], 4, r=1, b=1)
        elif a.get("pads", [0, 0, 0, 0]) != [0, 0, 0, 0]:
            pads = a["pads"]
            # symmetric padding only (YOLOX's spatial pyramid: k 5/9/13, stride 1, pad k//2); a max pool
            # reads padding as -inf, so the runner's pool skips it, as ONNX does
            if op != "max" or pads[0] != pads[2] or pads[1] != pads[3]:
                raise Refused("%s %s has asymmetric pads %r" % (node.op_type, node.name, pads))
            if a.get("ceil_mode", 0):
                raise Refused("%s %s has ceil_mode" % (node.op_type, node.name))
            self.emit(node.output[0], "pool", [xp], 4, k=[kw, kh], s=[sw, sh], p=[pads[1], pads[0]], kind=op)
            return
        if a.get("ceil_mode", 0):
            # ceil mode (IM6: U2-Net halves odd sizes upward): the runner pads the right and bottom so the last
            # window fits. It pads with ZEROS, which a max reads as -inf only when nothing is negative: a Relu output
            if op != "max" or not self._nonneg(node.input[0]):
                raise Refused("%s %s has ceil_mode on an input that may be negative" % (node.op_type, node.name))
            self.emit(node.output[0], "pool", [xp], 4, k=[kw, kh], s=[sw, sh], kind=op, ceil=1)
            return
        self.emit(node.output[0], "pool", [xp], 4, k=[kw, kh], s=[sw, sh], kind=op)

    def _nonneg(self, n, depth=0):
        # provably >= 0: a Relu or Sigmoid output, or a sum, concatenation, max pool or bilinear resize of such
        # (U2-Net adds a block's input back to its Relu output before pooling)
        src = self.producer.get(self.r(n))
        if src is None or depth > 64:
            return False
        nd = self.nodes[src]
        if nd.op_type in ("Relu", "Sigmoid"):
            return True
        if nd.op_type in ("Add", "Concat"):
            return all(self._nonneg(x, depth + 1) for x in nd.input if x)
        if nd.op_type in ("MaxPool", "Resize"):
            return self._nonneg(nd.input[0], depth + 1)
        return False

    def op_MaxPool(self, i, node):
        self._pool(node, "max")

    def op_AveragePool(self, i, node):
        self._pool(node, "avg")

    def op_Resize(self, i, node):
        a = self.attrs(node)
        # bilinear to ANOTHER tensor's size (IM6: U2-Net's upsample_like(src, tar) -- sizes = Shape(src)[:2] ++
        # Shape(tar)[2:]); half-pixel centres, as ggml's bilinear without align-corners computes them
        if a.get("mode") == "linear" and a.get("coordinate_transformation_mode") in ("pytorch_half_pixel", "half_pixel")                 and len(node.input) > 3 and node.input[3]:
            v = self.shape_of(node.input[3])
            if len(v) == 4 and isinstance(v[2], tuple) and isinstance(v[3], tuple) and v[2][0] == "dim" and                     v[2][1] == v[3][1] and (v[2][2], v[3][2]) == (2, 3):
                self.emit(node.output[0], "resize", [self.p(node.input[0]), self.p(v[2][1])], 4, m=1)
                return
            if v is not None and len(v) == 4 and all(isinstance(q, (int, np.integer)) for q in v):
                self.emit(node.output[0], "resize", [self.p(node.input[0])], 4, m=1, w=int(v[3]), h=int(v[2]))
                return
            raise Refused("Resize %s: linear to sizes %r" % (node.name, v))
        # bilinear with corners aligned (DPT's refine stages, Depth-Anything): to sizes now numbers (--static), or
        # by constant scales over a known input shape; ggml's GGML_SCALE_FLAG_ALIGN_CORNERS is PyTorch's
        if a.get("mode") == "linear" and a.get("coordinate_transformation_mode") == "align_corners":
            full = self.vshape.get(self.r(node.input[0]))
            v = self.shape_of(node.input[3]) if len(node.input) > 3 and node.input[3] else None
            if v is None and len(node.input) > 2 and node.input[2] and self.is_const(node.input[2]) and full is not None:
                sc = [float(q) for q in self.const(node.input[2]).flatten()]
                v = [int(np.floor(n * f)) for n, f in zip(full, sc)]
            if v is not None and len(v) == 4 and all(isinstance(q, (int, np.integer)) for q in v[2:]):
                # (the batch and channel entries may stay symbolic: only the height and width are read)
                self.emit(node.output[0], "resize", [self.p(node.input[0])], 4, m=1 | 256, w=int(v[3]), h=int(v[2]))
                return
            if v is not None and len(v) == 4 and isinstance(v[2], tuple) and isinstance(v[3], tuple) and                     v[2][0] == "dim" and v[2][1] == v[3][1] and (v[2][2], v[3][2]) == (2, 3):
                self.emit(node.output[0], "resize", [self.p(node.input[0]), self.p(v[2][1])], 4, m=1 | 256)
                return
            if v is None and len(node.input) > 2 and node.input[2] and self.is_const(node.input[2]):
                sc = [float(q) for q in self.const(node.input[2]).flatten()]
                if len(sc) == 4 and sc[:2] == [1.0, 1.0] and all(q == int(q) for q in sc[2:]):
                    # an integer scale over a size the converter does not know: the runner multiplies
                    self.emit(node.output[0], "resize", [self.p(node.input[0])], 4, m=1 | 256, fw=int(sc[3]), fh=int(sc[2]))
                    return
            raise Refused("Resize %s: align_corners to %r" % (node.name, v))
        if a.get("mode") != "nearest" or a.get("coordinate_transformation_mode") != "asymmetric" or a.get("nearest_mode", "floor") != "floor":
            raise Refused("Resize %s is not nearest/asymmetric/floor" % node.name)
        scales = [float(v) for v in self.const(node.input[2]).flatten()]
        if scales[:2] != [1.0, 1.0] or scales[2] != scales[3] or scales[2] != int(scales[2]):
            raise Refused("Resize %s scales %r" % (node.name, scales))
        self.emit(node.output[0], "up", [self.p(node.input[0])], 4, f=int(scales[2]))

    def op_Concat(self, i, node):
        a = self.attrs(node)
        rank = self.rank_of(node.input[0])
        axis = a.get("axis", 0) % rank
        self.emit(node.output[0], "concat", [self.p(x) for x in node.input], rank, d=rank - 1 - axis)

    def op_Softmax(self, i, node):
        a = self.attrs(node)
        rank = self.rank_of(node.input[0])
        if a.get("axis", -1) % rank != rank - 1:
            raise Refused("Softmax %s over an axis that is not the last" % node.name)
        self.emit(node.output[0], "softmax", [self.p(node.input[0])], rank)

    def op_MatMul(self, i, node):
        a_, b_ = node.input
        if self.is_const(b_):
            w = self.const(b_)
            if w.ndim != 2:
                raise Refused("MatMul %s with a %d-d constant" % (node.name, w.ndim))
            wp = self.add_const(None, np.ascontiguousarray(w.T))
            self.emit(node.output[0], "linear", [self.p(a_), wp], self.rank_of(a_))
            return
        if self.is_const(a_):
            raise Refused("MatMul %s with a constant first operand" % node.name)
        self.emit(node.output[0], "matmul", [self.p(a_), self.p(b_)], max(self.rank_of(a_), self.rank_of(b_)))

    def op_Transpose(self, i, node):
        a = self.attrs(node)
        rank = self.rank_of(node.input[0])
        if rank > 4:
            raise Refused("Transpose %s of a rank-%d tensor" % (node.name, rank))
        # a transpose of a tensor already written as a constant (SigLIP2's position embeddings, reshaped to their
        # 16 x 16 grid and back) is a constant too: the runtime cannot know a constant's ONNX rank
        src = self.p(node.input[0])
        if src.startswith("c"):
            for name, arr in self.consts:
                if name == src:
                    self.add_const(node.output[0], np.transpose(arr, a["perm"]))
                    return
        self.emit(node.output[0], "permute", [src], rank, p=a["perm"])

    def op_Reshape(self, i, node):
        x = node.input[0]
        rank = self.rank_of(x)
        items = self.shape_of(node.input[1])
        if items is None:
            raise Refused("Reshape %s with a shape that is neither constant nor traced" % node.name)
        # the attention head split: reshape [0,-1,3,h,d] -> transpose [2,0,3,1,4] -> slice k -> squeeze 0
        # (--static writes the same split with its numbers: [1, N, 3, h, d])
        if len(items) == 5 and all(isinstance(v, (int, np.integer)) for v in items) and                 (items[:3] == [0, -1, 3] or (items[0] == 1 and items[2] == 3)):
            self._heads(i, node, int(items[3]), int(items[4]))
            return
        if len(items) > 4:
            raise Refused("Reshape %s to rank %d" % (node.name, len(items)))
        spec = []
        for j, it in enumerate(items):
            if isinstance(it, tuple):
                spec.append("@%s:%d" % (self.p(it[1]), it[2]))
            elif int(it) == 0:
                spec.append("@%s:%d" % (self.p(x), j))
            else:
                spec.append(str(int(it)))
        self.emit(node.output[0], "reshape", [self.p(x)], len(items), d=spec)

    def _heads(self, i, node, h, d):
        items_h, items_d = h, d
        u1 = self.users.get(self.r(node.output[0]), [])
        if len(u1) != 1 or self.nodes[u1[0]].op_type != "Transpose" or self.attrs(self.nodes[u1[0]])["perm"] != [2, 0, 3, 1, 4]:
            raise Refused("Reshape %s to 5-d is not the head split" % node.name)
        tr = self.nodes[u1[0]]
        self.skip.add(u1[0])
        for ui in self.users.get(self.r(tr.output[0]), []):
            sl = self.nodes[ui]
            if sl.op_type == "Gather" and self.attrs(sl).get("axis", 0) == 0 and np.asarray(self.const(sl.input[1])).ndim == 0:
                # DINOv2 (Depth-Anything): q, k, v = qkv[0], qkv[1], qkv[2]
                self.skip.add(ui)
                self.emit(sl.output[0], "heads", [self.p(node.input[0])], 4, h=int(items_h), d=int(items_d),
                          i=int(self.const(sl.input[1])))
                continue
            if sl.op_type != "Slice":
                raise Refused("head split at %s used by %s" % (node.name, sl.op_type))
            k = int(self.const(sl.input[1]).flatten()[0])
            u3 = self.users.get(self.r(sl.output[0]), [])
            if len(u3) != 1 or self.nodes[u3[0]].op_type != "Squeeze":
                raise Refused("head slice at %s not followed by a Squeeze" % sl.name)
            sq = self.nodes[u3[0]]
            self.skip.update([ui, u3[0]])
            self.emit(sq.output[0], "heads", [self.p(node.input[0])], 4, h=h, d=d, i=k)

    def axes_of(self, node, a):
        # opset < 13 writes Squeeze/Unsqueeze axes as an attribute; opset 13+ as a constant second input
        if "axes" in a:
            return list(a["axes"])
        if len(node.input) > 1 and node.input[1]:
            return [int(v) for v in np.array(self.const(node.input[1])).flatten()]
        return []

    def op_Squeeze(self, i, node):
        a = self.attrs(node)
        x = node.input[0]
        rank = self.rank_of(x)
        axes = [ax % rank for ax in self.axes_of(node, a)]
        spec = ["@%s:%d" % (self.p(x), j) for j in range(rank) if j not in axes]
        self.emit(node.output[0], "reshape", [self.p(x)], len(spec), d=spec)

    def op_Unsqueeze(self, i, node):
        a = self.attrs(node)
        x = node.input[0]
        rank = self.rank_of(x)
        if rank + len(self.axes_of(node, a)) > 4:
            self._kv_split(i, node)
            return
        spec = ["@%s:%d" % (self.p(x), j) for j in range(rank)]
        for ax in sorted(self.axes_of(node, a)):
            spec.insert(ax, "1")
        self.emit(node.output[0], "reshape", [self.p(x)], len(spec), d=spec)

    def op_Slice(self, i, node):
        # every second row or column from offset 0 or 1 (YOLOX's Focus: x[..., ::2, ::2] and its three
        # siblings, each written as two Slices); anything else is refused
        if len(node.input) < 5 or not all(self.is_const(x) for x in node.input[1:5]):
            raise Refused("Slice %s on an activation without constant starts/ends/axes/steps" % node.name)
        starts = [int(v) for v in self.const(node.input[1]).flatten()]
        ends = [int(v) for v in self.const(node.input[2]).flatten()]
        axes = [int(v) for v in self.const(node.input[3]).flatten()]
        steps = [int(v) for v in self.const(node.input[4]).flatten()]
        rank = self.rank_of(node.input[0])
        # a unit-step slice of one axis whose length is known (--static): DINOv2 drops its CLS token, x[:, 1:]
        full = self.vshape.get(self.r(node.input[0]))
        if len(axes) == 1 and steps[0] == 1 and full is not None:
            ax = axes[0] % rank
            n = full[ax]
            st = max(0, min(n, starts[0] + n if starts[0] < 0 else starts[0]))
            en = max(0, min(n, ends[0] + n if ends[0] < 0 else ends[0]))
            if en <= st:
                raise Refused("Slice %s is empty" % node.name)
            self.emit(node.output[0], "slice", [self.p(node.input[0])], rank, d=rank - 1 - ax, o=st, n=en - st)
            return
        if len(axes) != 1 or steps[0] != 2 or starts[0] not in (0, 1) or ends[0] < 2 ** 30 or rank != 4 or axes[0] % 4 not in (2, 3):
            raise Refused("Slice %s is not a step-2 slice of rows or columns" % node.name)
        self.emit(node.output[0], "step2", [self.p(node.input[0])], 4, a=rank - 1 - axes[0] % 4, o=starts[0])

    def op_Cast(self, i, node):
        # the runner computes in float32 throughout: a cast of an activation (an fp16 export's outputs) is the identity
        self.pname[self.r(node.output[0])] = self.p(node.input[0])
        self.rank[self.r(node.output[0])] = self.rank_of(node.input[0])

    def op_Tile(self, i, node):
        # repeats of 1, or of the batch size (taken as 1: the runner computes one item), are the identity
        reps = self.shape_of(node.input[1])
        if reps is None or any(not (isinstance(v, tuple) or int(v) == 1) for v in reps):
            raise Refused("Tile %s repeats %r" % (node.name, reps))
        self.pname[self.r(node.output[0])] = self.p(node.input[0])
        self.rank[self.r(node.output[0])] = self.rank_of(node.input[0])

    def op_Gather(self, i, node):
        # a table indexed by the graph's token ids: an embedding lookup (SigLIP2's text tower)
        if self.is_const(node.input[0]) and self.r(node.input[1]) == self.input:
            tab = self.add_const(None, self.const(node.input[0]))
            self.emit(node.output[0], "embed", [tab, self.p(node.input[1])], 3)
            return
        # one index along one axis of an activation: a slice of length 1 and the axis dropped
        a = self.attrs(node)
        x = node.input[0]
        rank = self.rank_of(x)
        idx = np.asarray(self.const(node.input[1]))
        if idx.ndim != 0:
            raise Refused("Gather %s with an index list on an activation" % node.name)
        axis = a.get("axis", 0) % rank
        t = self.emit(node.output[0] + "/sl", "slice", [self.p(x)], rank, d=rank - 1 - axis, o=int(idx), n=1)
        spec = ["@%s:%d" % (t, j) for j in range(rank) if j != axis]
        self.emit(node.output[0], "reshape", [t], rank - 1, d=spec)

    def _kv_split(self, i, node):
        """nn.MultiheadAttention's packed key/value projection, as torch exports it: Reshape [.., 2, d] ->
        Unsqueeze -> Transpose -> Squeeze -> Gather(0) and Gather(1). Through rank 5, which ggml does not have;
        what it MEANS is k = the first d columns of the projection, v = the next d. Emitted as two slices."""
        rs = self.producer.get(self.r(node.input[0]))
        rnode = self.nodes[rs] if rs is not None else None
        items = self.shape_of(rnode.input[1]) if rnode is not None and rnode.op_type == "Reshape" else None
        if not items or len(items) < 2 or items[-2] != 2:
            raise Refused("Unsqueeze %s to rank > 4 outside the packed key/value split" % node.name)
        d = int(items[-1])
        src = rnode.input[0]
        u1 = self.users.get(self.r(node.output[0]), [])
        if len(u1) != 1 or self.nodes[u1[0]].op_type != "Transpose":
            raise Refused("packed k/v at %s: no Transpose" % node.name)
        u2 = self.users.get(self.r(self.nodes[u1[0]].output[0]), [])
        if len(u2) != 1 or self.nodes[u2[0]].op_type != "Squeeze":
            raise Refused("packed k/v at %s: no Squeeze" % node.name)
        self.skip.update([u1[0], u2[0]])
        rk = self.rank_of(src)
        for gi in self.users.get(self.r(self.nodes[u2[0]].output[0]), []):
            g = self.nodes[gi]
            if g.op_type != "Gather":
                raise Refused("packed k/v at %s used by %s" % (node.name, g.op_type))
            k = int(np.asarray(self.const(g.input[1])))
            self.skip.add(gi)
            self.emit(g.output[0], "slice", [self.p(src)], rk, d=0, o=k * d, n=d)

    def op_Flatten(self, i, node):
        a = self.attrs(node)
        x = node.input[0]
        rank = self.rank_of(x)
        axis = a.get("axis", 1) % rank
        lead = ["@%s:%d" % (self.p(x), j) for j in range(axis)]
        self.emit(node.output[0], "reshape", [self.p(x)], axis + 1, d=lead + ["-1"])

    def op_Gemm(self, i, node):
        a = self.attrs(node)
        if a.get("alpha", 1.0) != 1.0 or a.get("beta", 1.0) != 1.0 or a.get("transA", 0) != 0:
            raise Refused("Gemm %s with alpha/beta/transA" % node.name)
        if not self.is_const(node.input[1]):
            raise Refused("Gemm %s with a computed weight" % node.name)
        w = self.const(node.input[1])
        # ggml's mul_mat wants the weight as [out, in] rows -- ONNX B is that already when transB=1
        wt = w if a.get("transB", 0) == 1 else np.ascontiguousarray(w.T)
        wp = self.add_const(None, wt)
        t = self.emit(node.output[0] + "/mm", "linear", [self.p(node.input[0]), wp], 2)
        if len(node.input) > 2 and node.input[2]:
            self.emit(node.output[0], "add", [t, self.p(node.input[2])], 2)
        else:
            self.pname[self.r(node.output[0])] = t
            self.rank[self.r(node.output[0])] = 2

    def fuse_yunet(self):
        """YuNet writes 12 heads; the runner hands back one tensor. Per stride s in 8, 16, 32 the four heads
        cls_s [1,N,1], obj_s [1,N,1], bbox_s [1,N,4], kps_s [1,N,10] are concatenated on the last axis into
        [1,N,16], and the three strides on the anchor axis into [1, 8400, 16]: per anchor, cls, obj, 4 box,
        10 landmark values. The parity oracle builds the same tensor from onnxruntime's 12 outputs."""
        rows = []
        for st in (8, 16, 32):
            parts = []
            for head in ("cls", "obj", "bbox", "kps"):
                nm = "%s_%d" % (head, st)
                if nm not in self.outputs:
                    raise Refused("YuNet output %s missing" % nm)
                parts.append(self.p(nm))
            rows.append(self.emit("yunet/s%d" % st, "concat", parts, 3, d=0))
        out = self.emit("yunet/all", "concat", rows, 3, d=1)
        return out, 3

    # -- the file ----------------------------------------------------------------------------------------------
    def write(self, path, kind, out_name, out_rank, src_name):
        kvs = [
            kv_str("general.architecture", "stz-ocr-graph"),
            kv_str("general.name", os.path.basename(src_name)),
            kv_u32("general.alignment", ALIGN),
            kv_str("stz.ocr.kind", kind),
            kv_str("stz.ocr.output", out_name),
            kv_u32("stz.ocr.output_rank", out_rank),
            kv_strarr("stz.ocr.program", self.prog),
        ]
        if getattr(self, "static_input", None):
            kvs.append(kv_str("stz.graph.input_kind", "ids"))
            kvs.append(kv_u32("stz.graph.seq", self.static_input[1]))
        if getattr(self, "tokenizer", None):
            # a BPE tokenizer (HF tokenizer.json: SigLIP2's Gemma vocabulary): the vocabulary by id, and the merges
            # as two parallel arrays in rank order (a token may hold any character, so no separator is safe)
            tk = self.tokenizer
            kvs.append(kv_strarr("stz.tok.vocab", tk["vocab"]))
            kvs.append(kv_strarr("stz.tok.merge_a", [m[0] for m in tk["merges"]]))
            kvs.append(kv_strarr("stz.tok.merge_b", [m[1] for m in tk["merges"]]))
            kvs.append(kv_str("stz.tok.space", tk["space"]))
            kvs.append(kv_u32("stz.tok.eos", tk["eos"]))
            kvs.append(kv_u32("stz.tok.pad", tk["pad"]))
        if getattr(self, "labels", None):
            kvs.append(kv_strarr("stz.graph.labels", self.labels))
        if getattr(self, "input_wh", None):
            kvs.append(kv_u32("stz.graph.input_w", self.input_wh[0]))
            kvs.append(kv_u32("stz.graph.input_h", self.input_wh[1]))
        if getattr(self, "direction", ""):
            kvs.append(kv_str("stz.ocr.direction", self.direction))
        if getattr(self, "classifier", ""):
            kvs.append(kv_str("stz.ocr.classifier", self.classifier))
        if kind == "rec" and "character" in self.meta:
            # the CTC classes in output order: the blank at 0, the dictionary, the space last (RapidOCR's CTCLabelDecode)
            chars = ["blank"] + self.meta["character"].splitlines() + [" "]
            kvs.append(kv_strarr("stz.ocr.character", chars))
        infos = b""
        data = b""
        for pn, arr in self.consts:
            ne = list(arr.shape[::-1]) or [1]
            while len(data) % ALIGN:
                data += b"\x00"
            off = len(data)
            data += arr.astype("<f4").tobytes()
            infos += _s(pn) + struct.pack("<I", len(ne))
            for v in ne:
                infos += struct.pack("<Q", v)
            infos += struct.pack("<IQ", 0, off)  # GGML_TYPE_F32 = 0
        while len(data) % ALIGN:  # the reader expects every tensor, the last one too, padded to the alignment
            data += b"\x00"
        hdr = b"GGUF" + struct.pack("<IQQ", 3, len(self.consts), len(kvs))
        body = hdr + b"".join(kvs) + infos
        while len(body) % ALIGN:
            body += b"\x00"
        with open(path, "wb") as f:
            f.write(body + data)
        return len(body) + len(data)


COCO80 = ("person bicycle car motorcycle airplane bus train truck boat traffic_light fire_hydrant stop_sign "
          "parking_meter bench bird cat dog horse sheep cow elephant bear zebra giraffe backpack umbrella handbag "
          "tie suitcase frisbee skis snowboard sports_ball kite baseball_bat baseball_glove skateboard surfboard "
          "tennis_racket bottle wine_glass cup fork knife spoon bowl banana apple sandwich orange broccoli carrot "
          "hot_dog pizza donut cake chair couch potted_plant bed dining_table toilet tv laptop mouse remote keyboard "
          "cell_phone microwave oven toaster sink refrigerator book clock vase scissors teddy_bear hair_drier "
          "toothbrush").split()


def load_labels(arg):
    """'coco' -> the 80 COCO classes (YOLOX's order); a config.json -> its id2label in id order; '' -> none."""
    if not arg:
        return None
    if arg == "coco":
        return [w.replace("_", " ") for w in COCO80]
    import json
    with open(arg, encoding="utf-8") as f:
        cfg = json.load(f)
    if "id2label" in cfg:
        d = cfg["id2label"]
        return [d[str(i)] for i in range(len(d))]
    if "label_names" in cfg:
        return list(cfg["label_names"])
    raise Refused("no id2label in %s" % arg)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    kind = "det"
    direction = ""
    classifier = ""
    for a in sys.argv[1:]:
        if a.startswith("--kind="):
            kind = a[7:]
        if a.startswith("--direction="):
            # rtl: the recogniser reads a right-to-left script; it emits each line in VISUAL order (pixels left to
            # right), and the engine puts it back in logical order and orders a row's boxes from the right
            direction = a[12:]
        if a.startswith("--classifier="):
            # off: PP-OCR's angle classifier was trained on Chinese and Latin lines and does not apply to this
            # recogniser's script (it calls upright Arabic "180" with near certainty and the line is turned over)
            classifier = a[13:]
    labels_arg = ""
    input_arg = 0
    for a in sys.argv[1:]:
        if a.startswith("--labels="):
            labels_arg = a[9:]
        if a.startswith("--input="):
            input_arg = int(a[8:])
    out_arg = ""
    for a in sys.argv[1:]:
        if a.startswith("--output="):
            out_arg = a[9:]
    seq = 0
    for a in sys.argv[1:]:
        if a.startswith("--seq="):
            seq = int(a[6:])
    static_arg = "--static" in sys.argv[1:]
    tok_arg = ""
    for a in sys.argv[1:]:
        if a.startswith("--tokenizer="):
            tok_arg = a[12:]
    src, dst = args[0], args[1]
    cv = Converter(src)
    if static_arg:
        if not input_arg:
            raise Refused("--static needs --input=<side>")
        cv.use_static_input([1, 3, input_arg, input_arg])
    if seq:
        # a token-id input of a FIXED length (SigLIP2 pads every text to 64): rank 2, its shape known
        cv.static_input = [1, seq]
        cv.rank[cv.input] = 2
    if tok_arg:
        import json
        tj = json.load(open(tok_arg, encoding="utf-8"))
        mdl = tj["model"]
        if mdl.get("type") != "BPE" or not mdl.get("byte_fallback") or mdl.get("ignore_merges"):
            raise Refused("tokenizer %s is not a byte-fallback BPE without ignore_merges" % tok_arg)
        vocab = [""] * len(mdl["vocab"])
        for t, k in mdl["vocab"].items():
            vocab[k] = t
        merges = [m if isinstance(m, list) else m.split(" ", 1) for m in mdl["merges"]]
        norm = tj.get("normalizer") or {}
        space = norm.get("content", "") if norm.get("type") == "Replace" and norm.get("pattern", {}).get("String") == " " else ""
        ids = {a["content"]: a["id"] for a in tj.get("added_tokens", [])}
        cv.tokenizer = {"vocab": vocab, "merges": merges, "space": space, "eos": ids.get("<eos>", 1), "pad": ids.get("<pad>", 0)}
    if out_arg:
        # a graph with several outputs (SigLIP2's towers: last_hidden_state, pooler_output): name the one wanted
        if out_arg not in cv.outputs:
            raise Refused("no graph output named %s (it has %r)" % (out_arg, cv.outputs))
        cv.output = out_arg
    out_name, out_rank = cv.convert()
    if kind == "yunet":
        out_name, out_rank = cv.fuse_yunet()
    cv.labels = load_labels(labels_arg)
    m = onnx.load(src)
    dims = [d.dim_value for d in m.graph.input[0].type.tensor_type.shape.dim]
    if len(dims) == 4 and dims[2] > 0 and dims[3] > 0:
        cv.input_wh = (dims[3], dims[2])
    elif input_arg:
        cv.input_wh = (input_arg, input_arg)
    cv.direction = direction
    cv.classifier = classifier
    n = cv.write(dst, kind, out_name, out_rank, src)
    params = sum(int(a.size) for _, a in cv.consts)
    ops = {}
    for line in cv.prog:
        op = line.split("=", 1)[1].split("(", 1)[0]
        ops[op] = ops.get(op, 0) + 1
    print("%s -> %s: %d ops, %d constants, %d params, %d bytes, output %s rank %d" % (src, dst, len(cv.prog), len(cv.consts), params, n, out_name, out_rank))
    print("  ops:", ", ".join("%s %d" % kv for kv in sorted(ops.items())))
    print("  subnormal weights flushed to zero: %d" % cv.flushed)


if __name__ == "__main__":
    try:
        main()
    except Refused as e:
        print("REFUSED:", e)
        sys.exit(2)
