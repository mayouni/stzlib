#!/usr/bin/env python3
"""gguf_read.py -- reads a GGUF file's metadata and tensors in plain numpy (IM7's references).

No gguf package: the format is a header, key-value metadata, tensor descriptors and aligned data. Tensors
come back as float32 arrays in numpy order (the GGUF dims reversed), F32, F16, BF16 and Q8_0 dequantized.

    python -I gguf_read.py <file.gguf>        prints the metadata and the tensors
"""
import struct
import sys

import numpy as np

_SCALAR = {0: "<B", 1: "<b", 2: "<H", 3: "<h", 4: "<I", 5: "<i", 6: "<f", 7: "<?", 10: "<Q", 11: "<q", 12: "<d"}


class GGUF:
    def __init__(self, path):
        self.path = path
        self.buf = np.memmap(path, dtype=np.uint8, mode="r")
        self.pos = 0
        assert bytes(self.buf[:4]) == b"GGUF", "not a GGUF file"
        self.pos = 4
        self.version = self._u("<I")
        n_t = self._u("<Q")
        n_kv = self._u("<Q")
        self.meta = {}
        for _ in range(n_kv):
            k = self._str()
            self.meta[k] = self._val(self._u("<I"))
        self.tensors = {}
        for _ in range(n_t):
            name = self._str()
            nd = self._u("<I")
            dims = [self._u("<Q") for _ in range(nd)]
            typ = self._u("<I")
            off = self._u("<Q")
            self.tensors[name] = (dims, typ, off)
        align = self.meta.get("general.alignment", 32)
        self.data = (self.pos + align - 1) // align * align

    def _u(self, f):
        n = struct.calcsize(f)
        v = struct.unpack(f, bytes(self.buf[self.pos:self.pos + n]))[0]
        self.pos += n
        return v

    def _str(self):
        n = self._u("<Q")
        s = bytes(self.buf[self.pos:self.pos + n]).decode("utf-8", "replace")
        self.pos += n
        return s

    def _val(self, t):
        if t in _SCALAR:
            return self._u(_SCALAR[t])
        if t == 8:
            return self._str()
        if t == 9:
            it = self._u("<I")
            n = self._u("<Q")
            return [self._val(it) for _ in range(n)]
        raise ValueError("gguf: value type %d" % t)

    def tensor(self, name):
        dims, typ, off = self.tensors[name]
        n = int(np.prod(dims))
        at = self.data + off
        if typ == 0:
            a = np.frombuffer(self.buf, np.float32, n, at)
        elif typ == 1:
            a = np.frombuffer(self.buf, np.float16, n, at).astype(np.float32)
        elif typ == 30:
            a = (np.frombuffer(self.buf, np.uint16, n, at).astype(np.uint32) << 16).view(np.float32)
        elif typ == 8:
            nb = n // 32
            raw = np.frombuffer(self.buf, np.uint8, nb * 34, at).reshape(nb, 34)
            d = raw[:, :2].copy().view(np.float16).astype(np.float32)
            q = raw[:, 2:].copy().view(np.int8).astype(np.float32)
            a = (q * d).reshape(-1)
        else:
            raise ValueError("gguf: tensor type %d of %s" % (typ, name))
        return np.array(a, dtype=np.float32).reshape(list(reversed(dims)))


def main():
    g = GGUF(sys.argv[1])
    for k, v in g.meta.items():
        if isinstance(v, list) and len(v) > 8:
            v = "%s ... (%d)" % (v[:8], len(v))
        print(k, "=", v)
    for name, (dims, typ, _) in g.tensors.items():
        print("%-48s %-20s type %d" % (name, dims, typ))


if __name__ == "__main__":
    main()
