# ocr_v0 -- the two engines' texts on four golden documents, every page, 2026-10-30

`<id>_p<n>_win.txt`: Windows.Media.Ocr (fr-FR for z09, z01, u06; ar-SA for y11) through `_rig/winocr.ps1`.
`<id>_p<n>_rapid.txt`: RapidOCR (PP-OCRv6 small det+rec, v2.0 cls, onnxruntime CPU) through `_rig/_rapid_pages.py`.
`y11_win_all_rev.txt`: the floor's Arabic with each line's words reversed -- the bidi finding of the memo, section 2.
Pages rendered by `_rig/_render_pages.py` at 200 dpi (not kept: 0.3-0.4 MB each, reproducible). Scores: `_rig/ocr_score.py`.
The author's scan is NOT here and never will be.
