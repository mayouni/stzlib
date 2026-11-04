"""IM9c fixtures, step 2 of 2: the pictures. Reads the JSON of codes_gen.py and renders every code under the conditions
a real code is read in. Run with the docling venv (numpy, OpenCV, Pillow):

    python codes_render.py <codes.json> <out dir> <seed> [<negatives dir> ...]
    python codes_render.py --limits <codes.json> <out dir> <seed>     (harsher conditions, reported and never gated on)

For each code: clean; rotated (17, 45, 90 and 180 degrees, 133 and 271 for QR); blurred (two strengths, relative to the
module size); in perspective (the content's corners moved by up to 9% of its size); noisy (gaussian, two strengths);
low contrast; and in a SCENE (640 x 480 of gradient, rectangles and stripes, the code small and rotated among them).
QR codes are also paired two to a picture ('multi'). NEGATIVES -- pictures that hold no code and must read as none --
are noise, gradients, text-like stripes, parallel stripes of random widths (barcode-like but not a barcode), dense random
blocks (finder-pattern-like), and every picture of the folders named after the seed.

Writes <name>.png and truth.tsv: file <TAB> variant <TAB> kind <TAB> sha256 of the text's UTF-8 bytes <TAB> the text.
A negative has kind "none". Writes oracle.tsv too: what OpenCV's own QR and barcode detectors read from each file -- a
MEASURING oracle, never the truth (the truth is the string that was encoded).
"""
import hashlib
import json
import math
import os
import random
import sys

import cv2
import numpy as np

BG = 232


def qr_bitmap(modules, ms):
    m = np.array(modules, dtype=np.uint8)
    q = 4
    full = np.ones((m.shape[0] + 2 * q, m.shape[1] + 2 * q), dtype=np.uint8)
    full[q:-q, q:-q] = 1 - m
    return np.kron(full, np.ones((ms, ms), dtype=np.uint8)) * 255


def bar_bitmap(bars, ms, height):
    q = 10
    row = np.array([1] * q + [1 - int(c) for c in bars] + [1] * q, dtype=np.uint8)
    return np.kron(row[None, :], np.ones((height, ms), dtype=np.uint8)) * 255


def on_canvas(bmp, margin):
    h, w = bmp.shape
    c = np.full((h + 2 * margin, w + 2 * margin), BG, dtype=np.uint8)
    c[margin:margin + h, margin:margin + w] = bmp
    return c


def rotate(img, deg):
    h, w = img.shape
    rad = math.radians(deg)
    nw = int(abs(w * math.cos(rad)) + abs(h * math.sin(rad))) + 4
    nh = int(abs(w * math.sin(rad)) + abs(h * math.cos(rad))) + 4
    m = cv2.getRotationMatrix2D((w / 2, h / 2), deg, 1.0)
    m[0, 2] += (nw - w) / 2
    m[1, 2] += (nh - h) / 2
    return cv2.warpAffine(img, m, (nw, nh), flags=cv2.INTER_LINEAR, borderValue=BG)


def perspective(img, rnd, frac=0.09):
    h, w = img.shape
    src = np.float32([[0, 0], [w, 0], [w, h], [0, h]])
    j = lambda s: rnd.uniform(-frac, frac) * s
    dst = np.float32([[j(w) + w * 0.05, j(h) + h * 0.05], [w - j(w) - w * 0.05, j(h) + h * 0.05],
                      [w - j(w) - w * 0.05, h - j(h) - h * 0.05], [j(w) + w * 0.05, h - j(h) - h * 0.05]])
    m = cv2.getPerspectiveTransform(src, dst)
    return cv2.warpPerspective(img, m, (w, h), flags=cv2.INTER_LINEAR, borderValue=BG)


def noisy(img, rnd, sigma):
    r = np.random.RandomState(rnd.randrange(1 << 30))
    out = img.astype(np.float32) + r.normal(0, sigma, img.shape)
    return np.clip(out, 0, 255).astype(np.uint8)


def scene(code, rnd):
    r = np.random.RandomState(rnd.randrange(1 << 30))
    H, W = 480, 640
    yy, xx = np.mgrid[0:H, 0:W]
    bg = (110 + 90 * (xx / W) * (0.5 + 0.5 * np.sin(yy / 37.0))).astype(np.uint8)
    for _ in range(14):
        x0, y0 = r.randint(0, W - 40), r.randint(0, H - 40)
        x1, y1 = min(W, x0 + r.randint(20, 160)), min(H, y0 + r.randint(10, 90))
        bg[y0:y1, x0:x1] = r.randint(30, 230)
    for k in range(0, H, 11):
        if r.rand() < 0.25:
            bg[k:k + 2, :] = r.randint(40, 200)
    small = rotate(code, rnd.choice([0, 12, 25, 90, 200]))
    sh, sw = small.shape
    f = min(1.0, 260.0 / max(sh, sw))
    small = cv2.resize(small, (max(8, int(sw * f)), max(8, int(sh * f))), interpolation=cv2.INTER_AREA)
    sh, sw = small.shape
    x, y = rnd.randrange(10, W - sw - 10), rnd.randrange(10, H - sh - 10)
    bg[y:y + sh, x:x + sw] = small
    return bg


def negatives(out, rnd, dirs):
    r = np.random.RandomState(rnd.randrange(1 << 30))
    items = []
    items.append(("neg_noise", r.randint(0, 256, (240, 320)).astype(np.uint8)))
    items.append(("neg_gradient", np.tile(np.linspace(0, 255, 320, dtype=np.uint8), (240, 1))))
    stripes = np.full((240, 320), 235, dtype=np.uint8)
    for k in range(10, 230, 14):
        stripes[k:k + 3, 20:300] = 25
    items.append(("neg_textlines", stripes))
    pv = np.full((120, 400), 240, dtype=np.uint8)
    x = 30
    while x < 370:
        w = r.randint(1, 5)
        pv[10:110, x:x + w] = 20
        x += w + r.randint(1, 6)
    items.append(("neg_stripes", pv))
    blocks = (r.randint(0, 2, (30, 30)) * 255).astype(np.uint8)
    items.append(("neg_blocks", np.kron(blocks, np.ones((8, 8), dtype=np.uint8))))
    chk = np.kron(np.indices((20, 20)).sum(0) % 2 * 255, np.ones((12, 12))).astype(np.uint8)
    items.append(("neg_checker", chk))
    items.append(("neg_white", np.full((200, 300), 250, dtype=np.uint8)))
    items.append(("neg_black", np.full((200, 300), 8, dtype=np.uint8)))
    names = []
    for n, im in items:
        cv2.imwrite(os.path.join(out, n + ".png"), im)
        names.append((n + ".png", "negative"))
    for d in dirs:
        for f in sorted(os.listdir(d))[:12]:
            if f.lower().endswith((".jpg", ".jpeg", ".png")):
                im = cv2.imread(os.path.join(d, f))
                if im is None:
                    continue
                n = "neg_" + os.path.basename(d.rstrip("/\\")) + "_" + os.path.splitext(f)[0] + ".png"
                cv2.imwrite(os.path.join(out, n), im)
                names.append((n, "negative"))
    return names


def oracle_read(path):
    im = cv2.imread(path)
    q = ""
    b = ""
    try:
        ok, txt, pts, _ = cv2.QRCodeDetector().detectAndDecodeMulti(im)
        if ok:
            q = "|".join(t for t in txt if t)
    except Exception:
        pass
    try:
        det = cv2.barcode.BarcodeDetector()
        ok, info, typ, _ = det.detectAndDecodeWithType(im)
        if ok:
            b = "|".join(t for t in info if t)
    except Exception:
        pass
    return q, b


def main(codes_json, out, seed, neg_dirs):
    os.makedirs(out, exist_ok=True)
    rnd = random.Random(seed)
    d = json.load(open(codes_json, encoding="utf-8"))
    truth = []
    qrs = [c for c in d["codes"] if c["kind"] == "qr"]

    def save(name, img, variant, items):
        cv2.imwrite(os.path.join(out, name + ".png"), img)
        for kind, text in items:
            truth.append((name + ".png", variant, kind, hashlib.sha256(text.encode("utf-8")).hexdigest(), text))

    for c in d["codes"]:
        kind, text = c["kind"], c["text"]
        ms = rnd.choice([4, 5, 6]) if kind == "qr" else rnd.choice([2, 3])
        bmp = qr_bitmap(c["modules"], ms) if kind == "qr" else bar_bitmap(c["modules"], ms, rnd.choice([70, 90]))
        base = on_canvas(bmp, 24)
        save(c["id"] + "__clean", base, "clean", [(kind, text)])
        rots = [17, 45, 90, 180] + ([133, 271] if kind == "qr" else [])
        for a in rots:
            save(c["id"] + "__rot%d" % a, rotate(base, a), "rot%d" % a, [(kind, text)])
        save(c["id"] + "__blur1", cv2.GaussianBlur(base, (0, 0), 0.30 * ms), "blur1", [(kind, text)])
        save(c["id"] + "__blur2", cv2.GaussianBlur(base, (0, 0), 0.45 * ms), "blur2", [(kind, text)])
        save(c["id"] + "__persp", perspective(base, rnd), "persp", [(kind, text)])
        save(c["id"] + "__noise1", noisy(base, rnd, 18), "noise1", [(kind, text)])
        save(c["id"] + "__noise2", noisy(base, rnd, 35), "noise2", [(kind, text)])
        low = (base.astype(np.float32) * (70.0 / 255.0) + 100).astype(np.uint8)
        save(c["id"] + "__lowc", low, "lowc", [(kind, text)])
        save(c["id"] + "__scene", scene(base, rnd), "scene", [(kind, text)])
    for i in range(0, len(qrs) - 1, 2):
        a, b = qrs[i], qrs[i + 1]
        ba = on_canvas(qr_bitmap(a["modules"], 4), 16)
        bb = on_canvas(qr_bitmap(b["modules"], 4), 16)
        h = max(ba.shape[0], bb.shape[0])
        pad = lambda im: np.vstack([im, np.full((h - im.shape[0], im.shape[1]), BG, dtype=np.uint8)])
        save("multi_%s_%s" % (a["id"], b["id"]), np.hstack([pad(ba), pad(bb)]), "multi", [("qr", a["text"]), ("qr", b["text"])])
    for n, _ in negatives(out, rnd, neg_dirs):
        truth.append((n, "negative", "none", "", ""))
    with open(os.path.join(out, "truth.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for row in truth:
            f.write("\t".join(row) + "\n")
    seen = set()
    with open(os.path.join(out, "oracle.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for row in truth:
            if row[0] in seen:
                continue
            seen.add(row[0])
            q, b = oracle_read(os.path.join(out, row[0]))
            f.write("%s\t%s\t%s\n" % (row[0], q, b))
    print("wrote", len(seen), "pictures,", len(truth), "truth rows to", out)


def main_limits(codes_json, out, seed):
    """THE LIMITS: the same codes under conditions harsher than the pass bar asks for, in their own folder and with their
    own random stream (so the dev set is untouched). They are REPORTED, never gated on: they say where reading stops."""
    os.makedirs(out, exist_ok=True)
    rnd = random.Random(seed + 5000)
    d = json.load(open(codes_json, encoding="utf-8"))
    truth = []
    for c in d["codes"]:
        kind, text = c["kind"], c["text"]
        ms = rnd.choice([4, 5, 6]) if kind == "qr" else rnd.choice([2, 3])
        bmp = qr_bitmap(c["modules"], ms) if kind == "qr" else bar_bitmap(c["modules"], ms, rnd.choice([70, 90]))
        base = on_canvas(bmp, 24)
        variants = {
            "blur3": cv2.GaussianBlur(base, (0, 0), 0.70 * ms),
            "blur4": cv2.GaussianBlur(base, (0, 0), 1.00 * ms),
            "persp2": perspective(base, rnd, 0.18),
            "noise3": noisy(base, rnd, 60),
            "small": cv2.resize(base, None, fx=0.6, fy=0.6, interpolation=cv2.INTER_AREA),
            "rot45blur": cv2.GaussianBlur(rotate(base, 45), (0, 0), 0.30 * ms),
            "lowc2": (base.astype(np.float32) * (40.0 / 255.0) + 110).astype(np.uint8),
        }
        for name, img in variants.items():
            cv2.imwrite(os.path.join(out, c["id"] + "__" + name + ".png"), img)
            truth.append((c["id"] + "__" + name + ".png", name, kind, hashlib.sha256(text.encode("utf-8")).hexdigest(), text))
        ok, enc = cv2.imencode(".jpg", base, [cv2.IMWRITE_JPEG_QUALITY, 30])
        open(os.path.join(out, c["id"] + "__jpeg30.jpg"), "wb").write(enc.tobytes())
        truth.append((c["id"] + "__jpeg30.jpg", "jpeg30", kind, hashlib.sha256(text.encode("utf-8")).hexdigest(), text))
    with open(os.path.join(out, "truth.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for row in truth:
            f.write("\t".join(row) + "\n")
    seen = set()
    with open(os.path.join(out, "oracle.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for row in truth:
            if row[0] in seen:
                continue
            seen.add(row[0])
            q, b = oracle_read(os.path.join(out, row[0]))
            f.write("%s\t%s\t%s\n" % (row[0], q, b))
    print("wrote", len(seen), "limit pictures to", out)


if __name__ == "__main__":
    if sys.argv[1] == "--limits":
        main_limits(sys.argv[2], sys.argv[3], int(sys.argv[4]))
    else:
        main(sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4:])
