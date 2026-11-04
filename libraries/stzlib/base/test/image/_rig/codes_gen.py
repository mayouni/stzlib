"""IM9c fixtures, step 1 of 2: the codes themselves, made by libraries that are NOT the decoder.

Run with the isolated venv that holds segno (QR) and python-barcode (EAN-13, EAN-8, UPC-A, Code 128):

    D:/GitHub/_wti_codes_venv/venv/Scripts/python.exe codes_gen.py <seed> <out.json>

Writes a JSON list of codes: {id, kind, text, error, modules} where `modules` is a QR's matrix (rows of 0/1, no quiet
zone) or a 1D code's bar string ('1' = bar, '0' = space). THE ENCODED STRING IS THE TRUTH: no decoder has seen it.

Two seeds make two sets. The DEV set (seed 11) is what the decoders are built against; the JUDGING set (seed 777) is
generated once, from the same recipe, and judged once -- never tuned on.

The recipe: 12 QR texts of different kinds (short ASCII, a URL, 20 digits, alphanumeric-mode capitals, UTF-8, a long
text) at error levels L, M, Q, H, always a STANDARD QR (segno makes a Micro QR when the text fits unless told not to);
4 codes of each 1D symbology (EAN-13 not starting with 0 -- a leading 0 is a UPC-A on the same bars --, EAN-8, UPC-A,
Code 128 in text, digits-only and mixed forms).
"""
import json
import random
import sys

import barcode
import segno


def qr_texts(rnd):
    alnum = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 $%*+-./:"
    return [
        ("short ascii", "HELLO"),
        ("short mixed", "Softanza-" + str(rnd.randrange(100, 999))),
        ("url", "https://softanza.example/image/" + "".join(rnd.choice("abcdefghijklmnopqrstuvwxyz0123456789") for _ in range(40))),
        ("numeric 20", "".join(rnd.choice("0123456789") for _ in range(20))),
        ("numeric 7", "".join(rnd.choice("0123456789") for _ in range(7))),
        ("alphanumeric mode", "".join(rnd.choice(alnum) for _ in range(30))),
        ("utf-8", "Caf\u00e9 \u2615 \u6771\u4eac " + str(rnd.randrange(10, 99))),
        ("long text", " ".join(rnd.choice(["image", "plane", "code", "reads", "the", "pixels", "of", "a", "picture"]) for _ in range(28))),
        ("single char", rnd.choice("ABCDEFGHJKLMNPQRSTUVWXYZ")),
        ("json", json.dumps({"id": rnd.randrange(1, 9999), "ok": True, "tag": "x" + str(rnd.randrange(10, 99))})),
        ("email", "someone" + str(rnd.randrange(10, 99)) + "@example.org"),
        ("mixed case", "".join(rnd.choice("abcdefABCDEF0123456789") for _ in range(24))),
    ]


def main(seed, out):
    rnd = random.Random(seed)
    codes = []
    levels = ["L", "M", "Q", "H"]
    for i, (what, text) in enumerate(qr_texts(rnd)):
        lvl = levels[i % 4]
        q = segno.make(text, error=lvl, micro=False, boost_error=False)
        codes.append({"id": "qr%02d" % i, "kind": "qr", "text": text, "what": what, "error": lvl,
                      "version": q.version, "modules": [list(map(int, row)) for row in q.matrix]})
    ean13 = barcode.get_barcode_class("ean13")
    ean8 = barcode.get_barcode_class("ean8")
    upca = barcode.get_barcode_class("upca")
    c128 = barcode.get_barcode_class("code128")
    for i in range(4):
        d12 = str(rnd.randrange(1, 10)) + "".join(rnd.choice("0123456789") for _ in range(11))
        b = ean13(d12)
        codes.append({"id": "ean13_%d" % i, "kind": "ean13", "text": b.get_fullcode(), "modules": b.build()[0]})
        d7 = "".join(rnd.choice("0123456789") for _ in range(7))
        b = ean8(d7)
        codes.append({"id": "ean8_%d" % i, "kind": "ean8", "text": b.get_fullcode(), "modules": b.build()[0]})
        d11 = "".join(rnd.choice("0123456789") for _ in range(11))
        b = upca(d11)
        codes.append({"id": "upca_%d" % i, "kind": "upca", "text": b.get_fullcode(), "modules": b.build()[0]})
    c128_texts = [
        "Softanza-" + str(rnd.randrange(10, 99)),
        "".join(rnd.choice("0123456789") for _ in range(10)),
        "Image Plane " + "".join(rnd.choice("abcdefghijklmnopqrstuvwxyz") for _ in range(6)),
        "A" + "".join(rnd.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(11)),
    ]
    for i, t in enumerate(c128_texts):
        b = c128(t)
        codes.append({"id": "code128_%d" % i, "kind": "code128", "text": t, "modules": b.build()[0]})
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        json.dump({"seed": seed, "segno": segno.__version__, "python_barcode": barcode.version, "codes": codes}, f)
    print("wrote", len(codes), "codes, seed", seed, "(segno", segno.__version__ + ", python-barcode", barcode.version + ")")


if __name__ == "__main__":
    main(int(sys.argv[1]), sys.argv[2])
