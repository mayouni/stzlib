# _rapid_pages.py <png dir> <out dir> -- the RapidOCR reference run (onnxruntime, Docling's PP-OCRv6 small files) on every
# <id>_p<n>_200dpi.png, one <id>_p<n>_rapid.txt each; the lines are the recogniser's boxes in its own order.
import sys, pathlib, time, glob
from rapidocr import RapidOCR
M = "D:/GitHub/_wt_dl/docling-models/RapidOcr"
eng = RapidOCR(params={"Det.model_path": M + "/PP-OCRv6_det_small.onnx", "Rec.model_path": M + "/PP-OCRv6_rec_small.onnx", "Cls.model_path": M + "/ch_ppocr_mobile_v2.0_cls_mobile.onnx"})
out = pathlib.Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
for png in sorted(glob.glob(sys.argv[1] + "/*_p*_200dpi.png")):
    t = time.perf_counter(); r = eng(png); s = time.perf_counter() - t
    stem = pathlib.Path(png).name.replace("_200dpi.png", "")
    (out / (stem + "_rapid.txt")).write_text("\n".join(r.txts or []), encoding="utf-8")
    print(stem, "boxes", len(r.txts or []), "s", round(s, 2))
