# SOFTANZA IMAGE INTELLIGENCE — plan of record

*2026-11-01, stzlib-intelligence. Directed by the author the same day: "after OCR, the same ease
and power in Softanza Intelligence regarding image processing", built on what the graphics engine
already offers, with the classical and the neural capabilities, wise native/vendored choices, and a
selection of small models.*

**Status 2026-11-03: IM0 to IM8 are done. The record of what was achieved, measured and left open is
`SOFTANZA_IMAGE_INTELLIGENCE_ACHIEVED.md`; this plan keeps every number in full.**

This plan **does not replace** `base/graphics/SOFTANZA_VISION_PLAN.md`. That plan is the graphics
plane's doctrine and it governs here: **an analysis returns a GRID, never a picture**; the grid is
named **`stzImageGrid`**; deterministic generation stays the default and neural generation is
quarantined. Its phase **V2 (IMAGE → DATA)** was assigned to the graphics plane and never started;
this plan builds V2 and adds the neural tier the vision plan did not cover (it stopped at OCR and
generation). Where the two disagree, the vision plan is right and this file is the bug.

---

## 0. What exists, measured 2026-11-01 (the inventory, so nothing is built twice)

| | state |
|---|---|
| decode | `stb_image` v2.30 vendored (PNG/JPEG/BMP/GIF/TGA/PSD from memory), linked into stz_neural, stz_gpu, stz_gui |
| encode | ONE PNG encoder (adaptive filters, palette when <= 256 colours) — moved to `engine/src/png_encode.zig` by this plan so a DLL without a GPU can write PNG; private 24-bit BMP writers in OCR and PDF. **No JPEG encoder** |
| pixel types | **three unrelated structs**: `ocr_pipeline.Image` (RGB8), `gpu_render.DecodedImage` (RGBA8), `pdf.ImageOut` |
| classical ops | **all private to the OCR pipeline** (stz_neural): bilinear resize (OpenCV geometry), crop, rot90/180, a 256-bin histogram, 8-connected components, chamfer distance transform, projection-profile skew + bilinear deskew, separable Gaussian unsharp, colour-blob labelling. Gray is rebuilt inline four times. **No** Otsu/Sauvola, general convolution, morphology, edges, 2D FFT, warp |
| graphics | `stzCanvas.AddImage` (V0, done), `ToPixels`, PNG via the wgpu device; **no CPU rasterizer**; `color.zig` has sRGB/linear/Oklab/WCAG/APCA |
| neural runtime | vendored ggml (CPU, x86, + llamafile tinyBLAS in stz_neural); **the house's own graph interpreter** `ocr_graph.zig` runs ONNX graphs converted to GGUF+PROGRAM by `engine/tools/onnx_to_gguf.py` (30 ops: conv, dw-conv, convT, pool, upsample, attention heads, matmul, softmax, GELU, h-swish) — parity with onnxruntime proven on three PP-OCR graphs |
| decoders | own `neural_gen.zig` (llama, qwen2, qwen3, granite) — **takes token ids only, one model slot** |
| absent | llama.cpp / mtmd / clip.cpp, ONNX Runtime, OpenCV, Tesseract, any vision encoder, `stzImage`, `stzImageGrid`, `stz_vision.dll` |

The decisive fact is the graph interpreter: **the estate can already run a converted vision network
natively.** Everything below leans on it.

---

## 1. The native / vendored decisions

### 1.1 Classical image processing: NATIVE Zig, not OpenCV

Decided against vendoring OpenCV (or any OpenCV-class C++ library), for four reasons that are facts
of this estate, not preferences:

1. **The build.** OpenCV is CMake-generated C++ with static initialisers. The estate builds without
   CMake, and stz_neural's own rule is "no C++ static init" (the ggml DLL was patched to honour it).
2. **The weight.** core + imgproc alone is ~1M lines and tens of MB per DLL, for a subset we need
   perhaps 3% of.
3. **Half of it is already written here, in OpenCV's own geometry** (bilinear half-pixel centres,
   replicate borders) — privately, in the OCR pipeline. The work is to **lift it into one shared
   core**, not to replace it.
4. **The engine is the product.** Classical image ops are loops over bytes — exactly what Zig with
   `@Vector` does as well as OpenCV's C++ does, without the seam.

**OpenCV stays the ORACLE, never a dependency**: `opencv-python` in a measurement venv (as Docling is
for documents and onnxruntime is for graph parity) answers "what would OpenCV say?" and every ported
op is checked against it to a stated tolerance. **Kill line, per op:** an op whose native port costs
more than two focused sessions is vendored as a single-file C library if one exists (stb_image_resize2,
public domain, is the named runner-up for resampling) — never as OpenCV.

**Where it lives:** a new portable DLL **`stz_image`** (no GPU, no OS, no ggml), sources
`engine/src/image*.zig`. stz_neural (OCR) imports the same Zig sources so OCR and the image plane run
one implementation: duplicated logic diverges (measured in this repository more than once). The vision
plan's `stz_vision.dll` was named for the per-OS OCR bridge; OCR landed in stz_neural instead, and the
portable core takes the name of what it holds.

### 1.2 Codecs

| | decision |
|---|---|
| decode PNG/JPEG/BMP/GIF/TGA | **stb_image** (vendored, public domain) — kept |
| encode PNG | **native** (`png_encode.zig`, one encoder) |
| encode JPEG | **stb_image_write** (single header, public domain) — the only new vendoring of the classical tier, IM1 |
| WebP, TIFF | **deferred, named**: libwebp (BSD) when a caller brings a WebP; a native baseline TIFF reader when a scanner brings one (CCITT G4 is the hard part and is shared with the PDF reader's unsupported filters) |

### 1.3 Neural vision: ggml + the house's graph interpreter, not ONNX Runtime, not llama.cpp

- **CNN / ViT models** (classify, detect, segment, depth, embed) are converted ONNX → GGUF+PROGRAM
  and run by the graph interpreter, generalised from `ocr_graph.zig` into a vision graph runtime
  (adding what ViTs need: layer norm, patch embedding, position-embedding interpolation). ONNX files
  are a **conversion source**, never a runtime. `onnxruntime` is the PARITY ORACLE only.
- **VLMs** run on the house's own decoder (`neural_gen.zig`, which already speaks llama — SmolLM2 is
  llama) plus a SigLIP tower in the graph runtime, a pixel-shuffle connector, and the two seams the
  decoder lacks: **an entry that accepts embeddings** and **more than one model slot**. llama.cpp's
  MIT `mtmd/models/*.cpp` are read as reference for the graphs, not vendored.
- **GPU**: CPU floor first; wgpu compute kernels (already used for matmul/softmax) for the heavy ops
  later, measured as two paths that must agree.

### 1.4 Governance — every model call leaves a record

Every vision model call goes through ONE door that writes a chained seclog record before the answer
returns (this is the image plane's answer to COMPASS-KERN-05), and face *identification* is **refused
by default**: detection of faces is a capability, recognising who a person is is a governed act behind
a declared risk and a grant, never a default.

---

## 2. The model kit — small, permissive, practical

Selection rules: **Apache-2.0 / MIT / BSD only**; small enough for a laptop CPU; every model is a
FACULTY implementation that earns its place by **strictly beating a measured floor on an independent
golden set** (the model-flow law); the author said yes on 2026-11-01 and the kit is DOWNLOADED (19 files, sha256 in `models/MODELS.md`), held outside the tree until IM3 converts it.

| faculty | model | licence | size (approx.) | floor it must beat |
|---|---|---|---|---|
| `:classify` (1000 classes) | MobileNetV3-Large (timm `ra_in1k`) | Apache-2.0 | 5.5M params, ~22 MB | colour-histogram + kNN |
| `:embed-image`, `:zero-shot`, image search | **SigLIP2-base/16-224** | Apache-2.0 | vision tower ~93M; with text tower ~375M | histogram + edge-orientation descriptor |
| `:detect` (objects, 80 COCO classes) | YOLOX-Nano / -Tiny | Apache-2.0 | 0.9M / 5.1M | none exists — refused until a model measures |
| `:faces` (boxes + 5 landmarks) | YuNet (OpenCV model zoo) | MIT | ~0.1M params, ~0.3 MB | Windows.Media.FaceAnalysis (platform) |
| `:segment` (promptable: point/box → mask) | MobileSAM | Apache-2.0 | 9.7M, ~40 MB | colour flood-fill from the point |
| `:depth` (relative) | Depth-Anything-V2-**Small** (Base/Large are CC-BY-NC: excluded) | Apache-2.0 | 24.8M, ~50 MB F16 | none — refused until measured |
| `:cut-out` (background removal) | U²-Net-p | Apache-2.0 | 1.1M, ~4.7 MB | border-colour flood + morphology |
| `:describe`, visual questions | **SmolVLM-256M-Instruct** | Apache-2.0 | 175 MB + 104 MB mmproj | none — refused until measured |
| `:doc-vlm` (page → structure) | Granite-Docling-258M | Apache-2.0 | ~0.5 GB | the native PDF/OCR reader (it is the floor) |

**Why SigLIP2 carries the middle of the table:** SmolVLM's vision tower IS a SigLIP-base/16 — one
tower, built once in the graph runtime, serves embeddings, zero-shot labels, image search AND the VLM.

**Excluded, with reasons:** Ultralytics YOLO (AGPL-3.0); Depth-Anything Base/Large, MODNet, RMBG-1.4
(non-commercial); Qwen2.5-VL-3B (research licence); Moondream 3 (BSL). **Deferred:** Florence-2 (MIT,
but an encoder-decoder the house decoder does not run), D-FINE/RF-DETR (deformable attention),
Real-ESRGAN (16M for upscaling — Lanczos is the floor first).

---

## 3. The Ring surface — the same ease as OCR

```ring
oImg = StzImageQ("market.jpg")                    # decode once, an engine handle
? oImg.Size()                                     #--> [ 1600, 1200 ]
oImg { ApplyGrayScale() ApplyThreshold(:otsu) SaveAs("ink.png") }   # CHANGES oImg
? oImg.Components()                               # data: one row per region (box, area, centroid)

? oImg.Detect(:objects)                           # [ [ "person", 0.91, [x, y, w, h] ], ... ]
? oImg.ClassifyAs([ "a receipt", "a photo of food", "a diagram" ])   # zero-shot
? oImg.Describe()                                 # SmolVLM, with the engine named in Why()
oProduct = oImg.CutOut()                          # data: a new image, oImg untouched
oProduct.SaveAs("product.png")
oDepth = oImg.Depth()                             # a stzImageGrid: one number per pixel
```

- `stzImage` holds pixels (an engine handle, gen-keyed, freed once), and its names follow the house
  forms: `ApplyBlur()` CHANGES the image, `ApplyBlurQ()` changes it and returns it to chain, and
  `Blurred()` returns DATA -- a new image -- without altering the object. A pipeline is written
  with the Apply forms (`oImg { ApplyGrayScale() ApplyThreshold(:otsu) }`, or
  `oImg.ApplyGrayScaleQ().ApplyThresholdQ(:otsu)`), never as a chain of `...ed()` calls, each of
  which would be a new image left unreleased (corrected by the author, 2026-11-01).
- `stzImageGrid` holds what an analysis returns (rows × columns of numbers with what a row and a
  column MEAN), and is lossless back to an image when the grid IS the pixels (vision plan §3).
- Every neural answer carries `Why()`: which model, which floor it beat, on which golden.

---

## 4. The rungs

| rung | content | done means |
|---|---|---|
| **IM0** ✓ | shipped 2026-11-01 (e10c34f24) | image_core_narrated 46/46 under rnxc |
| **IM1** ✓ | analysis (engine/src/image_ops.zig): morphology (7 operations x rect/cross/ellipse), median, histogram equalisation, Sobel/Scharr, Canny (L1 and L2), adaptive mean and Sauvola thresholds, integral images, template matching (TM_CCOEFF_NORMED), connected components with statistics, 2D FFT (fft.zig, exact for every size), image comparison; JPEG out (stb_image_write v1.16, own translation unit without the UB sanitizer) | image_ops_narrated 28/28 under rnxc against `_oracle/` (OpenCV 5.0.0): every image result PIXEL-EXACT, Sobel/Scharr/integral value-exact, correlation within 1e-4, FFT within 1e-6 of the peak, JPEG q90 36.4 dB |
| **IM1b** ✓ | `engine/src/image_core.zig`, imported by stz_neural (OCR) and stz_image: ONE gray -- OpenCV 5's RGB2GRAY bit for bit, `(9798 R + 19235 G + 3735 B + 16384) >> 15`, derived over all 16,777,216 colours (the engine had three grays before, differing from OpenCV on up to 43,864 colours) --, the OCR pipeline's own bilinear resize, replicate crop, quarter turns, components, BMP; `ToImageScaled` | OCR guards unchanged under rnxc (59 / 43 / 38 / 96, pdf_reader 285); image_core 47, image_ops 29 incl. 3,072 random colours pixel-exact |
| **IM2** ✓ | `engine/src/image_geom.zig`: warps (affine, perspective) as OpenCV 5 computes them -- continuous positions, float bilinear, MEASURED (the pre-4.11 1/32-pixel fixed point differed on 874 of 6,912 pixels) --; matrices from points and angles; free-angle rotation; outer contours by OpenCV's border following; Douglas-Peucker, convex hull, minimum-area rectangle; `ForegroundMask` (background = border-connected, border-coloured, tolerance MEASURED as 3 robust sigmas of the border); `PageCorners`, `FlattenedPage(XT)` | image_geom_narrated 29/29: warps pixel-exact, contours point-for-point in OpenCV's order, a photographed page's corners within 1 px, flattened to 3.5 levels of the true page, and read by OCR. Limit stated: one photograph does not give a page's true proportions -- a known size is given with `FlattenedPageXT` |
| **IM3** ✓ | the vision graph runtime: `onnx_to_gguf.py` gains conv bias, Flatten, Gemm, padded max pool, `step2` (YOLOX's Focus), YuNet's 12 heads fused, labels and input size in the file; `ocr_graph.zig` runs them; `engine/src/vision.zig` prepares (image_core), runs and decodes MobileNetV3 / YuNet / YOLOX (+ `ObjectsTiled`: whole + four overlapping tiles); `stzImage.Classify / Faces / Objects / ObjectsTiled`, `ApplyBox / ApplyDot / ApplyFindings`; ONE governed door (`stzVision.ring`) records every call as `model.call` in the security ledger, opening it when none is open | image_vision_narrated 21/21: the engine equals onnxruntime on all four models (cosine 1.00, max diff < 0.001); golden retriever 0.77; 7 of 7 crew faces with landmarks; tiles 9 objects against 2; the detector's "sheep" for the dog MEASURED and kept (onnxruntime agrees: the model, not the engine); 8 calls, 8 ledger records, chain intact |
| **IM4** ✓ | three faculties in the model-flow registry (`StzVisionDeclare`): `:faces` (floor: the platform's Windows.Media.FaceAnalysis; model YuNet), `:objects` (floor: "nothing found"; models YOLOX-nano, -tiny), `:image-label` (floor: a fixed "chair", the vocabulary category in the most COCO val2017 images OUTSIDE the golden set; model MobileNetV3 mapped ImageNet -> COCO); golden sets from COCO val2017's OWN annotations (`_rig/coco_golden.py` -> `_golden/coco_v1.ring`, fixed rules, picked before any model ran); checkers `faces-anchors`, `boxes-f1`; measurements filed in `base/image/vision.zmdl.txt` | image_faculties_narrated 14/14. Measured: objects -- nothing 0, nano 0.85, **tiny 0.88 (chosen)**; image-label -- chair 0, **MobileNetV3 0.62 (chosen)**; faces -- at OpenCV's default threshold 0.9 YuNet scored 0.50 and the platform floor (0.80) kept the faculty; YuNet's threshold was then CHOSEN ON A DEV SET (`_rig/coco_dev.py`: the next 30 COCO images, no overlap): 0.9 -> 20/30, 0.5 -> 27/30, platform 25/30; re-measured on the untouched golden, **YuNet 0.87 beats the platform 0.80 and now answers** |
| **IM5** ✓ | SigLIP2 base patch16-224, both towers: `onnx_to_gguf.py` gains Tanh, shape-domain Gather/Tile, the packed k/v split, an embedding lookup, constant folding over a STATIC input (`--seq=64`), and `--tokenizer` (Gemma's 256,000 tokens and 580,604 merges stored in the GGUF); `ocr_graph.zig` gains `embed`, `tanh`, slices from the end and an id input (`runIds`); `engine/src/bpe.zig` is the byte-fallback BPE; `vision.zig` resizes as PIL does (its fixed-point antialiased bilinear) and returns unit vectors; `stzImage.Embedding / ClassifyAs(XT) / SimilarityTo / ToJpegDataURI`, `stzImageIndex` (`Search`, `SearchLike`) storing and ranking through `stzSemanticIndex`; a second `:image-label` model, `siglip2`, answering in the category NAMES (no mapping table) | image_search_narrated 21/21 under rnxc: tokens = HF's for 10 of 10 texts (French, Arabic, emoji, edge spaces, empty); text tower worst cosine 0.9999999, image tower 1.0000000 (max diff 3.3e-6), end to end from the JPEG >= 0.9998; ClassifyAs right in 8 of 8 sets incl. French, Arabic, Japanese labels; search over 118 COCO images judged by COCO's annotations, 25 queries fixed by rule (`_rig/coco_search.py`): **P@1 0.88, P@3 0.76, random 0.088**. image_faculties_narrated 16/16: `:image-label` **siglip2 0.82 (chosen) > MobileNetV3 0.62**. Cost: 160 ms a picture, 50 ms a text, 22 s to index 118 pictures |
| **IM6** ✓ | dense, U²-Net-p and Depth-Anything-V2-Small: the converter gains dilated convolution, ceil-mode max pool (only over a provably non-negative input), bilinear Resize to another tensor's size or to fixed sizes with corners aligned, ConvTranspose with a bias, and `--static` -- the input's dims fixed, ONNX shape inference with data propagation, every Shape of a known tensor folded, a constant Resize computed (DINOv2's position embeddings), unit-step slices; the PIL resampler gains Lanczos and bicubic. `stzImage.SalientMask` (a one-channel mask, as `ForegroundMask`), `BackgroundRemoved / ApplyBackgroundRemoval / ApplyMask`, `DepthMap` (a `stzImageGrid`: relative inverse depth, larger nearer); faculty `:foreground` (floor: the classical `ForegroundMask`; model U²-Net-p), golden `masks_v1` = 30 COCO polygons by a fixed rule (`_rig/coco_masks.py`), checker `mask-iou` (IoU >= 0.5 at level 128). **MobileSAM** (3 of 3): the converter gains several inputs, `--static-inputs` (every tensor's shape LEARNED by running the graph once in onnxruntime: TinyViT's computed pads stop ONNX shape inference), constants folded through onnxruntime when no fold knows the op, `--outputs` (pruned to what the named tensors need, packed end to end), `--zero-inputs`, `--int-inputs` (point labels: Equal as 1 - min(1, |x - k|)), LayerNormalization, Pad, Split, Sin/Cos, Expand, the channel mean of LayerNorm2d, and TinyViT's six-axis window partition as ONE four-axis swap (`win`); `vision.zig` encodes a picture once (kept per pixels, 8 at a time) and decodes each point or box, choosing the mask as the export does and resizing as SAM's postprocess. `stzImage.MaskAt / MaskAtXT / MaskInBox(XT) / CutOutAt / ApplyCutOutAt`; faculty `:object-at` ([ image, x, y ] -> mask; floor: the region of the classical foreground holding the point, `StzEngineImageComponentAt`), golden `points_v1` = the 30 COCO objects of masks_v1, each prompted by the pixel deepest inside COCO's mask (`_rig/coco_points.py`). And DEPTH JUDGED: faculty `:depth` (floor: "lower is nearer"), golden `depth_v1` = every 10th picture of DIODE's validation split, 78 laser scans (`_rig/diode_depth.py`), checker `depth-absrel` (a scale and a shift fitted, the MiDaS protocol, AbsRel <= 0.20; `StzEngineImageDepthScore`). FOUND ON THE WAY: the GPU router (`neural_gpu.zig`) cached a mul_mat's first operand on the GPU BY ADDRESS as if it were a weight -- through `ggml_conv_2d` it is the im2col of the activation, at the same address run after run, so a picture was encoded with the PREVIOUS picture's columns; fixed (only a leaf the graph does not compute is a weight). Only MobileSAM's neck crossed the router's threshold; OCR, U²-Net-p, Depth-Anything and SigLIP2 never reach it (counter 0), their measurements stand | image_dense_narrated 16/16 under rnxc: U²-Net-p = onnxruntime (cosine 1.000000, max diff 3.9e-5), its masks = rembg's end to end (IoU >= 0.988); DA-V2 = onnxruntime (max diff 4.5e-4), its maps = HF's end to end (0.08 of 255); the salient dog is NEARER than its background by the depth model (3.9 against 1.7); **:foreground u2netp 0.70 > classical 0.10 (chosen)**. Cost: 0.7 s a mask, 1.0 s a depth map. image_promptable_narrated 25/25 under rnxc: the MobileSAM encoder = onnxruntime (cosine 1.000000, max diff 2e-6), masks = the export's end to end for a point and a box on three photos (IoU >= 0.998, IoU estimates within 0.001); **:object-at mobilesam 0.633 > classical 0.133 (chosen)**; **:depth depth-anything-v2-small 0.615 > lower-is-nearer 0.308 (chosen)**, mean AbsRel 0.186 against 0.296. Two runs of 12 objects agree exactly after the router fix (before it: 0.467 and 0.500 on the same 30). Cost: 1.2 s to encode a picture, 0.07 s a point |
| **IM7** (2 of 2 ✓ 2026-11-03: v1 a TIE, v2 CHOSEN) | 2026-11-03: SmolVLM's SigLIP tower and idefics3 connector as a ggml graph of their own (engine/src/vlm.zig, read from the mmproj GGUF), the house decoder given an embedding entry (neural_gen.startWithRows). Parity with Hugging Face's own SmolVLM code loaded with the same weights: tower cosine >= 0.99984, the prompt's 79 tokens equal to an independent tokenizer's, the top-5 next tokens identical, 38 to 40 of 40 tokens agreeing under teacher forcing. `Describe()`, `DescribeXT()`, `Ask()`; about 1.2 s for the picture and 1.4 s for 96 tokens. :describe on 99 COCO pictures (does it name the main object COCO annotated): SmolVLM 0.828 against a fixed sentence 0.444, so SmolVLM answers; 35 of 99 also name a COCO category COCO did not annotate there. Granite-Docling (`:doc-vlm`) is 2 of 2 | `Describe()` and `:doc-vlm` beat their floors or are refused **2 of 2: Granite-Docling (`:doc-vlm`) ties its floor on golden v1 and BEATS it on the fresh golden v2.** Its tower is SmolVLM's (same graph); what is new is the PAGE: Idefics3's tiling (2048 on the long side, 512 x 512 tiles, one more view of the whole page: 13 views, 832 rows for an A4 page at 150 dpi; `vlm.pageViews`), a decoder entry that reads several pictures between texts (`neural_gen.startWithSegments`, DocTags' control tokens given back as text), DocTags read into the blocks the native PDF reader returns (`stzDocTags.ring`), and the house's one document scorer in Ring (`StzDocBlocksScores`, equal to `_doc_score.py` on 434 metrics). Parity with Hugging Face's Idefics3 on the same weights, three pages: the page's pixels identical (cosine 1, difference 0), the 878 prompt tokens equal, the views' rows cosine 0.9999, the two likeliest next tokens equal, 59 to 60 of 60 tokens agreeing under teacher forcing. Judged on the 31 golden pages (the first one-page English document of each of golden_v2 ... v33, a rule fixed before any model read a page), each read as a scan; the floor is the native PDF reader on the scan (OCR, then its own layout rules); a page agrees at a metric mean of 0.9: **native reader 4 of 31, Granite-Docling 4 of 31, a tie, so the registry keeps the floor**. Mean of the pages' means 0.755 and 0.750. The two read DIFFERENT things well: Granite-Docling wins on tables (0.53 against 0.29 of cells at the right row and column) and headings (0.86 against 0.72); the native reader wins on text (0.96 against 0.87) and on keeping page furniture out of the body (0.74 against 0.50). Cost: median 78 s a page against 6.7 s. Three pages (10%) fall into greedy repetition loops and run to the 3072-token cap (about 280 s): an alternating loop, an identical-line loop, a loop inside one line; a loop stop must be measured on a golden set of its own, these three being known now. The candidate for the next version is the COMBINATION (tables and headings from the model, text and furniture from the native reader), measured on a fresh golden set **DECIDED 2026-11-03, on the author's behalf (the two open points of the first verdict), THE RULE WRITTEN BEFORE ANY FRESH PAGE WAS READ:** (1) a COMBINATION `native-plus-granite` becomes a third implementation of `:doc-vlm`: the reader's blocks are the base; a reader paragraph that is exactly a cell of a table the model wrote is dropped and the model's table (with its caption) stands at the first such paragraph's place; a reader paragraph that is exactly a heading the model wrote becomes that heading; text, lists and page furniture stay the reader's (`StzDocBlocksCombine`). (2) the repetition loops get the engine's own stop, an identical line 3 times in a row, and a cap of 2048 tokens (the longest answer a page needed was 934); no loop detector is invented from the three known bad pages. Both are judged on golden v2, FRESH: the second and, when there is one, the third one-page English document of each of golden_v2 ... v33 (27 pages), read as scans, which no model had read; the faculty's golden version moves to doc-vlm-v2 and every implementation is measured on it; the combination is chosen only if it STRICTLY beats the native reader on that set, as any model must; v1's tie stays on record **THE FRESH SET'S VERDICT (golden v2, 27 pages, none read by any model before the rule was written; the floor was run again in the guard, the model and the combination read from results/doc_vlm_v2/):** pages reaching the bar of 0.9: native reader 6 of 27, **Granite-Docling 12 of 27**, native-plus-granite 10 of 27; mean of the pages' means 0.798, 0.823, 0.831; pages at 0.8 or more 16, 16, 20. By the registered rule (strictly beat the floor on pages reaching the bar, the best implementation wins) **the registry chooses granite-docling-258m**; the combination also strictly beats the floor, was never worse than it on any page (better on 12, equal on 15), and is not chosen because it is not the best by that rule. By metric on v2 (native, Granite, combined): tables 0.28, 0.42, **0.53**; headings 0.79, **0.91**, 0.79; text **0.97**, 0.93, **0.97**; furniture **0.81**, 0.77, **0.81**. What the combination taught: its TABLE half works (the model's grids stand where the reader tore tables apart, and the reader's own ruled tables stay, 0.53 against 0.42), its HEADING half did nothing (0.79 = the reader's: an exact-text match almost never promotes a paragraph, because the two readers split a heading differently); a better heading rule is a new rule and owes a third golden set. v1's tie (4 of 31 each) stays on record: the model's 3 repetition loops weighed on it. Loops on v2 with the engine's stop (an identical line 3 times) and the cap of 2048: 3 of 27 pages again, one stopped by the line stop, two (an alternating loop and an in-line loop, shapes that stop does not see) ran to the cap, 153 s instead of 280 s |
| **IM8** (a ✓ b ✓ 2026-11-03) | **a: the vision tower resident on the GPU** (`engine/src/neural_vit.zig`, built from the BERT backbone's kernels, plus a residual-add kernel and a flash-form attention). THE MEASUREMENT CHOSE THE TARGET: of the 65 s a Granite-Docling page took, the tower (13 views of a 12-layer, 1024-token SigLIP) was 17 to 30 s, and the existing per-node router (`neural_gpu.zig`), lowered to claim the tower's matmuls, was SLOWER (3.3 to 3.7 s a view against 2.0 to 2.5 s): every claimed node pays an upload and a readback, so a graph that hops CPU and GPU per node is not a resident chain. Measured on the way (RTX 3050 Laptop): the generic matmul variant the table names for these shapes is 6.3 times slower than the register-tiled 8 x 8 (620 against 98 ms for the pass without attention), and the tower files the faster one for its own shapes unless a calibration filed another; the backbone's attention, one workgroup per (head, row), re-reads every key and value from global memory (77 GB a pass, a second), and its tree-reduction variants were WORSE at 1024 tokens (1.5 s and 2.9 s against 1.0 s, and the 128-wide one lost the device); a flash-form kernel (32 rows a workgroup, 16-key tiles through workgroup memory, online softmax rescaled once a tile) took the pass from 1.9 s to about 0.45 s. **THE TWO PATHS AGREE, and the GPU one is the more faithful:** against Hugging Face's own tower on the page's 13 views the GPU rows have cosine 1.000 and largest difference 0.004 on rows up to 190, the CPU graph (which quantises its activations to Q8) 11.3. **SPEED, which moves with the load:** the page's 13 views took 18.3 to 23.7 s on the CPU graph and 6.4 to 8.0 s on the GPU tower on a free GPU (2.6 to 3.5 times), 10 to 28 s while another process shared the GPU (1.1 to 1.9 times): a GPU shared in time slows the GPU path far more than the CPU one, so the guard asserts the direction at the best round and the range lives here. **WHAT IT CHANGED:** SmolVLM's `:describe` on COCO rose from 0.828 to **0.879** (the exact rows; the Q8 tower had cost five points), and Granite-Docling's verdict on golden v2 is unchanged (12 of 27 pages, mean 0.829 against 0.823; 13 of the 27 pages byte-identical), the page 64 s to 58 s median: the tower fell from about 18 s to 7 to 10 s and the DECODER is now the page's cost. On by default; `StzEngineNeuralVisionGpu(0)` puts the CPU graph back. **b: THE DECODER'S STEP IS FLAT IN THE CONTEXT (`neural_gen.zig`, not GPU).** Measured by phase first: a step took 27 ms at a context of 82 tokens and 55 ms at 1439 (27, 33, 36, 39, 55 ms at 82, 348, 679, 878, 1439), and the whole slope was two phases, the compute (17 to 28 ms: the concat and transpose copies inside the graph) and the build with the cache copied in (6 to 18 ms: scalar loops over every layer's cache, and the first touch of a pool of 14 to 166 MB allocated each step). The cache was two lists of f32 per layer copied into fresh tensors on every step, concatenated with the new K and V, and V transposed again for the attention. It is now PERSISTENT, per layer, in the layout the attention reads it (K [hd, cap, n_kv], V transposed [cap, hd, n_kv], the capacity doubling as a prompt grows), written in place from inside the graph (a `ggml_cpy` into a view; the writes are expanded first, in layer order, so every read of the cache comes after its write) and read through views: only the new tokens are written. **Result: 8.6, 9.6, 10.5, 10.5, 12.8 ms at the same contexts (3 to 4 times faster at long context, 0.035 -> 0.003 ms per context token), the pool 3 to 5 MB instead of 14 to 166 MB, the append phase 0.** THE ANSWERS DID NOT CHANGE: the greedy text of four decoder families (SmolLM2 llama, Qwen2.5-Coder with biases, Qwen3 with q/k norms, Granite 4.0) on prompts of 5, 11 and 1100+ tokens (every capacity doubling crossed) is byte-identical to what the old decoder wrote (built from the commit before and diffed; the old outputs are the fixture `base/test/neural/_data/decode_equiv_expected.txt`), as are four Granite-Docling pages; the eight generation guards that report (granite 21, options 15, pool 17, qwen3 17, termination 20, window 23, generative 14, door 14) keep their counts (and ran in a third to a fifteenth of the time, cold start of the baseline included); four (constrained_decoding, llmfunction, structuredoutput, schema_grammar) cannot run under Ring++ at all (a bare global `nPass` in `chk()`, Rule A) before or after and are NOT RUN. A Granite-Docling page: 57.8 s -> 17.9 s end to end (the views 8.9 s on the GPU tower, the words 8.9 s). **And a hazard the work met, whose cause is NOT established:** two guard runs died with `Parent device is lost` while another session's `rnxc` (`D:\ringpp\ringpp-win64\bin\rnxc.exe`) was on the same GPU, and Windows logged NVIDIA driver timeouts (LiveKernelEvent 0x141, nvlddmkm) in the same minutes; a driver reset kills every client of the adapter. Whether the other session's work or the tower's single 0.45-1.4 s submit crossed Windows' 2 s limit is not known: the pass is now a submit every three layers as a precaution, at no measurable cost, and the rule stands that one neural job uses the GPU at a time; both guards then passed on a rerun | guards `image_gpu_tower_narrated` 13/13, `decode_cache_narrated` 9/9 (new), `image_describe` 32/32, `image_docvlm` 55/55 on the new engine |

**The perception gate** (`CENTRAL-PERCEPTGATE-01`) binds every rung: images reach a person through
sight, so each rung ships PNGs a person can open, and records who looked and what they said. A
counter proves delivery; only a look proves the picture is right.
