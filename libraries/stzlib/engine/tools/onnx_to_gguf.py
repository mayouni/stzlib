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
    out = _s(k) + struct.pack("<I", ARRAY) + struct.pack("<IQ", STRING, len(vals))
    for v in vals:
        out += _s(v)
    return out


class Refused(Exception):
    pass


class Converter:
    def __init__(self, path):
        m = onnx.load(path)
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
        if node.op_type == "Reshape":
            return self.r(node.input[0]) in self.shape
        return any(self.r(x) in self.shape for x in node.input)

    def do_shape_node(self, node):
        t = node.op_type
        if t == "Shape":
            src = self.r(node.input[0])
            if src not in self.rank:
                raise Refused("Shape of %s whose rank is unknown" % src)
            self.shape[node.output[0]] = [("dim", src, j) for j in range(self.rank[src])]
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
        ins = [self.const(x) for x in node.input]
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
            return ins[0]
        if t == "Concat":
            return np.concatenate(ins, axis=a.get("axis", 0))
        if t == "Transpose":
            return np.transpose(ins[0], a["perm"])
        if t == "Mul":
            return ins[0] * ins[1]
        if t == "Add":
            return ins[0] + ins[1]
        raise Refused("cannot fold constant op %s (%s)" % (t, node.name))

    # -- the walk ---------------------------------------------------------------------------------------------------
    def convert(self):
        for i, node in enumerate(self.nodes):
            if i in self.skip:
                continue
            if all(self.is_const(x) for x in node.input) and node.op_type != "Shape":
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
        if len(node.input) > 2:
            raise Refused("Conv %s carries a bias; the family writes it as an Add" % node.name)
        if a.get("dilations", [1, 1]) != [1, 1]:
            raise Refused("Conv %s has a dilation" % node.name)
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
        self.emit(node.output[0], "conv", [xp, wp], 4, s=[sw, sh], p=[pw, ph], dw=dw)

    def op_ConvTranspose(self, i, node):
        a = self.attrs(node)
        w = self.const(node.input[1])
        if len(node.input) > 2:
            raise Refused("ConvTranspose %s carries a bias" % node.name)
        kh, kw = a["kernel_shape"]
        sh, sw = a.get("strides", [1, 1])
        if a.get("pads", [0, 0, 0, 0]) != [0, 0, 0, 0] or a.get("group", 1) != 1 or kh != sh or kw != sw or kh != kw:
            raise Refused("ConvTranspose %s is not the kernel==stride, no-pad shape" % node.name)
        wp = self.add_const(None, w)
        self.emit(node.output[0], "convt", [self.p(node.input[0]), wp], 4, s=sh)

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
            raise Refused("%s %s has pads" % (node.op_type, node.name))
        if a.get("ceil_mode", 0):
            raise Refused("%s %s has ceil_mode" % (node.op_type, node.name))
        self.emit(node.output[0], "pool", [xp], 4, k=[kw, kh], s=[sw, sh], kind=op)

    def op_MaxPool(self, i, node):
        self._pool(node, "max")

    def op_AveragePool(self, i, node):
        self._pool(node, "avg")

    def op_Resize(self, i, node):
        a = self.attrs(node)
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
        self.emit(node.output[0], "permute", [self.p(node.input[0])], rank, p=a["perm"])

    def op_Reshape(self, i, node):
        x = node.input[0]
        rank = self.rank_of(x)
        items = self.shape_of(node.input[1])
        if items is None:
            raise Refused("Reshape %s with a shape that is neither constant nor traced" % node.name)
        # the attention head split: reshape [0,-1,3,h,d] -> transpose [2,0,3,1,4] -> slice k -> squeeze 0
        if len(items) == 5 and all(isinstance(v, int) for v in items) and items[:3] == [0, -1, 3]:
            self._heads(i, node, items[3], items[4])
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
        u1 = self.users.get(self.r(node.output[0]), [])
        if len(u1) != 1 or self.nodes[u1[0]].op_type != "Transpose" or self.attrs(self.nodes[u1[0]])["perm"] != [2, 0, 3, 1, 4]:
            raise Refused("Reshape %s to 5-d is not the head split" % node.name)
        tr = self.nodes[u1[0]]
        self.skip.add(u1[0])
        for ui in self.users.get(self.r(tr.output[0]), []):
            sl = self.nodes[ui]
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
        spec = ["@%s:%d" % (self.p(x), j) for j in range(rank)]
        for ax in sorted(self.axes_of(node, a)):
            spec.insert(ax, "1")
        self.emit(node.output[0], "reshape", [self.p(x)], len(spec), d=spec)

    def op_Slice(self, i, node):
        raise Refused("Slice %s on an activation outside the head split" % node.name)

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
    src, dst = args[0], args[1]
    cv = Converter(src)
    out_name, out_rank = cv.convert()
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
