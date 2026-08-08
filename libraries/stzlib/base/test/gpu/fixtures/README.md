# Text-pipeline guard fixtures (GR2, SOFTANZA_GRAPHICS_PLAN.md)

## amiri_arabic_subset.ttf

A committed subset of **Amiri Regular 1.003** (OFL 1.1 — license
committed beside it as `OFL.txt`, as the license requires), so CI shapes
REAL Arabic — joining, lam-alef mandatory ligature, marks — with no
download and no system-font dependence. The tiny_bert.gguf pattern
applied to fonts.

- Kept codepoints: Basic Latin printable (U+0020..U+007E), Arabic
  letters/marks/digits/punctuation (U+060C..U+066F), bidi controls
  (U+200C..U+200F). GSUB/GPOS retained — they are the point.
- 131,820 bytes, 1,449 glyphs. SHA-256:
  `e2bd48513e841274509cdca134b105ebee4220d44646e32164e79fe14d5769ca`

Regeneration (deterministic, inputs pinned): see the header of
`engine/tools/font_subset_gen.c` — hb-subset compiled from the SAME
HarfBuzz 14.3.0 tarball pinned in `engine/vendor/harfbuzz/VERSION.txt`,
over the official Amiri-1.003.zip release asset (SHA-256 recorded in the
tool header). CI never regenerates; it uses this committed file.
