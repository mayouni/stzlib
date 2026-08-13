# SOFTANZA VISION — plan of record

Closing the graphics plane's loop: it can **draw**, and it cannot **see**.

Transposed from the sound plane's SN0–SN6 and its voice plan, but **not**
transposed blindly — §0 is a correction of what that transposition assumed.

---

## 0. What the brief expected, and what this machine actually does

The brief that opened this session was written from the sound side. It was
right about the shape and wrong about one thing that changes a phase.

### Verified, and it holds

`Windows.Media.Ocr.OcrEngine` offers exactly **`ar-SA` and `fr-FR`** here.
`DirectML.dll` and `Windows.AI.MachineLearning.dll` are present — and so is
**`onnxruntime.dll`**, which the brief did not mention and which matters,
because it is a far shorter path to a local model than DirectML alone.

Searched `base/graphics/` for `ocr|recogni|classif|image analysis`: **zero
files**. The finding stands — this plane is production-side.

### The round trip closes in French, exactly

`stzCanvas` rendered two lines to PNG; OCR read them back:

```
ELAPSED_MS 10
Le disque est presque plein Softanza rend, puis relit
9 words, each with a bounding box
```

Perfect, including the comma in `rend,` and the invented word `Softanza` —
so it is reading glyphs, not guessing from a language model. **10 ms.**
This is the plane's VC0 and it is already proven.

### THE CORRECTION — Arabic does NOT arrive for free

The brief: *"an RTL cursive script working natively is not a footnote; it
is the hardest case arriving for free, and it belongs in the first guard."*

Measured. `stzCanvas` rendered `مرحبا بالعالم` through the SheenBidi →
HarfBuzz → stb pipeline. **The render is correct** — the gap after `مر` is
proper shaping, because ر is a non-connecting letter. OCR at `ar-SA`, 10 ms:

| | |
|---|---|
| `بالعالم` | read **exactly** |
| `مرحبا` | **split at the shaping gap** into `حبا` + a misread `ور` |

Two further facts, both design-relevant:

1. **It segments on visual gaps, not on words.** Arabic's non-connecting
   letters produce intra-word gaps by design, so a word-box API that is
   trusted will report word boundaries that are not word boundaries.
2. **It returns words in visual left-to-right order, not logical order.**
   `بالعالم` came back first though it is the second word logically.

**So Arabic OCR is available, fast, and partly wrong — and the failure is
in exactly the place this library cares most about.** It belongs in the
first guard, as the brief said, but as a **measured limitation**, not a
free win. A guard that asserted "Arabic works" would have been green on
one word out of two.

**This is the contradiction this session was asked to report.** The brief's
reasoning was sound and its conclusion was wrong, for a reason only visible
on the machine: the platform's OCR does not model Arabic morphology.

---

## 1. The four transforms, honestly scored

| transform | graphics | evidence |
|---|---|---|
| `DATA → IMAGE` **render** | **owned**, the library's strongest asset | GR0–GR6, the graph/material/diagram planes |
| `IMAGE → DATA` **analyse** | **missing** | zero hits; no shortcut exists — this is ours to build |
| `TEXT → IMAGE` **generate** | **owned deterministically**, absent neurally | see §2 |
| `IMAGE → TEXT` **describe** | **platform, measured** | fr-FR exact; ar-SA partial |

---

## 2. `TEXT → IMAGE` is two different things, and conflating them is the
   error this plan exists to avoid

**Deterministic generation is already shipped and is the default.**
`stzPlotCanvas` turns data into a chart. `stzDiagram` turns a declaration
into a picture with no external binary. `stzMaterialGraph` turns a node
graph into a surface. These are image generation, and they are **exact,
reproducible and explainable** rather than plausible.

That is not a nostalgic preference. **This plane's method is "assert the
mechanism, and give every positive a negative sibling". A diffusion model's
output is not assertable** — there is no guard for "the picture is right".
So the deterministic generator stays the default *because* it is guardable.

**Neural generation is quarantined**: its own phase, its own tier, its own
licence and weight-provenance question, and an explicit statement that
output crossing that boundary leaves the guarded part of the library.

---

## 3. The interchange: an analysis returns a GRID, never a picture

Taken whole from the sound plane, whose one-sentence reason is unimprovable:
*"the 1 kHz sine is in the 1 kHz bin" is a claim a guard can check; "the
spectrogram looks right" is a claim about nothing.*

**The naming question the brief asked me to decide.** It expected a
collision with `base/list/stzGrid.ring`. There is none: `stzGrid` is a
*positional navigator* that explicitly **"doesn't host data itself"**;
`stzSoundGrid` *holds* rows × columns of f64 plus axis meaning. Different
objects. So: **`stzImageGrid`**, following the existing precedent, and no
generalisation until a third caller wants one.

**The realisation to build on:** a spectrogram and a greyscale image are the
same object — rows × columns of magnitude with axis meaning. Not an analogy.
Every image operation applies to a spectrogram, and a 2D FFT is a row pass
then a column pass over `fft.zig`, which already exists.

**Invertibility must be carried IN the grid.** `IMAGE → DATA → IMAGE` is
lossless when the grid *is* the pixels. `SOUND → DATA → SOUND` is not — a
magnitude spectrogram discards phase. A grid says which it is, and an
inversion that guessed phase says that it guessed.

---

## 4. Phases

**V0 — `AddImage`. DONE, ahead of this plan.** The sound plane's standing
SN5 request: a spectrogram cost 1,574 rects / 88 ms / 104 KB of SVG.
Measured after: **1,024 commands → 1**, **69,439 chars of SVG → 1,762**.
Both tiers carry it. It is also the primitive `IMAGE → DATA` needs, so it
was owed twice. Guard `gg_image_primitive.ring` (14).

**V1 — `IMAGE → TEXT`, in a `stz_vision.dll`.**
Per-OS, beside `stz_audiodev.dll`, and the portable tier must not link it.
Report capability **per language and per direction**, and **refuse rather
than substitute**.
*Kill:* the round trip is already measured at 10 ms and exact in French, so
the kill line is not accuracy — it is **honesty**: if the face cannot
report that `ar-SA` splits words at shaping gaps and returns visual order,
it is worse than no face, because a caller would trust it.

**V2 — `IMAGE → DATA`, and `stzImageGrid`.**
Threshold, histogram, morphology (open/close/median), edges, connected
components, 2D FFT. Engine-side, in the portable DLL.
*Inherit the measured finding:* `fft.zig`'s twiddle table was **3.1× at
N=131k and no win at N=4M** (16 MB, cache cliff). An image FFT lands in
that range — **measure before tabulating**.
*Kill:* if a grid returned here cannot be handed to the sound plane's
spectrogram operations and back without conversion, invariant 2 is not
real and this is two libraries wearing one name.

**V3 — the debt repaid: audio restoration through image morphology.**
Take a recording's spectrogram, median-filter it as an image, invert back.
The composition that is only expressible because both planes agreed on the
grid *before* either needed it.
*Kill:* if inversion cannot state its phase loss, it is a demo.

**V4 — the legibility gate for vision.**
Colour has 4.5:1 (C3). Sound has the LU margin. **Vision needs a third**,
and a cross-modal translation must pass *both* channels' gates. Nobody
ships this; without it, modality translation produces output that is
technically present and practically unreadable.
*Kill:* if no measurable vision gate can be stated, say so — an unstated
gate is worse than a missing one.

**V5 — neural generation, quarantined.** Only after V1–V4. `onnxruntime.dll`
is present, which shortens the path; the licence and provenance question is
answered **before** a byte is vendored.

---

## 5. Limits that change a design decision

1. **Latency is dominated by the channel you would not guess.** OCR 10 ms;
   audio output ~419 ms native, ~10 ms in a browser. A `camera → OCR →
   voice` loop is bounded by **audio**, not vision — so cross-modal
   *interaction* lives in the browser tier, not the native one.
2. **Dimensionality does not match and there is no canonical fix.** An
   `IMAGE → SOUND` mapping must choose what becomes time. The library
   offers the mapping and **must not pick one**; picking silently would
   make sonification unreproducible across versions.
3. **Five semantic values translate STATE, not CONTENT.** The semantic
   layer carries status; the grid carries content. Conflating them is how
   "one declaration, every channel" collapses under its own generality.
4. **The frame budget is the ceiling.** Cheap features on the frame path,
   heavy analysis off it — said per phase, or the first game that uses it
   stutters and the wrong plane is blamed.
5. **Warm-up is real.** Sound measured a cold synthesis at 4.3× a warm one.
   Expect the same of a first OCR call and a first model load; warm out of
   band.
6. **A wasm static array's size is DOWNLOAD size.** The sound plane's
   per-node delay lines produced a 26 MB module against 182 KB pooled.
   Image buffers are far larger than audio buffers.

---

## 6. The claim that survives

Not "any medium converts to any other" — limits 1–3 say why that is false.

**Two media, analysed into one data model, with one semantic vocabulary
above them and one legibility gate per channel — so a transformation
written for one medium is available to the other, and a state declared once
renders to whichever channel the operator can actually receive.**

Small enough to be true, and unusual enough to be worth building.
