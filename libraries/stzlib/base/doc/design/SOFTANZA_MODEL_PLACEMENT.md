# Model placement: models and engines where you build, and where you deploy

*stzlib-intelligence, 2026-11-05, at the author's direction: "Softanza must think and design for programmer experience and ease of use,
discovery, setup, and embedding of such external models and engines depending on the development and the deployment platforms. It must also
provide whatever tools made specifically for that task to help developers see the real picture, take the good decisions, and think about what
Softanza takes as a default choice to get the job done."*

---

## 0. Why now -- the defect that asked for it

The court became the registry's default gate on 2026-11-05 (`SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md` section 8). Applied to `:ocr`, it showed
a fault that was there before the court and that the court only made visible: **the registry measured CAPABILITY as if it were QUALITY.**
The platform OCR floor (the operating system's engine) can read a language only where that machine has its language pack. The machine that
measured `:ocr` has French and Arabic packs and no Russian or English one; so the floor "scored 0 of 9" in Russian, and the shipped evidence
says the model beat it 8 to 0. On a developer's Windows machine with the Russian pack, that evidence is false; on Linux or macOS the floor does
not exist at all. `:faces` has the same shape: its floor is the Windows face detector. A choice made from such evidence is right only on the
machine that made it -- and Softanza's users build on one machine and deploy to another.

## 1. The questions a developer actually has

| when | the question | what answers it today | what must answer it |
|---|---|---|---|
| discovering | what can Softanza do with models, and with which ones? | `MODELS.md`, prose | a **catalogue** the library reads: every model it knows, what faculty it serves, size, licence, source, digest |
| setting up | what do I need to install for this faculty, here? | reading guards | a **setup plan**: the files to fetch, from where, how big, which licence, how to verify them -- never a silent download |
| developing | what does my program do HERE, and why? | `Why()`, one faculty at a time | a **report** of every faculty on this machine: what can run, what is chosen, on what evidence, what is missing |
| deploying | what will it do THERE (a Linux container, a Windows server, a laptop)? | nothing | the same report **for a declared target**, resolved without being on it |
| shipping | what must travel with my app, and is it intact? | nothing | a **bundle manifest**: the model files and their digests, checked at start-up |
| deciding | is installing that model worth it? | nothing | the **measured gain**, with the court's verdict, beside the cost (MB, memory, ms) |

## 2. The three things the registry must keep apart

1. **CAPABILITY -- can this implementation run here, for this input?** A fact about the machine, checked by a cheap probe that runs no
   inference: the files present and their digests right; the operating system the implementation exists on; the language pack installed;
   the memory available. Never measured on a golden set, never inferred from a failure.
2. **QUALITY -- where two implementations can both run, which is better?** Measured on golden sets, judged by the court. An item one of them
   could not run is UNAVAILABLE for that pair: it is neither a gain nor a loss, and it is not evidence.
3. **THE DEFAULT -- what Softanza chooses when the developer chooses nothing.** A policy over 1 and 2, written once, stated in every Why.

Every implementation has a kind that says where its capability comes from:

| kind | runs where | capability depends on | examples |
|---|---|---|---|
| floor | everywhere Ring runs | nothing | the fixed sentence, keyword rules, trim-and-lower |
| graph (engine) | every platform the engine is built for | the model file (and its digest), memory | yolox, siglip2, ppocr, owlvit, smolvlm |
| platform | ONE operating system | the OS, its version, its packs | Windows OCR, Windows face detector, SAPI speech |
| service | over the network | a key, a network, a grant -- never chosen implicitly | a hosted model |

## 3. The default, written down

What Softanza chooses, in this order, for a faculty and an input:

1. **The available implementations only.** Capability is checked first; an unavailable implementation is set aside with its reason, exactly
   as an uninstalled model is today. A floor that is unavailable here is set aside too.
2. **Among them, the court decides** on evidence from items both could run: the incumbent holds unless a challenger is upheld against it and
   against the floor.
3. **If the floor is unavailable**, the court sits without it: the best measured available implementation answers, and the Why says the floor
   is unavailable here and why.
4. **If nothing is available**, the answer is a REFUSAL that is a setup plan: what to install to make this faculty answer here.
5. **Never** a network service unless pinned by name; **never** a model file whose digest is not the recorded one; **never** a silent download.

The portable kinds (floor, graph) are what a deployment can count on. A platform implementation is a bonus where it exists and is never the
only thing a faculty can stand on in a shipped default.

## 4. The evidence carries where it came from

A measurement row and a court record carry a **profile**: the operating system, and for platform implementations their capability set at
measurement time (`ocr:platform` with packs `ar-SA, fr-FR`). The registry uses a comparison only where the implementations were both
available; the report shows the profile, so "measured on a Windows machine with French and Arabic" is visible, not buried in a comment.

## 5. The tools

| tool | what it gives | rung |
|---|---|---|
| `StzModelsReport()` | every faculty on THIS machine: implementations, available or not and why, measured score, court verdict, the choice -- as text, and as a page (`StzModelsReportPage(path)`) a person can look at | MP1 |
| `StzModelsReportFor(target)` | the same for a declared target: `:linux`, `:macos`, `:windows`, or a profile (`[ :os = "linux", :packs = [], :models = [ ... ] ]`) -- what WOULD answer there | MP2 |
| `StzModelCatalog()` | every model Softanza knows (read from a machine-readable `models/catalog.zcat`, the table `MODELS.md` is written from): faculty, size, licence, source, sha256, the measured gain | MP3 |
| `StzModelSetupPlan(faculty)` | what to fetch to make a faculty answer (or answer better) here: files, URLs, sizes, licences, the command, the digest check; it fetches nothing | MP3 |
| `StzModelDoctor()` | every model file present against its digest, every engine DLL loadable, every platform pack, every faculty's evidence present; each problem with its fix | MP4 |
| `StzModelBundle(faculties)` | the manifest of what must ship with an app for those faculties, digests included; `StzModelBundleCheck(manifest)` at start-up | MP5 |
| a CI exit code | `StzModelsReportFor(target)` returns a status a deployment script can fail on: a required faculty that would REFUSE on the target | MP2 |

All of them read the registry's own data; none decides anything the registry does not. They are views, so they cannot disagree with it.

## 6. The rungs

- **MP0 -- capability before quality.** Implementation specs gain `:available` (a probe: `fn(input, params) -> [ ok, reason ]`) and
  `:platforms` (`[ "windows" ]` for a platform kind). The registry's hard filters set aside an unavailable implementation with its reason,
  floor included; the court sits with the available ones; measurement marks an item unavailable for an implementation instead of wrong, and
  court counts skip it. `:ocr` and `:faces` declare their platform floors' probes. The OCR and faces evidence is re-measured.
  *Kill:* if a guard can make the registry choose an implementation that cannot run, or refuse while an available measured one exists.
- **MP1 -- the report, here.** Text and page; the perception gate applies: the page is looked at.
- **MP2 -- the report, there.** Profiles; the CI status.
- **MP3 -- catalogue and setup plan.** `catalog.zcat` beside `MODELS.md`, MODELS.md generated from it.
- **MP3b -- release and fetch.** The converted files published under org softanza; a verified fetch.
- **MP4 -- the doctor.**
- **MP5 -- the bundle.**

## 7. Status (2026-11-05)

- **The court is the default gate** (`SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md` section 8): `StzRunGoldens` records the evidence of every pair it
  measures; a guard that scores by hand records it with `StzRecordCourtFromVerdicts`; every shipped faculty was convened by its own guard and the
  shipped files (`base/image/vision.court.txt`, 64 counts, 12 incumbents; `base/ocr/ocr.court.txt`, 8 counts) were merged by
  `_rig/court_merge.py`, which proves each count belongs to the shipped scores. Today's choices are the incumbents.
- **MP0 done**: `:platforms` and `:available` on every implementation spec (`SetAvailability`); the OCR floor's probe reads the machine's packs
  once per process; the faces floor is declared Windows-only. Measurement leaves out what could not run; the court compares only items both could
  run; a floor that cannot run is no bar and no fallback; nothing available is a refusal naming what is missing. Guard `placement_narrated.ring`.
- **MP1 done**: `StzModelsReport()`, `StzModelsReportText()`, `StzModelsReportPage(path)`.
- **MP2 begun**: `StzModelsReportFor("linux" | "macos" | "windows")` resolves the operating-system axis. A probe that reads THIS machine (an OCR
  pack) is not yet replaced by the target's: profiles with packs and shipped models are MP2's remaining half.
- **MP3 done** (2026-11-05): `models/catalog.zcat` -- every file a faculty needs (26), what each implementation requires (20 rows, per
  language where it differs), what a platform implementation needs from the operating system (2), and which conversions were replayed;
  `StzModelCatalog()`, `StzImplementationFiles()`, `StzModelFileState()`, `StzModelVerify()`, `StzModelSetupPlan(faculty)` and
  `StzModelSetupPlanText(faculty)`; the report page gains *What you could install here*. Capability now includes "the files it needs are here",
  a floor included (`:find`'s floor quietly needs `yolox_tiny.gguf`). Guard `catalog_narrated.ring` (16). **Replaying the steps found three
  wrong records**: the converter read `--kind rec` (as its own usage line wrote it) as no kind at all, so the catalogue's first OCR steps made a
  recogniser without its dictionary -- the usage line is corrected and the converter now refuses an option without a value; `MODELS.md` had
  SigLIP2's vision tower 3,072 bytes short; and the five OCR model files were in no record at all. Twelve conversions now reproduce their file
  byte for byte; OWL-ViT's two (torch exports) and the Arabic and Cyrillic recognisers (no source on this machine) are marked not replayed.
- **MP3b built** (2026-11-05, the author's word: "Hugging Face, org softanza"). The machinery is library code; nothing is uploaded by it.
  - *The gate* (`StzModelPublishGate`): only a file Softanza CONVERTED, under a permissive licence, named by a `repo` row whose licence TEXT
    is in `models/licences/`. 17 files pass, in nine repositories; the 8 downloaded files are linked to their upstream, never republished;
    the refused OWL-ViT shift patch is derived, so it is remade, never published.
  - *The stager* (`StzModelReleaseStage(version, folder, repos)`): one folder per repository with the catalogued bytes (each copy checked
    again), a model card (hub metadata; what the files are and are not -- not llama.cpp models; each file's sha256, source and steps; what
    Softanza measured and the court's word; the limits of that), the licence text, a notice, `SHA256SUMS`, a manifest Softanza itself
    reads; and `upload.ps1` that the AUTHOR runs signed in (`hf repos create`, `hf upload`, `hf repos tag create`). A repository whose
    bytes are not the catalogued ones is not staged and its script uploads nothing.
  - *The fetch* (`StzModelFetchFile(path)`, `StzModelFetch(faculty)`; engine `StzEngineHttpDownloadVerified`): the developer's explicit
    call, streamed to `<path>.part` while hashed, renamed only with the catalogue's sha256 and size; anything else leaves nothing at the
    path. A converted file is read from a PUBLISHED release's hub revision (`release` rows, written by `StzModelReleaseMark`), never from
    a moving branch; the hub is a mirror and the catalogue in git is the authority. The setup plan prints a `fetch` line wherever one exists.
  - *Load-time digests, which the release needed and found missing*: graph models and VLM projectors reached the GGUF parser with no
    digest check -- only the decoders had one, while the threat model's G23 said every model file did. `ocr_graph.load` and the projector
    load now refuse a file whose sha256 is not recorded, from `SHA256SUMS` files the catalogue generates (`StzModelSumsWrite`); a patched
    model the process wrote itself is trusted in that process (`weights.removeDirection`).
  *And one defect the gate run found*: the catalogue (MP3) and the registry's loaders split lines with Ring's `split()`, which reads the
  global `NL` -- and `image_quality_narrated.ring` writes `nL = len(aLines)` at its line 50, so the next catalogue read raised inside the
  standard library. The faculty modules now split with `_StzFieldsBy` and count words with `_StzWordCount`, which read nothing global;
  at least 188 other library lines in 46 files still call `split()` and carry the same exposure.
  Guard `release_narrated.ring` (52), offline: every exchange is with the engine's loopback server. **Owed**: the author's upload, then
  one `release` row per repository; until then every converted file's fetch source is empty and the setup plan gives the steps.
- **MP4 (the doctor) and MP5 (the bundle) open.**

**What the court and MP0 changed, faculty by faculty** (every other faculty keeps its choice, now on evidence):

| faculty | before | now | the evidence |
|---|---|---|---|
| `:faces` | yunet | the platform floor on Windows; **yunet on Linux and macOS** | yunet 3 better, 1 worse of 30 against the platform detector (P = 0.31): never proven where both run |
| `:doc-vlm` | granite-docling-258m | **the native reader** (the floor) | Granite 8 better, 2 worse of 27 pages: P = 56/1024 = 0.055, just above 0.05 -- a larger golden set would decide it |
| `:ocr`, whole set | ppocr | the platform floor where it runs | measured on the 17 items it can run here, the floor is better on Arabic (5 to 0) and ties French; Russian is no longer evidence |
| `:ocr` in a language with no pack here (Russian, English, ...) | the whole set's choice | **ppocr** | the floor cannot run it: set aside before any measurement is read |
| `:ocr` on Linux and macOS | -- | **ppocr** | the platform engine exists only on Windows |

## 8. What the developer sees on this machine (MP1, as it ran: `? StzModelsReportText()`)

```
SOFTANZA MODELS -- windows, this machine

:faces                 platform                 no model was proven better here
> platform               floor   0.80 (n=30)      
  yunet                  graph   0.87 (n=30)      incumbent; refused over platform (3 better, 1 worse)

:objects               yolox-tiny               incumbent; upheld over nothing (35 better, 0 worse)
  nothing                floor   0 (n=40)         
  yolox-nano             graph   0.85 (n=40)      refused over yolox-tiny (2 better, 3 worse)
> yolox-tiny             graph   0.88 (n=40)      incumbent; upheld over nothing (35 better, 0 worse)

:image-label           siglip2                  incumbent; upheld over prior (33 better, 0 worse)
  prior                  floor   0 (n=40)         
  mobilenetv3            graph   0.62 (n=40)      refused over siglip2 (0 better, 8 worse)
> siglip2                graph   0.82 (n=40)      incumbent; upheld over prior (33 better, 0 worse)

:foreground            u2netp                   incumbent; upheld over classical (19 better, 1 worse)
  classical              floor   0.10 (n=30)      
> u2netp                 graph   0.70 (n=30)      incumbent; upheld over classical (19 better, 1 worse)

:object-at             mobilesam                incumbent; upheld over classical (17 better, 2 worse)
  classical              floor   0.13 (n=30)      
> mobilesam              graph   0.63 (n=30)      incumbent; upheld over classical (17 better, 2 worse)

:depth                 depth-anything-v2-small  incumbent; upheld over lower-is-nearer (24 better, 0 worse)
  lower-is-nearer        floor   0.31 (n=78)      
> depth-anything-v2-small graph   0.62 (n=78)      incumbent; upheld over lower-is-nearer (24 better, 0 worse)

:describe              smolvlm-256m             incumbent; upheld over fixed (47 better, 4 worse)
  fixed                  floor   0.44 (n=99)      
> smolvlm-256m           graph   0.88 (n=99)      incumbent; upheld over fixed (47 better, 4 worse)
  smolvlm-500m           graph   0.87 (n=99)      refused over smolvlm-256m (9 better, 10 worse)

:doc-vlm               native-reader            no model was proven better here
> native-reader          floor   0.22 (n=27)      
  granite-docling-258m   graph   0.44 (n=27)      incumbent; refused over native-reader (8 better, 2 worse)
  native-plus-granite    graph   0.37 (n=27)      refused over granite-docling-258m (2 better, 4 worse)

:codes                 quirc-native1d           incumbent; upheld over nothing (362 better, 0 worse)
  nothing                floor   0 (n=366)        
> quirc-native1d         graph   0.99 (n=366)     incumbent; upheld over nothing (362 better, 0 worse)

:near-duplicate        siglip2-cosine           incumbent; upheld over identical-pixels (390 better, 0 worse)
  identical-pixels       floor   0.50 (n=780)     
  phash                  graph   1 (n=780)        refused over siglip2-cosine (0 better, 1 worse)
> siglip2-cosine         graph   1 (n=780)        incumbent; upheld over identical-pixels (390 better, 0 worse)

:find                  owlvit+warm-rule         upheld over owlvit (10 better, 1 worse)
  yolox-by-name          floor   0.63 (n=952)     
  owlvit                 graph   0.82 (n=952)     incumbent; upheld over yolox-by-name (226 better, 38 worse)
> owlvit+warm-rule       graph   0.83 (n=952)     upheld over owlvit (10 better, 1 worse)
  owlvit+shift-patch     graph   0.83 (n=952)     refused over owlvit (44 better, 37 worse)

:ocr                   platform                 no model was proven better here
> platform               floor   0.82 (n=17)      
  ppocr                  graph   0.65 (n=26)      refused over platform (0 better, 5 worse)

:ocr [fr]              platform                 no model was proven better here
> platform               floor   1 (n=9)          
  ppocr                  graph   1 (n=9)          refused over platform (0 better, 0 worse)

:ocr [ar]              platform                 no model was proven better here
> platform               floor   0.62 (n=8)       
  ppocr                  graph   0 (n=8)          refused over platform (0 better, 5 worse)

:ocr [ru]              ppocr                    the floor cannot run here
  platform               floor   UNAVAILABLE: no 'ru' language pack here (installed: ar-SA, fr-FR)
> ppocr                  graph   0.89 (n=9)       no comparison here: platform cannot run
```
