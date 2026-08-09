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
