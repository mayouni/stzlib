#!/usr/bin/env python3
"""screenshot_facts_golden.py -- the golden set of the screenshot facts writer (stzScreenshotFacts.ring).

THE TRUTH IS THE PAINT, NOT A MEASUREMENT: each row of a page is text of a CSS colour on a CSS background, and
the expected luminances are those colours' WCAG 2.x relative luminance, computed here from the hex codes by
the standard's formula -- not by the engine whose estimate is being judged. The page is rendered by a real
browser (headless Chrome, its own antialiasing) at two scales, so the writer is judged on a screenshot and not
on a picture made to suit it.

    <docling venv>/python -I screenshot_facts_golden.py

Writes _data/facts/facts_page.html, facts_s1.png (scale 1) and facts_s2.png (scale 2), the same three for
facts_texture, and _data/facts/facts_golden.ring. ROWS were fixed before the writer ran on them; TEXTURE was
added after, and says why.
"""
import os
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_data", "facts"))
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

# text, colour, background (a hex, or a CSS gradient whose background has no single luminance), CSS px
ROWS = [
    ("Overdue balance", "#999999", "#ffffff", 16),
    ("Account summary", "#333333", "#ffffff", 16),
    ("Save changes", "#ffffff", "#0b57d0", 16),
    ("Cancel", "#5f6368", "#f1f3f4", 14),
    ("Last updated 3 minutes ago", "#9aa0a6", "#ffffff", 12),
    ("Error: card declined", "#d93025", "#ffffff", 14),
    ("Dark mode heading", "#e8eaed", "#202124", 20),
    ("Muted label on dark", "#5f6368", "#202124", 14),
    ("Warning banner", "#3c2a00", "#fdd663", 16),
    ("Link to settings", "#1a73e8", "#ffffff", 16),
    ("Placeholder text", "#bdc1c6", "#ffffff", 16),
    ("Over a gradient", "#ffffff", "linear-gradient(90deg, #0b57d0, #fbbc04)", 18),
    ("Large title", "#202124", "#ffffff", 32),
    ("Tiny footnote", "#5f6368", "#ffffff", 10),
    ("Payment received", "#188038", "#e6f4ea", 14),
    ("Disabled button", "#9aa0a6", "#f1f3f4", 14),
]

# ADDED AFTER the writer first ran on ROWS: there the one gradient row's box held only the gradient's blue end,
# so nothing tested bg_spread. Text over backgrounds with NO single luminance, where the spread must be large
TEXTURE = [
    ("Text on stripes", "#202124", "repeating-linear-gradient(90deg, #ffffff 0 8px, #8ab4f8 8px 16px)", 18),
    ("Caption on a checkerboard", "#202124", "repeating-conic-gradient(#ffffff 0 25%, #a8c7fa 0 50%) 0 0 / 16px 16px", 16),
    ("A gradient that runs under the whole line", "#ffffff", "linear-gradient(90deg, #0b57d0, #fbbc04)", 18),
]


def lum(hexcode):
    def ch(v):
        x = v / 255.0
        return x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4
    r, g, b = (int(hexcode[i:i + 2], 16) for i in (1, 3, 5))
    return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b)


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, rows in (("facts", ROWS), ("facts_texture", TEXTURE)):
        render(name, rows)
    with open(os.path.join(OUT, "facts_golden.ring"), "w", encoding="utf-8", newline="\n") as f:
        f.write("# facts_golden.ring -- written by _rig/screenshot_facts_golden.py: the rows of facts_page.html and the\n")
        f.write("# WCAG luminance of the colours they were PAINTED with. [ text, fg luminance, bg luminance (\"\" = no\n")
        f.write("# single colour), CSS px, fg as painted, bg as painted ]\n")
        for fn, rows in (("StzFactsGolden", ROWS), ("StzFactsGoldenTexture", TEXTURE)):
            f.write("\nfunc %s()\n\treturn [\n" % fn)
            for n, (text, fg, bg, px) in enumerate(rows):
                b = "%.6f" % lum(bg) if bg.startswith("#") else '""'
                f.write('\t\t[ "%s", %.6f, %s, %d, "%s", "%s" ]%s\n' % (text, lum(fg), b, px, fg, bg,
                                                                        "," if n < len(rows) - 1 else ""))
            f.write("\t]\n")
        f.write("\n# the box-kind picture: [ text, em (px), top of its row ] -- each row drawn at a known size\n")
        f.write("func StzFactsGoldenBoxKind()\n\treturn [\n")
        rows = boxkind()
        for n, (text, px, top) in enumerate(rows):
            f.write('\t\t[ "%s", %d, %d ]%s\n' % (text, px, top, "," if n < len(rows) - 1 else ""))
        f.write("\t]\n")
    print("facts golden: %d + %d rows, 2 scales, %d box-kind rows -> %s" % (len(ROWS), len(TEXTURE), len(BOXKIND), OUT))


# what kind of box the OCR returns: the same letters at four sizes, and letters with no ascender or descender
# ("esc") beside letters with both ("Hxgp"). A line box would be as tall for both; an ink box follows the ink
BOXKIND = [("esc", 16), ("esc", 24), ("esc", 32), ("esc", 48), ("Hxgp", 16), ("Hxgp", 24), ("Hxgp", 32), ("Hxgp", 48)]


def boxkind():
    from PIL import Image, ImageDraw, ImageFont
    img = Image.new("RGB", (400, 70 * len(BOXKIND) + 40), "white")
    d = ImageDraw.Draw(img)
    rows = []
    y = 30
    for text, px in BOXKIND:
        d.text((60, y), text, font=ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", px), fill="black")
        rows.append((text, px, y))
        y += 70
    img.save(os.path.join(OUT, "boxkind.png"))
    return rows


def render(name, rows):
    body = []
    for text, fg, bg, px in rows:
        body.append('<div class="row" style="background:%s"><span style="color:%s;font-size:%dpx">%s</span></div>'
                    % (bg, fg, px, text))
    html = ("<!doctype html><html><head><meta charset=\"utf-8\"><style>"
            "html,body{margin:0;background:#ffffff}"
            "body{font-family:'Segoe UI',sans-serif;padding:16px}"
            ".row{width:520px;padding:14px 18px;margin:0 0 10px 0}"
            "</style></head><body>" + "".join(body) + "</body></html>")
    page = os.path.join(OUT, name + "_page.html")
    with open(page, "w", encoding="utf-8", newline="\n") as f:
        f.write(html)
    for scale in (1, 2):
        png = os.path.join(OUT, "%s_s%d.png" % (name, scale))
        # its own profile, so a Chrome the user has open is never joined (it was, and the run hung)
        profile = tempfile.mkdtemp(prefix="stz_facts_chrome_")
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
                        "--user-data-dir=" + profile,
                        "--force-device-scale-factor=%d" % scale, "--window-size=600,1080",
                        "--screenshot=" + png, "file:///" + page.replace("\\", "/")],
                       check=True, capture_output=True, timeout=120)

if __name__ == "__main__":
    main()
