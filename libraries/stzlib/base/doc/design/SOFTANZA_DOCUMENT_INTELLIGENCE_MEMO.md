# Document intelligence for Softanza — a decision memo on Docling

**Status**: DECISION MEMO, v0.1 · **Date**: 2026-10-21 · **Plane**: stzlib-intelligence · **Builds nothing.**
**Ref read**: `intelligence/model-flow` @ `main` a6a59d4f6 + engine commits 2f5dd6c33, 9c7514fc4, 13ea45735 (not `origin/main`, which has diverged).
**Evidence**: Docling's repo, documentation, technical reports and model cards, read 2026-10-21 by a research pass and **spot-checked by the author of this memo** (licences and parameter counts for Granite-Docling, the layout model, Indra and Qwen3 re-fetched live). Every claim is tagged `[page]`, `[repo]`, `[card]`, `[paper]`, `[code]` (read in this tree) or `[inferred]`. Anything not verified is in §7.
**Machine**: NVIDIA GeForce RTX 3050 6GB Laptop GPU, driver 561.00; a CPU the firmware often throttles (read `% Processor Performance` before quoting any time).

---

## 0. The decision, first

1. **Do not adopt Docling as a dependency.** It cannot ship on Softanza's path: every model stage runs through PyTorch, transformers or onnxruntime `[repo]`, and the serve image is 4.4–11.4 GB `[docs]`. It is legitimate as an **optional external faculty** for people who already have it — never implicit (LAW 2).
2. **Build the floor first, and the floor is not a model: a native PDF text-layer reader plus layout heuristics.** Softanza has no PDF code at all `[code]`. A born-digital PDF needs a parser, not a neural net.
3. **The best native model lever is Granite-Docling-258M** (Apache-2.0, a 165M llama-architecture decoder + a SigLIP2 vision tower, official GGUF published): its decoder is the family `neural_gen.zig` already runs; the vision tower and an embedding-prefill entry point are what is missing. It comes **second**, behind the floor, and only if it beats the floor on a golden page set.
4. **The RTX 3050 is an accelerator for the VLM and the encoders, never a requirement.** The route is Softanza's own wgpu plane, not a vendored CUDA runtime.
5. **Nothing here has been measured against a floor, because no floor exists yet.** §6 says what can and cannot be measured today.

---

## 1. Docling's real architecture

### 1.1 What the page said — and did not
The page `docling.ai/blog/20261016_00_docling-on-nvidia-rtx-spark/` `[page]` is a launch note dated 16 Oct 2026, no author. Every claim in the prior summary is on it: PDF/DOCX/PPTX/scanned images → structured Markdown/JSON preserving layout, tables, headings, reading order; GPU-accelerated OCR, layout, table-structure and VLM backends; a CUDA build of PyTorch is "all it takes"; local agent stacks pair it with Ollama/LM Studio/vLLM and expose a usage skill and an MCP server; the same API targets a local install, `docling-serve`, or IBM watsonx. **It names no model, no number, no licence.** It is marketing for a Python + PyTorch stack. Everything below came from the repository, the docs, the papers and the model cards.

### 1.2 Project facts
Docling is **MIT** `[repo]`; v2.141.0 released 2026-10-20. `docling-parse`, `docling-ibm-models`, `docling-serve` and `docling-mcp` are MIT `[repo]`. It is a Python package; torch and `docling-ibm-models` are optional extras `[repo: pyproject]`.

### 1.3 Pipelines and the model behind each stage

| Pipeline / stage | Model | Licence `[card]` | Size | Runtime |
|---|---|---|---|---|
| PDF parser backend | `docling-parse` (C++20, CMake) / pypdfium2 | MIT | ~1.8 MB C++ source, ~10 sub-dependencies (qpdf, libjpeg, openjpeg, lcms2, freetype, blend2d, pdfium_jbig2, utf8, nlohmann json, loguru, cxxopts) `[repo]` | native, pybind11 |
| Layout | `docling-layout-heron` — **RT-DETRv2**, 640×640 input, 17 classes | **Apache-2.0** (re-fetched live) | **42,889,979 params** (re-fetched live); official ONNX 171 MB | PyTorch / ONNX |
| Table structure | **TableFormer** v1 (`ds4sd/docling-models`): ResNet-18 backbone at 448 px, 6-layer encoder + 6-layer decoder, 8 heads, hidden 512, bbox head | two tags on the card (cdla-permissive-2.0 **and** apache-2.0) with no statement of which applies to which file | accurate 213 MB, fast 145 MB (F32) | PyTorch |
| OCR | `OcrAutoOptions`: RapidOCR / EasyOCR / Tesseract / others | RapidOCR Apache-2.0 (ONNX models); Tesseract Apache-2.0; EasyOCR is the slow one (30+ s/page on CPU `[paper]`) | not stated on any page read | ONNX / PyTorch / native |
| VLM pipeline | **Granite-Docling-258M** (Idefics3: SigLIP2 vision tower of 12 layers + a 30-layer llama decoder, hidden 576, 9 heads, 3 KV heads), output **DocTags** | **Apache-2.0** (re-fetched live) | 257,517,120 BF16 params (re-fetched live); 515 MB BF16; **official GGUF: BF16 332 MB + 190 MB projector** | transformers / MLX / vLLM / Ollama / LM Studio / llama.cpp |
| (older VLM) | SmolDocling-256M | the card gives conflicting licences | — | — |
| Simple pipelines | DOCX/PPTX/XLSX/HTML/Markdown/CSV | — | — | no neural model: zip + XML |

Formats in: PDF, DOCX, PPTX, XLSX, HTML, Markdown, CSV, images (and an ASR pipeline). Formats out: the `DoclingDocument` JSON, Markdown, HTML, DocTags, text `[docs]`.

### 1.4 Cost
Published numbers exist only for the Python stack `[paper/docs]`: **1.27 pages/s on an M3 Max and 0.60 on a Xeon E5-2690** (native backend, no OCR); a GPU guide gives **4.2 pages/s on an RTX 5070 against 1.2 CPU-only** on the same machine, and Granite-Docling through a server 2.0 pages/s on the 5070. **There are no VRAM figures, no RTX 3050 figures and no CPU VLM figures.** I am not estimating them. The VLM's cost is driven by decode length: Docling's defaults allow 4,096 new tokens per page `[docs]`.

### 1.5 `docling-serve`, the MCP server and the skill
`docling-serve` is a REST API (convert source/file, async tasks); the MCP server and usage skill expose the same. It is a process you run — Docker or a Python environment — and a **service call** in Softanza's governance vocabulary (capability `sensing`, posture `:local` or `:live`).

---

## 2. What Softanza has for documents today `[code]`

| Capability | Present | Absent |
|---|---|---|
| Files, zip | file ops; `stzZipFile` — **extracts to disk only** | in-memory entry reads |
| XML / HTML | XML parser with exclusive C14N and query paths; an HTML DOM; markdown handling | OOXML (DOCX/PPTX/XLSX) *readers* — only the pieces |
| **PDF** | **nothing** — a `grep` for pdf finds a router keyword list, a Unicode bidi class name and a polyglot example | reader, renderer, generator |
| Images | stb decode vendored, **used only inside `gpu_render.zig`** | analysis: no thresholding, morphology, connected components |
| OCR | none in-engine. **Measured platform floor:** `Windows.Media.Ocr` — French exact on a rendered 2-line PNG (9 words, 10 ms, with boxes); Arabic: second word exact, first word split at a shaping gap, and returned in visual order. Not wired to any class | OCR faculty |
| Tables | `stzTable` (~2,500 definitions), pivots, columnar engine | table *recognition* from an image or a PDF |
| Text | the linguistic tier, C9 structured output, `stzLLMFunction`, semantic index | — |
| Producing documents | `stzCanvas`, SVG, plots, diagrams, text shaping incl. Arabic | — |
| Neural | decoders llama/qwen2/qwen3/smollm, BERT encoders, reranker, NER head, GBNF constrained decoding; one model slot | vision tower, audio encoder, **a decoder entry that takes embeddings**, cross-attention, beam search |

**The honest summary**: Softanza is strong at *producing* documents and at everything *downstream* of text (C9 extraction, summaries, retrieval). It has **no way to get text out of a PDF or an image**. The ingestion half is a void, not a weak floor.

---

## 3. The constraint, and the options compared

The constraint: the shipped path has **no Python and no PyTorch**; the engine is Zig with a vendored **CPU** ggml; a GPU may help but must never be required. The vendored ggml already compiles the conv, pool, upsample, group-norm, `gelu_erf`, `flash_attn_ext` and window ops `[code]` — so a missing capability is **missing graph code in Zig, not a missing kernel.**

| | (i) native pipeline in the engine | (ii) a document VLM as a GGUF through the engine | (iii) Docling / `docling-serve` as an optional external faculty | (iv) hybrid |
|---|---|---|---|---|
| **What** | PDF reader → layout → table → OCR, each stage native | Granite-Docling-258M end-to-end: page image → DocTags | a `:service` implementation behind the flow's port, with the floor beneath | native PDF text-layer **floor**; VLM and Docling as *measured* upgrades |
| **Engine work** | very large: see §4 | medium: vision tower, embedding-prefill entry point, preprocessing, DocTags converter | small: an HTTP client faculty (the engine has libcurl/mbedTLS) | the sum of the floor + (ii) |
| **Risk** | high — PDF parsing, deformable attention, TableFormer post-processing | medium — it is checkable token-by-token against llama.cpp | low technically; **LAW 2 posture**: external, optional, never implicit | medium, staged |
| **Dependency** | none | none beyond the GGUF (Apache-2.0) | Python + PyTorch (+ optional CUDA) on the *user's* machine | none for the floor |
| **RTX 3050 role** | optional accelerator for detector/tower prefill | prefill of the ViT (compute-bound) benefits; decode of 165M is cheap on CPU | whatever the user's PyTorch does; this machine would use CUDA PyTorch | optional |
| **Sovereignty / offline** | full | full | the *service* is local, but the install is not Softanza's | full for the floor |
| **When it wins** | the long run | scanned/complex pages once the floor exists | users who already run Docling; a ground-truth oracle for our golden sets | now |

### 3.1 Governance posture of (iii)
A Docling call is **`sensing`**, not `inference`: it is a process or endpoint outside the engine. It is a `:service` implementation (design §4.1): **never selected implicitly**, only when pinned by name, posture declared, budget mandatory, its parcel a *proposal* that a gate or rule admits. Its output validates through the same `:document` court as any other implementation's.

---

## 4. Which stages are feasible natively (with ggml on CPU) `[repo/code/inferred]`

| Stage | Reference | What the engine lacks | Effort / risk |
|---|---|---|---|
| **PDF text/glyph/cell extraction** | `docling-parse` (MIT, C++20, ~10 deps) — **not vendorable safely**: the engine's `vendor/ggml/NOTICE` records that C++ static constructors **do not run** in its Windows DLLs, and this code is C++20 with exceptions and statics | a **native Zig PDF reader**: xref + object streams, Flate (zlib is vendored), a content-stream interpreter with text/graphics state, fonts (simple, ToUnicode, CID, embedded programs for widths), output as positioned chars → words → lines | **large / high**, but dependency-free, **and testable against docling-parse as an oracle** |
| Page → bitmap (for the 640×640 layout input and for scans) | pdfium in Docling | a rasteriser over outlines/paths, or reuse of the canvas stack; JPX/JBIG2/CCITT decoders for scanned PDFs (stb has none) | large |
| **Layout (RT-DETRv2, 42.9M)** | HF `RTDetrV2` | conv backbone ✔ in ggml; hybrid encoder ✔ (attention); the **deformable cross-attention sampling** (`grid_sample`) — the paper's *discrete* decoder method reduces it to gathers; box decode glue; a converter | medium–large / medium |
| **TableFormer** | `docling-ibm-models` (MIT) | cross-attention over image features, beam search, a bbox head, OTSL→table post-processing (Python, to be ported by hand) | medium–large / medium (decoder wiring unverified) |
| **OCR** | RapidOCR (Apache, ONNX) / Tesseract (Apache, C++) | RapidOCR: DB detection + CTC recognition — convs mostly in ggml, plus a polygon post-process; Tesseract: C++ static-init risk, large | medium / medium |
| **Document VLM** | Granite-Docling-258M | the **SigLIP2 tower** (12 layers, hidden 768, patch 16, a strided-conv patch embed — closest existing code is the BERT-style encoder in `neural_embed.zig`), a pixel-shuffle connector, image tiling/normalisation, **a decoder entry that accepts embeddings** (today it takes token ids only: `ggml_get_rows(token_embd, tokens)`), and DocTags conversion | **medium / medium** |
| OOXML (DOCX/PPTX/XLSX) | zip + XML | an in-memory zip reader + a structure builder; **no model** | small–medium / low |

Risk order, highest first: native PDF parsing → Tesseract vendoring → TableFormer post-processing → deformable sampling → VLM tower → OOXML.

**An asset worth stating**: the engine's constrained decoder (`gbnf_machine.zig`) can constrain a VLM's output to *well-formed DocTags*. That is the house idea — structure kills malformedness — applied to documents, and it is a capability the Python stack does not have for free.

---

## 5. Recommendation — the minimal vertical slice, and how it appears in the flow

**Slice D1 (the floor, no model):** `bytes → pages → text regions → reading-order text`, for **born-digital PDFs**, in Zig:
1. A PDF reader giving **positioned characters** (xref, Flate, content streams, ToUnicode fonts).
2. **Layout by heuristics over positions**: group characters into words and lines, detect columns by gaps, mark headings by size/weight, header/footer by repetition across pages.
3. An `stzDocument` of pages → regions (kind, box, order, text).
4. Downstream, unchanged: `:extract` (C9), `:summarise`, `:classify`, `:embed` + `:rerank` for retrieval.

In the flow design (§15 of `SOFTANZA_MODEL_FLOW.md`) these are faculties: `:document-pages` (floor = the reader), `:document-layout` (floor = the heuristics), `:document-table` (floor = alignment/ruling heuristics), `:ocr` (floor = `Windows.Media.Ocr` on Windows, **refuses** elsewhere — and says so). Each later model (RT-DETR layout, TableFormer, RapidOCR, Granite-Docling) is an **implementation of the same faculty**, selected only by **beating the floor on the document golden set** (design §9.2).

**Slice D2 (the first model, after D1 exists):** Granite-Docling-258M as the implementation of `:document-pages → :document` for *scanned or complex* pages — the tower, the embedding-prefill entry, DocTags under grammar. It needs the **second model slot** (decoder + projector) — design §11 (A5).

**Slice D0 (parallel, small, no model):** OOXML (DOCX/PPTX/XLSX): an in-memory zip reader + structure. This is the other "document" half and has no model risk.

The three slices share the `:document` parcel type; D1's golden pages can be **generated by Softanza itself** (the canvas/SVG stack produces pages with exact ground truth), which is how a deterministic checker exists without an LLM judge.

---

## 6. Measured baselines (2026-10-22)

**There is still no floor**: Softanza cannot read a PDF, so the numbers below are the bar a native reader will have to meet, not a comparison.

**The golden set** `base/test/document/_data/golden_v1/`: 10 PDFs rendered by headless Chrome from HTML, each with an `expected.json` (headings, key sentences in reading order, table grids, list items, page furniture, code). It was written by a separate agent that never ran an extractor, and the metrics in `base/test/document/_docling_baseline.py` were fixed before Docling's output on it was seen.

**Docling 2.141.0, OCR off, CPU** (`results/docling_baseline_golden_v1.md`): text 0.97, reading order 1.00 (the two-column page included), headings 1.00, tables 0.95, lists 1.00, furniture kept out of the body 1.00, code 0.00. 239 s for 10 documents, 83 s of them the first document's model loading. Its two failures are real, checked against its output:

- **code**: the block is found and labelled `code`, but `mass_kg` comes out as `mass _ kg`, so the text is not the code.
- **Arabic**: every French sentence is found, but the right-to-left paragraph's lines come back reordered and spliced, so 2 of the 3 Arabic sentences are lost. **Bidi is where a Softanza reader can beat Docling**: the graphics plane already shapes and orders RTL text.

**OCR on a real scan** (one page, no text layer, a French attestation supplied by the author; never committed): RapidOCR through Docling, 55 s on CPU, the whole body text recovered with its accents, one missing space. The logo, the stamp and the footer band are not in the exported text (pictures and page furniture). Perceived by Claude against the rendered page, then read by the author, whose document it is: **"it's good"** (Mansour Ayouni, 2026-10-22).

**How it ran**: the venv is outside the tree (`D:\GitHub\_wt_dl\docling-venv`, plus `onnxruntime` for RapidOCR), and the models were fetched beforehand with `curl -C -` and checked against the hub's SHA-256 (layout 171,658,996 B `00333a43...`, TableFormer accurate 212,758,388 B `2a7d6c92...`), because the Hugging Face client stalled on this network. Run with `--artifacts <models dir>` and `HF_HUB_OFFLINE=1`.

**The floor now exists (2026-10-22): Softanza's native reader**, `engine/src/pdf.zig` in `stz_file.dll`, Zig standard library only, with its Ring face `base/file/stzPdf.ring`. It reads the text layer: objects (a broken xref does not matter), object streams, five filters, ToUnicode and simple encodings, the text and path operators; then lays the glyphs out (rows, right-to-left lines in logical order, tables from ruling lines, an XY cut for columns) and types each block. Guard `pdf_reader_narrated.ring`, 42 assertions.

**Measured on golden_v2**, 12 harder PDFs written by a second independent agent that saw neither reader nor golden_v1 (borderless table, three columns, a sidebar, a table across two pages, Hebrew, a scientific page, a form, bold-only headings, a) b) lists, German with a soft hyphen, landscape, code with tabs). Both readers write the same prediction format and are scored by the same function, `_doc_score.py`:

| golden_v2 | text | order | headings | tables | lists | furniture | code | per document |
|---|---|---|---|---|---|---|---|---|
| Softanza native | **0.97** | **0.99** | 0.94 | 0.66 | **1.00** | 0.25 | **1.00** | about 2 ms |
| Docling 2.141 | 0.96 | 0.97 | **1.00** | **0.89** | 0.00 | **1.00** | 0.50 | about 5 s |

On golden_v1 the native reader scores 1.00 everywhere, but golden_v1 is its DEVELOPMENT set (it was built while reading those ten files), so that number proves behaviour, not quality; only golden_v2 is a measurement. **golden_v2 is now spent the same way the moment the reader is changed to fix what it showed**: a fix is re-measured on a new set.

What the native reader got wrong on golden_v2, each cause read off its output:

- **tables**: a table WITHOUT ruling lines is not found (e01, 0.00; its text is still read, in order); a table continued on a second page comes back as two tables (e04, 0.62).
- **furniture**: a running header or a form's footer on a ONE-page document has no repetition to give it away (e06, e07); Docling's layout model sees it.
- **headings**: numbered headings ("1. Introduction") were taken for list items, because the list-marker rule runs before the heading rule (e06).
- **bidi**: in Hebrew, the period after a Latin run at the end of a sentence lands on the wrong side of it (".Rivulet S3"), a weak-character rule the line reordering lacks (e05).
- **hyphenation**: a word split by a soft hyphen across a COLUMN break is not joined (e10).

What Docling got wrong on the same set: every a) b) c) list (lists 0.00), the code block with tabs (0.50), two of the six Hebrew sentences, the reading order around the German column break, and the same two-page table (0.62).

**Second round, the same day: the six misses fixed, then measured on golden_v3.** The fixes, each general and each pinned in the guard (60 assertions): a table without ruling lines is found from aligned columns of short cells (rows in one type size); a table continued on the next page is joined and its repeated header dropped; two columns must stand side by side, a column's tail below the other column ends it, and a narrower column in smaller type is an aside read after the main flow; a short line in smaller type in the page's margin band is furniture even on a one-page document; a numbered line set larger or bold is a heading, not a list item; in a right-to-left line, spaces are found between glyphs that are neighbours ON THE PAGE before the line is reordered, and punctuation joins a left-to-right run only inside it; a word broken by a hyphen at the end of a line or a column is joined to its other half; a heading in larger type than the table under it is not its caption. After the fixes both development sets read 1.00 on every metric -- which is what a development set is for, and not a measurement.

golden_v3: 14 PDFs by a THIRD independent agent that saw neither reader, nor golden_v1 or v2, aimed at the same families of difficulty with new layouts. The reader was frozen before it was run; both readers were run once:

| golden_v3 | text | order | headings | tables | lists | furniture | code | per document |
|---|---|---|---|---|---|---|---|---|
| Softanza native | **0.90** | 1.00 | 1.00 | **1.00** | 0.80 | 1.00 | **1.00** | about 2.5 ms |
| Docling 2.141 | **0.90** | 1.00 | 1.00 | 0.89 | **1.00** | 1.00 | 0.50 | about 3.9 s |

What golden_v3 shows, causes read off the outputs: **both** readers lose the same three things -- a word with soft hyphens in a narrow column, which Chrome draws as syllables a few points apart, so both readers write "re spon si bil i ties" (f10, 0.125 for both); the sentence ending in "(KPI)" in Hebrew, where the parentheses need mirroring (f08); the sentence holding a word broken across a column break, in a monospaced page (f09). **Only Docling** splits the two-page table (f03, 0.56; the native reader now joins it, 1.00) and loses half the code (f14, 0.50). **Only the native reader** misses typed "→" list markers (f12, lists 0.60) and a ligature it leaves as U+FB01 "ﬁ" where Docling writes "fi" (f14). Fixing these spends golden_v3: they are re-measured on a golden_v4.

**Third round, the same night: golden_v3's misses fixed, then measured on golden_v4.** Fixed, each general and pinned in the guard (69 assertions): a space glyph another glyph is drawn over is an invisible soft hyphen (Chrome writes U+00AD as a space and draws the next syllable back over it) and is dropped, so words are no longer cut into syllables; brackets outside a Latin run in a right-to-left line are mirrored; prose set in a monospaced font is prose, not code; a typed arrow starts a list item; ligature code points read as their letters. Only what golden_v3 showed was fixed: the brief of golden_v4 was written by this desk, and building for its categories in advance would have been teaching to the test.

golden_v4: 16 PDFs by a FOURTH independent agent (soft hyphens that do and do not break, ligatures, Arabic and Hebrew with brackets and guillemets, typed list markers, roman-numbered lists, three columns, merged and borderless tables, a two-page table, four heading levels, a pull quote, small caps, a line-numbered listing, French typography, a mixed layout). The reader was frozen before it ran; both readers ran once:

| golden_v4 | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.98** | 1.00 | 0.92 | 0.70 | **0.73** | 1.00 | **0.50** |
| Docling 2.141 | 0.69 | 1.00 | **0.97** | **0.90** | 0.13 | 1.00 | 0.00 |

The native reader read every document in 6 to 31 ms; Docling took 5 to 59 s on the same run (the machine was slower that night than in the earlier rounds, for both). Docling's text falls to 0.69 on the soft hyphens and ligatures the native reader now handles. **What the native reader got wrong on golden_v4**, causes read off its output: guillemets « » are not mirrored in Hebrew (g04); typed "✓" and roman-numeral markers "i." "ii." do not start list items (g05, g06); a borderless table with right-aligned numbers collapses to two columns (g09); a table continued on page 2 is not joined when a page footer sits between its halves in reading order (g10); headings marked by italics alone are paragraphs (g11); a letter-spaced heading comes out as spaced letters (g13); a code listing with a line-number gutter breaks into seven blocks (g14); an Arabic heading is not found (g03); two sentences of a two-column section that follows a full-width table are missed (g16). These are round 4, to be measured on a golden_v5.

**Fourth round: golden_v4's misses fixed, then measured on golden_v5 -- the first set of REALISTIC documents.** Fixed and pinned in the guard (87 assertions): cell boundaries between close, right-aligned figures; letter-spaced text; italic-only headings; line numbers in a code gutter; a table split by page furniture; the aside test on medians; a column ending at the first gap below the other column's end; a sentence running on into the next column; compounds keeping their own hyphen; Arabic-or-Persian decided over the whole document; guillemets mirrored; typed check marks and roman numerals as list markers.

golden_v5 was briefed differently from v2-v4: not one difficulty per document but whole documents an office, school, clinic or administration produces -- an NGO annual report (3 pages), a French business letter, an invoice, a Portuguese receipt on a narrow page, a landscape school timetable, board minutes, a product datasheet, a three-column newsletter, a technical note with footnotes and code, a two-page application form, a French and Arabic notice side by side, a four-language safety leaflet, a Swahili and English schedule, an IT runbook, a memo, a German bus timetable, a financial statement, a Turkish lab report. 18 PDFs by a fifth independent agent; the reader was frozen (2498ba92e) before it ran; both readers ran once:

| golden_v5, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | 0.91 | 0.95 | **0.74** | 0.60 | 0.52 | 0.79 | **1.00** |
| Docling 2.141 | 0.91 | **1.00** | 0.70 | **0.84** | **0.58** | **0.95** | 0.13 |

**This is the most informative number of the series, and it is not flattering.** On single-difficulty documents the native reader overtook Docling; on whole realistic documents it ties on text, keeps its lead on headings and code, and falls clearly behind on tables (0.60 against 0.84) and page furniture (0.79 against 0.95). Causes read off its output: a real table is cut into pieces -- the invoice's 13 x 5 table comes back as four tables, the lab report's 12 x 5 as three, the financial statement's 16 x 6 as two -- because totals rows, section rows and partial rulings make separate ruling groups; a two-column specification table is not found at all; a letterhead or a legal footer of several lines, or set in body-size type, is not furniture on a one-page letter. Many expected "lists" have no visible marker (dated event lines, "[1]" references, "R = ..." legends): they are lists in the HTML source, and Docling also scores 0 on those documents -- partly an ambiguity of the set, not only a gap of the readers. These are round 5, to be measured on a golden_v6 of realistic documents.

**Fifth round: tables and furniture of realistic documents, then golden_v6.** Fixed on golden_v5 (now a development set; there tables 0.60 -> 0.81, furniture 0.79 -> 0.90, headings 0.74 -> 0.83): tables carry their column bands and grow by header rows above (spanning cells fill each column, past one section row) and totals rows below (the label fills the cells it spans); tables stacked with the same columns are one; a prose line of a neighbouring column is never a cell; a Type3 font's widths use its own FontMatrix (Chrome's synthetic bold: read as thousandths its spaces were taken for soft hyphens) and fill-and-stroke text is bold; the full NFKC mapping of the Arabic presentation forms, generated from Unicode 15.1; run-in headings; typewriter headings; small-type footers of any length. Guard 102 assertions.

golden_v6: 20 realistic documents (a quotation, a purchase order, a payslip, a bank statement, an electricity bill, an Arabic report card, a discharge summary, lab results, a prescription, a project report, a call for tenders, board minutes, a two-column policy, a user guide, a product catalogue, a conference programme, an itinerary, a Hausa certificate, a stock sheet, a four-language notice), eight languages besides English, eleven of 2-3 pages, by a sixth independent agent; reader frozen at e8f8dd773; both readers ran once (Docling in resumable pieces, the machine throttled to 42 per cent for part of it):

| golden_v6, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.94** | **0.99** | **0.98** | 0.50 | **0.72** | 0.51 | **1.00** |
| Docling 2.141 | 0.88 | 0.98 | 0.87 | **0.70** | 0.67 | **0.73** | 0.67 |

The native reader now leads on text, order, headings, lists and code on unseen realistic documents, and still trails on **tables** and **furniture** -- and the table gain made on golden_v5 (0.81) did NOT carry over (0.50): it was partly fitted to that set. Causes read off the output: a page-spanning table is still cut in two when its halves differ (a 42-row purchase order comes back as 18 + 21 rows; a bank statement as two tables with different column counts); small key/value tables side by side are merged into one wide table (a payslip's three become one 16 x 4); a letterhead of several lines in body size or larger (company name, street, town) is not furniture, which Docling's layout model sees. Round 6, measured on a golden_v7 of realistic documents.

**Sixth round: header bands, page-spanning tables, letterheads; then golden_v7.** Fixed on golden_v6 (now a development set; there tables 0.50 -> 0.61, furniture 0.51 -> 0.73): a table's header gathered as a band of lines (wrapped cells joined per column, several cell-lines as several header rows, cells short, a further row close above); totals labels filled across the cells they span in every table; a letterhead's capitals logo and short address lines ending above the title are furniture. A side-by-side split of borderless tables was tried and REMOVED: it did not fire on the payslip it was written for and cost elsewhere. Known limit: a row span in a borderless header is not inferred. Guard 111 assertions.

golden_v7: 20 realistic documents in 11 languages besides English (a hotel invoice, a rental contract, a customs declaration, an Arabic patient leaflet, a Swahili timetable, a transcript, a league table, a Turkish train timetable, an A3 research poster, an NGO report, a Hausa extension sheet, cooperative accounts, a municipal budget, election results, a receipt, an exam paper, a veterinary record, an insurance schedule, a Hebrew listing, a cargo manifest), 10 of 2-3 pages, by a seventh independent agent; reader frozen at a13d04600; both readers ran once:

| golden_v7, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.99** | **1.00** | **0.98** | 0.68 | 0.55 | 0.53 | **0.50** |
| Docling 2.141 | 0.81 | 0.99 | 0.71 | **0.72** | **0.63** | **0.72** | 0.25 |

The native reader keeps a wide lead on text and headings on unseen documents, draws level on tables (0.68 against 0.72, from 0.50 against 0.70 on v6), and **trails on furniture again (0.53 against 0.72): the letterhead gain on golden_v6 did not carry over.** The cause is visible: on receipts, posters and club letters the organisation's name is the LARGEST text on the page, so the rule takes it for the title, and nothing ends above a title; golden_v7 marks those blocks as furniture, and so does Docling's layout model, which has seen many such pages. A deterministic floor can only meet this with a stated convention (the first block group of page 1, set apart by a gap, is a letterhead when it holds an address or a legal line), and that convention will be wrong on documents whose name is their title -- the honest place for this judgement may be a measured model above the floor, not the floor. Tables still missed: a three-column poster's narrow table, a Hausa sheet's small table, a receipt's items split in two.

**The letterhead decision as a measured faculty, and round 7 on golden_v8 -- now under Ring++.** Ring is retired (the author, 2026-10-23): the reader and its guards run on Ring++ (`rnxc`), against the Rule-A-migrated library, with every engine DLL built for Ring++'s native interface (`rpp_init`) from this tree's sources by Ring++'s own `bench/engine_copy.py`. The PDF guard passes 111 of 111 under Ring++, and the letterhead floor scores the same under Ring++ as under Ring (128 of 167).

The **:letterhead faculty** (`base/file/stzPdfLetterhead.ring`) decides, for each block of page 1's top band, letterhead or content. Its floor is the reader's own rule; each installed generative model reads its probability for the two answers; the registry takes a model only if it measures strictly better than the floor. Golden set: the 167 top-band blocks of golden_v7 (fixed before any rule or model was tuned to it), labelled from that set's own furniture lists: 55 letterhead, 112 content.

| letterhead, 167 blocks of golden_v7 | score | chosen |
|---|---|---|
| reader's rule (floor) | **0.77** | **yes** |
| Granite-4.0-1b, read by probability | 0.71 | no: below the floor |
| Qwen2.5-Coder-1.5B, Granite-4.2-3B | not measured | -- |

The two larger models are NOT measured yet: the CPU was firmware-throttled to 21 per cent for the rest of the day (an item took 45 to 90 s, so one model needed more than two hours), and another repository's engine build ran meanwhile. Until a model beats 0.77, the registry answers with the floor -- so "the reader plus the decision" is, today, the reader.

golden_v8: 24 realistic documents in 10 languages besides English, 12 of 2-3 pages, 20 with a letterhead, four tables across pages, by an eighth independent agent; reader frozen at the round-6 state; both readers ran once:

| golden_v8, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **1.00** | 1.00 | **0.99** | 0.64 | **0.83** | **0.56** | **1.00** |
| Docling 2.141 | 0.84 | 1.00 | 0.84 | **0.75** | 0.78 | 0.55 | 0.25 |

Across eight sets the pattern holds: on unseen realistic documents the native reader leads on text, headings, lists and code by a wide margin and at a thousandth of the time; it is level on reading order and on furniture (both readers are weak there); it trails on tables by about a tenth. Furniture is where a measured model above the floor has room, and the faculty is in place to take one when it earns its place.

**Not measured**: Granite-Docling-258M (not downloaded), the GPU, scanned golden pages with an expected text, PDFs from producers other than Chrome (both golden sets are Chrome-made and tagged; the native reader does not read the tags).

---

## 7. Verified vs not verified

**Verified live by the author of this memo (2026-10-21):** Granite-Docling-258M is Apache-2.0, `idefics3`, 257,517,120 BF16 parameters; `docling-layout-heron` is Apache-2.0, `rt_detr_v2`, 42,889,979 parameters; Indra's weights are a modified OpenRAIL-M with a $20M funding/revenue cap and a no-compete clause, code Apache-2.0; Qwen3-4B-Instruct-2507 is Apache-2.0, `qwen3`, 4.02B parameters.
**Read in the tree:** the engine's lack of PDF/OCR/OOXML code, the token-id-only decoder entry, the C++ static-initialiser NOTICE, the one model slot.
**From the research pass, not re-verified:** TableFormer's internal wiring (the `tablemodel04_rs` source was not read); the published pages/s figures; the official Granite-Docling GGUF file sizes; whether Granite uses extra scale multipliers (the config says `llama`); RapidOCR model sizes and which Paddle models exist for Arabic/French; ONNX operator coverage of the layout model.
**Not tools-checkable here:** any claim of the form "faster than" on this machine. No time was taken on this machine for any document stage.
