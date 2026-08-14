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
  music notation, 3D/HRTF spatial audio, time-stretching, and VST/CLAP
  hosting.

  **AMENDED 2026-08-13.** This risk originally also ruled out "speech
  synthesis or recognition (the last two would be NEURAL-tier work riding
  ggml, not this plane's)". **That was a category error, and it is
  withdrawn**: speech was filed under machine learning because the state of
  the art in speech is machine learning, but every desktop OS has shipped a
  synthesiser for twenty years and it is an OS service exactly like the
  audio device. VC0 measured it — SAPI reached from Zig with ole32 and
  nothing else, 8 seconds of speech synthesised in 15 ms warm, rendered to
  a buffer that loads as an ordinary `stzSound`. See
  `SOFTANZA_VOICE_PLAN.md`. What remains out is NEURAL TTS and ASR, voice
  cloning, speaker identification and emotion inference — those are the
  NEURAL tier, and the original sentence was right about them.
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
| sound_examples_narrated | 33 | last example only |
| Zig unit tests | 43 | no |

168 Ring assertions and 43 Zig tests, of which everything but two scenes runs on
a machine with no sound card at all.

`sound_examples_narrated.ring` is the odd one out and deliberately so: it is
seven WORKED EXAMPLES -- a tone to a file, a chord, a bell with an echo, a
filter sweep, stereo placement, preparing audio for delivery, and live playback
with a fade -- where each example is also its own assertion. Examples that are
never run rot; guards that cannot be read teach nothing. It is the file to LOOK
at to learn the plane, and it fails if the plane misbehaves.

It earned its keep immediately. The chord example first asserted that three
different pitches must drift out of phase, and it FAILED: 440 : 554.37 : 659.25
is almost exactly 4 : 5 : 6, so the three waves nearly RE-ALIGN, and their peaks
nearly add. That near-alignment is not a bug in the mix -- it is what consonance
IS. The example now says so, and asserts it.

---

## SN4 CHALLENGE PASS — 2026-08-11, BEFORE any face was written

Lesson 7 says a deliberate challenge precedes the declarative faces, because
GR4's found four gaps. This one found six, and the §2 sketch does not survive
it intact — exactly as the graphics sketch did not.

### The house naming law, restated (from the graphics plan, GR4)

1. A method is an explicit **VERB** acting on the object — `AddCircle()`,
   `SetBackground()`. Never a bare noun, which says what a thing IS rather
   than what the call DOES.
2. **`...Q()` performs the same action and returns the MAIN object**, so a
   chain never leaves it for a sub-object to be held or lost. The plain twin
   ACTS and returns nothing.
3. **`To...()` keeps its name** and returns DATA.

### FINDING 1 — the sketch's graph surface breaks rule 2

The plan sketched:

    oG.Add(StzOscillatorQ(:Sine).Hz(440)).Named(:tone)
    oG.Add(StzEnvelopeQ().Attack(0.01).Release(0.4)).On(:tone)
    oG.Add(StzReverbQ().Room(0.6)).After(:tone)

Every line builds an INTERMEDIATE object, configures it, and hands it to the
graph — precisely what rule 2 exists to prevent. It is also three different
ways of saying where a node goes (`Named`, `On`, `After`), none of which is a
verb, and two of which are prepositions.

The graphics plane had the same shape of error and corrected it to
`oC.AddCircleQ(400, 300, 120)` — the shape is created BY a verb ON the main
object. The sound equivalent:

    oG.AddOscillator(:Sine, 440, 0.8)
    oG.AddEnvelope(:tone, 0.01, 0.3, 0.0, 0.4)
    oG.AddDelayAfter(:tone, 0.25, 0.4, 0.4)

    # fluent -- every Q returns the GRAPH
    oG.AddOscillatorQ(:Sine, 440, 0.8).NameItQ(:tone).
       AddEnvelopeQ(:tone, 0.01, 0.3, 0.0, 0.4)

`Named(:tone)` becomes `NameIt(:tone)` — a verb acting on the last node added,
the same "last shape added" mechanism stzCanvas uses for `Fill()`.

### FINDING 2 — `oS.Analysis()` and `oA.Spectrogram()` are nouns AND are SN5

Both name a thing rather than an act, and both belong to SN5 (analysis, the
graphics convergence). They are removed from SN4's surface rather than stubbed.
When SN5 builds them they should read `ToSpectrum()` / `ToSpectrogramPNG()` —
`To...` forms returning data, which is what rule 3 is for.

### FINDING 3 — StzReverbQ has no node behind it

The sketch offers a reverb. The engine has a DELAY, and a delay is not a
reverb: one echo repeating is not a diffuse field. Options were to fake it
(a name that lies), to build a real reverb (SN5-shaped work — Schroeder or
FDN, and convolution reverb is explicitly an SN5/GPU question), or to name
what exists.

**Decision: the face offers `AddDelay`/`AddEcho`, not `AddReverb`.** A name
that promises a room and delivers an echo is the kind of thing that survives
into documentation and then into someone's expectations.

### FINDING 4 — stzMicrophone has no capture stream to face

SN1 delivered capture ENUMERATION only; SN3 built a playback sink and no
capture path. So `stzMicrophone` as sketched would be a face over nothing.

**Decision: build the capture stream in SN4** rather than ship a stub or drop
a named deliverable. It is small — the ring already exists and is SPSC; capture
simply runs it the other way round (the device callback is the producer, the
Ring thread the consumer). What it needs: `pushInterleaved` on the ring, a
capture device in audiodev, and a drain-into-buffer on the portable side.

### FINDING 5 — `oS.Play()` on a sound is not the same act as `oG.Play()`

A stzSound is a sample buffer; the device sink plays a STREAM fed by a graph.
So `oS.Play()` has to build a one-node graph internally and run it. That is
fine and it is what a declarative face is FOR — but it means Play() on a sound
is synchronous-until-done, and the face must say so rather than let a caller
discover it. Named `Play()` (blocks until the sound ends) and `PlayFor(nSecs)`.

### FINDING 6 — no metadata, and the sketch never promised any

Worth recording because SN4 is where someone would reach for `oS.Title()`:
miniaudio parses no tags at all (SN1 status, gap 3). The face does not offer
Title/Artist/Album. Adding them later means a tag parser this plane would own.

### What SN4 therefore builds

    stzSound        a sample buffer: load, generate, inspect, convert, save, play
    stzSoundGraph   the declarative graph, verbs + Q twins, named nodes
    stzMicrophone   real capture, on a capture stream built here

and does NOT build: stzOscillator/stzEnvelope/stzFilter/stzReverb as separate
classes. They are not objects a caller should hold — they are verbs on the
graph, and rule 2 says so.

---

## SN4 STATUS — 2026-08-11. The faces, and the capture the challenge pass demanded

Delivered: `base/sound/stzSound.ring`, `stzSoundGraph.ring`,
`stzMicrophone.ring`, loaded from `base/stzBase.ring`; a capture stream in the
engine (`soundring.pushInterleaved`, `audiodev.captureOpen/Start/Stop/Close`,
`sound.recorderNew/Drain/Finish`); and
`base/test/sound/sound_faces_narrated.ring` — 49 assertions, green.

Plane totals: **237 Ring assertions across six guards, 64 Zig tests**, all
passing. Everything but two scenes runs with no audio hardware.

### The challenge pass changed the surface before it was built

Lesson 7 says the challenge precedes the faces. It found six things (recorded
in full in the SN4 CHALLENGE section above); three changed what shipped:

**The sketch's graph API was rejected outright.** `oG.Add(StzOscillatorQ(:Sine).Hz(440)).Named(:tone)`
builds an intermediate object per line, which is exactly what the Q law exists
to prevent — the same error the graphics sketch made before GR4 corrected it.
What shipped instead is verbs on the graph, with names to refer back:

    oG.AddOscillatorQ(:Triangle, 440, 0.6).NameItQ(:tone).
       AddEnvelopeOnQ(:tone, 0.01, 0.3, 0.0, 0.4, 0.35).
       AddEchoOnQ(:tone, 0.25, 0.4, 0.4).
       ToFileQ("bell.wav", 3)

There are **no stzOscillator / stzEnvelope / stzFilter classes**, deliberately.
A node is not a thing a caller should be left holding.

**`AddReverb` became `AddEchoOn`.** The engine has a delay; one repeat fading
out is not a diffuse room. A name that promises a hall and delivers a slapback
survives into documentation and then into expectations.

**`stzMicrophone` had nothing to face**, so SN4 built the capture path rather
than ship a stub or drop a named deliverable. The ring already existed and is
SPSC — capture is that ring run the other way round, with the device callback
as PRODUCER. Measured: 96,000 frames for a 2-second recording (exactly 2 s at
48 kHz), zero overruns.

Overrun is the capture-side twin of underrun and is counted the same way: when
the reader has not kept up, the NEWEST frames are dropped, never written over
unread audio. Losing the newest is recoverable; losing the middle of a
recording silently is not.

### The Q law is asserted by IDENTITY, not by eye

Rule 2 rots quietly — a `...Q` that returns a sub-object looks fine at the call
site until someone chains two of them. So the guard asserts that what a Q hands
back IS the object it was called on (`oRet.GraphId() = oG.GraphId()`), and that
the plain twin returns NULL. That is a mechanical check on a naming convention,
which is the only kind worth having.

### What SN4 does NOT deliver, and why

- **No analysis.** `oS.Analysis()` and `oA.Spectrogram()` from the sketch are
  nouns AND they are SN5. They were removed rather than stubbed. When SN5
  builds them they should read `ToSpectrum()` / `ToSpectrogramPNG()`.
- **No metadata.** miniaudio parses no tags; there is no `Title()`. Recorded
  because SN4 is exactly where someone would reach for it.
- **`Play()` blocks.** A sample buffer is not a stream, so the face builds a
  one-node graph and runs it to the end. Named so in the docs rather than
  discovered.
- **Only gain is controllable while playing** (SN3's limit, unchanged).

### What SN5 inherits

1. **A face to hang analysis on.** `oS.ToSpectrum()` belongs on stzSound, and
   the buffer id it needs is already exposed via `BufferId()`.
2. **A graph that can take a sound as a source**, so an analysis of a rendered
   graph is one call away.
3. **The naming law, now with a guard that enforces it.** Add a face, add the
   identity assertion.
4. **Capture exists**, so SN5's analysis can run on something recorded rather
   than only on something synthesised.

---

## SN5 STATUS — 2026-08-12. Analysis, and the first cross-plane composition

Delivered: `engine/src/soundanalysis.zig` (spectrum, spectrogram, onsets,
tempo, LUFS), `base/sound/stzSoundGrid.ring` (the data model + the drawing),
analysis methods on `stzSound`, and
`base/test/sound/sound_analysis_narrated.ring` — 33 assertions, green.

Plane totals: **270 Ring assertions across seven guards, 100 Zig tests.**

### FACT 2 cashed: nothing here reimplements a DFT

Every transform rides `fft.zig` — the same radix-2/Bluestein pair the numeric
tier has had all along, already held to a LAPACK-grade reference by its own
guards. The plan said the signal half was already strong; this is where that
paid.

### The output is a DATA MODEL, and that is what makes it testable

Every analysis returns a **grid**: rows x cols of f64, gen-keyed like every
other handle, carrying `x_step` (seconds per row) and `y_step` (hertz per
column) so a caller can label an axis without recomputing what the analysis
knew. A spectrum is one row; a spectrogram is many; onset times are one row of
seconds. One shape, one lifetime, one table.

That boundary is not tidiness. "The 1 kHz sine is in the 1 kHz bin" is a claim
about numbers a guard can check; "the spectrogram looks right" is a claim about
nothing.

### Measured

| | |
|---|---|
| a 1 kHz sine's peak | within one bin of 1 kHz |
| amplitude recovery ON a bin centre | 0.800 for a 0.8 tone |
| amplitude recovery OFF a bin (1 kHz at 11.72 Hz bins) | 0.744 — scalloping, predicted 0.7443 |
| spectrogram, 1 thread vs 4 | **bit-identical**, worst difference exactly 0 |
| a 200 Hz → 4 kHz sweep | peak rose 154 times, fell 0 |
| click track at 0.5 s | 119.7–122.3 BPM |
| doubling amplitude | **+6.02 LU**, as a dB scale must |
| drawing a 184-row spectrogram through stzCanvas | 88 ms, 87 KB of SVG |

### THE SWEEP IS THE CENTREPIECE, because it is provable AND visible

A tone sliding 200 Hz → 4 kHz must make the peak bin climb, row after row.
Drawn, it is a diagonal you can see is right; measured, it is monotonic and a
guard can prove it. That combination is rare and worth building tests around.

### The graphics convergence, and a finding for the graphics plane

The sound plane hands a grid of numbers to `stzCanvas`, which knows how to
draw. Neither knows the other's internals: `ToCanvas()` speaks only canvas
verbs, and stzCanvas has never heard of audio. The SVG tier needs no device at
all, so **CI can draw a spectrogram**.

**FINDING: stzCanvas has no image primitive.** It offers AddRect, AddCircle,
AddLine, AddText — so a spectrogram costs ONE RECTANGLE PER CELL. The grid is
downsampled to the pixel size asked for (each output cell takes the LOUDEST
value beneath it, which is the right summary — an average hides a brief bright
partial), and even so a 760x260 picture is ~87 KB of SVG and 88 ms to build.
An `AddImage` / `AddPixels` on stzCanvas would make this one call instead of
twenty thousand. That belongs to the graphics plane, and is recorded here as
the first thing the sound plane has ever wanted from it.

Colour is dB, not amplitude: hearing is logarithmic, and a linear ramp shows
one bright line on an otherwise black picture.

### Two bugs the guards caught, both mine and both instructive

**A steady tone reported 1125 BPM.** The onset detector compared spectral flux
against a moving average of ITSELF and nothing else. On a steady tone the flux
is numerical noise — and noise still has peaks above its own mean. A note
starting changes the spectrum by an amount comparable to the spectrum itself,
so an absolute floor (2% of mean spectral magnitude) now sits beside the
relative one. A steady tone finds nothing and `tempo()` returns -1, which is a
better answer than a confident wrong number.

**Two test expectations were naive, not the code.** The spectrum read 0.744
where I asserted 0.8 — 1000 Hz at 11.72 Hz bins lands on bin 85.33, BETWEEN
two bins, and the arithmetic predicts exactly 0.7443. And LUFS came out 0.7 dB
above my hand-derived value because I assumed K-weighting is flat at 1 kHz; it
is not. The loudness test now predicts the answer by running a probe tone
through the very same biquads and measuring the gain — two independent
measurements of one truth, so if the filters change the test moves with them.

### What is NOT here

- **LUFS is integrated only.** No short-term (3 s) or momentary (400 ms)
  windows, no loudness range (LRA), no true-peak. The blocks exist internally;
  exposing them is small when something needs them.
- **Surround weighting is not claimed.** BS.1770 weights Ls/Rs at 1.41; this
  plane does not claim surround, so every channel weighs 1.0.
- **Tempo is a median of onset gaps**, not a beat tracker. It reports what it
  can defend and -1 otherwise; it will not follow a tempo that changes.
- **No key or pitch detection**, no chroma, no MFCC.

### What SN6 inherits

1. **A grid model** any later analysis can return without inventing a shape.
2. **A working cross-plane path** to stzCanvas — the pattern for the reactive
   layer and the delivery plane's browser tier.
3. **The stzCanvas image gap**, named, if drawing gets heavier.

---

## POST-SN5 RECORD — 2026-08-12. Work that shipped between SN5 and SN6

Rule 9 says record the outcome in this file. The following was committed and
was not written down; closing that gap here rather than leaving it to be
rediscovered.

### The web studio

`engine/tools/stz_sound_studio.zig` + `tools/studio.html`, built by
`zig build studio`. Launching the exe opens the browser and serves the app with
no other tool and no configuration — the requirement that shaped it. It exists
to hear a sample and tune it during development, not to be a product.

Bug worth not repeating: `stz_tcp`'s `tcp_recv` used `Stream.read`, which on
Windows reaches `ReadFile` and does not work on an accepted socket. Fixed with
`std.posix.recv`; guarded by `74_tcp_server_read_narrated.ring`.

### stzSoundPlot, and six plates that teach one thing each

`base/sound/stzSoundPlot.ring` turns an analysis grid into a picture a person
can read: an inferno ramp whose lightness rises monotonically (computed, not
guessed — OKLab L from 0.048 to 0.978, smallest step 0.077), log frequency
because the ear hears octaves, and a note under every plate saying what it
MEANS. Guard: `test/sound/sound_plot_narrated.ring` (23).

`test/sound/sound_insights_gallery.ring` writes six plates and plays the sound
behind each: aliasing, a click against a fade, timbre, beats, resonance, and
the alias removed. **Plate 1 was a bug report** — see below.

Five drawing faults, each now a guard:

- `AddPolyline` takes a FLAT point list. Handed pairs it drew nothing and
  reported no error; two plates came out as bare axes.
- Each series was normalised to ITS OWN peak, which puts every curve at 0 dB
  and destroys the comparison the chart exists to make. The guard now proves
  the drawn gap IS the measured gap: 13.0083 dB drawn against 13.0085 dB in the
  data.
- The footer ran off the right edge, losing the end of the sentence explaining
  the picture. It wraps and measures now.
- `SetFont` before `AddText` restyles the PREVIOUS shape. On an empty canvas
  that looks harmless, which is how it survived; in a RUN of labels every size
  lands one late. Asking for 28 px then 11 px drew 10.29 then 26.20.
- A −70 dB floor lights up every pixel of a sound with a broadband floor.
  `SetDynamicRange` added.

**The guards measure GEOMETRY, not markup**, because stzCanvas renders text as
glyph outlines: there is no `<text>` element and no `font-size` to read, so a
claim about a label's size becomes a claim about how tall its glyphs are.

Recorded and still open: **stzCanvas has no image primitive**, so a spectrogram
costs one rectangle per cell. This is SN5's finding, unchanged.

### Band-limited oscillators — the defect plate 1 found

The oscillators were NAIVE. A square, saw or triangle drawn literally is wrong
in a sampled system: the harmonics past Nyquist fold back as tones nobody
played, and no downstream filter can undo it. Plate 1 drew a swept saw growing
a second set of partials sweeping DOWNWARD through it — that picture is what
found the bug.

Fixed with **PolyBLEP**, and polyBLAMP for the triangle (which has no jump in
value, only in slope). Measured at a bin that can only hold a fold-back —
harmonic 7 of a 5 kHz saw lands at 35 kHz and reflects to 13 kHz:

| waveform | naive | band-limited | improvement |
|---|---|---|---|
| saw | 0.09384 | 0.00977 | 9.6x |
| square | 0.18805 | 0.01953 | 9.6x |
| triangle | 0.01775 | 0.00178 | 9.9x |

The triangle took two attempts. polyBLEP is normalised for a jump of TWO, so
the BLAMP factor is HALF the slope change — 4·dt, not 8. The first draft used 8,
over-corrected, and bought 1.3x instead of 10x. **The measurement caught it; the
arithmetic alone had looked fine.**

Three guards, because "quieter" is also true of silence: the naive wave really
does put energy at 13 kHz; the real harmonics SURVIVE (2/(πk) to within 5%,
fundamental to within 2%); and at 50 Hz only 5 samples in 4800 differ — a
correction at the jumps, not a differently-shaped wave.

Two tests used a 1 Hz square as a stand-in for DC and read sample zero, which
now sits exactly on the discontinuity. **A band-limited step is worth the
MIDPOINT of its jump at the instant it steps**, so they read from frame 1 — the
oscillator being right, not the ramp being early.

### SN6 — see the SN6 STATUS section below, which closed it

What this record listed as in-flight:

- **`base/sound/stzSoundTransport.ring`** — play, pause, resume, stop, without
  blocking. `PlayFor` sleeps for the length of the sound, which means nothing
  else in the program happens while it plays; the transport owns the same three
  engine handles and never sleeps. Three properties it exists for:
  - the state machine is not decoration — stzStateMachine declares the five
    legal moves and "resume something that was never paused" is refused by the
    machine rather than by an if-ladder;
  - **the clock is the DEVICE's, not the wall's** — position comes from frames
    the device has CONSUMED, so it cannot drift from what is being heard;
  - pause is a RAMP, not a switch, reusing SN3's click-free ramp.

  Bug worth not repeating: **stzStateMachine refuses an illegal event by
  STAYING PUT and returning the state it is still in — it does not raise.** The
  first `_Move` assumed a raise, caught nothing, treated every refusal as a
  success, and "resume" from stopped opened a second device on a graph that
  already had one. The process died on the spot.

- **`base/sound/stzVoicePool.ring`** — voices as pooled handles, the game-plane
  door. Built once, prepared once, mixed into one stream; firing is an atomic
  flag. Slot stealing is COUNTED, and the count is read from the transport
  clock rather than inferred from the fire count — the first version guessed
  from the count and printed fiction (eight shots through three slots read as
  five steals when every shot had long finished).

- **`soundgraph.zig`: `triggerNode`** — a per-node retrigger. `rewind()` takes
  the whole graph to zero, which is useless when thirty sounds share one graph
  and one must fire. The request is an atomic FLAG consumed at the TOP of a
  block, before any node has produced a sample: applying it inline as each node
  is reached would reset a voice's source AFTER the source had already rendered
  that block. Guarded both ways — one voice restarts while its neighbour keeps
  running.

**What SN6 has NOT done:** the WebAudio sink. The blocker is concrete and worth
recording: `soundgraph.zig` imports `sound.zig` for its sample buffers, and
`sound.zig` is miniaudio, which will not build for freestanding wasm32. A
browser sink needs the graph's render path separated from buffer storage — a
real refactor, not a build flag. The reactive layer and the shared clock are
done (above); the transport's `DriveWith(oReactive)` is the seam.

Plane totals after this work: **338 Ring assertions across ten guards, 36 Zig
tests in soundgraph alone.**

---

## SN6 STATUS — 2026-08-12. The convergence dividend, closed

Sound joined the planes that exist. Four parts, all standing.

### The reactive layer, and the transport

`base/sound/stzSoundTransport.ring` — play, pause, resume, stop, without
blocking. `PlayFor` sleeps for the length of the sound, which means nothing else
in the program happens while it plays; the transport owns the same three engine
handles and never sleeps. `DriveWith(oReactive)` hands the STEP to the loop that
already exists rather than owning a second one.

Three properties it exists for:

- **The state machine is not decoration.** stzStateMachine declares the five
  legal moves and "resume something that was never paused" is refused by the
  machine, not by an if-ladder that drifts from the comment above it.
- **The clock is the DEVICE's, not the wall's.** Position comes from frames the
  device has CONSUMED, so it cannot drift from what is being heard. A wall clock
  started at Play() drifts the moment the machine is busy, and drifts in the
  direction that looks fine in a demo.
- **Pause is a RAMP, not a switch** — SN3's click-free ramp, reused.

Bug worth not repeating: **stzStateMachine refuses an illegal event by STAYING
PUT and returning the state it is still in — it does NOT raise.** The first
`_Move` assumed a raise, caught nothing, treated every refusal as a success, and
"resume" from stopped opened a second device on a graph that already had one.
The process died on the spot. Compare before/after; never rely on a catch.

### Voices as pooled handles

`base/sound/stzVoicePool.ring` — the game-plane door. Built once, prepared once,
mixed into one stream; firing is an atomic flag the render consumes at the top of
a block. A game fires the same footstep thirty times a minute and two overlap;
building a graph per shot would allocate inside the frame that has to draw.

Slot stealing is COUNTED, and read from the transport clock rather than inferred
from the fire count. The first version guessed from the count and printed
fiction: eight shots through three slots read as five steals when every shot had
long finished. Verified after the fix — six fires into two slots with 1 s shots
at 0.12 s intervals reports exactly four steals.

The engine primitive it needed: **`soundgraph.zig triggerNode`**. `rewind()`
takes the whole graph to zero, which is useless when thirty sounds share one
graph and one must fire. The request is an atomic FLAG consumed at the TOP of a
block — applying it inline as each node is reached would reset a voice's source
AFTER the source had already rendered that block, so the note would start a
block late, and only sometimes.

### THE BROWSER SINK — and the blocker that turned out to be real

The plan recorded this as blocked: `soundgraph.zig` imports `sound.zig`, which
does `@cImport("miniaudio.h")` and uses `std.heap.c_allocator`, and freestanding
wasm32 has neither a C header nor a libc. **Measured rather than assumed, and it
was true.** But the coupling was not the DSP — it was the sample TABLE and the
DECODER sitting in the same file the render loop reads from.

So the seam moved:

- **`engine/src/sounddsp.zig`** — the arithmetic of a sound and nothing else:
  band-limited oscillators, the RBJ biquad, the ADSR envelope. It imports `std`
  and nothing more, and it compiles for `wasm32-freestanding` (proved: a probe
  linked to 650 bytes). 5 Zig tests.
- **`engine/src/soundwasm.zig`** — the graph for a target with no libc and no
  device: fixed static arrays, no allocator, and no source nodes, because a
  browser already ships `decodeAudioData` and duplicating a decoder into wasm to
  avoid the platform's own would be absurd. 4 Zig tests.
- **`base/system/emulator_assets/stz-sound.js`** — an AudioWorklet. A worklet and
  not a ScriptProcessorNode: a worklet runs on the AUDIO thread, and putting the
  render behind the main thread would throw away everything SN3's lock-free ring
  was for.

`soundgraph.zig` now delegates to `sounddsp.zig`. **Proved behaviour-preserving
by hashing the render before and after: FNV-64 `a9da6b773c240925`, identical.**

**THE PROPERTY THE SEAM EXISTS FOR, asserted:** the native tier and the browser
tier render the same graph — saw + lowpass + envelope + triangle + mix + pan,
eight blocks so filter state and envelope position cross a block boundary — and
the worst sample difference is **exactly 0**, not "close". A tolerance there
would hide the drift being hunted. Its negative sibling puts the two graphs one
hertz apart and asserts they DISAGREE, so the comparison is measuring something.

**A 26 MB wasm, and the fix.** The first cut gave every node a one-second delay
line and a 1024-frame bus and produced a 26 MB `stz.wasm` — unshippable, and
invisible until the artefact was weighed. Two causes: `Node` has non-zero
defaults so an array of them is `.data` rather than `.bss` and every byte lands
in the module; and `--import-memory` means wasm-ld cannot assume the memory
arrives zeroed, so even `undefined` statics are emitted. Sized against the
artefact instead of by habit:

| configuration | stz.wasm (sound group only) |
|---|---|
| per-node 1 s lines, 1024-frame bus | 26 MB |
| shared pool of 4 x 250 ms, 256-frame bus | 515 KB |
| shared pool of 2 x 125 ms, 128-frame bus | **182 KB** |

Recorded because it generalises: **in a wasm module a static array's size is
DOWNLOAD size.** Every cap in `soundwasm.zig` is bytes on someone's connection.

### VERIFIED IN A BROWSER, and the latency result is the surprise

`base/test/sound/webaudio/index.html`, served and driven: 9 nodes, 48 kHz,
worklet running on the audio thread, a live scope showing the trace, and the
bell retriggering through the port into wasm (the trace's vertical span went
19 -> 24 px on trigger and back to 19 as it decayed).

**The browser is the LOWER-latency sink, by a factor of forty:**

| path | latency | Rule 18's 100 ms |
|---|---|---|
| native, Windows shared-mode WASAPI | ~419 ms (329 ms ring + 90 ms device/OS) | **4x over** |
| browser, AudioWorklet | **10.0 ms** measured (`outputLatency` + `baseLatency`) | **inside** |

This inverts what the semantics section had to conclude. S.5 says a sound cannot
be a lawful Rule 18 acknowledgement on this pipeline, and on native Windows that
stands. **In a browser it can** — there is no ring at all, because the worklet
IS the clock: it asks, wasm fills, it plays. So the eyes-free surface that S.5
had to declare unserviceable is serviceable on the web tier, which is also where
§2.1 of THE-SECOND-FOUNDING says gamification audio will actually live.

Not a consolation, and not a licence either: 10.0 ms is one browser on one
machine, and `outputLatency` is a browser's own estimate. The page REPORTS it
rather than claiming it, and says nothing at all when a browser does not.

### Plane totals

**47 Zig tests in soundgraph** (including the cross-tier identity pair), 9 in
soundwasm + sounddsp, **338 Ring assertions across ten guards.**

### What SN6 did NOT do

- **No sample playback in the browser.** No source nodes there; a browser has
  `decodeAudioData` and its own buffers. Stated in `soundwasm.zig`, not
  discovered later.
- **No shared-memory path.** The worklet instantiates its own module on the
  audio thread and reads its own linear memory. A `SharedArrayBuffer` design
  would let the main thread write parameters without a port message, and it
  needs COOP/COEP headers — a delivery-plane decision, not this plane's.
- **The 26 MB lesson is not generalised into a build check.** Nothing yet fails
  a build for shipping a fat wasm. Worth doing where the delivery plane weighs
  its bundles.

---

## SOUND SEMANTICS (SS) — the meaning layer, opened 2026-08-12, BEFORE SN6

This plane is a production engine with no notion of what a sound *means*.
Searched across the whole plane for `earcon`, `sonification`, `sound role`,
`alert sound`, `notification`, `auditory`: **zero hits.** There is no success
sound, no error sound, no alert taxonomy, no priority, no mapping from an
application event to a sound. Meanwhile the UI constitution
(`stzzui/constitution/rules.json`) legislates five semantic values in **Rule
118** and has never once been cited by this plane, nor cited it.

**The timing is the whole point.** SN0–SN5 are closed; SN6 is where the plane
first reaches outward — the reactive layer, a browser sink, the game-plane
doors. A vocabulary agreed before those doors open costs a document. Agreed
after, it costs a migration. The colour plane learned this the expensive way:
§1 of `graphics/SOFTANZA_COLOR_SYSTEM.md` records a ramp that drifted into
incompatible spellings before anyone measured it.

**Precondition, checked before starting:** Rule 118 settles the five values —
`success` (OK, valid, under control), `warning` (watch this), `danger`
(critical, exceeded, incident), `info` (in progress, neutral), `muted`
(waiting, inactive). Without a settled vocabulary there is nothing to
transpose and this section would have been a guess.

**What this session did not touch:** no node type, no sink, no callback, no
buffer, no timing path. The semantic layer sits ABOVE the graph and composes
verbs that already exist. Where a deliverable turned out to need the real-time
path, it was deferred to a phase and said so — see §S.3 on ducking.

**On the discipline (rule 2).** Two of the findings below are measurements
taken *before* the design, as reconnaissance, and are presented as findings
rather than as gate results. The kill criteria in §S.8 are written now, before
the phases they gate have run.

### S.1 The transposition from colour, audited line by line

`stzzui/doc/THE-SECOND-FOUNDING.md` §6.1 proposes the colour system's
structure, transposed. It was written from the colour precedent by someone who
had read this plan once, and it is explicitly a proposal to this plane rather
than a specification of it. Audited:

| Colour — built and proven | §6.1's analogue | Verdict here |
|---|---|---|
| the five semantic names | the same five names | **ACCEPTED.** One vocabulary, two channels — §S.2 |
| hue = identity | timbre = identity | **REFUSED as written.** Measured in SS1: timbre alone scores 0.80, contour 1.55 — identity is a MOTIF, contour-first |
| lightness = prominence | salience = loudness × brightness × repetition | **AMENDED.** Repetition is a time cost, not an intensity, and is unlawful in a cue — §S.2 |
| the sRGB gamut | the band between noise floor and discomfort ceiling | **ACCEPTED, with an asymmetry that matters** — §S.4 |
| chroma searched to fit the gamut | salience fitted to the room, never chosen | **AMENDED.** The gamut is free; the room costs a microphone and a consent — §S.4 |
| `.Surface .Border .Solid .Text` | `.Ambient` · `.Cue` · `.Alert` | **ACCEPTED, with `.Ambient` gated** — §S.2 |
| `:OnDanger` — what can be *read on* it | `:OverDanger` — what can be *heard over* it | **REFUSED on acoustic grounds** — §S.3 |
| contrast, floor 4.5 | audibility margin over the measured floor | **ACCEPTED — and the instrument cannot measure it yet** — §S.4 |

The refusal is the most valuable line in the table and is argued in §S.3.

### S.2 The five values, in sound

An author writes a meaning and gets a sound. The colour plane's rule holds
unchanged: *nobody types a waveform where they should type a meaning.*

```ring
oEar.Fire(:Danger)              # one word, like oC.FillQ(:Danger)
oEar.Fire("Warning.Alert")      # the role step, spelled as colour spells it
```

**`:Muted` renders as SILENCE, and that is a rendering rather than a gap.**
`muted` means waiting or inactive; a sound announcing inactivity is a
contradiction, and in this channel silence already carries it exactly. So the
five names survive intact and one of them is lawfully empty. This is also why
no sixth value is needed: the pressure that would have produced one is
relieved by admitting that a value may render to nothing.

**Identity is a MOTIF, and CONTOUR is its primary carrier.** A motif is
(contour, interval, duration, timbre). **SS1 settled which component carries the
load — see its STATUS section below: timbre alone measures 0.80 separability
through a small speaker, contour alone 1.55, and below 1 a motif is nearer a
different meaning than to itself.** Timbre reinforces; it is never the sole
distinction between two meanings.

The first attempt at this question failed honestly, and the failure is worth
keeping because it names an instrument not to reach for again: a square/triangle pair at
880 Hz kept 86% of its spectral distance through a 500 Hz–6 kHz band (a rough
laptop speaker), which would support timbre — but the same measurement read
*over 100%* at 150–440 Hz, because normalising each spectrum to its own peak
lets the filter's removal of the fundamental rescale everything and inflate the
distance. **The metric was confounded, by exactly the fault `stzSoundPlot` had
to be fixed for.** A spectral L1 distance is the wrong instrument for an
audibility question; SS1's kill criterion names the right one.

**Salience is loudness and spectral centroid. Repetition is excluded from a
cue.** §6.1 multiplies three terms; the third does not belong with the other
two. Loudness and brightness are properties of one sound at one instant.
Repetition is a property of a SEQUENCE, and it costs time the constitution has
already spent: Rule 18 allows 100 ms, and the second element of a repeat is by
construction later than the first. So repetition is admitted for `.Alert`,
which reports a *persistent* condition and may legitimately continue, and
refused for `.Cue`, which reports an event and must not.

**The three role steps are an ATTENTION ladder, not a layering.** Colour's four
steps describe spatial depth — a surface behind a border behind text, all
co-present. Sound has no depth; it has time and attention. So:

| step | what it is | admitted |
|---|---|---|
| `.Cue` | one short sound reporting one event | **the default** for a bare `:Name` |
| `.Alert` | a persistent condition, may repeat | on declaration |
| `.Ambient` | a continuous bed | **opt-in only, never produced by `Fire`** |

`.Ambient` is gated because Rule 1's own lint forbids exactly this shape —
*"html lint: `<video>`/`<audio>` with autoplay — attention is never taken
uninvited."* A continuous semantic bed is autoplay with a justification
attached. It stays in the vocabulary because a monitoring wall is a real
surface, and it never arrives by default.

### S.3 Priority — and why `:OverDanger` is refused

**The refusal.** `:OnDanger` works in colour because the pair is *co-present
and spatial*: text sits on a fill in the same instant, and contrast is a ratio
between two things that are both simply there. Two sounds in the same instant
do not layer — they **mask**, and masking is frequency-selective and
asymmetric. A loud low sound hides a quiet higher one far more than the reverse
(the upward spread of masking), so there is no fixed answer to "what can be
heard over `:Danger`": it depends on the spectral overlap of the particular
pair and on the level of both, and it changes when either changes.

And constitutionally it should not be asked. **An alert that can be talked over
is not an alert.** So the answer to "what can be heard over danger" is
*nothing* — you duck the other thing, or you drop it. `:OverDanger` is
therefore not a pair to be computed but a **priority contract**, which is
genuinely new work and not a relabelling: the plane has no bus and no priority
concept today beyond the mix node.

**The contract, decided:**

1. **One semantic bus.** At most one `.Alert` sounds at a time.
2. **Order:** `danger` > `warning` > `info` > `success`. `muted` is silent and
   never contends.
3. **Higher pre-empts lower.** A `.Cue` displaced by something louder in
   meaning is **DROPPED, not queued.** A cue that arrives after its event is
   not a cue — it is a lie about when something happened, and Rule 18's
   causality window is the reason.
4. **Equal priority inside a refractory window is ONE event.** Default 150 ms.
   The same state reported twice in a tenth of a second is one state.
5. **Everything dropped is COUNTED** (working discipline, rule 4). "Why did
   that sound vanish" must have an answer that is a number.

**Ducking is specified here and NOT built here.** Attenuating a lower-priority
voice needs a per-bus gain node, and adding a node — even an instance of a type
that already exists — is on the far side of this session's boundary. It is
SS3, with its kill criterion in §S.8. Deliberately not smuggled into a
vocabulary session; the colour plan's §5 records what smuggling a visible
change inside another phase costs.

### S.4 The audibility floor — and the instrument that cannot yet measure it

Colour's doctrine transposes exactly: **a sound system that cannot fail an
audibility check does not have one.** The check is a MARGIN in LU over the
ambient floor, and it is the auditory analogue of Rule 62's 4.5:1.

**MEASURED, and it is a hard finding: SN5's `Loudness()` cannot see an
earcon.** BS.1770-4 integrates over 400 ms blocks with a −70 LUFS absolute
gate. An earcon is shorter than one block. An 880 Hz tone at **peak 0.50**,
5 ms in / 10 ms out:

| duration | `Loudness()` |
|---|---|
| 40 ms | **−1000 LUFS** |
| 60 ms | **−1000 LUFS** |
| 100 ms | **−1000 LUFS** |
| 200 ms | **−1000 LUFS** |
| 400 ms | −9.38 LUFS |
| 800 ms | −9.29 LUFS |
| 2000 ms | −9.27 LUFS |

−1000 is this plane's "silence" answer. **A plainly audible sound at half full
scale reports as silence** because it is shorter than the standard's window.
SN5 recorded that "LUFS is integrated only… the blocks exist internally;
exposing them is small when something needs them." Something now needed them.
**SS2 built it — see its STATUS section below.** `LoudnessOfSupport` applies the
same K-weighting and the same formula over the sound's own length, reads −9.26
for a 60 ms earcon, and agrees with the standard to a hundredth of a decibel
wherever the standard has an opinion. The gate runs on it now; the unweighted RMS
substitute this section originally described is gone.

**The asymmetry with colour that must not be papered over.** The sRGB gamut is a
property of the medium: constant, known at build time, free to consult — which
is why the colour engine can *search* chroma to fit it. The ambient noise floor
is a property of the room: unknown, changing, and unknowable without a
microphone. This plane ships `stzMicrophone`, so it *can* be measured — but
measuring it is a privacy act requiring consent, it is unavailable on a machine
with no input, and CI has neither. Therefore:

- The floor is **DECLARED**, with a conservative default (a quiet office,
  −40 LUFS ambient), and never silently measured.
- A measured floor is **opt-in and consented**, and when present it supersedes
  the declaration.
- **The gate proves the design is audible in the room it DECLARES, not in the
  room it is in.** This is weaker than colour's gate. It is stated rather than
  hidden, because a gate whose limits are unwritten is worse than no gate.

Required margins, to be gated: **≥ 10 LU over the declared floor for `.Cue`,
≥ 20 LU for `.Alert`.** The discomfort ceiling is the other wall of the gamut,
is a declaration too, and no `.Cue` may exceed it.

### S.5 The latency budget, against Rule 18

Rule 18: *"Actions must acknowledge the user within 100 ms."* Placed beside
this plane's own numbers for the first time.

SN0's decomposition, with the standing instruction *quote the buffer, never the
112 ms* honoured — the 22 ms loopback tap is a measurement artefact and is
excluded:

| stage | cost |
|---|---|
| device buffer, shared mode (480 × 3) | 30 ms |
| Windows audio pipeline, application cannot remove | ~60 ms |
| **pipeline floor, before the application does anything** | **~90 ms** |

**And a stage nobody had measured: the SN3 ring.** The producer thread keeps it
as full as it can, so a sound triggered now is rendered into audio that plays
only after everything already queued. Measured on this machine, shared mode,
256-frame device period, 40 samples over 0.8 s after an 0.8 s settle:

| ring capacity | queued ahead of the device | underruns |
|---|---|---|
| **16384 frames** (the current default) | **329.1 ms** avg (314.7–341.3) | 0 |
| 4096 frames | 75.5 ms avg (58.7–85.3) | 0 |
| 1024 frames | 9.6 ms avg (0–21.3) | **6,912** |
| 512 frames | 10.1 ms avg (0–21.3) | **7,424** |

Trigger-to-ear, therefore:

| configuration | ring | pipeline | total | Rule 18 |
|---|---|---|---|---|
| the default path today | 329 ms | 90 ms | **~419 ms** | **4x over** |
| the smallest ring that does not underrun | 75 ms | 90 ms | **~165 ms** | **over** |
| a hypothetical zero-depth ring | 0 ms | 90 ms | **~90 ms** | inside, by 10 ms |

**The plain answer the constitution is owed: on this pipeline a sound cannot be
a lawful Rule 18 acknowledgement.** The ring depth that would fit the budget is
about 480 frames, and 1024 frames already underran 6,912 times — **the depth
the rule requires is below the depth this machine can sustain.** The 90 ms
pipeline floor alone spends nine tenths of the budget before the application
has done anything.

Two consequences, and they are not the same:

- **On a surface that has a screen this is not a problem, because the sound was
  never the acknowledgement.** The visual state change acknowledges within Rule
  18; the sound arrives afterwards and *corroborates*. This is the third law in
  §S.6 arrived at from the other direction — and it means the constitution is
  already self-consistent, provided Rule 18's acknowledgement is read as
  belonging to the visual channel.
- **On an eyes-free surface, where the sound IS the only acknowledgement, Rule
  18 is unsatisfiable here.** That is a constitutional finding, not a defect
  this plane can fix: no application-side change removes 60 ms of Windows audio
  pipeline. It belongs in front of whoever owns the rule.

The plane's own SN0 finding — *what has a deadline is the WAKE-UP; what must fit
inside it is the burst's TOTAL work* — is why the compute side is not the
problem: the burst spends 14–32 µs of a 10 ms wake-up, 0.13–0.32%. **Nothing in
the budget above is computation. All of it is queueing.**

### S.6 Three laws sound needs that colour does not

1. **Sound is interruptive by default.** A colour waits to be looked at; a
   sound seizes attention, and there is no eyelid for the ear. Rule 112 —
   *motion reports, it never decorates* — becomes **sound reports, it never
   decorates**, and in this channel it is the STRONGER rule.
2. **Silence is the default and must remain sufficient.** Sound is the first
   thing switched off, and it is absent in open-plan offices, in meetings, and
   for deaf operators. **A semantic sound is always redundant with another
   channel and never the sole carrier of a state.** One sentence that is
   simultaneously the accessibility law and the practicality law.
3. **A sound is not persistent.** A colour stays until changed; a sound is
   gone. Anything the operator has a *right* to know cannot be delivered by a
   sound alone — it must remain re-requestable. This is the Right to Understand
   with a channel attached.

### S.7 The constitutional cross-citation

The rules this layer serves, recorded so the next drift has something to hit:

| rule | what the semantic layer owes it |
|---|---|
| **Rule 118**, Two Families of Colour | the five values, unextended. A sixth would be a constitutional matter, not a plane's |
| **Rule 3**, Color Is a Signal | a sound that means something must not also decorate |
| **Rule 18**, The Speed of Thought | the budget in §S.5, and the verdict that a sound cannot carry the acknowledgement on this pipeline |
| **Rule 112**, Motion Reports | its auditory form, and the stronger one |
| **Rule 62**, Contrast & Legibility | the audibility margin as its auditory analogue, and the admission that our gate is weaker |
| **Rule 1**, Cognitive Mercy | why `.Ambient` is opt-in and never default |

Reciprocally, StzZui is to record the instrument — that `Loudness()` exists,
what it cannot measure (§S.4), and the latency floor (§S.5). **The colour plane
and the law both skipped this step, and that is how more than one spelling of
one palette shipped.**

### S.8 Phases, each with a kill criterion written before the numbers

**SS1 — the vocabulary, and what actually carries identity.** Five values,
three role steps, motifs for four of them (`:Muted` is silence). Then settle
§S.2's open question with an instrument that can answer it: a masked-detection
model or a listening test, NOT a spectral L1 distance.
*Kill:* if the four sounding values cannot be told apart at a stated margin
through a 500 Hz–6 kHz band, the motifs are wrong — and if no motif set can,
timbre is not the identity carrier and §6.1's second row is refused too.

**SS2 — a loudness the floor can bind to.** Expose the momentary (400 ms)
blocks SN5 already computes internally, plus a gated short-window loudness over
a sound's own support.
*Kill:* if a 60 ms earcon at peak 0.5 still cannot be given a defensible
loudness number, the audibility gate has no instrument and the floor must be
stated in peak/RMS terms instead — labelled as not-LUFS, every time.

**SS3 — priority and ducking.** The contract in §S.3, plus the per-bus gain
node ducking needs, ramped through SN3's existing atomic slot.
*Kill:* if ducking cannot be made click-free at the 10 ms ramp SN3 measured, it
is dropped in favour of drop-and-count — a missing sound is better than a
click, and plate 2 of the insight gallery shows why.

**SS4 — the cross-plane declaration.** One `:Danger` declaration rendering to
both a colour and a sound.
*Kill:* if the two channels need separate declarations to look and sound right,
the shared vocabulary is decorative and this section's central claim is false.

### S.9 What is NOT here

- **No speech.** Synthesis and recognition remain out of scope as neural-tier
  work (§4). Voice is a separate medium with a separate owner.
- **No sixth value.** Five, per Rule 118. `:Muted` rendering to silence is what
  removes the pressure for a sixth.
- **No ducking implementation** — specified in §S.3, built in SS3.
- **No measured ambient floor by default** — declared, per §S.4.
- **No sonification** (continuous data mapped to sound). A different problem
  from semantics; naming it here is not claiming it.

### SS1 STATUS — closed 2026-08-12. Contour carries identity; timbre reinforces it

The question section 6.1 asked and S.2 could not answer: does TIMBRE carry
identity as hue does? The semantics session tried a spectral L1 distance, got 86%
at 880 Hz and *over 100%* at 150 Hz, and correctly refused to legislate from a
metric whose per-signal normalisation had confounded it.

**THE INSTRUMENT, rebuilt to the shape S.8 demanded.** Guard:
`test/sound/sound_ss1_narrated.ring` (12).

- **Features, not a raw spectral difference.** Pitch contour (peak frequency per
  spectrogram row) and brightness contour (spectral centroid per row), sampled at
  eight points across the sound, both in **log2 hertz** — an octave is a
  doubling, and a distance in linear hertz would call 200→400 Hz the same step as
  4000→4200 Hz.
- **Z-scored per dimension** across the whole set. This is what kills the earlier
  confound: no dimension dominates through its units, and no per-signal
  renormalisation happens anywhere.
- **Separability is a RATIO, because identity must survive the CHANNEL.** Each
  motif is featurised through two stated bands — a laptop (500 Hz–6 kHz) and a
  phone (700 Hz–4 kHz) — and

      separability = smallest between-motif distance / largest within-motif distance

  Above 1, a listener has something to go on. Below 1, a motif is nearer a
  DIFFERENT meaning heard through another speaker than it is to itself.

**MEASURED:**

| set | separability | reading |
|---|---|---|
| the four shipped motifs | **6.44** (4.47 between / 0.69 within) | identifiable with room to spare |
| CONTOUR only — one waveform, four melodic shapes | **1.55** | survives |
| TIMBRE only — one pitch, four waveforms | **0.80** | **does not survive** |
| four copies of ONE motif (the negative sibling) | **0.00** | the instrument can fail |

**THE FINDING: section 6.1's second row is REFUSED as written.** Timbre is not
the analogue of hue. Hue survives a screen because a screen reproduces it; timbre
lives in the harmonics ABOVE the fundamental, and those are exactly what a small
speaker's band removes. At 0.80 a timbre-only vocabulary is not a vocabulary.

What replaces it: **identity is a MOTIF, and CONTOUR is its primary carrier —
timbre reinforces, and is never the sole distinction between two meanings.** The
shipped motifs already obey this (they differ in contour, note count and timbre
together, which is why they measure 6.44 rather than 1.55).

**The limits of this result, stated rather than left to be discovered.** The two
"speakers" are declared bands, not measured devices — no impulse response, no
non-linearity, no room. 0.80 against 1.55 is a clear ordering but not a wide one,
and neither figure is a listening test. What the measurement licenses is the
DESIGN RULE above; it does not license a claim about how a particular listener on
particular hardware performs.

### SS2 STATUS — closed 2026-08-12. A loudness the floor can bind to

S.4's finding was that the audibility gate had no instrument: BS.1770-4
integrates over 400 ms blocks behind a −70 LUFS gate, so an 880 Hz tone at **peak
0.50** reports **−1000 LUFS — this plane's answer for silence** — at every
duration below 400 ms. Every earcon is shorter than one block.

Added to `engine/src/soundanalysis.zig`, and exposed through `stzSound`:

- **`MomentaryLoudness()`** — the standard's own 400 ms window, ungated, taking
  the LOUDEST such window rather than a mean. Averaging an earcon against the
  silence around it answers nothing. BS.1770 arithmetic used as specified, so it
  is LUFS without qualification. It still cannot see a 60 ms sound, and does not
  pretend to.
- **`ShortTermLoudness()`** — the standard's 3 s window, same treatment.
- **`LoudnessOfSupport()`** — the same K-weighting and the same
  −0.691 + 10·log10(z) formula over the sound's **own length**. NOT a standard
  LUFS figure, and `LoudnessMetric()` says so in the string a caller prints.
- **`LoudnessMetric()`** — the method, so a number never travels without it.

**MEASURED, an 880 Hz tone at peak 0.50:**

| duration | integrated | momentary | support |
|---|---|---|---|
| 40 ms | −1000 | −1000 | **−9.26** |
| 60 ms | −1000 | −1000 | **−9.26** |
| 100 ms | −1000 | −1000 | **−9.27** |
| 200 ms | −1000 | −1000 | **−9.27** |
| 400 ms | −9.27 | −9.27 | −9.27 |
| 2000 ms | −9.27 | −9.27 | −9.27 |

**The property that makes the support measure trustworthy: it agrees with the
standard to a hundredth of a decibel wherever the standard has an opinion.** A
measure that disagreed at 400 ms would be a different quantity wearing a loudness
label. Guarded both ways, including the negative sibling — silence still reports
−1000 rather than a small number, and doubling the amplitude is still +6.02 LU.

**Why not simply widen the standard's window.** Because that makes a 60 ms sound
and a 400 ms sound comparable when they are not: the shorter one is quieter over
any fixed window purely for being shorter. The support measure answers a
different question honestly instead of answering the standard's question wrongly.

**The semantic layer's gate now runs on it.** `stzEarcons` used unweighted RMS as
an admitted substitute; `LevelOf` is `LoudnessOfSupport` now, which is the
difference between a gate that models hearing and one that models arithmetic. The
margins are unchanged (≥ 10 LU for a cue, ≥ 20 for an alert) and the guard still
proves the gate can CLOSE: raise the declared room to −10 dB and the shipped
motifs are refused as inaudible.

**Still not here:** loudness range (LRA), true-peak, and surround weighting. And
the floor is still DECLARED rather than measured — S.4's asymmetry with colour
stands, and SS2 does nothing about it.


---

## SS3 STATUS — 2026-08-14. Ducking ships, and the criterion is met by 13×

`stzVoicePool` gains a per-voice bus gain (`SetVoiceGain` / `VoiceGain` /
`BusNodeOf`); `stzEarcons` gains the policy (`DuckUnder` / `Unduck` /
`SetDuckDepth` / `SetDuckRampMs` / `GainOf` / `DucksApplied`). Guard:
`base/test/sound/sound_ss3_narrated.ring` (**26**), plus an audible
`sound_ss3_demo.ring`.

### The kill criterion

> *if ducking cannot be made click-free at the 10 ms ramp SN3 measured, it is
> dropped in favour of drop-and-count — a missing sound is better than a click.*

A click is a **step discontinuity**, so the instrument is the largest
sample-to-sample difference in the buffer, and the yardstick is the test tone's
own steepest slope — `0.5 · 2π · 440 / 48000 = 0.0288`, derived rather than
measured so it cannot drift with the thing it is measuring.

| | worst step over 16 phases |
|---|---|
| no gain change at all | **0.0288** — the instrument's own noise |
| change with **no ramp** | **0.3744** — a real click, 13× the slope |
| change over a **10 ms ramp** | **0.0288** — identical to no change |

**MET.** The unramped jump is **13.02×** the ramped step, and the ramped step is
indistinguishable from leaving the gain alone. The ramp both moves and arrives:
50 ms into a 200 ms ramp the render reports **0.7333**, and afterwards **0**.

### The instrument was wrong twice, and both ways are recorded

Either mistake would have "proved" ducking click-free without ever looking at a
click.

1. **Looking in the wrong buffer.** Set the gain between two renders, then look
   for the click INSIDE the second one. With no ramp that whole buffer is
   uniformly quieter, so its steepest step is *smaller* than the original
   tone's — **the control passed by being quiet.** The discontinuity is at the
   seam, the one place not being examined.
2. **A seam that was not a seam.** Looking at the seam gave a step of **0.810**
   — with **no gain change at all**. `ToSound` renders in whole blocks of 512
   frames and returns the seconds asked for, so a length that is not a multiple
   of the block leaves the oscillator further along than the buffer shows. It
   was measuring discarded samples. Block-aligned, the same seam steps **0.003**.

A third correction followed from the second: one seam is not enough, because
the size of a jump depends on **where in the cycle it lands** — at a zero
crossing even an unramped change is nearly silent. 512 frames is 4.693 periods
of the test tone, so each extra block lands the change at a different phase, and
sixteen sweep the cycle. The worst is taken, because a real duck lands wherever
it lands.

**A control for the control** is now the first assertion in the scene: with no
gain change the worst step must not exceed the tone's own slope. Had that been
there from the start, mistake 2 would have been caught in one run.

### The shape: one bus per voice

Every voice's slots are mixed together, that mix passes through a gain node
belonging to the voice alone, and the master mix takes the **gains** rather than
the slots. One extra node per voice is what makes ducking a value written to an
atomic instead of a re-render — the audio thread never learns a duck happened.

### The policy, and the number behind the default

`danger > warning > info > success`, and `muted` never contends. Firing a value
ducks everything **quieter in meaning** and nothing else. Measured live through
the real buses:

```
fired Success:  danger=1     warning=1     info=1     success=1
fired Info:     danger=1     warning=1     info=1     success=0.25
fired Warning:  danger=1     warning=1     info=0.25  success=0.25
fired Danger:   danger=1     warning=0.25  info=0.25  success=0.25
```

**Priority is one-way**, and the guard asserts the negative: a success ducks
neither danger nor warning. An alert never ducks itself.

**−12 dB is a number with a reason, not a taste.** A duck to silence is
indistinguishable from a **drop**, and this plane already drops. −12 dB
(linear 0.2512) leaves the ducked cue audibly present, so a listener can tell
*quieter* from *gone* — which is information. A positive dB is refused: a duck
is an attenuation.

Everything is **counted** — `DucksApplied()` — because "why did that get quiet"
must have an answer that is a number.

### What SS3 did NOT do

- **No ducking of SPEECH.** VC4's phrases play through their own transport, not
  the pool, so they have no bus. Speech already has a stronger rule — higher
  priority CANCELS — and a cancelled sentence needs no attenuation.
- **No automatic unduck.** `Unduck()` is explicit. Restoring on a timer would
  need the pool to own a clock policy, and a duck that lifts while an alert is
  still sounding is worse than one that lasts too long.
- **No per-shot gain.** The bus is per VOICE, not per fire, exactly as the
  pool's own documentation already says.

### Plane totals

**586 Ring assertions across seventeen guards** and 29 browser assertions;
67 Zig tests in the sound modules, 13 across `voice.zig` and `listen.zig`.
SN0–SN6, SS1–SS3 and VC0–VC6 closed. **SS4 remains open.**

---

## SS4 STATUS — 2026-08-14. The vocabulary is shared, and it was not failing alike

`stzEarcons` gains `StzEarconSteps()` and a `_Parse` that REFUSES an unknown
step. Guard: `base/test/sound/sound_ss4_narrated.ring` (**20**), plus an
audible `sound_ss4_demo.ring`.

### The kill criterion

> *if the two channels need separate declarations to look and sound right, the
> shared vocabulary is decorative and this section's central claim is false.*

**MET.** One string, handed to two faces that share no code:

| declaration | colour | sound |
|---|---|---|
| `:danger` | `#ff0000` | 0.180 s, priority 4 |
| `:warning` | `#ffff00` | 0.180 s, priority 3 |
| `:info` | `#0000ff` | 0.100 s, priority 2 |
| `:success` | `#008000` | 0.160 s, priority 1 |

Nothing is declared twice, and **there is no bridging verb in this phase,
because none is needed** — which is a stronger result than shipping one would
have been. `:Muted` renders as ABSENCE in both: colour refuses it (there is
nothing to paint), sound renders silence, and both say so.

### What SS4 actually caught: the two faces did not fail alike

It is easy to "prove" a shared vocabulary by only ever asking questions both
faces answer. So the guard asks each face a question the OTHER's vocabulary
makes natural, and requires the same answer.

Both faces spell a step `value.step`, but the steps belong to the medium —
colour has `surface, border, text, solid`; sound has `cue, alert, ambient`.
That divergence is correct: **a SURFACE is not a thing sound has, and an ALERT
is not a thing colour has.** Sharing the lists would force one medium to carry
the other's ideas.

But they handled a foreign step differently:

| | before | after |
|---|---|---|
| colour asked for `danger.alert` | **refused** | refused |
| sound asked for `danger.surface` | **silently became a cue** | **refused, with the reason** |

**And the downgrade was not harmless.** `.alert` is the step that pre-empts and
demands 20 LU of headroom against a cue's 10. A typo — `Danger.Alrt` — became
an ordinary cue with no alert behaviour and **no message**. That is this
plane's own law broken inside its own vocabulary: *a setting that silently does
nothing is worse than one that says no.*

`_Parse` now returns `[ value, step, reason ]`, and the reason distinguishes the
two halves — reporting "no semantic value named 'danger.surface'" would have
been a lie about a value that exists perfectly well.

### The asymmetry the shared vocabulary survives

Sound needs a severity ORDER — `danger > warning > info > success` — because two
sounds in one instant MASK rather than layer, so one must yield. Colour has no
such need: two colours in one instant are simply both there.

**Priority is a property of the CHANNEL, not of the MEANING.** Colour not having
it is not colour missing something. One declaration still serves both, and each
channel brings its own physics to it. The same is true of the steps. What is
shared is the VALUE; what is not shared is not shared *by nature* rather than
by omission.

### One observation left for the colour plane's owner, not fixed here

`StzThemeColor("light", "danger.surface")` returns `#00000000` rather than
refusing — a transparent colour where a refusal belongs. `light` is a real
theme and the step resolves fine through `StzColorToNumber`, so this is the
theme lookup silently answering a question it does not handle. Recorded rather
than changed: the colour face has its own owner and its own plan, and this
plane's business here was its own half of the vocabulary.

### Plane totals

**606 Ring assertions across eighteen guards** and 29 browser assertions;
67 Zig tests in the sound modules, 13 across `voice.zig` and `listen.zig`.
**SN0–SN6, SS1–SS4 and VC0–VC6 all closed.**
