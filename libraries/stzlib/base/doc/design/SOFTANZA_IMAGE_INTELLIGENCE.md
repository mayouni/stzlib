# SOFTANZA IMAGE INTELLIGENCE — plan of record

*2026-11-01, stzlib-intelligence. Directed by the author the same day: "after OCR, the same ease
and power in Softanza Intelligence regarding image processing", built on what the graphics engine
already offers, with the classical and the neural capabilities, wise native/vendored choices, and a
selection of small models.*

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
| IM4 | faculties + goldens: a golden of Softanza-rendered scenes (exact by construction) and an INDEPENDENT photo set written by a separate author | each model's measurement vs its floor in the calibration ledger |
| IM5 | SigLIP2: embeddings, zero-shot, image search through `stzSemanticIndex` | cosine parity >= 0.999 vs the reference |
| IM6 | dense: MobileSAM, Depth-Anything-V2-Small, U²-Net-p | masks and depth as stzImageGrid, judged on the golden |
| IM7 | VLM: SmolVLM-256M, then Granite-Docling (embedding prefill, pixel-shuffle connector, second slot) | `Describe()` and `:doc-vlm` beat their floors or are refused |
| IM8 | GPU tier for the heavy ops, two paths asserted to agree | measured speed-up, not assumed |

**The perception gate** (`CENTRAL-PERCEPTGATE-01`) binds every rung: images reach a person through
sight, so each rung ships PNGs a person can open, and records who looked and what they said. A
counter proves delivery; only a look proves the picture is right.
