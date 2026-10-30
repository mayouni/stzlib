# OCR for Softanza -- a decision memo, and the plan it decides

**Status**: DECISION MEMO, v0.1 · **Date**: 2026-10-30 · **Plane**: stzlib-intelligence · **Builds nothing yet; names what to build.**
**Ref read**: `intelligence/model-flow-pub` @ a7b0f511a (the PDF reader closed, memo section 8 of `SOFTANZA_DOCUMENT_INTELLIGENCE_MEMO.md`).
**Why now**: the first real-world file the author handed the closed reader was an iOS scan -- one image, no text layer -- and the reader returned 0 glyphs, as its closing memo (8.4) said it would. OCR is the ingestion half the reader does not have.
**Evidence**: everything in section 2 was MEASURED today on this machine; everything in section 3 was READ from the model files with `onnx` 1.23; claims tagged `[inferred]` or `[listed]` were not run. Nothing here was judged by a person yet (section 7).
**Machine**: the laptop of the PDF reader memo, CPU only; Windows 11 with the `fr-FR` and `ar-SA` OCR language packs installed and **no `en-US` pack**.

---

## 0. The decision, first

1. **OCR is a faculty, `:ocr`, declared in library code like `:letterhead` is** (`StzPdfDeclareLetterhead`): input `:image`, output `:text` (later `:document`), a floor, zero or more implementations, a golden set the floor runs first. Domain folder `base/ocr/`, entry object `stzOcr`, entry `StzOcrQ(path)` (LAW 1).
2. **The floor is the platform engine where there is one** -- `Windows.Media.Ocr` -- **with a bidi reorder of right-to-left lines**, and it **refuses elsewhere, naming the missing language pack or platform** (design 4.2: a floor that says "I cannot" is a valid floor). Measured: on clean rendered pages it reads French and English (with the French pack) to 1.00 of the key sentences in 60-120 ms a page; Arabic comes back in visual order and the reorder lifts it from 0.00 to 0.62 of the sentences and 1.00 of the headings; Russian is 0.00 because no Cyrillic pack is installed. It is reached first through a process bridge (0.4 s per call, measured), and through WinRT from Zig only if that cost is ever paid in practice.
3. **The model implementation is PP-OCR small, ported to the engine as GGUF and run by `stz_neural` on ggml**: a detector of 2.45 M parameters, a recogniser of 5.27 M, an orientation classifier of 0.6 M, Apache-2.0, **every operator already in the vendored ggml**. It is the sovereign path: no language pack, no platform, no Python, same answer on every OS. It reads Latin, Greek, Japanese and Chinese with the dictionary it ships; Arabic, Cyrillic, Devanagari, Korean and others come from the per-script recognisers RapidOCR lists `[listed]`, same architecture, another head and dictionary, converted the same way.
4. **LAW 2 decides between them per machine, by measurement, never by preference.** On this Windows machine with its two packs the model will not beat the floor on clean Latin or Arabic pages (the floor is at 1.00); it beats it wherever the floor refuses -- Linux, an absent pack, a language the packs do not cover -- because a refusal scores 0 on the quality goldens. The registry already represents that.
5. **OCR output enters the PDF reader's layout stage as fragments** (lines with boxes), so the headings, lists, tables and furniture rules of thirty-four rounds apply to scans unchanged, and a scanned page yields the same `stzDocument` as a born-digital one. That is the slice that makes OCR a document capability rather than a text dump.
6. **Not Docling for OCR** (12.8 s on the scan where the floor takes 50 ms; Python and PyTorch on the user's machine -- legitimate only as a pinned `:service`, never implicit). **Not Tesseract** (C++ with static initialisers, the class the engine's DLLs cannot run, `vendor/ggml/NOTICE`). **Not the document VLM first** (Granite-Docling stays the second model, behind a measured OCR floor, as the Docling memo ruled).

---

## 1. What exists today `[code]`

| piece | where | state |
|---|---|---|
| the PDF reader | `engine/src/pdf.zig`, `stzPdf` | closed at f6391819c; returns 0 blocks on a page with no text layer; `HasText()` says so |
| image decode | `stz_gpu` (vendored stb, memory only, RGBA8 out: PNG/JPEG/BMP) | reachable from Ring as `stzenginegpuimagedecode` |
| image XObjects in a PDF | `pdf.zig` `doXObject` | **Form XObjects only**; an image stream is skipped. The author's scan is one image: 1660 x 2338, 8-bit RGB (ICC), **Flate** -- the vendored zlib inflates it; a JPEG (DCT) one would go through stb |
| ggml in the engine | `stz_neural` (`neural_embed.zig`, `neural_gen.zig`, `neural_backbone.zig`) | BERT and llama graphs run; GGUF loads by tensor name; the ctor-independent patches hold |
| the operators PP-OCR needs | `vendor/ggml/include/ggml.h` | `conv_2d`, `conv_2d_dw`, `conv_transpose_2d_p0`, `pool_2d`, `interpolate`, `hardsigmoid`, `hardswish`, `sigmoid`, `gelu_erf`, `norm`, `mul_mat`, `soft_max`: **all present** |
| a GGUF writer | `base/test/neural/tools/gen_tiny_bert.py` (`write_gguf`, struct + numpy, no package) | reusable by the ONNX-to-GGUF converter |
| the faculty contract | `base/faculty/` (`stzFaculty`, `stzModelRegistry`, `stzParcel`, `stzRequirement`), payload type `image` in the closed vocabulary | the `:letterhead` faculty in `base/file/stzPdfLetterhead.ring` is the shape to copy |
| a golden checker fit for OCR | `StzGoldenAgrees("contains", got, expected)`: the expected text found inside the answer, case-folded | one golden = (page image, one key sentence); the faculty's score = the share found, which IS the reader memo's `text` measure |
| the platform OCR | `Windows.Media.Ocr` through WinRT; packs here `fr-FR`, `ar-SA`; max image side 10 000 | measured once in the Docling memo (section 2); today measured on whole documents, below |
| a page rasteriser | none in the engine; `pypdfium2` in the Docling scratch environment | the oracle renderer for the golden set, as Docling is the oracle reader (0.05-0.11 s a page at 200 dpi) |

---

## 2. Measured today

Four documents from the goldens (their expected structure written by independent authors who never saw a reader), rendered at 200 dpi (1654 x 2339), **every page**, each engine once. The scorer is `base/test/ocr/_rig/ocr_score.py`: `text` = share of the expected key sentences found verbatim (whitespace collapsed, NFC) in the OCR text, the reader memo's measure; `headings` = share of expected headings found; `cells` = share of expected table cells found anywhere; `words` = share of expected words present. Floor = `Windows.Media.Ocr` through `winocr.ps1` (one PowerShell process per call). RapidOCR = PP-OCRv6 small detector + recogniser and the v2.0 classifier, the files Docling ships, through onnxruntime 1.31 on CPU.

| document | language, pages | floor text / headings / cells / words | floor ms per page | RapidOCR text / headings / cells / words | RapidOCR s per page |
|---|---|---|---|---|---|
| z09 bus leaflet (v36) | fr, 2 | **1.00 / 1.00 / 0.97 / 0.99** | 61 | 1.00 / 1.00 / 0.94 / 0.97 | 2.9 |
| z01 electricity bill (v36) | en, 2 (read with the fr-FR engine: no en-US pack) | **1.00 / 1.00 / 0.93 / 0.98** | 72 | 0.71 / 1.00 / 1.00 / 0.95 | 3.0 |
| y11 insurance summary (v35) | ar, 2 | 0.00 / 0.30 / 0.44 / 0.96 as returned; **0.62 / 1.00 / 0.85 / 0.96 after reversing each line's words** | 264 | 0.00 / 0.00 / 0.33 / 0.08 (no Arabic in its dictionary) | 2.5 |
| u06 (v33) | ru, 3 | 0.00 / 0.00 / 0.57 / 0.19 (no Cyrillic pack) | 118 | 0.00 / 0.00 / 0.61 / 0.19 (no Cyrillic in its dictionary) | 2.9 |

What the table says:
- **On a clean page in a language it has, the platform floor is at the ceiling of this measure** and forty times faster than RapidOCR on CPU through Python. The engine port (section 3) changes the second number, not the first.
- **The floor's Arabic is right and in the wrong order**: 0.96 of the words are there; the sentences fail because each line comes back visually, right to left read as left to right. A naive per-line word reversal already gives 0.62 / 1.00; a proper bidi reorder (runs of digits and Latin kept, the reader's `arabicLogical` exists) will give more. This is the cheapest large gain in the plan.
- **Each engine has a language hole the other does not**: the floor reads what packs are installed (here no English, no Russian); RapidOCR's shipped dictionary has no Arabic, Cyrillic, Hebrew, Devanagari, Thai or Hangul. Neither alone covers the author's own three scripts. The faculty's `Languages` field and the registry's `RequireLanguages` are what route around the holes.
- **The process bridge costs 0.4 s a call** (PowerShell start plus WinRT load), the recognition 50-280 ms. A document of ten pages is 5 s through the bridge, 1 s through WinRT from Zig. That is the only reason the Zig WinRT path (slice O5) exists, and it waits for a measured need.

**The author's scan** (iOS, one page, Flate RGB): floor 18 lines, 124 words, 50 ms; RapidOCR 20 boxes, 2.0 s; Docling 2.141 with RapidOCR forced on the whole page 12.8 s. The three agree on the title and the body; nobody has read the three texts against the paper yet (section 7). The scan and its text stay out of the repository.

---

## 3. The candidate model, read from its files `[code]`

| | detector `PP-OCRv6_det_small` | recogniser `PP-OCRv6_rec_small` | classifier `ch_ppocr_mobile_v2.0_cls` |
|---|---|---|---|
| parameters | 2 453 416 (f32) | 5 267 734, of which 2 245 200 in the output head | ~0.6 M (weights in `Constant` nodes, no initialisers) |
| nodes | 464, opset 11 | 480, opset 11 | 566 |
| structure | 83 convolutions (17 depthwise, groups > 1), SE blocks (8 global pools + 13 HardSigmoid), GELU-erf x 13, an FPN of three nearest x 2 resizes and two concats, a DB head of two transposed convolutions (24->24->1), sigmoid out | 57 convolutions (14 depthwise) to a height-1 sequence, then an SVTR mixer of width 120: two attention blocks (qkv 120->360, projection 120->120, FFN 120->240->120, softmax x 3) with LayerNorm written as ReduceMean / Pow / Sqrt, then a 120 x 18 710 head; CTC over 18 708 classes | a small MobileNet to 2 classes (0 / 180 degrees) |
| input | `[1, 3, H, W]`, H and W multiples of 32, longest side limited to 736-2000, normalised (x / 255 - 0.5) / 0.5 | `[N, 3, 48, W]`, crops resized to height 48, width kept, batches of 6 | `[N, 3, 48, 192]` |
| post-process | threshold 0.3 on the probability map, boxes from the connected components, box score >= 0.5, unclip ratio 1.6, dilation on | greedy CTC: argmax per step, collapse repeats, drop blank 0; text score 0.5 | flip when p(180) >= 0.9 |
| dictionary | -- | 18 708 classes: Latin 94, Latin-1 93, Latin extended 336, Greek 76, kana 180, CJK 15 565; **no Cyrillic, Arabic, Hebrew, Devanagari, Thai, Hangul** | -- |
| ggml | every operator present (section 1) | every operator present; the mixer is the BERT block the engine already runs | every operator present |
| licence | Apache-2.0 (PaddleOCR, RapidOCR) | same | same |

Per-script recognisers in RapidOCR's own registry `[listed, not fetched]`: `arabic_PP-OCRv4/v5_rec_mobile`, `cyrillic_PP-OCRv3/v5`, `latin_PP-OCRv3/v5`, `devanagari_PP-OCRv4/v5`, `korean_PP-OCRv4/v5`, `japan_PP-OCRv4`, `ka`, `ta`, `te`, `eslav_PP-OCRv5`; detectors `multi_PP-OCRv6_det_tiny/small/medium`. The same converter and the same Zig graph serve all of them: a recogniser differs by its head size and dictionary.

**Port cost, honestly**: the detector and classifier are plain convolutional graphs (a day each once the first conv block is right); the recogniser's mixer is the engine's attention block with a different normalisation (a day); the DB post-process (binarise, components, polygon unclip) and the crop pipeline (perspective crop of a rotated box to height 48) are Zig code with no model (two days); the converter is a script. The risk is not the operators, it is **the parity check**: as with `tiny_bert.gguf`, each graph gets a numeric comparison against onnxruntime on the same input before any OCR quality is claimed. Two to four sessions.

---

## 4. Options compared

| | (i) platform floor + bidi | (ii) PP-OCR small on ggml | (iii) Tesseract vendored | (iv) Docling / RapidOCR as a `:service` | (v) Granite-Docling VLM |
|---|---|---|---|---|---|
| measured here | 1.00 fr/en, 0.62 ar (after reorder), 0.00 without a pack; 60-280 ms | 1.00 fr, 0.71 en, 0.00 ar/ru; 2.5-3.0 s on CPU through Python | not run | 12.8 s on the scan | not run |
| dependency | the OS and its packs | a 35 MB GGUF per script set; none else | a C++ library the DLLs cannot host | Python, PyTorch on the user's machine | a 258 M GGUF, a vision tower not built |
| sovereignty | Windows only, and only the packs the user installed | full | full | none | full |
| engine work | small (bridge), then optional (WinRT in Zig) | medium: section 3 | refused | an HTTP client faculty | large: the Docling memo section 4 |
| LAW 2 | the floor | the model that beats the floor where the floor refuses | -- | never implicit | second, behind a measured floor |

**Chosen: (i) now, (ii) next, in that order**, because (i) is measured at the ceiling where it works and costs a session, and (ii) is what makes the result the same on every machine -- which is the promise `UseFloorEverywhere()` and the flow make.

---

## 5. The faculty, as it will be declared

```ring
func StzOcrDeclare()
	_o_ = StzFacultyQ(:ocr)
	_o_.SetInputTypeQ(:image).SetOutputTypeQ(:text).SetParamsQ([ :lang = "" ]).
	    SetFloorQ("platform", "_StzOcrFloor").SetGoldenCheckerQ("contains").SetGoldenVersionQ("v1")
	_o_.AddImplementation([ :id = "pp-ocr-small", :kind = "model", :fn = "_StzOcrModel",
	    :languages = [ "la", "el", "ja", "zh" ], :memory = 40, :licence = "Apache-2.0", :deterministic = 1 ])
	# goldens: one per key sentence of a rendered golden page -- (image path, sentence)
```

- `_StzOcrFloor(image, params)`: the platform engine for `params[:lang]` (or the page's script when empty), lines joined by spaces, right-to-left lines put in logical order; on any machine or language it cannot serve it returns the refusal parcel that names the pack or platform missing -- and that refusal is what the registry measures as 0.
- `_StzOcrModel(image, params)`: `StzEngineNeuralOcr(rgba, w, h)` once slice O3 exists; until then it is not declared (an unmeasured implementation is never selected: design 9.2).
- `stzPdf`: `PageImages()` (slice O2) and, when `HasText()` is 0, `Blocks()` built from the `:ocr` lines through the reader's layout (slice O4). The flow is `bytes -> pages -> (text layer | image -> :ocr) -> fragments -> blocks -> stzDocument`.

---

## 6. The slices

| slice | what | where | size | proof |
|---|---|---|---|---|
| **O1** | `base/ocr/`: `stzOcr` entry, the platform floor through the bridge, the bidi reorder, `StzOcrDeclare`, the golden set from rendered golden pages (four documents today, twenty-four later), the scorer, the measurement filed in the faculty's results, a narrated guard under Ring++ that skips (and says so) where a pack is absent | Ring; `_rig` scripts kept | one session | the four documents above re-measured through the faculty; Arabic >= 0.62 after the reorder |
| **O2** | image XObjects out of a PDF: `pdf.zig` lists them (page, box, size, bits, colour space, filter) and inflates Flate; `stzPdf.PageImages()`; DCT through `stz_gpu`'s stb; the author's scan goes end to end: PDF -> image -> `:ocr` -> text | Zig + Ring | small | the scan returns its text from `StzPdfQ(path)` |
| **O3** | the port: `tools/onnx_to_gguf.py` (the `write_gguf` of `gen_tiny_bert.py`), `engine/src/ocr.zig` in `stz_neural` -- detector graph + DB post-process, classifier, recogniser graph + CTC, crops to height 48; parity of each graph against onnxruntime on a fixed input; `StzEngineNeuralOcr` | Zig + a Python tool run once | two to four sessions | numeric parity within a stated band; the golden set scored; the model beats the floor where the floor refuses and nowhere else is it selected |
| **O4** | OCR lines as reader fragments: `stzDocument` from a scan with headings, lists, tables, furniture by the reader's rules | Zig | medium | the scan's blocks compared with a born-digital twin of the same page |
| **O5** | the floor through WinRT from Zig (no process) | Zig | medium | only when the 0.4 s bridge is measured to matter |

Order: O1, O2, then O3; O4 after O3 has a parity; O5 never unless measured.

**O1 DONE (2026-10-30, the same day):** `base/ocr/stzOcr.ring` -- `StzOcrDeclare`, the platform floor through an embedded bridge (written once to the temp folder), `StzOcrLogicalLineXT(line, dir)` with the direction taken from the language pack's script and `StzOcrLogicalLine` guessing it, the `stzOcr` entry object (`StzOcrQ`, `StzOcrText`), `StzOcrPlatformLanguages`; loaded by `stzBase.ring`. Golden set v1: 17 items (the key sentences of z09 in French and y11 in Arabic over their pages rendered at 150 dpi greyscale, `base/test/ocr/_data/`, 60-80 KB each, generated by `goldens_v1.ring` from the documents' expected.json). Guard `base/test/ocr/ocr_narrated.ring`: **24 of 24 under Ring++**; the registry measured the floor at **0.82 over 17** (French 9 of 9, Arabic 5 of 8 in logical order -- the platform's visual order was the whole loss), filed in `base/test/ocr/results/ocr.zmdl.txt`. A scene the machine cannot run is skipped by name; a language with no pack is a refusal that names it. Not changed: the memo's numbers above (200 dpi, the scratch rig); the floor at 150 dpi reads the same sentences.

**O2 DONE (2026-10-30):** `pdf.zig` records every image XObject a page draws, with the box it lands in (the unit square under the content stream's matrix), and hands each out in one of three kinds: **samples** -- 8-bit channels decoded by the engine from Flate (1, 2, 4, 8, 16 bits; DeviceGray/RGB/CMYK, CalGray/CalRGB, ICCBased by N, Indexed through its palette, ImageMask, Decode [1 0] inverted); **jpeg** -- a DCTDecode stream's bytes as they are (a JPEG file already); **unsupported** -- JPX, CCITT, JBIG2, named so, never a wrong picture. The bridge adds `StzEnginePdfImages()` and `StzEnginePdfImageSave(n, path)` (a 24-bit BMP of the samples, or the JPEG bytes). `stzPdf` gets `PageImages()`, `NumberOfImages()`, `HasImages()`, `IsScanned()` (images and no text layer), `SaveImage(n, pathBase)` (".bmp" or ".jpg" added), `PageImageFile(page)`, `Ocr(lang)` (a `stzOcr` over the pages' images through the `:ocr` faculty) and `TextOrOcr(lang)`. Not through `stz_gpu`'s stb as the row above said: the platform floor reads a file, so decoding a JPEG to pixels buys nothing today; it is O3's concern, where the model wants pixels. Fixtures: two synthetic scans of golden_v36/z09 page 1 in `base/test/ocr/_data/` -- `scan_flate_gray.pdf` (DeviceGray Flate, 73 KB) and `scan_dct_rgb.pdf` (DeviceRGB DCT, 164 KB), made by `_rig/_make_scan_pdfs.py`; the reader finds 0 glyphs and one 1241x1754 image in each. Guard `ocr_narrated.ring` **40 of 40 under Ring++** (two new scenes: the images handed out and saved; a scan end to end through `TextOrOcr("fr-FR")`, with a born-digital PDF keeping its text layer). Reader guard 285 of 285. **The reader is unchanged: the A/B rig scored HEAD's `pdf.zig` and this one over all 36 golden sets, 7 measures each, 0 differences.** The author's own scan (one Flate RGB image, 1660x2338): `StzPdfQ(path).TextOrOcr("fr-FR")` returns 877 characters in 0.9 s -- the attestation's title, body and closing read whole; the letterhead's small print and the stamp come out as noise. Its text stays local and is **unperceived** (the author has not read it against the paper).

---

## 7. Verified vs not verified

**Measured today** (this machine, CPU, once each): everything in section 2; the model files' structure in section 3; `pypdfium2` render time; the bridge's 0.4 s.
**Read, not run**: the per-script recognisers (names from RapidOCR's `default_models.yaml`, 141 entries; licence assumed the same as the family's); PaddleOCR's post-process constants (from RapidOCR's `config.yaml`).
**Not verified**: that any ggml graph reproduces onnxruntime (that is O3's first proof, not an assumption); OCR on degraded pages (skew, noise, JPEG, low dpi) -- no golden has any; the Linux refusal path; Docling's OCR on golden pages (run on the scan only); the quality of the three texts of the scan against the paper -- **unperceived until the author reads them**, which the perception rule requires before any "it reads my scan" sentence is written.
**Not tools-checkable here**: Tesseract's quality (not installed, not vendorable); the VLM's.

Instruments: `base/test/ocr/_rig/` (`winocr.ps1` the platform floor, `run_win2.ps1`, `_render_pages.py` the oracle renderer, `ocr_score.py` the scorer, `_rapid_pages.py` the RapidOCR reference run) and the outputs of both engines on the four documents in `base/test/ocr/results/ocr_v0/`.
