# SOFTANZA SOUND PLAN — analysis and phased plan (SN0–SN6)

Status: PLAN OF RECORD, written 2026-08-09, before any code. Siblings:
`base/gpu/SOFTANZA_GPU_PLAN.md` (G0–G6, complete) and
`base/graphics/SOFTANZA_GRAPHICS_PLAN.md` (GR0–GR6, complete). This plan
inherits their laws — and, more valuably, their **mistakes**, which are
enumerated in §0.5 and have already changed three decisions below.

The requirements, by analogy with graphics (the author's standing pair,
plus the two that graphics proved are not optional):

1. **Softanzified programmability** — a DECLARATIVE experience for
   sound in Ring, as stzCanvas is for pixels.
2. **An efficient backend** — riding the numerical assets already here
   (SIMD loops, the FFT engine, the multicore tier), NOT a black-box
   audio middleware.
3. **All OSs** — Windows/Linux/macOS as peers, with the honesty about
   verification that graphics learned the hard way.
4. **Unicode-correct where text meets sound** — file paths, tags,
   metadata, and any spoken/subtitle text; the library's multilingual
   identity does not stop at the speaker.

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

This file is written to be **sufficient on its own** for a dedicated
session that has never seen the sound work. It carries the analysis,
the settled decisions, the inherited lessons, the phases with their
kill criteria, AND the orientation below. There is deliberately no
companion "context" document: this repo has already been bitten by
duplicated rule lists that DRIFT (the knob-gate audit found two entry
points whose copies of the same rules had diverged). One document.

### The mission, in one paragraph

Give Softanza a sound plane with two faces: a DECLARATIVE Ring surface
(describe a sound or a graph of sounds; the engine realizes it) and an
efficient engine backend built on assets this repo already owns — the
FFT module, the SIMD element loops, the multicore tier — with only the
genuinely missing half (device I/O and file decode) vendored. Sound is
greenfield here: there is no audio code in Softanza today.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/sound/SOFTANZA_SOUND_PLAN.md` |
| sibling planes (READ their RESULTS sections) | `base/gpu/SOFTANZA_GPU_PLAN.md`, `base/graphics/SOFTANZA_GRAPHICS_PLAN.md` |
| engine sources | `libraries/stzlib/engine/src/*.zig` |
| the FFT you will build on | `libraries/stzlib/engine/src/fft.zig` |
| vendored deps (the pattern to copy) | `libraries/stzlib/engine/vendor/` — see `wgpu/VERSION`, `harfbuzz/VERSION.txt` |
| build definition (domains + `addXxx` helpers) | `libraries/stzlib/engine/build.zig` |
| the per-OS DLL precedent to copy | `stz_window` domain in build.zig + `src/stz_window_entry.zig` |
| Ring loaders for engine DLLs | `libraries/stzlib/engine/stz_*.ring`, registered in `base/common/stzRingLibs.ring` |
| Ring faces (where stzSound will live) | `libraries/stzlib/base/sound/` (create), loaded from `base/stzBase.ring` |
| guards | `libraries/stzlib/base/test/sound/` (create) |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```
# build every engine DLL (from libraries/stzlib/engine)
zig build

# run a guard (MUST be run from inside its topic directory)
cd libraries/stzlib/base/test/sound && ring sound_xxx_narrated.ring

# cross-compile check (the portable DLL must pass; the device DLL will not)
zig build -Dtarget=x86_64-linux-gnu
zig build -Dtarget=aarch64-macos
```

### The working discipline (non-negotiable, and the reason the two
sibling planes are trustworthy)

1. **Measure before believing anything, including this plan.** Every
   phase gate is a measurement. The plans have named the wrong line
   repeatedly — G0's crossover seed was 62x too cautious, GR0's kill
   criterion aimed at a tier that cost 3% of the budget.
2. **Write kill criteria BEFORE looking at numbers**, in the doc, and
   then apply them even when they hurt. Half this work's value is
   saying where sound does NOT need acceleration.
3. **Guards are narrated and assert the MECHANISM**, never the vibe —
   and every positive needs its negative sibling (the thing that
   proves the guard would notice a failure). Counters are the usual
   witness: assert that a number MOVED, and that it did NOT move on
   the other side of the gate.
4. **A bounded record COUNTS what it drops.** Underruns, dropped
   voices, queue overflows — countable from the first phase.
5. **Engine-first**: substance in Zig so any binding gets it; Ring is
   ONE face. Ring-side logic is capability other bindings won't have.
6. **CI has no audio device** (and no GPU): every guard must pass
   through the offline path, with device assertions gated on presence.
7. **Parallel sessions work this repo**: `git add <explicit paths>`,
   never `-A`. Expect foreign commits between your edit and your
   commit; rebuild before diagnosing a strange failure.
8. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; VERIFY both with
   `git ls-remote <remote> main` against `git rev-parse main` (push
   output can lie). If codeberg fails, say PENDING and move on.
9. **Record the outcome** in this file (a `## SN<n> STATUS/RESULTS`
   section) and in memory (`project_sound_plan.md`) when a phase ends.

### Traps this repo has already paid for (do not re-pay them)

- A vendor-root file named `VERSION` **collides with C++'s `<version>`
  header** on case-insensitive filesystems → name it `VERSION.txt`.
- In Ring, **top-level code after a `func` never runs** → main logic
  first, helpers at the bottom.
- In Ring, **a `func` written after a `class` in the same file becomes
  a METHOD of that class** → shared helpers must precede the class.
- Ring's `substr/len/upper` are byte-oriented → use the `Stz*` engine
  helpers for anything multibyte.
- Don't name a method/variable after a Ring keyword (`load`, `call`).
- Engine bridges are **0-based**; Ring faces are 1-based — translate
  at the face, and say so.
- A guard must **isolate its subject**: when two paths can serve the
  same call, the guard for one must disable the other, or it will
  measure the wrong thing (this cost the GPU plane a false green).

### The first action

**SN0**, exactly as specified in §3 below: the audio spike, measurement
only, no product code — with its kill criteria applied before the
numbers are interpreted, and a `## SN0 RESULTS` section appended here.

---

## 0. The facts that shape everything (surveyed 2026-08-09)

**FACT 1 — Softanza has NO audio of any kind today.** No playback, no
capture, no decode, no synthesis, no format. Unlike graphics — which
had three drawing islands to unify — sound is genuinely greenfield.
That is a warning, not a licence: greenfield is where scope dies.

**FACT 2 — but the SIGNAL half is already strong.** `engine/src/fft.zig`
is real and complete (transform, inverse, convolveReal, magnitudes,
phases, powerSpectrum, dominantBin/Frequency — f64). Add the SIMD
element loops, the multicore tier (M1–M5, with a calibration store),
the resident-buffer discipline, and stzNumBuffer. **Analysis, filtering
and convolution are not new capability — they are existing capability
pointed at a new domain.** The genuinely missing half is I/O: getting
samples to a speaker and from a microphone, and decoding files.

**FACT 3 — the device tier is a PER-OS problem, and graphics already
paid to learn what that costs.** GR5's amendment (2026-08-09) measured
that windowing CANNOT cross-compile from this machine: Zig bundles
libc, not platform GUI SDKs (`X11/Xlib.h` and `Cocoa/Cocoa.h` are
absent; Apple's frameworks are not redistributable). The consequence
was architectural: **the window tier moved OUT of `stz_gpu.dll` into a
separate `stz_window.dll`**, so the portable engine stayed portable and
only the per-OS part became per-OS. Audio devices are the SAME SHAPE
(WASAPI / CoreAudio / ALSA-PulseAudio), so this plan adopts the answer
up front rather than rediscovering it: **`stz_sound.dll` (portable DSP,
decode, synthesis, files — cross-compiles everywhere) and a SEPARATE
`stz_audiodev.dll` (the device backend, per-OS, dynamically loaded,
counted refusal when absent).** This is decision #1 that the graphics
session's experience changed.

**FACT 4 — the real-time constraint has no analogue in this codebase.**
Every plane so far has been throughput-bound: finish sooner is always
better, and a 30 ms hiccup is invisible. Audio is DEADLINE-bound: the
device callback fires every few milliseconds on a thread the OS owns,
and missing it produces an audible click that no amount of average
throughput repairs. Three house habits are therefore FORBIDDEN inside
the callback: allocation, locks, and any Ring/VM call. The audio thread
touches only pre-allocated buffers and lock-free queues. This is the
plane's defining discipline, and §2 makes it structural rather than
advisory.

**FACT 5 — the GPU is probably the WRONG accelerator here, and the
plan says so before measuring.** G0's law (transfer share vs compute)
and the per-node routing verdict (0.45–0.67x — a graph that hops
CPU↔GPU per node is not a resident chain) both predict badly for
audio: a 5 ms buffer at 48 kHz stereo is 1,920 bytes of work, and the
measured GPU dispatch floor is ~60 µs against a ~5,000 µs deadline —
with PCIe round trips inside a deadline-bound callback. **The default
position is that real-time audio DSP stays on CPU/SIMD**, and SN0
measures rather than assumes. Where the GPU may genuinely pay is
OFFLINE, batch work: rendering a long convolution reverb, resampling a
library, computing spectrograms for a corpus — the same "batch, not
interactive" verdict G6 reached for decode.

---

## 0.5 Lessons inherited from GPU + GRAPHICS (each already applied)

1. **Measure the DECOMPOSITION, not the total.** GR0's kill criterion
   aimed at the GPU raster tier; the measurement found 95% of a 1080p
   frame's cost was CPU zlib deflate and the GPU part was 1.7 ms of 29.
   Demoting the GPU tier would have changed nothing. → SN0 decomposes
   {decode, resample, mix, device-submit} separately and names which
   one the criterion is actually about.
2. **A floor on cost is not a promise of speed** (the backbone spine:
   2.12x measured on matmuls alone, 1.5x delivered). → SN0's spike
   measures a WHOLE round trip, not a kernel.
3. **A bounded record must COUNT what it drops** — the glyph atlas
   dropped text SILENTLY until it was made to grow and count. → every
   underrun, dropped voice, and queue overflow in this plane is
   COUNTED and readable, from the first phase.
4. **Cross-platform claims decay silently** → per-OS split (FACT 3),
   cross-compile in CI from SN1, and the plan states runtime-verified
   vs cross-compile-verified per OS.
5. **One model, two backends that CANNOT disagree** (GR2b's display
   list → SVG + GPU). → the sound graph renders to the DEVICE and to a
   FILE through the same path; an offline render is the same graph with
   a different sink, so "what you hear" and "what you export" cannot
   drift.
6. **Vendor amalgamations DO compile under Zig** (harfbuzz.cc, the
   largest C++ vendor, no cmake) — but two Windows traps were paid for:
   a vendor-root `VERSION` file collides with C++'s `<version>` on
   case-insensitive filesystems (use VERSION.txt), and a bare `text`
   import shadowed bridge locals. → both avoided by construction here.
7. **A challenge pass before the declarative faces** (GR4's found four
   gaps). → SN4 is preceded by the same deliberate challenge.

---

## 1. The vendor decision

| | miniaudio | libsoundio | PortAudio | RtAudio | SDL_audio | FMOD/Wwise | dr_libs / stb_vorbis | libsndfile | Opus/Vorbis refs |
|---|---|---|---|---|---|---|---|---|---|
| Weight | **1 header, ~90k lines, no deps** | small C | mid C | C++ | pulls SDL | huge, licensed | single headers | mid + deps | mid |
| Builds under zig, no cmake | **✓** | ✓ | painful | ✓ | ✗ | ✗ | **✓** | painful | ✓ |
| All 3 OSs from one source | **✓ (WASAPI/CoreAudio/ALSA+Pulse)** | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | n/a | n/a |
| Capture as well as playback | **✓** | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | n/a | n/a |
| Licence | public domain / MIT-0 | MIT | MIT | MIT | zlib | commercial | public domain | LGPL | BSD |
| Decode included | **wav/flac/mp3 built in** | none | none | none | wav only | yes | wav/flac/mp3/ogg | many | ogg/opus |

**DECISION: vendor `miniaudio.h` for the device tier and the built-in
decoders; add `stb_vorbis.c` only if Ogg is asked for.** miniaudio is
the same shape of choice as stb and GLFW: one public-domain file, no
dependencies, all three OSs from a single source, playback AND capture,
with wav/flac/mp3 decoding already inside — which removes a whole
vendoring question. It compiles as one C TU under `zig cc` with
per-OS backends selected by its own `#ifdef`s (no cmake, no SDK).

Killed on the house invariants, in writing: **FMOD/Wwise** (commercial
licensing + weight — the "vendor wisely, lightweight" rule refuses it,
and the PI doctrine's cost-nothing law doubly so); **SDL_audio** (drags
SDL in for one subsystem); **PortAudio/libsndfile** (build systems that
fight `zig build`); **libsoundio/RtAudio** (fine libraries, but each
answers only devices, leaving decode a second vendor — miniaudio
answers both, and one vendor beats two at equal weight).

**Written IN ZIG, not vendored** (because the assets exist and the
domain is ours): the mixer/graph, resampling, the synthesis primitives
(oscillators, envelopes, noise), the filter set (biquads, one-pole),
delay/reverb, and all analysis — the last riding `fft.zig` rather than
duplicating it. This is the same call the graphics plane made for its
rasterizer, and the same reason: the SIMD and multicore tiers make this
shape of loop our strength, and a vendored DSP framework would be an
opaque middle layer between Ring and capability we already own.

Runner-up recorded: **libsoundio** if miniaudio's device layer ever
disappoints on a specific OS (swap the device tier only — the DSP half
does not move, which is precisely why FACT 3's DLL split matters).

---

## 2. Architecture — the house laws, applied to samples

- **TWO DLLs, for the reason graphics paid to learn (FACT 3):**
  - `stz_sound.dll` — PORTABLE: decode, encode, resample, the sound
    graph, synthesis, filters, analysis. Cross-compiles to all targets
    like every other engine domain. Testable with NO device.
  - `stz_audiodev.dll` — PER-OS: miniaudio's device backends only.
    Dynamically loaded at use time (the wgpu_native precedent), with a
    counted refusal when absent so CI and headless boxes are first-
    class citizens rather than special cases.
- **The audio callback is a NO-ALLOCATION, NO-LOCK, NO-RING zone.**
  Structurally enforced: the callback consumes a pre-rendered ring
  buffer filled by the graph; control changes cross as messages on a
  lock-free SPSC queue; every buffer the graph needs is allocated at
  Prepare() time. **Underruns are COUNTED** (`sound.underruns`),
  alongside `sound.callback.us`, `sound.voices.active`,
  `sound.queue.drops` — house instrument naming, lesson 3 applied.
- **The sink is a parameter, not a fork** (lesson 5): the same sound
  graph renders to the device, to a WAV/FLAC file, or to a buffer. An
  offline render is the identical graph with a file sink and no
  deadline — so exported audio and heard audio cannot diverge, and CI
  can assert the graph's OUTPUT SAMPLES with no device present. This
  is the sound plane's equivalent of "one display list, two renderers,"
  and it is what makes this plane CI-testable at all.
- **f32 samples internally**, f64 only where analysis wants it (fft.zig
  is f64) — the graphics f32/f64 split, repeated: the numeric oracle
  tier's bit-stability contract is untouched by either.
- **The GPU is an OFFLINE option, gated by measurement** (FACT 5), and
  the compute plane is already there if SN0 says it pays: long FFT
  convolution and batch spectrograms are the only candidates named.
- **Unicode**: file paths through the engine's existing UTF-8 file
  layer; tags/metadata decoded as UTF-8; any text-to-be-spoken or
  subtitle text rides the graphics plane's proven bidi→shape pipeline
  when it is DISPLAYED. No new Unicode machinery is needed — but the
  guard corpus includes an Arabic-named file and Arabic tags, because
  "it works on ASCII paths" is exactly the assumption that rots.

**Level-1 surface (sketch, on the house naming law — GR4's correction
applies here BEFORE any code):**

    oS = new stzSound("bell.wav")          # load, decode
    oS.Play()                              # device tier
    ? oS.Duration()  ? oS.SampleRate()

    oG = new stzSoundGraph()               # the declarative graph
    oG.Add(StzOscillatorQ(:Sine).Hz(440)).Named(:tone)
    oG.Add(StzEnvelopeQ().Attack(0.01).Release(0.4)).On(:tone)
    oG.Add(StzReverbQ().Room(0.6)).After(:tone)
    oG.ToFile("bell.wav")                  # offline sink -- CI-assertable
    oG.Play()                              # device sink -- same graph

    oA = oS.Analysis()                     # rides fft.zig
    ? oA.DominantFrequency()  ? oA.Spectrum()
    oA.Spectrogram().ToPNG("spec.png")     # the GRAPHICS plane draws it

---

## 3. Phases

**SN0 — the audio spike (go/no-go, measurement only).** Vendor
miniaudio; open a device on this machine; play a synthesized tone;
capture a buffer; decode a wav/mp3; measure the DECOMPOSITION (lesson
1): device callback period and jitter, per-buffer graph render time at
128/256/512 frames, decode MB/s, resample MB/s, and the round-trip
output latency. Also measure the SIMD mix loop against a scalar one,
and (FACT 5) a GPU FFT convolution against the CPU fft.zig at 1 s and
60 s of audio. KILL CRITERIA, written now: if a 256-frame graph render
cannot hold **under 25% of its 5.3 ms deadline** with a plain mix
graph, the real-time tier is demoted to offline-only and the plan says
so; if miniaudio does not compile as one TU under `zig cc` with no
cmake, STOP (the harfbuzz precedent says it will); if the GPU FFT
convolution does not beat CPU by ≥2x at 60 s, the GPU stays OUT of
this plane entirely — recorded, not revisited per-phase.

**SN1 — the two DLLs and the sample foundation.** `stz_sound.dll`
(portable) + `stz_audiodev.dll` (per-OS, dynamically loaded, counted
refusal). Sample buffers as gen-keyed handles on the house pattern;
decode (wav/flac/mp3 via miniaudio) and WAV/FLAC encode; resampling;
format conversion. Cross-compilation to linux-x64 and macos
(x64+arm64) enters CI HERE (lesson 4) — and, per FACT 3, the portable
DLL must cross-compile even though the device DLL cannot.

**SN2 — the sound graph, offline first.** Nodes (source, gain, mix,
pan, filter, delay, envelope), a Prepare()/Render() contract with all
allocation at Prepare, and the FILE sink before the device sink — so
the whole graph is guard-assertable with no hardware (lesson 5). The
guard corpus asserts SAMPLES, not vibes: a known oscillator's exact
values, a filter's measured magnitude response against an analytic
reference, a mix's summation exactly.

**SN3 — the real-time tier.** The device sink, the lock-free control
queue, the pre-rendered ring buffer, the no-alloc/no-lock/no-Ring
callback discipline, and the counters (underruns first). Guards:
sustained playback with ZERO underruns at a stated buffer size; a
deliberately overloaded graph that underruns and PROVES the counter
moves (the negative sibling); control changes applied without a click.

**SN4 — the declarative faces** (preceded by a challenge pass, lesson
7): stzSound, stzSoundGraph, stzOscillator/Envelope/Filter/Reverb,
stzMicrophone, on the Q/maker/Show conventions with the naming law
checked BEFORE the faces are built, not after.

**SN5 — analysis, and the graphics convergence.** Spectrum, spectrogram
(fft.zig, multicore for batch), onset/tempo, loudness (LUFS). The
spectrogram renders through stzCanvas — the first cross-plane
composition, and the reason this plane's analysis output is a DATA
model rather than a picture.

**SN6 — the convergence dividend.** Sound joins the planes that exist:
the reactive layer drives envelopes and sequencing; stzStateMachine
carries transport state; the delivery plane's WASM/browser tier gets
WebAudio as the fourth sink (the G5 edge precedent, and the browser is
where gamification audio will actually live); and the game-plane
foresight doors (§3b of the graphics plan) get their audio siblings —
one shared clock, and voices as pooled handles.

---

## 4. Risks, named now

- **The real-time deadline is a different failure mode** from anything
  this codebase has met: correct-but-late is WRONG. Hence SN2 before
  SN3 (prove the samples with no clock, then add the clock) and
  underrun counting from the first device line.
- **Scope gravity is worse here than in graphics** — synthesis, effects
  and music theory are bottomless. OUT until asked, in writing: MIDI,
  music notation, 3D/HRTF spatial audio, time-stretching, VST/CLAP
  hosting, and speech synthesis or recognition (the last two would be
  NEURAL-tier work riding ggml, not this plane's).
- **The GPU may simply not belong here** (FACT 5) — SN0 decides it once
  and the answer is recorded, so no later phase re-litigates it.
- **Device backends are where portability claims die** — the split in
  FACT 3 contains the damage, and verification status is stated per OS
  rather than implied.
- **Licence hygiene**: miniaudio is public-domain/MIT-0 and stb_vorbis
  public domain; anything LGPL (libsndfile) or commercial (FMOD) stays
  out — recorded so a later session does not casually reach for one.
- **CI has no audio device**: every guard passes through the offline
  sink and the counted-refusal path, exactly as the 162-assert GPU
  suite and the device-free text suite already demonstrate.

---

## SN0 RESULTS — measured 2026-08-09/10. VERDICT: GO, on all three criteria

Environment: miniaudio 0.11.25 (pinned; commit + SHA-256 in
`engine/vendor/miniaudio/VERSION.txt`), Zig 0.15.2, ReleaseSafe (the shipped
mode). Backend WASAPI; playback "Haut-parleurs (Realtek(R) Audio)", capture
"Réseau de microphones (Intel® Smart Sound)". GPU half: wgpu-native v29.0.1.1,
RTX 3050 6GB Laptop + Intel iGPU, both on Vulkan. Spikes:
`engine/tools/sound_spike.zig` and `engine/tools/sound_gpu_spike.zig` (build
lines in their headers). **Machine shared with other sessions — recorded as-is,
variance noted where it moved.**

Methodology, unchanged from G0/GR0 so the planes' numbers are comparable:
monotonic clock only; 3 warmups then 5 timed reps, min AND median; CPU samples
inner-loop scaled to >=1 ms; device sessions 3 s each; every whole suite run 5
times. Every GPU result verified against the CPU f64 reference before it was
allowed into a table.

### The decomposition — where a second of audio actually goes

One second of 48 kHz stereo, each stage measured on its own (lesson 1):

| stage | cost per 1 s of audio | x realtime | share of a 5.333 ms buffer |
|---|---|---|---|
| decode, wav s16 (dr_wav) | 0.050 ms | 19,600x | — |
| decode, flac (dr_flac) | 0.38 ms | 2,590x | — |
| resample 48k->44.1k (linear) | 1.17 ms | 853x | — |
| **graph render, 128 voices** | **0.60 ms** | **1,675x** | **0.06%** |
| device submit (work inside the callback) | 0.003–0.006 ms | — | 0.13–0.32% |

Nothing in the real-time path is within two orders of magnitude of its deadline.
The most expensive stage of the whole plane is RESAMPLING, at 1.17 ms/s — and it
is still 853x faster than real time.

### Graph render — a plain mix graph, offline (the CI path)

Four forms of the same mix, 5 runs, min, at the 256-frame deadline size
(5.333 ms; kill criterion #1's budget is 25% of that = 1.333 ms):

| voices | interleaved-index | planar-index | planar-**slices** | planar-@Vector | best as % of the 1.333 ms budget |
|---|---|---|---|---|---|
| 1 | 0.051 us | 0.070 us | **0.065 us** | 0.152 us | 0.005% |
| 8 | 0.296 us | 0.269 us | **0.205 us** | 0.309 us | 0.015% |
| 32 | 1.297 us | 1.145 us | **0.898 us** | 0.949 us | 0.067% |
| 64 | 2.472 us | 2.164 us | **1.661 us** | 1.786 us | 0.125% |
| 128 | 4.982 us | 4.256 us | **3.186 us** | 3.442 us | 0.239% |

All four forms agree to 0.000e0 max absolute deviation — the fastest one is fast
at producing the *same* samples. Across 128/256/512 frames the best form never
exceeded **0.09% of its deadline** at any voice count tested.

### SIMD vs scalar — linalg.zig's law reproduces in the audio domain

| | ratio | reading |
|---|---|---|
| planar-slices / planar-index | **1.08–1.34x faster** | handing LLVM slices instead of computed indices wins |
| planar-@Vector / planar-slices | **0.43–0.95x — a LOSS** | the explicit vector is never faster, and 2.3x slower at 1 voice |
| planar-slices / interleaved-index | **1.56x faster at 128 voices** | accumulate planar, interleave once at the end |

This is `src/linalg.zig`'s finding, re-derived rather than assumed: *reach for
`@Vector` where the compiler cannot see the structure, not where it merely needs
to be shown.* A mix bus is the second case. **SN2 writes the mixer as planar
slice loops with a single interleave at the sink, and does not hand-vectorise.**

### Device wake-up — period, jitter, and the counted shortfall

**The callback is not the deadline, and the first cut of this measurement got it
wrong.** Timing gaps between successive data callbacks gave a p50 of 2.3 us
against a mean of 2,639 us — nonsense, because WASAPI wakes the device thread
once per internal period and miniaudio then issues a BURST of callbacks
back-to-back to fill it (four 128-frame callbacks in ~7 us, then a 10 ms gap).
What has a deadline is the WAKE-UP; what must fit inside it is the burst's TOTAL
work. Lesson 1 again, caught inside SN0 instead of inherited by SN3.

SHARED mode, 3 s per session, 3 sessions (asked -> internal frames):

| asked | internal | wake p50 | p99 | max | jitter | burst work p99 | % of budget | frames short |
|---|---|---|---|---|---|---|---|---|
| 128 | 480 x3 | 10.00 ms | 10.24–10.55 | 10.29–11.29 | 43–51% | 17–32 us | 0.17–0.32% | **0** |
| 256 | 480 x3 | 10.00 ms | 10.24–10.49 | 10.35–10.99 | 35–47% | 14–16 us | 0.14–0.16% | **0** |
| 512 | 512 x3 | 10.01 ms | 19.98–20.12 | 20.19–20.31 | 107–110% | 14–22 us | 0.13–0.21% | **0** |

EXCLUSIVE mode, same sessions:

| asked | internal | wake p50 | p99 | max | jitter | frames short (of 144,000) |
|---|---|---|---|---|---|---|
| 128 | 128 x3 | 8.2–14.9 ms | 28.6–67.4 | 39.2–79.2 | 470–527% | 0 / 0 / **78,020** |
| 256 | 256 x3 | 15.9–22.3 ms | 34.4–77.0 | 34.7–79.8 | 208–370% | **1,170 / 43,338 / 47,094** |
| 512 | 512 x3 | 31.4–34.6 ms | 53.2–77.2 | 58.3–97.9 | 156–256% | 0 / 4,319 / **12,821** |

`frames short` = frames the wall clock expected minus frames the device took —
COUNTED, not assumed, because miniaudio exposes no underrun counter of its own.

**Shared mode never dropped a frame in any run. Exclusive mode dropped up to
78,020 frames — 1.6 s of audio missing from a 3 s run — while jittering 5x.**
Exclusive buys a smaller total buffer (8 ms vs 30 ms) and, on this
machine/driver, cannot hold it. The 512-frame shared p99 of 20 ms is the device
coalescing two periods, not a dropout: the frame count stayed exact.

### Decode and resample

| file | in bytes | frames | rate | min ms | in MB/s | out MB/s (f32) | x realtime |
|---|---|---|---|---|---|---|---|
| 10 s tone, wav s16 | 1,920,044 | 480,000 | 48000 | 0.50 | 3,687–3,856 | 7,373–7,712 | 19,200–20,100x |
| 16-44100-stereo.flac | 1,798,051 | 1,553,920 | 44100 | 13.4–13.8 | 130–134 | 899–925 | 2,548–2,621x |

| resampler | 1 s stereo f32, 48000->44100 | in MB/s | Mframes/s | x realtime |
|---|---|---|---|---|
| miniaudio linear | 1.17 ms | 327–330 | 41.0 | 853x |

**MP3 decode: NOT MEASURED.** miniaudio's upstream `data/` carries a
public-domain FLAC and an Ogg but no MP3, and this machine has no MP3 anywhere
and no encoder to make one. dr_mp3 is compiled in and available; it wants one
corpus file. **SN1 adds an MP3 to the guard corpus and measures it there** —
stated rather than implied, per lesson 4.

### Output latency

| mode | impulse -> loopback tap | device-claimed buffer |
|---|---|---|
| shared | **112.6 ms** (min 112.57, median 112.65, 5/5 detected) | 30.00 ms (480 frames x 3 periods) |
| exclusive | **not measurable this way** | 8.00 ms (128 frames x 3 periods) |

The measured figure is an **upper bound**: WASAPI loopback taps the endpoint's
render mix and has ~22 ms of buffering of its own (352 frames x 3), so
112.6 = our 30 ms buffer + the tap's 22 ms + ~60 ms of Windows audio pipeline
that no application-side change can remove. It is the software path only — not
the DAC, not the speaker; no CI box can ever measure those.

The intended trick of differencing two configurations to cancel the tap's offset
**does not work, and the reason is definite**: an exclusive-mode client takes
over the endpoint, so the loopback capture sees literal silence (peak exactly
0.000e0 — the tap saw nothing, rather than the impulse missing a threshold).
Exclusive-mode latency and loopback measurement are mutually exclusive by
construction on WASAPI.

A first cut of this measurement fired the impulse on the 40th callback and read
122 ms. The instrumentation showed why: `ma_device_start` takes ~500 ms, and
during startup the callbacks run AHEAD of real time to prefill the ring, so
callback 40 had already queued 104 ms of audio that had not begun to play.
Arming on the wall clock after 1.5 s of silence measures the steady state, which
is the only regime in which "latency" means anything.

### GPU FFT convolution vs CPU — 1 s IR, offline render

CPU baselines (5 runs, min; the twiddle column is a THIRD implementation added
so the criterion is not a GPU-versus-unoptimised-CPU comparison):

| audio | samples | FFT N | fft.zig f64 (as shipped) | twiddle-table f32 | table vs fft.zig |
|---|---|---|---|---|---|
| 1 s | 48,000 | 131,072 | 24.0–25.6 ms | 7.9–8.3 ms | **3.0–3.1x faster** |
| 60 s | 2,880,000 | 4,194,304 | 1,390–1,464 ms | 1,324–3,097 ms | **0.47–1.06x — no win, and unstable** |

**A CPU surprise worth more than the GPU answer: precomputing the twiddle
factors is a 3.1x win at N=131k and NOT a win at N=4M.** The table is 2M entries
x 2 arrays x 4 bytes = 16 MB, walked with a stride that doubles every stage; past
last-level cache it stops paying, and its run-to-run spread (1,324–3,097 ms on
this shared machine) dwarfs fft.zig's (1,390–1,464 ms, tight). fft.zig's
per-butterfly `@cos`/`@sin` — a deliberate accuracy choice its header defends —
is compute-bound and cache-friendly, and at 4M points that is the better trade.
**SN5 must not "optimise" fft.zig into a twiddle table without re-measuring at
the size it will actually run.**

GPU, decomposed as submit+wait per phase (min of 5 runs):

| adapter | audio | FFT N | disp | upload | forward | mul | inverse | readback | TOTAL | vs fft.zig | vs twiddle-f32 | max rel err |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RTX 3050 | 1 s | 131,072 | 52 | 0.52 | 0.60 | 0.08 | 0.28 | 0.23 | **1.74 ms** | 10.3–13.8x | 3.4–4.6x | 1.47e-6 |
| RTX 3050 | 60 s | 4,194,304 | 67 | 15.4 | 25.2 | 1.1 | 12.6 | 7.4 | **61.96 ms** | **19.0–22.7x** | 19.6–34.5x | 1.75e-6 |
| Intel iGPU | 1 s | 131,072 | 52 | 0.69 | 1.59 | 0.39 | 0.78 | 0.61 | 4.06 ms | 6.2x | 2.0x | 2.07e-5 |
| Intel iGPU | 60 s | 4,194,304 | 67 | 22.9 | 51.0 | 1.9 | 25.0 | 8.1 | 108.8 ms | **12.9x** | 12.2x | 2.75e-5 |

Transfer share at 60 s on the 3050 is **37%** (22.8 of 62.0 ms) — the opposite
end from G0's saxpy verdict (92% transfer, killed) and consistent with G0's
"compute-dense family" ruling. A 4M-point transform costs ~12.7 ms on the GPU
against ~460 ms on the CPU.

### KILL CRITERIA, APPLIED

**#1 — "if a 256-frame graph render cannot hold under 25% of its 5.3 ms deadline
with a plain mix graph, the real-time tier is demoted to offline-only."**
**PASSES, and the criterion was aimed at the wrong tier.** A 128-voice mix at
256 frames costs 3.19 us against a 1,333 us budget — **0.24% of it, a 418x
margin**. This is GR0's mistake repeating in a new plane: GR0 aimed at a GPU
raster tier that turned out to be 1.7 ms of a 29 ms frame, and SN0 aimed at a
mix loop that turns out to be a quarter of one percent of its deadline. The
real-time tier is NOT demoted, and **the criterion is retired rather than
inherited**: nothing SN3 does will be threatened by mix arithmetic. The stage
that actually consumes the plane's time is resampling (1.17 ms per second of
audio, 20x the mix), and the risk that actually threatens SN3 is the OS wake-up
(a 20 ms coalesced period in shared mode, a 78,020-frame shortfall in exclusive)
— **which is scheduling, not arithmetic, and no amount of SIMD touches it.**

**#2 — "if miniaudio does not compile as one TU under `zig cc` with no cmake,
STOP."** **PASSES.** Both translation units compile clean, ~12 s each, no
cmake, no SDK:

| target | portable TU (`MA_NO_DEVICE_IO`) | device TU (full backends) |
|---|---|---|
| x86_64-windows | OK (2.5 MB .o) | OK (3.0 MB .o) |
| x86_64-linux-gnu | OK | **OK** |
| x86_64-macos | OK | FAIL — `CoreAudio/CoreAudio.h` not found |
| aarch64-macos | OK | FAIL — same |

Backend presence was verified IN THE OBJECT FILES, not inferred from a clean
exit: the Linux device object carries `libasound.so.2`, `libpulse.so.0`,
`libjack.so.0`, `snd_pcm_open`; the Windows one carries `IAudioClient`/`2`/`3`
and `ma_context_init__wasapi`; the portable one carries `ma_decoder_init_file`
and **zero** device symbols. The harfbuzz precedent held, as sec.3 predicted.

**#3 — "if the GPU FFT convolution does not beat CPU by >=2x at 60 s, the GPU
stays OUT of this plane entirely."** **PASSES: 19.0–22.7x on the RTX 3050 and
12.9x on the iGPU**, against the shipped fft.zig, at f32 accuracy of 1.75e-6
(3050) — well inside audio's noise floor. **The GPU is IN, for OFFLINE BATCH
CONVOLUTION ONLY**, exactly as FACT 5 scoped it. Recorded once; no later phase
re-litigates it.

Two qualifications that travel with that admission:
- **The iGPU's transcendental precision is 16x worse** (2.75e-5 ~ -91 dB, above
  a 16-bit noise floor). If the iGPU is ever a real target for a reverb render,
  the WGSL must take twiddles from an uploaded table rather than calling `cos`/
  `sin` per butterfly. Named now so it is not discovered in a listening test.
- **This says nothing about real-time.** A 5.333 ms buffer is 1,920 bytes of
  work against a measured ~60 us dispatch floor. FACT 5 stands untouched.

### FACT 3, REFINED BY MEASUREMENT

FACT 3 adopted the GR5 split on the assumption that audio devices are "the SAME
SHAPE" as GLFW windowing — per-OS, therefore uncross-compilable. **The split is
right and the reason is now sharper.** GLFW's X11 backend needs `X11/Xlib.h` at
COMPILE time, so it cannot cross-compile to Linux from this box. miniaudio's
ALSA/PulseAudio/JACK backends declare what they need themselves and `dlopen` the
`.so` at RUNTIME — so **`stz_audiodev.dll` cross-compiles to Linux from here,
which `stz_window.dll` never could.** Only macOS is genuinely blocked, and only
by Apple's headers.

The two-DLL split survives on its original merit: it is what keeps
`stz_sound.dll` buildable for every target regardless. But the device DLL's
per-OS cost is **1 OS out of 3, not 3 out of 3** — so SN1's CI can
cross-compile-check BOTH DLLs for Windows and Linux, and only the macOS device
build is stated-not-verified.

### CALIBRATED NUMBERS SN1 INHERITS

1. **Buffer**: shared mode, internal period **480 frames (10 ms) x 3 periods**;
   asking for 128 or 256 does not change it. **Do not ship exclusive mode as a
   default** — it dropped up to 78,020 frames per 3 s run here. Expose it, count
   its refusals and its shortfall, and let a user opt in.
2. **The render budget is 10 ms, not 5.333 ms**, and it is consumed by a BURST
   of callbacks. SN3's guard must assert the burst total against the wake-up
   period, not one callback against one period.
3. **Mix cost: ~0.025 us per voice per 256-frame block** (planar slices). Write
   the mixer planar, interleave once at the sink, and do not hand-vectorise.
4. **Resampling is the plane's most expensive per-sample stage** — 1.17 ms per
   second of stereo audio, ~20x the mix. It is the first thing worth a resident
   buffer and the first candidate for the multicore tier in batch mode.
5. **Decode is free at real-time scale**: wav ~19,600x, flac ~2,590x. Streaming
   decode needs no lookahead heroics; it needs a bounded queue and a counter.
6. **`sound.underruns` has a working definition today**: frames the wall clock
   expected minus frames the device consumed. It moved (exclusive mode) and
   stayed at zero (shared mode) in the same suite — the positive and its
   negative sibling both exist before SN3 starts.
7. **Latency**: the application-side buffer is 30 ms shared / 8 ms exclusive;
   this machine's OS pipeline adds ~60 ms that no engine change removes. Quote
   the buffer, never the 112 ms, and say which is which.
8. **GPU offline convolution**: a 60 s render is 62 ms on the 3050 against
   1,400 ms on CPU. Crossover is already favourable at 1 s (10–14x), so the
   calibrated gate for SN5 is *not* a length threshold — it is whether the
   render is offline at all.
9. **Unicode arrived on day one, unprompted**: this machine's device names are
   `Haut-parleurs (Realtek(R) Audio)` and `Réseau de microphones (Intel(R)
   Smart Sound)`. miniaudio hands them over as UTF-8, padded to a fixed width —
   trim at the NUL, and never assume a device name is ASCII.

### WHAT SN0 DID NOT MEASURE (stated, not implied)

- **MP3 decode** — no corpus file; SN1 adds one.
- **Linux and macOS at runtime** — cross-compiled only, per the table above.
- **Capture beyond a smoke test** — 2 s from the mic array, 96,768–97,536 frames
  in ~380 callbacks, rms 1.5e-4 to 6.2e-3, peak up to 5.8e-2. It works, and its
  internal period is 256 frames at 48 kHz; its jitter was not characterised.
- **The mix under a cold cache** — the sweep re-reads the same source buffers,
  so they stay resident. Real playback streams from decoded buffers that will
  not always be. The margin is 418x, so this caveat does not endanger the
  verdict, but SN2's guard should read from a working set larger than L2.

---

## SN1 STATUS — 2026-08-10. The two DLLs stand, and the sample tier is guarded

Delivered: `stz_sound.dll` (portable, 1,168,384 bytes) and `stz_audiodev.dll`
(per-OS, 1,280,512 bytes), wired into `build.zig` as two domains on the
`stz_window` precedent, loaded by `engine/stz_sound.ring` and
`engine/stz_audiodev.ring`, registered in `base/common/stzRingLibs.ring`.

Sources: `engine/src/sound.zig`, `engine/src/audiodev.zig`, their
`ring_bridge_*.zig` and `stz_*_entry.zig`. Guards:
`base/test/sound/sound_samples_narrated.ring` (60 assertions) and
`sound_device_narrated.ring` (20 assertions), both green. Plus 9 Zig unit
tests inside the two engine modules.

### What each DLL owns

| | stz_sound (portable) | stz_audiodev (per-OS) |
|---|---|---|
| decode wav/flac/mp3 (file + memory) | yes | — |
| encode WAV (s16 / f32) | yes | — |
| resample (ours, in Zig) | yes | — |
| channel conversion | yes | — |
| gen-keyed sample-buffer table | yes | — |
| device enumeration, backend name | — | yes |
| **playback / capture streams** | — | **NO — that is SN3** |
| needs audio hardware | **never** | to answer anything |

`stz_audiodev` deliberately stops at enumeration. The device sink, the
lock-free control queue, the pre-rendered ring buffer and the underrun counter
are SN3, because the plan puts SN2 (prove the samples with no clock) before SN3
(add the clock). A half-built device tier now would be the thing SN2 is
supposed to make unnecessary.

### Cross-compilation — the CI gate SN1 was told to open

`zig build-obj` per module, ReleaseSafe, from this Windows box:

| target | stz_sound | stz_audiodev |
|---|---|---|
| x86_64-windows | built as a real DLL + 80 passing assertions | built as a real DLL + 80 passing assertions |
| x86_64-linux-gnu | **OK** | **OK** |
| x86_64-macos | **OK** | FAIL — `CoreAudio/CoreAudio.h` not found |
| aarch64-macos | **OK** | FAIL — same |

Exactly what SN0 predicted, now at DLL scope rather than TU scope. Note the
gate is per-module, not `zig build -Dtarget=...`: a whole-tree cross-build
cannot run from here for an unrelated reason (`addLibcurl` is Windows-only by
construction and panics at configure time on other targets). That is a
pre-existing property of another domain, recorded here so a later session does
not read a red whole-tree build as a sound-plane regression.

### Measured

**The resampler is ours, in Zig, and sec.1's "not vendored" now has a number.**
48000 -> 44100, stereo, 5 runs, min, against SN0's measured baseline of
1.17 ms per second of audio for miniaudio's linear:

| resampler | ms per 1 s of stereo | x realtime | max error vs an analytic 1 kHz sine |
|---|---|---|---|
| miniaudio linear (SN0) | 1.17 | 853x | — |
| **ours, linear** | **0.257** | **3,890x** | 2.13e-3 |
| **ours, windowed sinc** | 6.68 | 150x | **2.19e-5** |

Our linear is **4.6x faster than the vendor's linear** — same algorithm, and
the win is simply that it is a slice loop in Zig rather than a call through a
generic converter. The sinc costs 26x our linear and is **97x more accurate**,
and is still 150x faster than real time. It is the default worth using; linear
stays for the cases that genuinely want speed over fidelity.

Other measured facts the guards assert rather than assume:
- **DC gain is unity everywhere, edges included** — worst deviation across all
  1,000 upsampled frames was exactly 0. Without the per-output weight
  normalisation, every file would fade in and out by a few percent at the
  truncated ends of the kernel.
- **f32 WAV round-trip is BIT-EXACT.** s16 round-trip is 4.18e-5 worst against
  a quantum of 3.05e-5 — slightly over one quantum because encode scales by
  32767 and decode by 32768, the standard asymmetry that trades a hair of level
  for never clipping.
- **A freed buffer id is detected, not reused.** The generation bump makes the
  dead id answer STALE (-1 to readers), `sound.stale.hits` moves, and a NEW
  buffer landing in the recycled slot does not answer to the old id.

### The Unicode trap, paid for here rather than in a bug report

miniaudio's `ma_decoder_init_file` takes a NARROW path and reaches `fopen`,
which on Windows interprets bytes in the ANSI codepage: a UTF-8 Arabic filename
fails to open a file that plainly exists. The `_w` variants take `wchar_t` and
work. So every path in `sound.zig` is converted UTF-8 -> UTF-16 on Windows and
routed to `ma_decoder_init_file_w` / `ma_encoder_init_file_w`; on POSIX the
UTF-8 bytes pass straight through, which is already correct there.

The guard writes a WAV to an Arabic-named path, asserts the file exists on disk
under that name, decodes it back and asserts the samples are bit-exact — with a
negative sibling (a genuinely missing file must return 0) so the scene proves
Unicode handling rather than proving nothing. Requirement 4 says the library's
multilingual identity does not stop at the speaker. It very nearly stopped at
`fopen`.

### THREE GAPS, STATED RATHER THAN IMPLIED

**1. FLAC ENCODE IS NOT DELIVERED, and cannot be from this vendor.** SN1's line
in sec.3 says "WAV/FLAC encode". miniaudio's own documentation lists exactly one
encoding format — `ma_encoding_format_wav`. The enum carries flac/mp3/vorbis
names because the DECODER uses them. `SaveFlac` therefore returns UNSUPPORTED
and counts the refusal rather than writing a WAV with a `.flac` name; the guard
asserts that no file appears. Closing it needs either a second vendor (libFLAC
is **LGPL**, which sec.4's licence hygiene rules out) or a FLAC encoder written
here. **Recommendation: leave it open.** The offline sink that makes this plane
CI-assertable only ever needed WAV, and lesson 5's "one graph, two sinks"
property does not depend on the container.

**2. MP3 decode is still unguarded** — the same corpus gap SN0 recorded. dr_mp3
is compiled in and reachable; there is no MP3 on this machine and no encoder to
make one. The guard is structured so adding one file closes it.

**3. Tags and metadata have no vendor support at all.** sec.2 says "tags/metadata
decoded as UTF-8". miniaudio does not parse ID3, Vorbis comments or MP4 atoms —
it decodes audio only. That is a parser this plane would have to own, and it is
not written. Named now so it is not assumed present in SN4 when a face wants
`oSound.Title()`.

Also recorded: miniaudio 0.11.25 ships only `linear` and `custom` resampler
algorithms (the speex backend is gone from this version). Moot, since resampling
is ours — but it removes the runner-up the plan might otherwise have reached for.

### What SN2 inherits

1. **Sample buffers are gen-keyed handles**, and the graph's nodes should be
   too. The stale path is already proven to fire and to count.
2. **f32 interleaved is the in-memory form.** SN0's mix measurement says the
   graph should accumulate PLANAR and interleave once at the sink; the
   conversion helpers to do that live here now.
3. **The offline sink exists**: `SaveWav` + `LoadFile` round-trips bit-exactly
   at f32, so SN2's "assert the SAMPLES, not the vibe" is mechanically possible
   from the first node.
4. **Counters are established**: 10 on the portable side, 3 on the device side,
   all readable from Ring, all with a guard that proves each one moves.
5. **Verification status is Windows-runtime + Linux/macOS-cross-compile.** No
   line of this plane has run on Linux or macOS. Stated, not implied.

---

## SN2 STATUS — 2026-08-10. The graph renders, offline, and proves two things

Delivered: `engine/src/soundgraph.zig` (the graph), extended
`ring_bridge_sound.zig` + `stz_sound.ring` (23 new entry points), and
`base/test/sound/sound_graph_narrated.ring` (42 assertions). Plus 9 Zig unit
tests inside the module. All green; the whole phase runs with NO audio
hardware, which was the point of doing it before SN3.

Nodes: source, oscillator (sine/square/saw/triangle), gain, mix, pan
(constant-power), filter (RBJ biquad — low/high/bandpass), delay (with
feedback), envelope (ADSR). Sinks: buffer and WAV file.

### NAMED soundgraph.zig, NOT graph.zig

`src/graph.zig` was already taken by the graph-THEORY module behind
`stz_graph.dll` (nodes, edges, shortest path). Two unrelated meanings of
"graph" live in this engine and the filenames now say which is which. Recorded
because the collision is not obvious from either module's name, and the next
person to add a "graph" will meet it too.

### The two claims the guard exists to hold

**1. RENDER ALLOCATES NOTHING.** SN3's callback is a no-allocation, no-lock,
no-Ring zone; a graph that allocates while rendering cannot be handed to it. So
the contract is enforced rather than requested: every allocation in the module
goes through a counting allocator, and the guard reads the count either side of
200 render blocks over a filter + delay + envelope chain. It does not move — by
zero, not by "about zero". The negative sibling asserts that Prepare DOES
allocate, so the counter is live rather than stuck.

Wrapping the allocator, rather than counting our own call sites, is what makes
this catch an allocation inside something we call. A hand-rolled counter would
pass while a callee allocated.

**2. THE SINK IS A PARAMETER, NOT A FORK** (lesson 5). The same prepared graph
rendered to a buffer and to a WAV, then decoded back, is BIT-IDENTICAL — worst
difference exactly 0. What you hear and what you export cannot drift apart,
because they are the same `renderBlock` over the same node list. SN3's device
sink becomes a third caller of that one function.

### Other mechanisms asserted, not assumed

- **Exact arithmetic, not "sounds right".** A sine at rate/4 lands on exactly
  0, 1, 0, -1 and repeats. A mix of two saws at 0.25 and 0.5 sums to exactly
  0.75 — an exact statement a "roughly louder" test cannot make.
- **The block size is not audible.** The same graph at block 32 and block 500
  produces identical samples (worst difference 0). Filter state is per channel
  and carries across block boundaries. This is what makes a graph safe to hand
  to SN3's device, which picks the block size itself.
- **A lowpass crushes 12 kHz to 0.00017 and passes 50 Hz at 0.998.** Both halves
  asserted: without the second, "it went quiet" would prove only that the
  filter silences everything.
- **Cycles cannot be expressed.** A node may only reference inputs that already
  exist, so creation order is always a valid topological order. Feeding a mix
  back into an earlier node is refused and counted. Delay feedback lives INSIDE
  the delay node — which is what lets feedback exist without cycles existing.
- **Rewind repeats a render exactly and allocates nothing**, so a prepared
  graph is reusable.
- **The two-phase contract refuses both ways**: render-before-prepare,
  prepare-with-no-nodes, prepare-with-no-output, add-after-prepare, and
  prepare-twice each return their own distinct status.

### What SN3 inherits

1. **A render path that provably allocates nothing.** The callback can call
   `renderBlock` directly; the allocation guard is the regression test for
   that property.
2. **Block-size independence, proven.** The device may choose any block size.
3. **Coefficients are computed at BUILD time, not per block.** SN3's lock-free
   control queue is what will make filter/gain/pan parameters movable — the
   node fields exist, nothing writes them mid-render yet.
4. **What is NOT here**: no scheduling, no voice pool, no clock, no underrun
   counter, no parameter automation. SN3 adds the clock to a graph that is
   already correct without one.

---

## SN3 STATUS — 2026-08-10. The clock is on, and it holds

Delivered: `engine/src/soundring.zig` (the lock-free SPSC ring), the stream and
producer thread in `soundgraph.zig`, the device sink in `audiodev.zig`, 21 new
Ring entry points, and `base/test/sound/sound_realtime_narrated.ring` (33
assertions). Plus 43 Zig unit tests across the three modules. All green.

### The architecture, and why it is shaped that way

    producer thread            ring buffer             audio callback
    (stz_sound.dll)      ->    (soundring.zig)   ->    (stz_audiodev.dll)
    renders the graph          lock-free SPSC          bounded copy only
    NO deadline                                        THE deadline

FACT 4 says the callback is deadline-bound and that allocation, locks and
Ring/VM calls are forbidden inside it. Rather than ask the callback to be
careful, the split makes all three absences structural: **the callback does not
render the graph, it drains a buffer someone else already filled.** What it does
is one bounded copy and two atomics.

`soundring.zig` is ONE source file compiled into BOTH DLLs. The ring straddles a
DLL boundary, and two sides disagreeing about a struct layout would corrupt
audio in a way that looks like a hardware fault — so there is only one
declaration and the layouts cannot drift. What crosses the boundary is the
ring's ADDRESS, as a number: not an engine handle, exactly as stz_window hands
stz_gpu an HWND.

### Measured, on real hardware

Sustained playback of a 440 Hz tone, WASAPI shared mode, 256-frame period:

| | |
|---|---|
| callbacks | 289 |
| frames delivered | 73,984 (~1.5 s) |
| **worst callback** | **5.9 µs** |
| **underruns** | **0** |

SN0 measured the deadline as the WAKE-UP — ~10 ms in shared mode, carrying a
burst of callbacks. A 5.9 µs worst callback is **0.06% of that budget**. The
rendering already happened on the other thread; what is left inside the deadline
is a memcpy, and it costs what a memcpy costs.

### The three scenes SN3 was told to produce

1. **Sustained playback with ZERO underruns at a stated buffer size.** Done, on
   the device above, and again device-free through the same `popInterleaved` the
   callback runs.
2. **A deliberately overloaded graph that underruns and PROVES the counter
   moves.** A 256-frame ring drained 200,000 frames at once: served 0, underran
   exactly 200,000, counted in both frames and events. Without this, a guard
   that only ever sees zero underruns cannot tell a working counter from one
   that is never incremented.
3. **Control changes applied without a click.** Measured both ways: a 10 ms
   ramp gives a worst sample-to-sample jump of 0.00208; the identical change
   with no ramp gives exactly 1.0 — a full-scale step. The ramp is 480x
   smoother, and it ARRIVES at its target rather than merely approaching it.

### Two bugs the guards caught, both worth recording

**The ramp was asymptotic, not linear.** The first cut recomputed the step every
block as `(target - now) / ramp_frames`. That shrinks as the gap closes, so the
value approaches the target forever and never reaches it — measured 0.101 where
0.0 was asked for. A "10 ms fade" that never finishes is the kind of thing that
ships, because it sounds almost right. The step is now computed ONCE, when a new
target is first seen, and walked to arrival.

**An address from Ring could kill the process.** `playbackOpen` took an integer
across the DLL boundary and dereferenced it as a `*Ring`. The ring's hot fields
are 64-byte aligned, so a misaligned address is an immediate panic — a whole
process killed by a typo in a script. Now alignment, magic and version are all
checked before a single sample is read through it, and each failure is a counted
refusal.

### On the "lock-free control queue"

The plan's SN3 line says *queue*. What is built is a lock-free **atomic
parameter slot** per gain node: one aligned f32 written by the Ring thread with
release ordering, read by the render with acquire. For a single scalar, last
writer wins — which is exactly the desired semantics for a fader, and it is
lock-free in the sense that matters (no thread can block another).

A queue earns its complexity when the ORDER of several changes matters, or when
automation has to be sample-accurate. Neither is true yet. Recorded here as a
deliberate choice rather than an omission, so SN4 can build the queue when it
has a reason to.

### What is NOT here

- **Only gain is controllable.** Filter cutoff, pan and delay parameters are
  computed at build time and no path writes them mid-render. The node fields
  exist; nothing moves them.
- **No voice pool, no scheduling, no transport.** SN6's game-plane siblings.
- **Capture is still enumeration-only.** SN1's capture measurement was a spike;
  there is no capture stream in the plane.
- **Windows runtime only**, as with every phase so far. Linux and macOS remain
  cross-compile-checked and unrun.

### Guard inventory for the plane

| guard | assertions | needs hardware |
|---|---|---|
| sound_samples_narrated | 60 | no |
| sound_device_narrated | 20 | degrades to skip |
| sound_graph_narrated | 42 | no |
| sound_realtime_narrated | 33 | last scene only |
| Zig unit tests | 43 | no |

135 Ring assertions and 43 Zig tests, of which everything but one scene runs on
a machine with no sound card at all.
