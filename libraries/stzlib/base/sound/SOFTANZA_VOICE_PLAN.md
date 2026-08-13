# SOFTANZA VOICE PLAN — analysis and phased plan (VC0–VC6)

Status: PLAN OF RECORD, written 2026-08-13, **after VC0 and against its
numbers**. Sibling of `SOFTANZA_SOUND_PLAN.md` (SN0–SN6 closed, plus the SOUND
SEMANTICS section), and it inherits that plan's working discipline verbatim —
measure before believing anything including this document, kill criteria before
numbers, guards that assert the mechanism, a bounded record that counts what it
drops, engine-first, and CI that has no hardware.

---

## 0. The correction this plan begins with

`SOFTANZA_SOUND_PLAN.md` §4 rules speech out of scope: *"speech synthesis or
recognition (the last two would be NEURAL-tier work riding ggml, not this
plane's)."*

**That sentence is wrong as written, and this plan exists because it was
wrong.** It is true of NEURAL synthesis — a model, a download, a licence, a GPU
budget. It is not true of the synthesiser that every desktop operating system
already ships and has shipped for twenty years. Windows has SAPI; macOS has
AVSpeechSynthesizer and `say`; every modern browser has `speechSynthesis`.
A platform voice is an **OS service**, exactly like the audio device this plane
already vendors a library to reach — and the plane's own FACT 3 (a per-OS DLL
beside a portable one) is already the right shape for it.

The exclusion was not a measured decision. It was a category error: *speech*
was filed under *machine learning* because the state of the art in speech is
machine learning. VC0 measured what the platform gives away for free, and the
answer changed the scope.

**What stays out:** neural TTS and neural ASR (a model riding ggml, on the
NEURAL tier), voice cloning, speaker identification, and emotion inference.
Those are a different plane with a different owner, and §6.2 of
`stzzui/doc/THE-SECOND-FOUNDING.md` is right that voice-as-paradigm is not this
plane's to legislate. What this plan claims is narrower and concrete: **the
platform can speak and partly listen, and the sound plane can already hold what
it produces.**

---

## 1. The architecture, in one sentence

**Speech is not a new plane. It is two doors on the plane that exists** — because
a platform voice renders to a *buffer*, and a buffer is a `stzSound`.

That is the whole design, and VC0 proved it rather than assumed it. Once a
synthesised phrase is an ordinary sample buffer, every verb the sound plane
already owns applies to speech with no speech-awareness anywhere:

```ring
oSay = StzVoiceQ().ToSoundOf("The disk is nearly full")   # -> a stzSound

oSay.Loudness()                    # SN5's LUFS
oSay.LoudnessOfSupport()           # SS2's instrument
oSay.ToOnsets()                    # 31 events on a 5.4 s sentence
oG.AddSound(oSay)                  # a source node, like any other
oG.AddFilterOn(:voice, :LowPass, 1800, 0.9)      # a telephone
oP.DrawSpectrogram(oSay.ToSpectrogram(), 8000)   # the gallery's own plot
oTransport.Play()                                # SN6's clock
```

### 1.1 The four transforms, and the two that were missing

|  | transform | owner | status |
|---|---|---|---|
| text → sound | **synthesise** | platform (SAPI / AVSpeech / Web Speech) | **VC0: GO** |
| sound → text | **recognise** | platform, partial; neural beyond that | **VC0: partial, measured** |
| data → sound | sonify | this library (graph, earcons) | closed — SN0–SN6, SS1–SS2 |
| sound → data | analyse | this library (SN5 grids) | closed |

The symmetry is the point. **The plane already goes both ways for DATA; this
plan makes it go both ways for LANGUAGE.** And the four compose: a recognised
phrase is text, text is a meaning, a meaning renders to a colour and an earcon
and a phrase — which closes a loop that currently stops at the speaker.

### 1.2 The pieces, and why each is where it is

| piece | what it is | why there |
|---|---|---|
| `stz_voice.dll` | per-OS synthesis + recognition | FACT 3, exactly as `stz_audiodev.dll`. A voice is a per-OS service; the portable tier must not link it |
| `stzVoice` | text → `stzSound`, and text → speaker | the declarative face; `To...` returns DATA, so `ToSoundOf` is the primary verb and speaking is the convenience |
| `stzListener` | `stzSound` / microphone → text | the other door. Reuses `stzMicrophone` for capture rather than opening its own input |
| `stzEarcons` gains `Say` | a meaning renders to a phrase too | §4, and it is where "one world" pays |

**No new sink, no new clock, no new ring.** A voice plays through SN6's
transport and SN3's device path, because it is a sound.

---

## 2. VC0 RESULTS — measured 2026-08-13. VERDICT: GO on both criteria

`engine/tools/voice_spike.zig`, run with `zig build voice-spike`. Measurement
only; nothing links it.

### 2.1 Can the ENGINE speak, with no .NET and no helper process?

**Yes.** `CoCreateInstance(CLSID_SpVoice, IID_ISpVoice)` from Zig, through
`@cImport("sapi.h")` — Zig ships MinGW's SAPI headers, so there is nothing to
vendor. The only link dependency is **ole32**. No model, no download, no cloud,
no PowerShell, no child process.

This mattered more than it sounds. A face that shells out to PowerShell is not
an engine capability: every other binding of this library would be left without
it, and the plane's engine-first law exists precisely to prevent that.

The GUIDs are written out as literals rather than linked from `sapi.lib` —
MinGW's import libraries do not carry them consistently, and a spike that fails
to *link* teaches nothing about whether the platform can speak.

### 2.2 Does a voice render to a BUFFER, or only to a speaker?

**To a buffer** — `ISpStream::BindToFile` + `ISpVoice::SetOutput`. This is the
architectural question and the answer is what makes §1 true. A voice that
reached only the speaker would be bolted to the side of the plane forever.

Format: **22050 Hz, 16-bit, mono.**

### 2.3 What it costs

An 8-second sentence, five runs after the first:

| | time | × realtime |
|---|---|---|
| **cold** (first call, includes engine start-up) | 63.9 ms | 124× |
| **warm** (avg of 5) | 15.0 ms | ~530× |
| warm, best | 14.7 ms | |

**Cold costs 4.3× warm.** Same trap SN0 found in `ma_device_start` (500 ms, with
callbacks running ahead of real time during it): *a voice tier must warm up out
of band, or its first word is late by whatever that is.*

Short phrases, which is what a semantic layer actually speaks:

| phrase | synthesis |
|---|---|
| "yes" | 2.6 ms |
| "disk full" | 3.6 ms |
| "the deployment finished successfully" | 8.3 ms |

**Synthesis is effectively free.** The cost of speech is not computing it.

### 2.4 The recognition asymmetry, which is the real design problem

| direction | installed on this machine |
|---|---|
| synthesis | **2 voices** — Microsoft Zira (en-US), Microsoft Hortense (fr-FR) |
| recognition | **1 recognizer** — MS-1036-80-DESK (**fr-FR only**) |

**This machine can SPEAK English and cannot HEAR it.** That asymmetry is not a
quirk to be smoothed over; it is the shape of the problem. A voice architecture
must express capability **per language and per direction**, and refuse rather
than substitute. Speaking French to an operator who asked for English is worse
than saying nothing.

The round trip closes where both directions exist:

```
"bonjour le monde"  --speak-->  WAV  --recognise-->  "Bonjour le monde"
                     13 ms                  271 ms, confidence 0.585
```

Locally. No cloud, no model. **Confidence 0.585 is the honest headline**: a
desktop dictation recognizer is usable for commands from a closed grammar and
unreliable for free dictation, and the number must travel with the text.

### 2.5 Two findings that would have become bugs

- **SAPI's WAV is not the textbook 44-byte layout.** Its `fmt ` chunk is
  **18 bytes** (a `WAVEFORMATEX` carries `cbSize`), so `data` begins at 46 and
  its length is at 42 — not 36 and 40. Reading the canonical offset gave a
  length taken from the sample stream, which reported *"34611 seconds of
  speech"* and *"526293× realtime"* from an 8-second file. **Any WAV reader in
  this plane must walk the chunks.**
- **A voice is 22050 Hz and BS.1770 refuses anything but 48000.** So a voice
  must be resampled before it can be measured for loudness, and the plane's
  resampler is better than a speech engine's (SN1 measured it) — which is the
  argument for asking SAPI for its native rate and resampling ourselves rather
  than making SAPI resample.

### 2.6 The claim of §1, tested rather than asserted

A synthesised sentence, loaded through the ordinary `stzSound` face:

| | |
|---|---|
| loads | 119,484 frames, 1 ch, 22050 Hz, 5.42 s, peak 0.61 |
| integrated loudness | −22.19 LUFS |
| support loudness (SS2) | −23.57 |
| dominant frequency | 433.59 Hz |
| onsets | **31** on one sentence — syllable-scale events |
| as a graph source | low-passed to 1.8 kHz and echoed: 5.42 s, peak 0.45 |
| drawn | `stzSoundPlot` produced a speech spectrogram with visible formants, harmonic stacks in the voiced segments and broadband consonant bursts |

**Nothing in that list is speech-aware.** That is the deliverable of VC0: the
"one world" claim is a buffer handoff, not a slogan.

---

## 3. The laws speech needs that sound does not

The sound semantics section established three laws for a semantic sound. Speech
needs four more, and one of them *repairs* a limitation that section had to
accept.

1. **Speech is SERIAL where sound is parallel.** Two earcons can overlap and
   still both be heard; two sentences cannot — the result is neither. So the
   priority contract for speech is **a queue**, not a drop (§4).

2. **Speech carries WHICH.** An earcon says *something happened*; a phrase says
   *what*. This is why speech does not strain the redundancy law but satisfies
   it: it is the channel that can name the thing.

3. **Speech is language, therefore localisation, therefore refusal.** A voice
   has a culture. "No voice for this language" is a **counted refusal**, never a
   silent substitution into a language the operator cannot read. This is the
   sound plan's requirement 4 — *the library's multilingual identity does not
   stop at the speaker* — becoming load-bearing rather than aspirational.

4. **THE TEXT IS THE PERSISTENT FORM OF THE SPEECH.** The semantics section's
   third law says a sound is not persistent, so anything the operator has a
   *right* to know cannot be delivered by sound alone. A phrase repairs this:
   its text remains after the sound is gone, and is re-requestable and
   re-readable. **Voice is the first auditory channel that can satisfy the Right
   to Understand on its own** — and it does so by not being only auditory.

And one that constrains recognition rather than synthesis:

5. **Listening is a microphone, therefore a consent — and possibly a cloud,
   therefore a disclosure.** Local-only is the default. A recognizer that
   reaches a network must say so before it opens, every time, and must be
   refusable. Windows' online speech path is exactly this case.

---

## 4. The semantic contract: how a meaning gains a voice

Decided here, per the session's brief, and not built until VC4.

```ring
oEar.Fire(:Danger)                       # the earcon alone -- unchanged
oEar.Say(:Danger, "disk nearly full")    # the earcon, THEN the phrase
oEar.SetVoiceLanguage("en-US")
```

**The earcon precedes the phrase, always.** The earcon is the alerting signal
and it is fast (200 ms, and its synthesis is already done); the phrase is the
content and it is slow. That ordering *is* the "sound reports / speech explains"
split, and inverting it wastes the only fast channel on a slow message.

**Speech QUEUES where an earcon DROPS.** The semantics section decided that a
displaced cue is dropped rather than queued, because a cue arriving after its
event lies about when something happened. A phrase is different: dropping it
loses **the only statement of what occurred**, while delaying it merely makes it
late. So:

| | earcon | phrase |
|---|---|---|
| displaced by higher priority | **dropped**, counted | **queued**, counted |
| same value inside the refractory window | one event | one event |
| queue bound | n/a | **bounded, and overflow is counted** (discipline rule 4) |

**Higher priority CANCELS lower-priority speech; it never interleaves.** A
danger phrase stops a success phrase mid-word. Two half-sentences are worse than
one sentence and a counted drop — and a listener cannot un-hear the first half.

**`:Muted` has no earcon and no phrase.** Silence remains its rendering.

**Speech is never a Rule 18 acknowledgement, and this is now doubly true.**
Synthesis is nearly free (2.6–8.3 ms), but it lands *on top of* the plane's
output latency — ~419 ms native, ~10 ms in a browser (SN6) — and on top of
whatever the queue holds. The screen acknowledges; the earcon corroborates; the
phrase explains. Three channels, three jobs, one declaration.

---

## 5. Phases, each with a kill criterion written before the numbers

**VC0 — the spike. CLOSED, GO** (§2).

**VC1 — `stz_voice.dll`, Windows first. CLOSED, see VC1 STATUS below.** Synthesis to a sample buffer through
the plane's own handle table (gen-keyed, like `stz_sound.dll`), voice
enumeration with language tags, SSML prosody, and a counted refusal for every
absent capability. Cross-compile-checked for macOS and Linux; runtime-verified
on Windows only, and stated as such.
*Kill:* if a voice cannot be delivered as an in-memory buffer without a
temporary file, the seam is a file path rather than a sample handle, and §1's
claim weakens to "a voice is a file" — which would be worth knowing before a
face is designed around it.

**VC2 — `stzVoice`, the declarative face.** `ToSoundOf(text)` as the primary
verb; `Say(text)` as the convenience that goes through SN6's transport. Language
selection, rate and pitch, and a warm-up call so the 4.3× cold cost is paid
before the first word rather than during it.
*Kill:* if a warmed voice cannot start a short phrase within the plane's own
output latency, speech cannot be interactive on this tier and the face must say
so in its own documentation rather than in a footnote.

**VC3 — `stzListener`, and the honest capability matrix.** Recognition from a
buffer and from `stzMicrophone`, a closed grammar as well as free dictation,
confidence returned WITH every result, and per-language/per-direction capability
reporting. Local-only by default; any network path disclosed and refusable.
*Kill:* if free dictation on the platform recognizer cannot beat a stated
confidence on a stated phrase set, `stzListener` ships **closed-grammar only** —
commands, not transcription — and free dictation is deferred to the neural tier
rather than shipped unreliable.

**VC4 — the semantic bridge.** §4's contract: `Say`, the queue, cancellation,
and a meaning rendering to colour + earcon + phrase from one declaration.
*Kill:* if a phrase and an earcon cannot be composed without the earcon being
masked or the phrase being clipped, the bridge is two systems sharing a speaker
and should be documented as such rather than presented as one.

**VC5 — the browser tier.** `speechSynthesis` and `SpeechRecognition` behind the
same faces, so a declaration moves between tiers unchanged. SN6 already proved
the browser is the lower-latency sink (10.0 ms against 419 ms).
*Kill:* if the browser's voice list cannot be reconciled with the native one
into a single capability model, the faces expose the tiers separately and the
"one world" claim is limited to the native tier in writing.

**VC6 — the convergence.** A spoken transport (say the position), a sonified +
spoken analysis, and the loop §1.1 names: recognised phrase → meaning → colour +
earcon + phrase.
*Kill:* if the loop needs a step outside these faces to close, it is a demo
rather than an architecture, and the missing step is named.

---

## 6. Risks, named now

- **Scope gravity is worse here than in sound.** Speech invites dialogue
  management, wake words, intent parsing, barge-in, and voice UI as a paradigm.
  OUT until asked, in writing: all of it. §6.2 of THE-SECOND-FOUNDING is right
  that voice-as-paradigm has a separate owner.
- **The platform is not uniform and cannot be made to look uniform.** Two voices
  and one recognizer on this machine, in two different languages. A face that
  hides that will produce an application that speaks the wrong language to the
  wrong operator. Capability is REPORTED, per language, per direction.
- **Confidence is not accuracy.** 0.585 on a clean synthesised phrase is a
  warning about free dictation, not a score to be displayed as a percentage.
- **Recognition is the privacy boundary of this whole library.** An always-open
  microphone is a different product from a library. Consent is per-session and
  explicit, and the microphone's state must be visible — which is Rule 82,
  visible state, in the one place where invisibility would be indefensible.
- **A voice is 22050 Hz.** Every measurement path must resample first, and every
  guard that forgets will read −1000 LUFS and blame the wrong thing.

---

## VC1 STATUS — 2026-08-13. The voice DLL stands, and the kill criterion cleared

`stz_voice.dll`, the plane's third DLL. `engine/src/voice.zig` +
`ring_bridge_voice.zig` + `stz_voice_entry.zig`, loaded by
`engine/stz_voice.ring`. Guard: `base/test/sound/sound_voice_narrated.ring`
(**49**), plus **8 Zig tests** in `voice.zig`.

### The kill criterion, cleared

> *if a voice cannot be delivered as an IN-MEMORY buffer without a temporary
> file, the seam is a file path rather than a sample handle, and §1's claim
> weakens from "a voice IS a stzSound" to "a voice is a file".*

**It is a buffer.** `CreateStreamOnHGlobal` gives an `IStream` in memory,
`ISpStream::SetBaseStream` points SAPI at it, `GetHGlobalFromStream` reads the
samples back. No path, no temporary, nothing to clean up, and nothing to fail on
a read-only volume. Measured end to end: a 52-character sentence became
**239,012 bytes in 81 ms**, crossed into the sample tier, and came back as a
`stzSound` of 119,484 frames at 22050 Hz, 5.42 s, peak 0.61 — which then
resampled, measured **−23.57** on SS2's support loudness, reported **31 onsets**,
went into a graph as a source, came out low-passed, and produced a spectrogram.
**Nothing in that chain is speech-aware.**

### How a voice crosses the DLL boundary

It cannot hand over a sample handle: the buffer table lives in `stz_sound.dll`
and a handle from one DLL is meaningless in another. Same constraint SN3 solved
for the ring, same answer — **bytes cross, a handle never does**:

```ring
nV = StzEngineVoiceOpen()
StzEngineVoiceSpeak(nV, "the disk is nearly full")
nBuf = StzEngineSoundLoadMemory(StzEngineVoiceLastBytes(nV))   # a stzSound
```

**The bytes cross as a RING STRING, and the first cut got this wrong.** It
returned the ADDRESS and the length and expected the caller to pass both to
`LoadMemory` — which takes a Ring string, not a pointer, so the call **crashed
the interpreter**. A Ring string is length-delimited and byte-safe, which makes
it the language's own carrier for a block of bytes, and it means no address ever
appears in a script. The address accessor survives as a diagnostic and is
documented as not the path to use.

**The WAV is emitted in the CANONICAL layout — `fmt ` at 16, `data` at 36** —
deliberately not the 18-byte `WAVEFORMATEX` form SAPI's own files use. VC0 lost
an afternoon to that: a reader trusting the textbook offsets took a data length
out of the sample stream and reported *34,611 seconds of speech* from an
8-second file. Emitting the canonical form makes every reader right, including
the naive one.

### A finding that became a feature: the platform does not validate SSML

Handed `<speak><prosody rate='fast'>unclosed`, SAPI produced **byte-for-byte the
same audio as the bare word "unclosed"** — it neither refused nor read the tags
aloud. It silently discarded the markup. Mercifully it does not speak the tags;
unhelpfully, a typo in an attribute means the prosody simply does not happen and
the caller is never told.

That is the same failure this tier already refuses to tolerate for an
out-of-range rate: **a setting that silently does nothing is worse than one that
is visibly limited.** So SSML is checked here — minimally, and stated as minimal
rather than sold as a validating parser — and a failure is a counted refusal with
the fault named ("a tag was left unclosed", "a closing tag that does not match",
"no `<speak>` root"). The guard's negative sibling is the one that matters: a
real document with a namespace, attributes and a self-closing `<break/>` is
ACCEPTED and counts no refusal, because a validator that rejects valid input is a
worse defect than the leniency it covers.

And prosody is asserted to *work*, not merely to be accepted: `rate="-20%"`
produced 97,252 bytes against 80,272 for the same words unmarked.

### What it reports rather than hides

- **The format**, so a caller never guesses and never parses a header:
  22050 Hz, 1 channel, 16-bit. The guard asserts it is **not** 48 kHz, because
  BS.1770 loudness refuses anything else and a voice must be resampled first.
- **The installed voices**, with a counted refusal for an index that does not
  exist. On this machine: *Microsoft Hortense Desktop – French* and *Microsoft
  Zira Desktop – English (United States)*.
- **Clamping**: SAPI takes rate −10..10 and volume 0..100 and ignores anything
  else. Out-of-range is clamped **and reported** ("rate 99 clamped to 10").
- **Gen-keyed handles**, as `sound.zig` does: freeing bumps the generation, and
  a stale id is refused by every entry point and COUNTED. Guarded both ways —
  four stale hits on a dead handle, zero on a live one.
- **Selecting a voice changes the samples.** Two voices, same words, 80,056
  against 75,422 bytes. If those matched, `SetVoice` did nothing and the failure
  was silent.

### Portability, measured rather than claimed

| target | `stz_voice` | for comparison, `stz_audiodev` |
|---|---|---|
| x86_64-windows | **OK**, runtime-verified | OK |
| x86_64-linux-gnu | **OK** (compiles) | OK |
| x86_64-macos | **OK** (compiles) | **FAIL** (CoreAudio headers) |
| aarch64-macos | **OK** (compiles) | **FAIL** |

**Better than the device tier**, and for a structural reason: the platform
dependency sits behind a `comptime` branch on the OS tag rather than in a
vendored C library, so a non-Windows build simply has no SAPI import and the tier
refuses at runtime with a message. **Runtime-verified on Windows only** —
AVSpeechSynthesizer and espeak-ng are unbuilt, and `isAvailable()` returns FALSE
rather than pretending.

It vendors **nothing**. SAPI ships with Windows and Zig already carries MinGW's
`sapi.h`, so the whole dependency is `ole32` for COM.

### What VC1 did NOT do

- **No face.** `stzVoice` is VC2. Everything above is reachable only through
  `StzEngineVoice*`, which is deliberate: the DLL earns its own guards before a
  face is designed on top of it.
- **No language selection by tag.** `selectVoice` takes an index, because that is
  what the platform reports. Asking for `"en-US"` and getting a counted refusal
  when it is absent is VC2's job, and it is the job that matters most — capability
  is per language and per direction.
- **No recognition.** VC3, and it is an order more COM surface: `ISpRecognizer`
  needs a recognizer, a context, a grammar and an event loop.
- **No warm-up call.** VC0 measured cold at **4.3×** warm, and VC2's kill
  criterion is about exactly that. The tier does not yet let a caller pay that
  cost out of band.

### Plane totals

**402 Ring assertions across twelve guards**; 8 Zig tests in `voice.zig`, plus
the sound plane's 108.
