"""THE ORACLE for the image plane (SOFTANZA_IMAGE_INTELLIGENCE.md, IM1).

OpenCV is never a dependency of Softanza; it is the INDEPENDENT implementation
the native ops are measured against. This script draws deterministic inputs,
runs OpenCV (and NumPy, for the FFT and Sauvola, which base OpenCV lacks) on
them, and writes the expectations the Ring guard compares with:

    base/test/image/_oracle/*.png   images (inputs and expected outputs)
    base/test/image/_oracle/*.csv   grids (one row per line, comma-separated)

Run it in the measurement venv, from anywhere:

    D:\\GitHub\\_wt_dl\\docling-venv\\Scripts\\python.exe -I oracle_opencv.py

It is re-run only when an expectation is meant to change; the guard itself
needs no Python. The OpenCV version is written to _oracle/VERSION.txt.
"""
import os
import sys

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_oracle"))
PAGE = os.path.normpath(os.path.join(HERE, "..", "..", "ocr", "_data", "z09_p1_150dpi.png"))


def png(name, a):
    cv2.imwrite(os.path.join(OUT, name + ".png"), a)


def csv(name, a, fmt="%.6f"):
    np.savetxt(os.path.join(OUT, name + ".csv"), np.atleast_2d(a), delimiter=",", fmt=fmt)


def shapes():
    """96 x 72 gray: a filled rectangle, a ring, a disk, a diagonal line,
    two specks, and seeded noise -- every op has something to bite on."""
    a = np.full((72, 96), 40, np.uint8)
    cv2.rectangle(a, (6, 6), (30, 26), 200, -1)
    cv2.circle(a, (60, 22), 14, 230, 3)
    cv2.circle(a, (24, 52), 11, 170, -1)
    cv2.line(a, (44, 66), (90, 40), 250, 2)
    a[60, 70] = 255
    a[10, 85] = 255
    rng = np.random.default_rng(20261101)
    noise = rng.integers(-12, 13, a.shape)
    return np.clip(a.astype(int) + noise, 0, 255).astype(np.uint8)


def main():
    os.makedirs(OUT, exist_ok=True)
    s = shapes()
    png("in_shapes", s)
    page = cv2.imread(PAGE, cv2.IMREAD_GRAYSCALE)
    if page is None:
        sys.exit("cannot read " + PAGE)
    p = page[140:440, 60:460].copy()  # 400 x 300 of real text and a table rule
    png("in_page", p)
    t = s[8:37, 46:75].copy()  # the ring, as a template
    png("in_template", t)

    # morphology: every op x every shape, k = 5, on the shapes
    ops = {"erode": cv2.MORPH_ERODE, "dilate": cv2.MORPH_DILATE, "open": cv2.MORPH_OPEN,
           "close": cv2.MORPH_CLOSE, "gradient": cv2.MORPH_GRADIENT,
           "tophat": cv2.MORPH_TOPHAT, "blackhat": cv2.MORPH_BLACKHAT}
    shp = {"rect": cv2.MORPH_RECT, "cross": cv2.MORPH_CROSS, "ellipse": cv2.MORPH_ELLIPSE}
    for on, ov in ops.items():
        for sn, sv in shp.items():
            k = cv2.getStructuringElement(sv, (5, 5))
            png(f"morph_{on}_{sn}", cv2.morphologyEx(s, ov, k))
    png("median3", cv2.medianBlur(s, 3))
    png("median5", cv2.medianBlur(s, 5))
    png("equalize", cv2.equalizeHist(s))

    csv("sobel_x", cv2.Sobel(s, cv2.CV_64F, 1, 0, ksize=3), "%.1f")
    csv("sobel_y", cv2.Sobel(s, cv2.CV_64F, 0, 1, ksize=3), "%.1f")
    csv("scharr_x", cv2.Scharr(s, cv2.CV_64F, 1, 0), "%.1f")
    png("canny_shapes", cv2.Canny(s, 50, 150))
    png("canny_shapes_l2", cv2.Canny(s, 50, 150, L2gradient=True))
    png("canny_page", cv2.Canny(p, 60, 180))

    csv("integral", cv2.integral(s), "%.0f")
    png("adaptive_page", cv2.adaptiveThreshold(p, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 15, 8))

    # Sauvola, written independently in NumPy (base OpenCV has no Sauvola)
    w, k, R = 25, 0.2, 128.0
    r = w // 2
    f = np.pad(p.astype(np.float64), r, mode="edge")
    S = np.pad(f.cumsum(0).cumsum(1), ((1, 0), (1, 0)))
    Q = np.pad((f * f).cumsum(0).cumsum(1), ((1, 0), (1, 0)))
    H, W = p.shape
    win = lambda T: T[w:w + H, w:w + W] - T[0:H, w:w + W] - T[w:w + H, 0:W] + T[0:H, 0:W]
    m = win(S) / (w * w)
    sd = np.sqrt(np.maximum(win(Q) / (w * w) - m * m, 0))
    png("sauvola_page", np.where(p > m * (1 + k * (sd / R - 1)), 255, 0).astype(np.uint8))

    csv("match", cv2.matchTemplate(s, t, cv2.TM_CCOEFF_NORMED), "%.6f")

    n, lab, st, cen = cv2.connectedComponentsWithStats((s > 128).astype(np.uint8), connectivity=8)
    rows = [[st[i, 0] + 1, st[i, 1] + 1, st[i, 2], st[i, 3], st[i, 4], cen[i, 0] + 1, cen[i, 1] + 1] for i in range(1, n)]
    rows.sort(key=lambda q: (q[1], q[0]))
    csv("components8", np.array(rows), "%.4f")
    n4 = cv2.connectedComponents((s > 128).astype(np.uint8), connectivity=4)[0]
    csv("components4_count", np.array([[n4 - 1]]), "%.0f")

    # COLOUR -> GRAY: a seeded RGB image and OpenCV's RGB2GRAY of it (IM1b: the engine's
    # one gray must equal OpenCV 5's bit for bit, including the x.501 cases it rounds down)
    rng2 = np.random.default_rng(1101)
    rgb = rng2.integers(0, 256, (48, 64, 3), dtype=np.uint8)
    png("in_colour", cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR))
    png("gray_colour", cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY))

    csv("fft2_shifted", np.abs(np.fft.fftshift(np.fft.fft2(s.astype(np.float64)))), "%.4f")

    ok, jpg = cv2.imencode(".jpg", cv2.cvtColor(s, cv2.COLOR_GRAY2BGR), [cv2.IMWRITE_JPEG_QUALITY, 90])
    with open(os.path.join(OUT, "VERSION.txt"), "w") as fv:
        fv.write(f"OpenCV {cv2.__version__}, NumPy {np.__version__} -- written by _rig/oracle_opencv.py\n")
    print("oracle written to", OUT, "with OpenCV", cv2.__version__)


if __name__ == "__main__":
    main()
