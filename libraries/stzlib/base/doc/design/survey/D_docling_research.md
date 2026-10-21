# Docling research for Softanza document intelligence

Researched 2026-10-21. Read-only. Nothing installed, no weights or documents downloaded (web pages and HF/GitHub JSON listings only).

**Method caveat.** WebFetch returns a summary written by a small model, not raw text. Numbers below are second-hand through that summary. Where a figure matters for a decision, the primary URL is given so it can be re-read. The arXiv PDFs came back as unreadable binary, so the papers were read through their arXiv HTML versions.

**Local ref read (task 5/6).** `D:\GitHub\_wti` is on branch `intelligence/model-flow`, commit `a6a59d4f6` (2026-09-26). `origin/main` of `D:\GitHub\stzlib` is `ceafcbb14` (2026-10-19). On `origin/main`, `git grep docling` finds nothing, and the engine has no `vision|onnx|pdf|ocr|mmproj` source file. Both refs show the same `neural_*.zig` set. Tags: [page] the blog page, [repo] GitHub/raw source, [card] Hugging Face model card or file listing, [paper] arXiv, [inferred] my reasoning, not stated by a source.

---

## 1. The blog page

URL: https://docling.ai/blog/20261016_00_docling-on-nvidia-rtx-spark/ . It was reachable.

**What it is.** [page] "Docling on NVIDIA RTX Spark: Day-0 Support for On-Device AI", dated Oct 16, 2026, filed as an "Announcement". No author is given. It is a launch note about running Docling on NVIDIA's RTX Spark. It describes the device as a compact, PC-class machine on the CUDA stack, and says Docling works there with no configuration changes. I could not confirm what "RTX Spark" is beyond the page's own words.

**The prior summary, claim by claim.**

| Claim | Verdict |
|---|---|
| Converts PDF, DOCX, PPTX, scanned images to structured Markdown/JSON preserving layout, tables, headings, reading order | On the page [page]. The intro also mentions spreadsheets as a common enterprise format, but does not list them as Docling inputs. |
| GPU acceleration for OCR, layout analysis, table-structure recognition, VLM backends | On the page [page]. |
| CUDA build of PyTorch is all it takes | On the page [page]. It gives a `pip` example with the CUDA wheel index (CUDA 13.2), then `pip install docling`, then a `torch.cuda.is_available()` check. Docling is said to detect the GPU automatically. |
| Ollama, LM Studio, vLLM as model servers | On the page [page], alongside Unsloth. It also names Hermes Agent, pi, OpenHands and Goose as orchestrators. |
| Usage skill and MCP server | On the page [page]. The skill ships inside the Python package and is symlinked into an agent's skills directory with `uvx library-skills`. The compatible harnesses named are Hermes Agent, pi, OpenHands, Codex, Cursor, Copilot and Claude Code. The MCP server starts with `uvx --from docling-mcp docling-mcp-server --transport stdio`. Its tools let agents convert documents, inspect layout, extract tables and build structured outputs locally. |
| Same API targets local install, docling-serve, or IBM watsonx | On the page [page]. The same `DocumentConverter` API works with a local ML stack, a self-hosted `docling-serve` endpoint, or the managed Docling for IBM watsonx service. Switching is described as a configuration change. |
| Names no models, numbers or licences | Correct [page]. No OCR, layout, table or VLM model is named. No benchmark, speedup, latency or RTX Spark hardware spec. No Docling, MCP or serve version. No licence. The only number is the CUDA 13.2 example. The footer says "open-source" and "a series of LF Projects, LLC". |

**Page also gives** [page]: four example agent prompts (batch PDF to Markdown, a RAG pipeline with `HybridChunker`, contract metadata into a Pydantic schema, batch PPTX/DOCX).

**Takeaway.** The page is marketing for a Python-plus-PyTorch stack. It carries no evidence usable for a cost or licence decision. Everything below comes from the repo, docs, papers and model cards.

---

## 2. Docling's real architecture

### 2.1 Project facts
- Licence of Docling: MIT [repo: github.com/docling-project/docling, pyproject]. The README adds that individual models follow their own licences [repo].
- Latest release at research time: v2.141.0, published 2026-10-20 [repo: api.github.com/repos/docling-project/docling/releases/latest]. The package is split as `docling-slim`, Python >=3.10 [repo: pyproject.toml].
- The core install is only pydantic, docling-core, requests and small utilities [repo: pyproject]. torch, docling-ibm-models, docling-parse, pypdfium2, rapidocr, easyocr and onnxruntime are all optional extras. The `standard` bundle pulls format-pdf (docling-parse and pypdfium2), models-local (torch, torchvision, docling-ibm-models, accelerate, huggingface_hub) and feat-ocr-rapidocr. The `all` bundle adds VLM-inline (transformers, timm, mlx-vlm, peft...), onnxruntime, easyocr, tesserocr [repo].
- Every model stage needs PyTorch, transformers or onnxruntime. Non-PDF formats (DOCX, PPTX, HTML...) need no weights [docs FAQ].
- Offline use is supported: `docling-tools models download`, then `artifacts_path` or `DOCLING_ARTIFACTS_PATH` [docs: usage/advanced_options]. Docling "is not using any remote service" [docs FAQ].

### 2.2 Architecture
- A `DocumentConverter` maps each input format to a **backend** (parses the file) and a **pipeline** (orchestrates models), both overridable [docs: concepts/architecture]. The result is a `DoclingDocument`, exportable, serializable, or fed to a chunker [docs].
- Technical report v1 [paper: arXiv 2408.09869, HTML]: a linear pipeline of PDF parsing, then per-page AI models, then aggregation and post-processing (language detection, reading-order inference, assembly into a typed document).
- Report v2 [paper: arXiv 2501.17887, HTML]: adds the unified `DoclingDocument` (Pydantic model with text, tables, pictures, captions, lists, hierarchy, headers/footers, bounding boxes, provenance; lossless JSON, lossy Markdown/HTML) and a chunker hierarchy. Pipelines named: `StandardPdfPipeline` and `SimplePipeline` for markup/Office/HTML/AsciiDoc. Custom pipelines are made by subclassing.
- Other pipelines in the current release: `VlmPipeline` (`--pipeline vlm --vlm-model granite_docling`) [repo README]; an ASR pipeline with Whisper, extras `openai-whisper` and `mlx-whisper` [pyproject, docs model catalog mentions "ASR pipeline with Whisper" only as an example].
- **Parser backend** [paper]: default is `docling-parse`, a custom parser, with `pypdfium` as the alternative. Report v1 says docling-parse was "built on the low-level qpdf library". Per the report, pypdfium is faster and lighter but gives worse quality, especially for tables. Server default is `pdf_backend=docling_parse` [docling-serve docs].
- **Layout post-processing** [paper]: detector boxes are filtered by confidence and size, then intersected with PDF text tokens to form paragraphs, headings, list items, captions, figures, tables.
- **Reading order**: inferred and corrected in post-processing [paper]. The papers give no algorithm detail, and I did not read the code. It is heuristic Python code, not a model [inferred].

### 2.3 The model stack per stage

| Stage | Model | Architecture / size | Licence | Source |
|---|---|---|---|---|
| Layout (default) | `docling-project/docling-layout-heron` | RT-DETRv2 (`rt_detr_v2`), 42.9M params, F32 safetensors (~172 MB, derived: 42.9M x 4 bytes), 17 classes, input 640x640, ImageNet mean/std, score threshold 0.6 in the card example | Apache-2.0 | [card] huggingface.co/docling-project/docling-layout-heron; 640x640 from [card] heron-onnx preprocessor_config.json |
| Layout ONNX | `docling-project/docling-layout-heron-onnx` | one `model.onnx`, 171,220,471 bytes | Apache-2.0 | [card] file listing, HF API tree |
| Layout alternatives | `heron-101` (76.7M), `egret-medium` (19.5M), `egret-large` (31.2M), `egret-xlarge` (62.7M) | RT-DETR / D-FINE family | Apache-2.0 for heron; not read for egret | [card] org page; arXiv 2509.11720 |
| Layout training | DocLayNet plus other, partly proprietary data | The 2025 report says 150,000 heterogeneous documents; best model heron-101 gets 78% mAP at 28 ms/image on an A100 | the report says "permissive licence" for checkpoints | [paper] arXiv 2509.11720 |
| Legacy layout | `docling-layout-v2`, RT-DETR | marked legacy, unsupported | not stated | [docs: model catalog] |
| Table structure (default) | TableFormer v1, in `ds4sd/docling-models`, two files | accurate: `tableformer_accurate.safetensors` 212,758,388 bytes; fast: `tableformer_fast.safetensors` 145,453,276 bytes | the card shows tags cdla-permissive-2.0 and apache-2.0 without saying which file each applies to | [card] file listing and card |
| TableFormer config | accurate: ResNet-18 backbone, input 448x448, 28x28 encoder grid, 6 encoder + 6 decoder layers, 8 heads, hidden 512, tag vocabulary of 13 tokens (OTSL-style: `ecel fcel lcel ucel xcel nl ched rhed srow` plus specials), `max_steps` 1024, `beam_size` 5, predicts a box per cell. fast: 4 encoder + 2 decoder layers | | [card] `tm_config.json` for both modes |
| Table structure, preview | `TableFormerV2`, 52.4M params F32. EfficientNetV2-S encoder with squeeze-excitation and depthwise convs (no self-attention in the encoder), cache-aware Transformer decoder, a box per cell | Apache-2.0. The card says V1 remains the default and V2 is a preview whose weights may change | [card] |
| Table training data | PubTabNet, FinTabNet, TableBank (TableFormer format); TEDS 93.6 on all tables | | [repo] docling-ibm-models README, [card] docling-models |
| Table code | `docling-ibm-models` | MIT. Includes the TableFormer predictor and cell matcher (matches predicted cells to PDF cells, `pdf_cell_iou_thres` 0.05) | MIT | [repo] |
| Table via VLM (new option) | `granite-vision-4.1-4b` | listed as an alternative table-structure model | not stated | [docs: model catalog] |
| OCR | Auto, Tesseract (CLI and tesserocr), EasyOCR, RapidOCR, macOS Vision (ocrmac), Surya, Nemotron-OCR, remote KServe | `OcrAutoOptions` is the default and "selects the best available OCR engine (e.g., EasyOCR if GPU is present, Tesseract otherwise)" [repo: pipeline_options.py]. Third-party pages claim a different priority order; the source line above is the one verified. `do_ocr` defaults to True. RapidOCR default language is Simplified Chinese; EasyOCR defaults to English; RapidOCR handles one language per run [docs: concepts/OCR] | RapidOCR: Apache-2.0 code, models derived from PaddleOCR and redistributed under Apache-2.0, with ONNX Runtime, OpenVINO, MNN, Paddle, TensorRT and PyTorch backends [repo RapidAI/RapidOCR]. EasyOCR, Tesseract, Surya licences: not verified (see section 8) | [repo], [docs] |
| OCR speed | EasyOCR "upwards of 30 seconds per page" on CPU at 216 dpi | | | [paper] 2408.09869 |
| Picture classifier | `DocumentFigureClassifier-v2.5` | EfficientNet-B0, 4.08M params, 26 classes, ONNX export shown | MIT | [card] |
| Code and formula | `CodeFormulaV2` (also Granite-Docling) | Idefics3, 0.3B BF16 | CDLA-Permissive-2.0 | [card]; enrichments off by default [docs: usage/enrichments] |
| Picture description | SmolVLM-256M (default), Granite-Vision-3.3-2B, Pixtral-12B, Qwen2.5-VL-3B, any HF VLM or remote API | off by default; remote use requires `enable_remote_services=True` and sends data to the provider | not stated | [docs: model catalog, enrichments] |
| VLM pipeline models | Granite-Docling-258M (default), SmolDocling-256M, DeepSeek-OCR-3B, Granite-Vision-3.3-2B, Pixtral-12B, GOT-OCR-2.0, Phi-4-multimodal, Qwen2.5-VL-3B, Nanonets-OCR2-3B, Gemma-3 (MLX only), Dolphin, Nemotron Parse (0.9B and 0.6B), MinerU2.5-Pro (1.2B), Unlimited-OCR (3.34B MoE) | engines vary: Transformers, MLX, API, vLLM, AUTO_INLINE | licences not on the catalog page | [docs: model catalog] |

### 2.4 The two VLMs

**Granite-Docling-258M**, `ibm-granite/granite-docling-258M` [card].
- Licence: Apache-2.0.
- Built on Idefics3 with three parts: vision encoder `siglip2-base-patch16-512`, a pixel-shuffle projector connector, and a Granite 165M LLM.
- `config.json` [card]: text side `model_type: llama`, hidden 576, 30 layers, 9 heads, 3 KV heads, vocab 100,352, rope_theta 100,000, tied embeddings. Vision side `idefics3_vision`, hidden 768, 12 layers, 12 heads, patch 16, image_size 512. `scale_factor` 4.
- Preprocessor [card]: longest edge 2048, tiles of max 512, `do_image_splitting: true`. By arithmetic this is 32x32 patches per tile, shuffled by factor 4 to 64 tokens per tile, and a page of up to 16 tiles plus a global view could cost over 1,000 image tokens [inferred, not stated in a source].
- Weights: `model.safetensors` 515,093,104 bytes (BF16) [card file listing].
- Output format: DocTags, which converts to DoclingDocument and then Markdown/HTML/JSON [card].
- Training data named: DoclingMatix, SynthCodeNet, SynthFormulaNet, SynthChartNet; trained on IBM Blue Vela with H100 GPUs [card]. Speed numbers on the card: none.
- Inference listed on the card: Transformers, vLLM, SGLang, Docker Model Runner, MLX (separate repo), and community quantizations for llama.cpp, Ollama, LM Studio.

**SmolDocling-256M-preview**, `docling-project/SmolDocling-256M-preview` [card].
- Idefics3, finetuned from SmolVLM-256M-Instruct, base LLM SmolLM2-135M.
- The card header says `cdla-permissive-2.0` while its summary says Apache-2.0. The two disagree and I did not resolve it.
- "0.35 secs per page on A100 GPU" with vLLM (card; the hardware is the A100). VRAM not stated.
- Granite-Docling is described as the successor.

**GGUF and ONNX versions** [card, HF API listings]:
- `ibm-granite/granite-docling-258M-GGUF` exists, listing: `granite-docling-258M-BF16.gguf` 331,641,120 bytes, and `mmproj-model-f16.gguf` 190,031,712 bytes (about 522 MB together). The card shows run commands for `llama-server -hf ...:BF16`. The card text states no licence ("No model card"). The licence of the base model is Apache-2.0, so it is presumably the same, but that is not stated on the GGUF page [inferred].
- llama.cpp's multimodal README lists SmolVLM/SmolVLM2 among supported mmproj models and does not mention Idefics3 by name [repo ggml-org/llama.cpp tools/mtmd]. SmolVLM is itself an Idefics3-architecture model, and IBM published an official GGUF with a projector, so a llama.cpp path is shown to exist; I did not run it.
- Third-party GGUF repos also exist (infil00p, RockMan256, SandLogicTechnologies) [search results, not opened].
- ONNX: the SmolDocling card lists ONNX exports (vision encoder, embedding, decoder) [card]. The Granite-Docling card names ONNX as a bare-inference option without a linked repo [card].
- The layout model has an official ONNX file (171 MB) [card]. TableFormer v1 is safetensors only in the official repo [card listing].
- Docling's own docs say VLM local engines are Transformers and MLX, and remote is any OpenAI-compatible server (vLLM, Ollama named); llama.cpp and LM Studio are not mentioned there [docs: usage/vision_models]. The blog page says LM Studio works as a server [page].

### 2.5 Input and output formats
- Inputs [docs: usage/supported_formats]: PDF, DOCX, XLSX, PPTX, ODT/ODS/ODP, RTF, EPUB, LaTeX; Pages/Numbers/Keynote; Markdown, AsciiDoc, HTML/XHTML/MHTML, CSV, WebVTT; PNG, JPEG, TIFF, BMP, WEBP; audio and video (needs the `asr` extra, video also ffmpeg); EML and MSG email; schema XML (DocLang, USPTO patents, JATS, XBRL); Docling JSON. Legacy DOC/XLS/PPT and RTF need LibreOffice.
- Outputs [docs]: JSON (lossless), DocLang XML, DocTags, Markdown, HTML, plain text, LaTeX, WebVTT, DocLang archive, and RAG chunks as JSONL.
- The schema is `DoclingDocument` in the `docling-core` package [paper v2; I did not fetch its JSON schema file, so I cannot quote field names beyond the paper summary].

---

## 3. Cost

**Published numbers only. Source and hardware per row.**

| Number | Hardware | Source |
|---|---|---|
| 225 pages, default options, OCR off. Native docling-parse: 1.27 pages/s, 6.20 GB peak (M3 Max, 4 threads); 1.34 pages/s (16 threads). Intel Xeon E5-2690 16 cores, 4 threads: 0.60 pages/s, 6.16 GB; 16 threads: 0.92 pages/s | Apple M3 Max 16 cores; Xeon E5-2690 | [paper] 2408.09869 |
| Same set with the pypdfium backend: 2.18 pages/s, 2.56 GB (M3 Max, 4 threads); 2.45 pages/s (16 threads). Xeon: 0.94 pages/s, 2.42 GB; 1.57 pages/s (16 threads) | same | [paper] 2408.09869 |
| Typical TableFormer table: 2 to 6 s on a standard CPU | not specified | [paper] 2408.09869 |
| Layout model: "sub-second latency" on a single CPU, pages fed at 72 dpi (old model) | not specified | [paper] 2408.09869 |
| Median per page: 0.79 s (x86), 0.32 s (M3 Max), 114 ms (L4). Mean per page: 3.1 s (x86), 1.26 s (M3 Max), 481 ms (L4). Turning OCR off cuts about 60% on CPU/M3 Max and 50% on L4. Turning table structure off cuts 16% on CPU/M3 Max and 24% on L4 | AWS g6.xlarge 8 vCPU AMD EPYC 7R13 32 GB; Nvidia L4 24 GB on the same VM; MacBook Pro M3 Max 64 GB | [paper] 2501.17887 |
| Standard pipeline inline, no OCR: 3.1 pages/s on L40S (8 vCPU EPYC, 64 GB); 7.9 pages/s on RTX 5090 (CPU-only same machine: 1.5); 4.2 pages/s on RTX 5070 (CPU-only: 1.2). Dataset: one 192-page PDF with 95 tables | AWS g6e.2xlarge L40S 48 GB; Ryzen 7 9800 16 vCPU 128 GB + RTX 5090 (Linux); Ryzen 7 9800 64 GB + RTX 5070 (Windows 11). CUDA 13.0. CPU-only figures use 16 PyTorch threads | [repo] docs/usage/gpu.md (raw, summarised; the table mapping was checked against a second fetch) |
| Standard pipeline with OCR: 1.6 pages/s (RTX 5090) and 1.1 pages/s (RTX 5070) on ViDoRe V3 HR (14 documents, 1,110 pages, 258 tables). L40S: not measured | same | [repo] gpu.md |
| VLM pipeline through an inference server (Granite-Docling): 2.4 pages/s (L40S, PDF), 3.8 (RTX 5090, PDF; 3.6 to 4.5 on the image set), 2.0 (RTX 5070, PDF; 2.8 to 3.2 on the image set) | same | [repo] gpu.md |
| SmolDocling at 0.35 s/page, vLLM | A100 | [card] |
| One page, VLM pipeline: SmolDocling MLX 6.15 s; Qwen2.5-VL-3B MLX 23.5 s; SmolDocling Transformers on MPS 102.2 s; Granite Vision 3.2 2B Transformers/MPS 104.8 s; Pixtral-12B MLX 308.9 s; Phi-4-multimodal Transformers/CPU 1,175.7 s; Pixtral-12B Transformers/CPU 1,828.2 s | MacBook M3 Max, one page | [docs] usage/vision_models |
| Layout heron-101: 28 ms/image, 78% mAP | one A100 | [paper] 2509.11720 |
| Docling 3.1 s/page on x86 CPU and 1.27 s/page on M3 Max, the fastest of the CPU-tested tools; with GPU, MinerU leads at 0.21 s/page, Docling 0.49 s/page, Marker 0.86 s/page | as above | [paper] 2501.17887 |
| Docker images: `docling-serve` 8.7 GB amd64; `-cpu` 4.4 GB; `-cu128` 11.4 GB | n/a | [repo] docling-serve README |

**Where there are no numbers.**
- No VRAM requirement is published for any stage. The GPU guide gives none [repo gpu.md]. The only memory setting is vLLM's `--gpu-memory-utilization 0.9`.
- No CPU-only figure for Granite-Docling, SmolDocling or any VLM exists except the M3 Max single-page table above (which is Apple silicon, not a PC CPU).
- No RTX 3050 or any laptop-GPU measurement exists.
- The blog page has no numbers at all.
- The arXiv summaries I got did not show the GPU model used for the 2025 layout runs beyond the A100 figure.

**What fits a 6 GB RTX 3050 laptop GPU** [inferred; every size below is from the cards, the fit is arithmetic, not a measurement]:
- Standard pipeline weights: layout heron 172 MB (F32) + TableFormer accurate 213 MB + RapidOCR models (sizes not stated by any source I read) is well under 1 GB of weights. The runtime cost is activations and batch size: the docs default `layout_batch_size` and `ocr_batch_size` to 4 and recommend 64 for throughput, which would raise VRAM, and nothing publishes by how much. Also, PyTorch's CUDA context itself costs a few hundred MB [inferred from general knowledge].
- Granite-Docling: 515 MB of BF16 weights plus KV cache and a vision pass over up to ~1,000 image tokens (derived above). That fits in 6 GB easily. Running it in vLLM with its default high memory fraction is a configuration choice, not a hard need.
- The 3050 laptop part is an Ampere GPU of lower throughput than the RTX 5070 in the benchmark; scaling the 2.0 pages/s figure to it would be a guess, so I do not give one.
- Not run or measured on this machine.

---

## 4. docling-serve, docling-mcp, the skill

**docling-serve** [repo github.com/docling-project/docling-serve].
- Licence MIT. Its API is "stable at v1".
- Endpoints [repo docs/usage.md]: `POST /v1/convert/source` (JSON with URLs `http_sources` or base64 `file_sources`), `POST /v1/convert/file` (multipart), async twins `/v1/convert/source/async` and `/v1/convert/file/async`, `GET /v1/status/poll/{task_id}`, WebSocket `/v1/status/ws/{task_id}`, `GET /v1/result/{task_id}`, `GET /v1/capabilities` (no key needed). Interactive docs at `/docs`, demo UI at `/ui` (opt-in: `--enable-ui`). The docs I read do not document clear, health or version endpoints.
- Options: `from_formats`, `to_formats` (default markdown; also json, yaml, html, text, doctags, chunks), `do_ocr`, `force_ocr`, `ocr_lang`, `ocr_preset` (`ocr_engine` is deprecated), `pdf_backend` (default docling_parse), `table_mode` (fast/accurate, default accurate), `pipeline`, `vlm_pipeline_preset`, picture description presets.
- Response: JSON with `document` (md/json/html/text/doctags content), `status` (success, partial_success, skipped, failure), `processing_time`, `timings`, `errors`; multiple files return a zip. Async tasks go pending, started, success or failure.
- Auth [repo configuration.md]: `DOCLING_SERVE_API_KEY` is unset by default; when set, requests must carry an `X-Api-Key` header. So the default is open.
- Network posture: the README example shows `http://127.0.0.1:5001`, but the configuration doc says `UVICORN_HOST` defaults to `0.0.0.0` for `run` and `localhost` for `dev`. Port 5001. CORS defaults to `["*"]` for origins, methods and headers. These two sources disagree, so check which applies before exposing it. Remote services are off by default (`DOCLING_SERVE_ENABLE_REMOTE_SERVICES=false`). Engine kinds local, rq, ray. Local engine runs 2 worker threads and caches 2 converters; torch CPU threads default 4.
- Docker is optional: it runs from pip too (`docling-serve run`), but the published packaging is container images (cpu 4.4 GB, cu128 11.4 GB, cu130 size TBD, ROCm build-it-yourself; no `latest` tag on CUDA images) [repo].

**docling-mcp** [repo github.com/docling-project/docling-mcp].
- Licence MIT. Launch: `uvx --from docling-mcp docling-mcp-server --transport <stdio|sse|streamable-http>`.
- Tools I could confirm by name are only the document-generation ones: `create_new_docling_document`, `add_title_to_docling_document`, `open_list_in_docling_document`, `add_list_items_to_list_in_docling_document`, `close_list_in_docling_document`, `export_docling_document_to_markdown`. The README also says it converts PDFs to DoclingDocument JSON (no tool name given), supports Milvus-backed RAG, and has toolgroups chosen with `--tools` (`llama-index-rag`, `llama-stack-rag`, `llama-stack-ie`). The complete tool list is not on the README.
- Mode: `DOCLING_MCP_CONVERSION_MODE` defaults to `remote`, meaning it calls a docling-serve instance (`DOCLING_MCP_SERVICE_URL`, `DOCLING_MCP_SERVICE_API_KEY`); `local` needs the `docling-mcp[local]` extra and runs the Python library in-process; `DOCLING_MCP_FALLBACK_TO_LOCAL` defaults to false.
- Auth on the MCP endpoint itself: not described. Default host/port flags: not documented (an LM Studio example uses `http://localhost:8000/mcp`). The stdio transport is a local subprocess with no network listener [inferred from how stdio MCP works].
- Version note: docling-mcp >=3.0.0 needs `mcp>=2.0.0`; older clients pin `<3.0.0`.

**The usage skill.** Only the blog page mentions it [page]: it is shipped inside the Python package and linked into the agent's skills directory by `uvx library-skills`. I did not find the skill text and cannot say what it contains. The docling-mcp README has no mention of a skill.

---

## 5. What Softanza already has for documents

Everything here was read at `D:\GitHub\_wti`, `libraries\stzlib\`, commit `a6a59d4f6` (2026-09-26). `origin/main` of `D:\GitHub\stzlib` (`ceafcbb14`, 2026-10-19) shows the same engine file set under `engine/src` for the areas below.

**Not present at all.**
- **PDF**: no parser and no generator. `grep -i pdf` across all `engine/src/*.zig` hits only `graph.zig`, `listen.zig`, `special.zig`, `voice.zig` (I opened none of the first three matching lines, and `grep -niE "\bpdf\b"` on graph/listen/voice printed nothing, so those hits are probably a substring such as a probability-density function). In `base/` the `.ring` hits for "pdf" are unrelated files (cluster classifier, char data, DotCode, etc.). `base/binary/SOFTANZA_BINARY_PLAN.md` section 6 refuses PDF/ZIP/PNG/ELF as scope ("dedicated modules" instead) [read].
- **DOCX/XLSX/PPTX/OOXML**: no reader. A search for `docx|ooxml|xlsx|pptx` in `base/*.ring` matched one unrelated test (`test/stats/plot_engine_parity_narrated.ring`).
- **OCR engine**: none. `engine/src/voice.zig` only mentions OCR in comments (a measurement of what Windows offers). The plan `base/graphics/SOFTANZA_VISION_PLAN.md` (210 lines) states: `Windows.Media.Ocr.OcrEngine` offers exactly `ar-SA` and `fr-FR` on the author's machine; OCR took 10 ms on a rendered French line and read it exactly; Arabic was partly wrong (split at shaping gaps, words returned in visual order); `onnxruntime.dll` and DirectML are present on that Windows machine; "IMAGE → DATA analyse: missing, zero hits". Phase V1 (`stz_vision.dll`, per-OS OCR) is planned, not built.
- **Markdown parser**: no dedicated one found (`markdown` matches only data/education/meta files, not a parser).
- **ONNX**: no ONNX loader in the engine (only a mention in an archived list file).
- **Docling**: no mention anywhere in `origin/main` (`git grep -i docling` empty).

**Present, with names and paths** (`libraries\stzlib\...`).

| Capability | Where | What it can do |
|---|---|---|
| ZIP | `base/file/stzZipFile.ring`, class `stzZipFile` (295 lines) | create from files/dir/string (`CreateFrom`, `CreateFromDirectory`, `AddFile`, `AddString`), `ExtractTo`, `ListContents`, `FileCount`, `Contains`, `Size`. It calls Ring's own `zip_openfile`, `zip_addfile`, `zip_extract_allfiles`, `zip_getfilenamebyindex` functions (the Ring stdlib zip extension, not the Zig engine). Reading one entry's bytes out of a zip, in memory, is not among the methods listed, only extraction to a directory [read]. This matters for DOCX. |
| Deflate | `engine/vendor/zlib/` (deflate.c, inflate.c, inftrees.c, crc32.c...), built with flag `needs_zlib` (used by the PNG encoder in `engine/src/gpu_render.zig`) | zlib is available inside the engine for Flate streams. `engine/src/compressor.zig` is a different thing: CRC-32, Adler-32, RLE and a "simple" codec only, not deflate. |
| XML | `engine/src/xml.zig` (1,171 lines); Ring class `base/file/stzXml.ring` (325 lines) | strict namespace-aware parser plus exclusive C14N. It refuses any DOCTYPE/ENTITY by design (no XXE). Exported: `stz_xml_valid, _root, _text, _attr, _namespace, _count, _children, _pretty`. Stated limits: no DTD/XSD, no XPath. Enough to walk OOXML parts [inferred]. |
| HTML | `engine/src/html_dom.zig` (746 lines, flat tokenizer, find by tag/id/class, depth recorded, no tree, no CSS selectors), `engine/src/html.zig` (256 lines), Ring `base/file/stzHtml.ring` (399 lines) | tag/attribute/text extraction. Self-described as "NOT a spec-compliant HTML5 parser". |
| Tables | `engine/src/table.zig` (1,137 lines, columnar engine, sort/aggregate/groupby); Ring `base/table/stzTable.ring` (16,973 lines), `stzPivotTable.ring` | tabular data model. Docling's `TableItem` could land here [inferred]. No table-structure extraction from images or PDFs. |
| CSV, JSON | `engine/src/csv.zig`, `json.zig`; Ring `base/file/stzCSV.ring`, `stzJson.ring` | Docling JSON and CSV output are within reach. |
| Text, linguistics | `engine/src/text.zig` (paragraph splitting etc.), `string.zig` and `string/`, `natlang.zig`, `unicode*.zig`, vendored utf8proc, pcre2, snowball, SheenBidi, HarfBuzz; Ring `base/linguistic/` (`stzText.ring`, `stzCorpus.ring`, `stzParseTree.ring`...) | strong text handling. |
| Image decode | vendored `engine/vendor/stb/stb_image.h` plus `stb_truetype.h`, used in `engine/src/gpu_render.zig` ("memory-only", always RGBA8 out) | PNG/JPG/BMP etc. to RGBA8; reachable only through the `stz_gpu` module, which also needs wgpu [build.zig lines 128, 147]. A PDF-page-to-bitmap renderer does not exist. |
| Graphics, SVG | `engine/src/gpu_*.zig`, `base/graphics/` (`stzCanvas.ring`, `stzScene.ring`, `stzPlotCanvas.ring`...), PNG encoder in `gpu_render.zig`; SVG output in graph/diagram classes | production side only; the vision plan says this plane "can draw, and it cannot see". |
| Neural | `engine/src/neural*.zig` (see section 6) | ggml CPU inference for BERT-style encoders (embeddings) and llama-family text generation, with grammar-constrained decoding. |
| Docs folders | `base/doc/` (`deepdives`, `design`, `faqs`, `images`, `internals`, `narrations`, `quickers`, `references`, `stz-doc-system-overview.md`) | documentation of the library itself, not document processing. |

**Gap list.** PDF parsing/rendering; OOXML readers; in-memory zip entry read; Markdown parse/emit; an image-to-grid/analysis layer; image-input path in the neural module; OCR beyond what the OS offers; a DoclingDocument-like structured model and reading-order logic; layout and table-structure models.

---

## 6. Which stages could be native (Zig engine + ggml, CPU)

**What the engine's neural module has today** [read, `engine/src/neural_gen.zig` 1,354 lines, `neural_embed.zig` 956, `neural_backbone.zig` 922]:
- ggml is vendored CPU-only, compiled by Zig's clang with no CMake (`engine/vendor/ggml/NOTICE`, `build.zig addGgml`). The vendored `ggml.c` contains these ops that matter here: `conv_2d`, `conv_2d_dw`, `im2col`, `pool_2d`, `upscale`, `interpolate`, `group_norm`, `pad_ext`, `win_part/win_unpart`, `roll`, `flash_attn_ext`, `sigmoid`, `hardswish`, `gelu_erf`, `top_k`, `argsort`, `set_rows`, `rope_multi`, `conv_transpose_2d_p0` (grep of function names).
- The ops the neural code actually calls today are only transformer ones (`mul_mat`, `add`, `rms_norm`, `norm`, `rope_ext`, `soft_max_ext`, `get_rows`, `silu`, `gelu`, `concat`, permute/reshape/view). Nothing in it uses a convolution.
- `neural_gen.zig`: the header says it covers llama-family GGUF generation (arch names `llama`, `qwen2`, `qwen3`, `smollm`), RMSNorm + RoPE + GQA attention + SwiGLU + tied lm_head, a KV cache, greedy and sampled decoding, GPT-2 byte-level BPE read from the GGUF, grammar-constrained decoding (`neural_gen_set_grammar`, built on `gbnf_machine.zig`), repetition stop, and a streaming API. Every entry point takes a text prompt (`neural_gen_start(text, len, ...)`). A grep of the three neural files for `mmproj|vision|clip|image|inputs_embeds|siglip|idefics` found nothing: there is no way to feed embeddings or images into the decoder today.
- Known engine hazard for vendoring C++ [read, ggml NOTICE]: the Zig-built mingw DLL does not run C++ static initializers on Windows, including function-local statics, so any C++ code with dynamic statics crashes at first use unless patched. ggml needed several patches for this. It applies directly to the next two items.
- GPU is wired separately (`neural_gpu.zig`, wgpu), I did not read it in detail.

**Stage by stage.**

1. **PDF text/glyph/cell extraction** (needed first; it is the input to everything else for born-digital PDFs).
   - docling-parse [repo]: MIT, C++20, CMake, source about 1.77 MB of C++ plus 0.78 MB Python (GitHub language bytes). Its CMake lists dependencies qpdf v12, libjpeg, openjpeg, lcms2, freetype, blend2d, pdfium_jbig2, utf8, nlohmann json, loguru, cxxopts. It builds a static library `parse` and a pybind11 module. The README does not document a C++ library API, only a CLI and the Python API.
   - Vendoring that is possible by licence (MIT, and qpdf is Apache-2.0 per my own knowledge, not verified here), but it is the heaviest vendor yet: about ten sub-dependencies, C++20 with exceptions and statics. The static-initializer hazard above makes this high risk on the Windows DLL path [inferred].
   - The alternative is a native Zig PDF reader: xref and object streams, Flate (zlib already vendored), a content-stream interpreter with text state and graphics state, font handling (simple fonts, ToUnicode CMaps, CID fonts, embedded font programs for glyph widths), and output as positioned chars/words/lines. That is new code with many format corner cases, but it is dependency-free and testable against docling-parse output as an oracle. Rendering a page to a bitmap (needed for the layout model's 640x640 input, and for scans) is a second job: either a rasteriser over glyph outlines and paths, or reusing the engine's existing text and canvas stack [inferred]. For scanned PDFs the page is just an embedded image, which `stb_image` plus a DCT/JPX/CCITT decoder chain can cover partly (stb has no JPX or JBIG2).
   - Effort: large. Risk: high either way. Value: highest, since the born-digital path needs no neural model for text.

2. **Layout detector (RT-DETRv2).**
   - Facts: heron has 42.9M params and 640x640 input [card]. 42.9M in the RT-DETR family corresponds to the ResNet-50 variant, and heron-101 (76.7M) to ResNet-101 [inferred from the parameter counts; the card does not say]. The architecture, from the Transformers config [docs: HF RTDetrV2]: CNN backbone, a hybrid encoder (1 encoder layer, 8 heads, hidden 256, FFN 1024, multi-scale feature fusion), 300 object queries, a 6-layer decoder with deformable cross-attention over 3 feature levels, 4 sampling points, iterative box refinement. The class head has 17 labels.
   - ggml has the conv, pooling, upsampling, norm, sigmoid and top-k ops. BatchNorm can be folded into the convs at conversion time [inferred]. What is missing is the deformable attention's sampling step (`grid_sample`); the RT-DETRv2 paper adds a "discrete" sampling variant (`decoder_method: "discrete"` in the HF config) meant to avoid it [docs: HF RTDetrV2], which would reduce to gathers with computed indices. That still needs a custom op or a gather built from `get_rows`/`set_rows`, plus the query-selection and box-decode glue (sigmoid, inverse-sigmoid).
   - Conversion: a safetensors-to-GGUF converter with a new architecture tag, or a small ONNX reader that maps the 171 MB `model.onnx` graph to ggml ops (the ONNX route would need an operator subset interpreter; I did not inspect the ONNX op list).
   - Cost at runtime: no Docling number exists for CPU with the new heron. The v1 report claimed sub-second per page on a CPU for the older layout model [paper]. The engine has never run a convolutional net in anything I read, so its speed here is unmeasured.
   - Effort: medium to large (one new model family, 1 to 2 new ops, a converter, post-processing: threshold, overlap removal, matching boxes with PDF cells). Risk: medium.

3. **TableFormer.**
   - Facts: from the shipped `tm_config.json` (accurate): ResNet-18 backbone at 448x448 giving a 28x28 grid, a 6-layer transformer encoder, a 6-layer decoder, 8 heads, hidden 512, 13 structure tokens, beam 5, up to 1,024 decode steps, plus a bounding-box head that predicts one box per cell. Fast mode: 4 encoder and 2 decoder layers. File sizes 213 MB and 145 MB (F32) [card]. The config names `tag_attention_dim` and `bbox_attention_dim`, which suggests the decoder is not a plain transformer decoder; I did not read `tablemodel04_rs`, so the exact decoder wiring is unverified.
   - A conv backbone plus an autoregressive decoder with a KV cache is close to what `neural_gen.zig` already does for text, but it needs: a cross-attention over image features (not in the module today: the gen code is self-attention only), beam search (the module is greedy/sampled), a bbox head, and the cell-matching and OTSL-to-table post-processing, which in Docling is Python code in `docling-ibm-models` (MIT). I would port that logic by hand.
   - The report quotes 2 to 6 s per table on CPU [paper], the slowest non-OCR stage; the fast model halves the layers.
   - Effort: medium to large. Risk: medium (decoder wiring unverified, post-processing is fiddly, quality needs an oracle against the Python output).

4. **OCR.**
   - Tesseract: Apache-2.0 C++ with Leptonica (BSD-style) [from my own knowledge, not fetched here]. Vendoring would repeat the C++ static-initializer risk, and it is a large code base. Docling supports it via CLI or the tesserocr binding [docs].
   - RapidOCR / PaddleOCR: code Apache-2.0, models Apache-2.0 and shipped as ONNX [repo RapidAI/RapidOCR]. Detection (DB-style conv net with a polygon post-process) plus recognition (CTC over a small CNN/transformer) plus a text-direction classifier. The ops are convs, depthwise convs, hardswish, upsampling, small transformers/LSTMs: mostly in ggml. Needs the DB post-processing (contour tracing and polygon offsetting) written natively. Model sizes were not stated by any page I read.
   - EasyOCR (PyTorch, Python) is the one Docling says is slow on CPU (30+ s/page [paper]) and is not a candidate.
   - Windows OCR already exists on the machine but covers only the languages the user installed (ar-SA and fr-FR per the vision plan) and has an Arabic-word-boundary fault, so it cannot be the shipped path.
   - An alternative to hand-porting is vendoring ONNX Runtime (MIT, I believe; not verified) and running the RapidOCR and layout ONNX files unchanged. That is a large binary with its own C++ static-init concerns, so I would treat it as a fallback, not a plan. This is a design option, not something I measured.
   - Effort: medium for the recogniser, medium for detection plus post-processing. Risk: medium; quality for Arabic/French depends on which Paddle models exist for those scripts, which I did not check.

5. **Document VLM as GGUF (Granite-Docling-258M).**
   - It is the best fit by size and by what already exists. The decoder is a 30-layer llama-arch model with hidden 576, 9 heads, 3 KV heads, vocab 100,352, rope 100k, tied embeddings [card config]. That is within the family `neural_gen.zig` already runs (RMSNorm, RoPE, GQA, SwiGLU, KV cache, BPE tokenizer from the GGUF). One thing to verify before trusting this: IBM's Granite family sometimes uses extra scale factors (embedding, residual, attention multipliers); the config reports `model_type: llama`, so probably not here, but I did not confirm [unverified].
   - Official GGUF with projector exists (BF16 332 MB + F16 mmproj 190 MB) [card]. So the conversion work is already done by IBM, and it proves a llama.cpp-style split.
   - Missing in the engine: (a) the vision tower, a SigLIP2 ViT of 12 layers, hidden 768, 12 heads, patch 16, 512x512 tile (strided conv patch embedding, learned positions, LayerNorm, GELU MLP, full attention); the existing encoder code in `neural_embed.zig` for BERT-style models is the nearest thing and may be largely reusable, plus one `conv_2d` for the patch embed; (b) the pixel-shuffle connector (reshape/permute) and a projection to 576; (c) image preprocessing: resize, tile into 512 px pieces up to a 2048 longest edge, normalise; (d) a decoder entry point that accepts embeddings or an interleaved text/image-embedding prefill instead of only token ids (the current API is text only); (e) DocTags handling: the `<loc_*>` position tokens must exist in the tokenizer (they are in the model's vocabulary per the card; I did not inspect the token list), and a DocTags-to-DoclingDocument converter.
   - Useful existing asset: the grammar-constrained decoder (`gbnf_machine.zig`) could constrain output to well-formed DocTags, which is the engine's "structure kills malformedness" idea.
   - Cost: unknown on CPU. The only VLM CPU-class numbers published are for much larger models on a laptop and are not usable. The decode length is the driver: the Docling VLM defaults allow 4,096 new tokens per page [docs gpu.md], and a dense page of DocTags is long. Throughput of a 165M decoder on this engine is unmeasured, so I will not guess a pages/second figure.
   - Effort: medium (one new tower, one entry point, one converter), plus a long accuracy campaign, since DocTags quality is only checkable against Docling's own output. Risk: medium; it is the stage where "same weights, same output" can be tested token by token against llama.cpp.

**Summary of risk order** (highest first): native PDF parsing or docling-parse vendoring; Tesseract vendoring; TableFormer post-processing; layout model deformable sampling; VLM tower and embedding entry point; OOXML via existing zip + xml (low).

**What needs no neural model at all.** DOCX/PPTX/XLSX (zip + XML), HTML, Markdown, CSV: Docling's own `SimplePipeline` formats run no model [docs FAQ]. Softanza has zip and XML in hand; the gap there is a reader producing structure, plus in-memory zip entry reads.

---

## 7. The three facts that matter most for a no-Python, Zig-engine product

1. **Docling is not shippable as-is.** Every model stage runs through PyTorch, transformers or onnxruntime (pyproject: torch and docling-ibm-models only under optional extras). The serve image is 4.4 to 11.4 GB. But the pieces are MIT/Apache-2.0 permissively licensed (Docling, docling-parse, docling-ibm-models, docling-serve, docling-mcp: MIT; heron: Apache-2.0; Granite-Docling: Apache-2.0; RapidOCR: Apache-2.0), so a native port of the weights is legally open. Exceptions to check: TableFormer v1 weights carry two licence tags (cdla-permissive-2.0 and apache-2.0) and SmolDocling's card is inconsistent.
2. **The best native lever is the small VLM.** Granite-Docling-258M is a llama-architecture 165M decoder plus a 12-layer SigLIP2 encoder, 515 MB in BF16, with an official GGUF + mmproj pair already published. The engine's `neural_gen.zig` already runs the decoder family; what is missing is the vision tower and an embedding-prefill entry point, and nothing in the engine takes images into the neural code today.
3. **Born-digital PDF needs a parser, not a model, and Softanza has none.** The engine has no PDF code at all, no OCR, no OOXML reader. docling-parse (MIT, C++20 with ~10 dependencies) is the reference, but this engine's own notes say C++ static initializers do not run in its Windows DLLs, so vendoring it is risky. Published speed is only known for the Python stack (e.g. 1.27 pages/s on an M3 Max, 0.60 on a Xeon E5-2690, native backend, no OCR); no number exists for the RTX 3050 or for any CPU VLM run.

---

## 8. Verified vs not verified

**Verified on the live web this session** (through fetch summaries):
- Blog page content and what it omits. Docling MIT, v2.141.0 released 2026-10-20, pyproject extras and the Python >=3.10 requirement.
- Heron card (RT-DETRv2, 42.9M, Apache-2.0, 17 classes), heron-onnx file size 171,220,471 bytes and 640x640 preprocessor, the model list and sizes on the org page (egret, heron-101, TableFormerV2).
- TableFormer file sizes, accurate and fast configs (ResNet-18, 448, layers, tokens, beam, max steps).
- Granite-Docling card (Apache-2.0, Idefics3, SigLIP2-base-patch16-512, Granite 165M, DocTags), `config.json` and `preprocessor_config.json`, file size 515,093,104 bytes. Official GGUF repo exists with BF16 331,641,120 bytes and mmproj F16 190,031,712 bytes.
- Report v1 and v2 numbers (through arXiv HTML); GPU guide table (two fetches agreeing); VLM per-page table; docling-serve endpoints, options, env vars and defaults; docling-mcp env vars, transports and named tools; docling-parse dependencies from CMakeLists; DocumentFigureClassifier (MIT), CodeFormulaV2 (CDLA-Permissive-2.0); RapidOCR licence statement.
- Local files read: `neural_gen.zig` header and exports, ggml op list from `ggml.c`, `stzZipFile.ring`, `xml.zig`, `html_dom.zig`, `table.zig` headers, vendor list, `SOFTANZA_VISION_PLAN.md`, `SOFTANZA_BINARY_PLAN.md` refusals, git refs of both trees.

**Not verified or uncertain:**
- The arXiv PDFs could not be decoded; I used the arXiv HTML renderings, which I could not cross-check against the PDFs. The v1 HTML says the layout model runs on onnxruntime while the v2 HTML says transformers/safetensors; the docs model catalog says the ONNX Runtime path for Heron is "in progress". I did not reconcile this.
- What "RTX Spark" is.
- The SmolDocling licence (card header says cdla-permissive-2.0, summary says Apache-2.0).
- Which licence applies to which TableFormer v1 file; DocLayNet's own licence; licences of EasyOCR, Tesseract, Surya, Leptonica, qpdf, ONNX Runtime (my statements about them are from general knowledge and are marked as such).
- The exact decoder structure of TableFormer (`tablemodel04_rs` source not read) and the backbone depth of heron (R50 is my inference from parameter count).
- The Granite-Docling `<loc_*>` token set and whether any Granite-specific scaling factors apply.
- That llama.cpp actually runs the Granite-Docling GGUF (the pair exists; I did not run it, and llama.cpp's multimodal README does not list Idefics3 by name).
- The default OCR engine in practice: source code says `OcrAutoOptions` (EasyOCR if GPU present, Tesseract otherwise); the install extra for the standard bundle is RapidOCR; third-party pages disagree. I report the source line.
- Any VRAM figure for any Docling stage; any RTX 3050 or CPU-VLM throughput; RapidOCR model sizes; ONNX op list of the heron model.
- The Docling usage skill's contents; the full docling-mcp tool list; the DoclingDocument JSON schema field names.
- The reading-order algorithm details.
- Engine effort statements are judgements from reading the module headers, not from a build or a prototype.
