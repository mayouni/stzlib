# Image intelligence -- what was achieved

*IM0 to IM8, 2026-11-01 to 2026-11-03. The record of a finished plan; the plan itself is `SOFTANZA_IMAGE_INTELLIGENCE.md`, whose rows carry every measurement in full.*

**The direction** (the author, 2026-11-01): *"after OCR, the same ease and power for image processing"*, on the library's own graphics engine, with wisely chosen native or vendored parts and a small selection of models.

**The result, in one paragraph.** `stzImage` now analyses, warps and reads a picture, and tells you what is in it, where, how far, and in words. Classical operations (morphology, edges, thresholds, warps, contours, FFT) are native Zig and **pixel-exact against OpenCV**; ten models run on the library's own engine and **equal their reference** (onnxruntime for the eight converted from ONNX, to within 1e-3 and mostly 1e-5 or better; Hugging Face's own code loaded with the same weights for the two vision-language models); every model that answers a faculty **earned its place by beating a stated floor on a golden set built from other people's truth**, and two kept the floor at first (YuNet at its default threshold, Granite-Docling on the first golden set) while a third, the combination of the two readers, was built and not chosen. A Granite-Docling page that took 57.8 s (the 27-page median had been 64 s) took 17.9 s when measured again in the same guard, and the two paths that make that fast (the vision tower on the GPU, the decoder's cache) were each **asserted equal to the slow path before they were allowed to be the default**.

---

## 1. What you can call

All on `stzImage` (three forms for every verb: `Verb()` mutates, `Verbed()` copies, `VerbQ()` chains; `...ed()` returns data and never alters the object; every model call goes through **one governed door** and is recorded in the security ledger).

| you want | you call | what runs | measured |
|---|---|---|---|
| clean, measure, find shapes | morphology, median, equalise, Sobel/Scharr, Canny, adaptive and Sauvola thresholds, integral image, template match, components, 2D FFT, compare | `image_ops.zig` | **pixel-exact** against OpenCV 5.0.0 (28/28), FFT within 1e-6 of the peak |
| straighten, outline | affine and perspective warps, free rotation, contours, polygons, hull, min-area rectangle, `FlattenedPage` | `image_geom.zig` | warps pixel-exact; a photographed page's corners within 1 px and then **read by OCR** (29/29) |
| what is it | `Classify()`, `ClassifyAs(labels)` (any language), `Embedding()`, `SimilarityTo()`, `stzImageIndex.Search()` | MobileNetV3, SigLIP2 | `:image-label` **0.82** (SigLIP2) over 0.62 (MobileNetV3) over a fixed guess 0; search P@1 **0.88** against 0.088 random |
| who and what, where | `Faces()`, `Objects()`, `ObjectsTiled()`, `ApplyBox / ApplyDot / ApplyFindings` | YuNet, YOLOX | `:faces` 0.87 over the platform's 0.80; `:objects` 0.88 over "nothing found" 0 |
| what stands out, what is behind it | `SalientMask()`, `BackgroundRemoved()`, `DepthMap()` | U²-Net-p, Depth-Anything-V2-Small | `:foreground` **0.70** over the classical 0.10; `:depth` **0.615** over "lower is nearer" 0.308 |
| the object under this point or box | `MaskAt()`, `MaskInBox()`, `CutOutAt()` | MobileSAM | `:object-at` **0.633** over the classical 0.133 |
| in words | `Describe()`, `Ask(question)` | SmolVLM-256M | `:describe` **0.879** over a fixed sentence 0.444 |
| a page as structure | `DocTags()`, `DocBlocks()` | Granite-Docling-258M | `:doc-vlm` **12 of 27** fresh pages at the 0.9 bar over the native PDF reader's 6 |
| a screenshot as audit facts | `StzScreenshotFacts()`, `tools/screenshot_facts.ring` | OCR plane + `TextLuminanceInBox` | accepted by stzzui's checker; the hero contrast of a real page confirmed from its pixels (3.99:1) |

Sizes and costs on the dev machine (RTX 3050 Laptop, 31 GB): 160 ms to embed a picture, 0.7 s a mask, 1.0 s a depth map, 1.2 s to encode a picture for SAM then 0.07 s a point.

## 2. What each model had to earn

The model-flow law (SOFTANZA_MODEL_FLOW.md): **an implementation answers a faculty only if it strictly beats its floor on a golden set built by fixed rules from independent truth.** Every golden set here comes from someone else's annotations (COCO val2017, DIODE's laser scans, the golden documents' expected structure written from their HTML) and was fixed before any model ran.

| faculty | floor | model | floor score | model score | verdict |
|---|---|---|---|---|---|
| `:faces` | Windows.Media.FaceAnalysis | YuNet | 0.80 | 0.87 | model, **after its threshold was chosen on a dev set** (at the default 0.9 it scored 0.50 and the floor kept the faculty) |
| `:objects` | nothing found | YOLOX-nano / -tiny | 0 | 0.85 / **0.88** | tiny |
| `:image-label` | a fixed "chair" | MobileNetV3 / SigLIP2 | 0 | 0.62 / **0.82** | SigLIP2 |
| `:foreground` | border-colour flood | U²-Net-p | 0.10 | **0.70** | model |
| `:object-at` | classical region at the point | MobileSAM | 0.133 | **0.633** | model |
| `:depth` | lower is nearer | Depth-Anything-V2-Small | 0.308 | **0.615** | model |
| `:describe` | a fixed sentence | SmolVLM-256M | 0.444 | **0.879** | model |
| `:doc-vlm` (golden v1, 31 pages) | native PDF reader on a scan | Granite-Docling | 4 of 31 | 4 of 31 | **a tie: the floor kept the faculty** |
| `:doc-vlm` (golden v2, 27 fresh pages) | native PDF reader on a scan | Granite-Docling / the two combined | 6 of 27 | **12 of 27** / 10 of 27 | Granite-Docling |

Two of these rows are lessons, not scores. **YuNet was refused first** (0.50 against the floor's 0.80) until its threshold was chosen on pictures nobody judges it on. **Granite-Docling tied on the first golden set and won on the second with the same models**: a verdict on one golden set is that set's verdict, so the combination's rule was written down *before* any fresh page was read and judged on a set no model had seen.

## 3. What changed in speed, and why

The plan said "a GPU tier for the heavy operations". **The measurement chose the target, and it was not the one the plan named.** Of the 65 s a Granite-Docling page took, the vision tower was 17 to 30 s and the decoder 17 to 35 s and *growing with the prompt*; the library's per-node GPU router, lowered to claim the tower's matmuls, was *slower* than the CPU (3.3 to 3.7 s a view against 2.0 to 2.5 s).

| | before | after | how |
|---|---|---|---|
| one view of the vision tower | 1.0 to 4.0 s (CPU graph) | **about 0.46 s** (free GPU) | resident on the GPU: one upload, one submit per three layers, one readback (`neural_vit.zig`) |
| a page's 13 views | 18.3 to 23.7 s | 6.4 to 8.0 s free, 10 to 28 s while the GPU is shared | the same; **a ratio of speeds is not a constant: it moved 1.1 to 3.5 with the GPU's load** |
| tower accuracy against Hugging Face's own tower | largest difference 11.3 | **0.004** on rows up to 190 | the CPU graph quantises its activations to Q8; the GPU pass is f32 over the dequantised weights, as the reference is |
| the decoder's step at 82 / 1439 tokens of context | 27 / 55 ms | **8.6 / 12.8 ms** | a persistent per-layer KV cache read through views, instead of copying the cache into fresh tensors every step |
| one Granite-Docling page (a borderless-table page, 335 tokens, the same guard) | 57.8 s | **17.9 s** | both. The 27-page median was 64 s before; the median after is not re-measured |

What the work found on the way (each is in the module's comments and in the plan): the generic matmul variant the library names for the tower's shapes is **6.3 times slower** than the register-tiled one; the BERT backbone's attention re-reads every key and value from global memory (77 GB for 12 layers) and its tree-reduction variants are *worse* at 1024 tokens (one lost the GPU device), so the tower has a flash-form kernel (1.9 s to 0.45 s); the decoder's slope was never matmul compute but copies of a cache the graph did not need to own and a fresh 160 MB pool each step.

**Side effects, measured:** SmolVLM's `:describe` rose from 0.828 to 0.879 (the exact rows; the Q8 tower had cost five points); Granite-Docling's verdict was unchanged.

## 4. The engine, module by module

| module | what it is |
|---|---|
| `engine/src/image.zig`, `image_core.zig` | the handle table, ONE gray (OpenCV 5's, bit for bit, derived over all 16,777,216 colours), crop, rotate, BMP, PNG/JPEG in and out, `textLuminance` (WCAG luminance of text and its background) |
| `image_ops.zig`, `image_geom.zig` | the classical analyses and warps above, each pixel-exact against an OpenCV oracle |
| `ocr_graph.zig` + `onnx_to_gguf.py` | the **vision graph runtime**: ONNX models converted to GGUF (dilated and transposed convolutions, ceil-mode pools, bilinear resizes, shape folding, `--static` inputs, Gemma's tokenizer inside the file) and run on ggml |
| `vision.zig`, `bpe.zig` | prepare (PIL's own resampler, bit for bit), run and decode every model; the byte-fallback BPE for SigLIP2's text tower |
| `vlm.zig` | the SigLIP tower and Idefics3 connector for SmolVLM and Granite-Docling, **a page's tiling** (2048 on the long side, 512 tiles plus the whole page) |
| `neural_vit.zig` | the same tower, resident on the GPU, built from the BERT backbone's kernels plus a residual-add kernel and a flash-form attention |
| `neural_gen.zig` | the house decoder: now takes **picture rows and several pictures between texts** (`startWithRows`, `startWithSegments`), and keeps a persistent KV cache |
| `base/image/stzDocTags.ring` | Granite-Docling's DocTags read into the blocks the native PDF reader returns, **the one document scorer in Ring** (equal to `_doc_score.py` on 567 metrics), and `StzDocBlocksCombine` |
| `base/image/stzVision.ring` | the governed door, the faculties' declarations, and every model's prompt and load |

Ten models in fourteen files, all Apache-2.0 or MIT, all sha256-recorded in `models/MODELS.md`, none run without a check against its reference: MobileNetV3-Large, YOLOX-nano and -tiny, YuNet, SigLIP2 base (both towers), U²-Net-p, Depth-Anything-V2-Small, MobileSAM (encoder and decoder), SmolVLM-256M, Granite-Docling-258M.

## 5. The method that worked

1. **Measure before the sentence.** The plan's GPU target, the decoder's slope and the attention's cost were each found by measuring by phase, not by reading the plan or guessing.
2. **A model answers only if it strictly beats a floor** on a golden set from someone else's truth, fixed first. A refusal is a result: YuNet's 0.50 and Granite-Docling's tie were reported, not tuned away.
3. **Two paths must agree before the fast one is the default.** CPU graph against the GPU tower against Hugging Face's own code loaded with the same weights; the old decoder built from the commit before and diffed against the new one on four model families.
4. **Never tune on the judging set.** When a rule was refined after a result (YuNet's threshold, the combination), the refinement was chosen on a different set, and the verdict was re-read on a fresh one.
5. **Ask what else the disagreement could be.** An independent scorer disagreeing with the Ring one (0.824 against 0.755) was a bug in the Ring one (`0 = ""` is true in Ring).
6. **Name what was not run.** Gates owned and not run are listed by name, never summed with those run.
7. **Show something a person can look at.** Every faculty ships a report page (below); the audit facts were checked against a real screenshot's pixels.

## 6. Findings other desks can use

- **Ring `0 = ""` is TRUE.** Tell a number from "none" by type (`isNumber`, `isString`); a score of 0 was once dropped from a mean.
- **A statement after a `func` is part of that function.** File-level globals go above the first function.
- **Two processes using the GPU at once can reset the driver.** A segfault in `nvoglv64.dll`, then "Parent device is lost" in a *second* run while another session's `rnxc` held the adapter; Windows logged 31 NVIDIA driver timeouts in a day. Check `nvidia-smi --query-compute-apps` before a GPU run, across sessions. Whose work crossed the 2 s limit is not established.
- **A GPU shared in time slows the GPU path far more than the CPU one.** Assert the direction at the best round, record the range.
- **The per-node GPU router must not cache a mul_mat's first operand by address** (it did: a picture was encoded with the previous picture's im2col columns; fixed, and the `:object-at` score stopped moving between runs).
- **Preprocessing is part of the model.** SmolVLM's processor resizes *twice*; one direct resize gave cosine 0.95 on a 3:2 picture and a score that looked better, so the faithful path was kept and the score reported.
- **llama.cpp's mmproj files may name a layer's two linears the other way round**: pick them by shape.
- **The OCR box is an ink box**, so type size is not decided from it (reported to stzzui, who now states it).

## 7. Adjacent deliverable: the screenshot facts writer

`tools/screenshot_facts.ring <png> <scale> <out.json> [lang]` writes stzzui's `zui-audit-facts 1.0`: per OCR line, its box, its text colour, its background colour and spread, and the WCAG contrast ratio, measured and never judged (a field that cannot be measured is null). Checked on 16 rows of known colours rendered by Chrome at two scales, then on a **real screenshot of the StzZui home page**: 25 lines, 22 contrast passes, 3 fails, the three (the pink hero title) confirmed independently from the pixels at 3.99:1; four words misread and three code-block marks missed, listed in the mailbox. Two findings were routed to stzzui (text over stripes is not detected; a gradient can pass the spread limit while 46% of a line is below 4.5:1) and a third (large text has a 3:1 bar) after the real run.

## 8. What is open, and what is not claimed

- **Unperceived.** The two page reports (`_ocr_look/im7_docvlm.html` for golden v1, `im7_docvlm_v2.html` for the fresh set) were made and shown; **nobody has given a verdict on them.** Unperceived is a state, not a pass.
- **Four generation guards cannot run under Ring++** (`constrained_decoding`, `llmfunction`, `structuredoutput`, `schema_grammar`: a bare global `nPass` in `chk()`, Rule A). They are owned, not run, before and after the decoder change; the logits they mask are unchanged.
- **Closed on the author's word:** a better heading rule for the combination (the model alone is chosen and wins headings), and a wider loop stop for Granite-Docling's repetition loops (3 of 27 pages still loop to the 2048-token cap; reopen when something reads pages in bulk, with a golden set of its own).
- **The combination `native-plus-granite` is built and not chosen:** it beats the floor and was never worse than it, but Granite-Docling alone wins on the registered rule.
- **Not built, named:** WebP and TIFF (a baseline TIFF reader when a scanner brings one), Florence-2 (an encoder-decoder the decoder does not run), a GPU path for the classical operations (never measured as a cost), Granite-Docling beyond English.
- **The GPU tower's speed-up is conditional** on the GPU not being shared (2.6 to 3.5 times free, 1.1 to 1.9 shared). Its accuracy gain is not.

## 9. How to verify (the gates)

Ring is retired: run Ring code with `D:\GitHub\ringpp\zig-out\bin\rnxc.exe`, from the test's own folder. The engine DLLs for `rnxc` are a Ring++ copy (`bench/engine_copy.py`). Models are in `models/vision/` (gitignored, sha256 in `MODELS.md`); the golden pages and Hugging Face reference fixtures live in `D:\GitHub\_wti_models_src\` (a guard that does not find them says so and is skipped by name). **One neural job on the GPU at a time.**

| guard | asserts | assertions |
|---|---|---|
| `base/test/image/image_core_narrated` | handles, three forms, channels, geometry | 47 |
| `image_ops_narrated` | the analyses, pixel-exact against OpenCV | 29 |
| `image_geom_narrated` | warps, contours, a flattened page read by OCR | 29 |
| `image_vision_narrated` | four models equal onnxruntime; the door records every call | 21 |
| `image_faculties_narrated` | the faculties judged on COCO | 16 |
| `image_search_narrated` | SigLIP2 equals the reference; search over 118 pictures | 21 |
| `image_dense_narrated` | U²-Net-p and Depth-Anything equal the reference; `:foreground` | 16 |
| `image_promptable_narrated` | MobileSAM equals the export; `:object-at` and `:depth` judged | 25 |
| `image_describe_narrated` | SmolVLM against Hugging Face's own code; `:describe` on 99 COCO pictures | 32 |
| `image_docvlm_narrated` | Granite-Docling's tiling, tokens, rows and words against Hugging Face; the parser; the scorer against `_doc_score.py`; `:doc-vlm` on 27 fresh pages | 55 |
| `image_gpu_tower_narrated` | the GPU tower equals the CPU graph and Hugging Face's, and is faster at its best round | 13 |
| `base/test/neural/decode_cache_narrated` | the decoder's text is byte-identical to before the cache change; the pool and phases are flat in the context | 9 |
| `base/test/ocr/screenshot_facts_narrated` | the facts writer on known colours | 26 |

## 10. Where things are

`base/image/` (`stzImage`, `stzImageGrid`, `stzImageSearch`, `stzVision`, `stzDocTags`, `vision.zmdl.txt`: the measurements), `base/ocr/stzScreenshotFacts.ring`, `engine/src/` (the modules of section 4), `models/MODELS.md`, `base/test/image/` (guards, `_golden/` golden sets, `_rig/` the instruments and references, `results/` the stored predictions), `base/test/neural/_data/decode_equiv_expected.txt` (the old decoder's greedy text), and this plan's `SOFTANZA_IMAGE_INTELLIGENCE.md` for every number in full.

| rung | commit on `main` |
|---|---|
| IM0 `stz_image`, `stzImage`, `stzImageGrid` and the plan | `e10c34f24` |
| IM1 analyses, pixel-exact; IM1b one image core | `926eff328`, `9ea98f6ff` |
| IM2 warps, contours, a flattened page read | `5cd31cf0c` |
| IM3 classify, faces, objects; the governed door | `8a01081ea` |
| IM4 the faculties earned, YuNet's threshold | `b72976aa9`, `b516fc931` |
| IM5 SigLIP2: pictures and words in one space | `59f5b9255` |
| IM6 salient masks, depth, MobileSAM; the router fix | `aad421d53`, `446dc671f` |
| the screenshot facts writer | `74b964f78` |
| IM7 SmolVLM; Granite-Docling and its fresh verdict | `10feb5ca6`, `401d00b6d`, `0e14ab08c` |
| IM8a the tower on the GPU | `90f2c01b0` |
| IM8b the decoder's flat step | `fc5f8e88b` |
