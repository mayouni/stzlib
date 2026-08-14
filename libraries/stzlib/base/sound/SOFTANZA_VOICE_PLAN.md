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

**VC2 — `stzVoice`, the declarative face. CLOSED, see VC2 STATUS below.** `ToSoundOf(text)` as the primary
verb; `Say(text)` as the convenience that goes through SN6's transport. Language
selection, rate and pitch, and a warm-up call so the 4.3× cold cost is paid
before the first word rather than during it.
*Kill:* if a warmed voice cannot start a short phrase within the plane's own
output latency, speech cannot be interactive on this tier and the face must say
so in its own documentation rather than in a footnote.

**VC3 — `stzListener`, and the honest capability matrix. CLOSED, see VC3 STATUS below. The kill criterion FIRED: closed-grammar only.** Recognition from a
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

---

## VC2 STATUS — 2026-08-13. The face, and the kill criterion answers a better question

`base/sound/stzVoice.ring`, registered in `stzBase.ring`. Guard:
`base/test/sound/sound_voiceface_narrated.ring` (**44**), plus an audible demo,
`sound_voice_demo.ring`.

```ring
oV = StzVoiceQ()
oSay = oV.ToSoundOf("The disk is nearly full")   # -> a stzSound
oV.Say("The disk is nearly full")                # or just say it
oV.UseLanguage("fr-FR")                          # refused if absent
```

### `ToSoundOf` is the primary verb, and that ordering IS the architecture

`To...` returns DATA, per the house law — and the data is a `stzSound`, which is
what makes every verb this plane owns apply to speech. A face whose primary verb
were `Say` would make speech a dead end. Guarded: a synthesised sentence
resamples, measures **−21.24** on SS2's instrument, reports **21 onsets**, goes
into a graph, comes back low-passed and echoed, and draws a spectrogram —
**none of which knows it is speech.**

`Say` is the convenience (synchronous, one line for a script) and
`ToTransportOf` is the non-blocking path through SN6's transport.

### The kill criterion, and it answers a better question than it asked

> *if a warmed voice cannot start a short phrase within the plane's own output
> latency, speech cannot be interactive on this tier and the face must say so in
> its own documentation rather than in a footnote.*

Measured, warmed:

| | |
|---|---|
| synthesising "disk full" | **8 ms** |
| the plane's native output latency (S.5) | **~419 ms** |
| synthesis, as a share of it | **1.9%** |

A fresh voice: **23 ms** for the first phrase, **6 ms** for the second — the
4.3× cold cost VC0 measured, reproduced through the face, and `WarmUp()` exists
to pay it when the program starts rather than mid-sentence.

**So the criterion passes, and the passing is not the finding.** Synthesis is
under two percent of the delay: **speech is not late because it is computed, it
is late because the audio path is long — and that was true before a voice
existed.** The plan required this to be said in the face's own documentation
rather than a footnote, and it is, in `stzVoice.ring`'s header, together with
the consequence: the screen acknowledges inside Rule 18, the earcon
corroborates, the phrase explains. A caller who needs speech to feel immediate
belongs on the web tier, where SN6 measured 10 ms instead of 419.

The face also answers `SynthesisIsTheBottleneck()` — **FALSE** — so a caller can
read the conclusion without reading the plan.

### Language selection, which is the part that matters

The engine gained `installedLanguage`, and it uses **no lookup table**: SAPI keeps
a hex LCID on the voice token's `Attributes\Language`, and `LCIDToLocaleName` —
the OS, the authority — turns it into a BCP-47 tag. Verified: *Microsoft
Hortense Desktop – French* → **fr-FR**, *Microsoft Zira Desktop – English (United
States)* → **en-US**.

`UseLanguage` **refuses and counts** rather than substituting, and the refusal
names what the machine actually has:

```
no voice speaks 'ja-JP' -- this machine has: fr-FR, en-US
```

A caller can recover from that; it cannot recover from being handed French.
Asking for `"fr"` and getting `fr-FR` IS allowed — a widening inside one
language, not a substitution across two — and the distinction is guarded.

### A trap found by the demo, and fixed in the face

`ToTransportOf` first called the transport's `Play()`, which means *play until
stopped*. So the obvious loop —

```ring
while oT.IsPlaying()   oT.Tick()   end
```

— never ended: the phrase finished, the transport went on rendering silence, and
`IsPlaying` stayed true. **It hung this face's own demo**, which is how it was
found. A spoken phrase has a KNOWN length, so the transport is given it via
`PlayFor(duration)`. Guarded both ways: the transport now ends by itself (47
ticks, well inside the guard's bail-out), and an explicit early `Stop` is still
obeyed.

That it took a *demo* to find a defect the guards missed is the argument for the
plane's rule that every phase ships something audible.

### What VC2 did NOT do

- **No pitch.** SAPI's rate and volume are exposed and clamped; pitch is only
  reachable through SSML markup, and the face does not pretend otherwise.
- **No recognition.** VC3.
- **No semantic bridge.** `oEar.Say(:Danger, "disk full")` is VC4, and §4 of
  this plan already decided its contract.
- **No browser tier.** VC5. SN6 proved the web path is 40× lower latency, which
  makes it the tier where speech can actually be interactive.

### Plane totals

**446 Ring assertions across thirteen guards**; 8 Zig tests in `voice.zig` and
108 across the sound modules.

---

## VC3 STATUS — 2026-08-13. The kill criterion fired, and shaped what was built

`engine/src/listen.zig` + `ring_bridge_listen.zig` (both inside
`stz_voice.dll`), and `base/sound/stzListener.ring`. Guard:
`base/test/sound/sound_listener_narrated.ring` (**21**), plus 5 Zig tests.

### The gate, and the measurement that ran into it

The bar was written before any number was taken: **free dictation ships as
transcription only at ≥80% exact AND ≥0.60 mean confidence** on a stated set;
**closed grammar ships at ≥90% exact.**

Nine phrases — six commands, three sentences — synthesised by this plane's own
fr-FR voice and fed straight back. **That is the cleanest audio recognition will
ever see**: no noise, no room, no accent, correct pronunciation. Three rounds,
identical every round:

| | exact | mean confidence | verdict |
|---|---|---|---|
| free dictation | **66.7%** (6/9) | 0.600 | **FAIL** |
| closed grammar | **100%** (6/6) | **0.898** | **PASS** |

So `stzListener` ships **closed-grammar only**. There is no `Transcribe()`, and
there will not be one until a better recognizer exists. Free dictation is
deferred to the neural tier, exactly as the criterion said.

### Why dictation failed is the useful part

**Every miss was a WRITTEN FORM, not a mishearing:**

```
"annuler"                           -> "annule"
"arreter"                           -> "arrete"
"il reste soixante deux gigaoctets" -> "il reste 60 de gigaoctet"
```

The recognizer heard the sounds correctly and chose a different spelling — a
verb ending, a numeral instead of words, a singular for a plural. **A closed
grammar cannot make that mistake**, because it maps the sound to the string the
caller DECLARED; there is no spelling left to get wrong. One measurement, two
verdicts, and that is the reason for the split.

### Cross-validated, which is why the numbers are trusted

The gate was measured through the platform (System.Speech). The engine
implementation was then measured independently on the same phrases:
**6/6 exact, mean confidence 0.897** against the platform's 0.898. Two
implementations, one answer.

### The round trip is the centrepiece, and it needs both directions

```ring
oV = StzVoiceQ()      oV.UseLanguage("fr-FR")
oL = StzListenerQ()   oL.Accept([ "ouvrir le fichier", "annuler", ... ])
oL.HearSound( oV.ToSoundOf("annuler") )
? oL.HeardText() + "  " + oL.Confidence()      # annuler  0.939
```

No microphone, no file, no hand-recorded fixture — a `stzSound` passed between
two faces. **That is what makes recognition testable at all on a machine with no
audio input**, and it is only possible because this library owns both
directions.

It required one supporting addition: **`stzSound.ToWavBytes()`**, the symmetric
half of `loadMemory`. Its absence was a real gap — a sound could be decoded FROM
bytes but not encoded back TO them, so handing a buffer to another tier meant a
temporary file. VC1 went to some trouble to keep a voice out of the filesystem;
without this, VC3 would have put it straight back.

### What it refuses, and what it merely reports

- **A phrase outside the grammar is a NO-MATCH, not a wrong answer** — and a
  no-match is a RESULT, not a refusal. "Somebody said something that is not a
  command" is information a control surface needs; the dangerous alternative is a
  confident wrong command. Guarded: `je voudrais un cafe au lait` returns empty
  text and increments no refusal counter.
- **An empty grammar is a counted refusal**, not a listener that silently hears
  nothing forever.
- **Confidence is a separate call** so it cannot be skipped by accident. One of
  the six commands scores **0.747** even on clean synthetic audio: even a closed
  grammar is not certain.

### Local only, and it is a promise rather than a default

The engine uses **`CLSID_SpInprocRecognizer`** — the in-process engine, running
here, reaching no network. The SHARED recognizer can be routed to Windows'
online speech service and is deliberately not used; choosing it would have to be
an explicit, disclosed act. A microphone is a consent boundary, and a microphone
that reaches a network is a different product. `HearMicrophoneFor` exists and its
documentation says the caller must make the listening state visible — Rule 82 in
the one place invisibility would be indefensible.

### Three findings from the COM surface, recorded so they are not re-paid

- **`SPWT_LEXICAL` is 1, not 0.** Zero is `SPWT_DISPLAY`, and a display-type word
  needs a pronunciation, so every `AddWordTransition` returned `E_INVALIDARG`
  (0x80070057) — for a single ordinary word. The error names the argument and
  the fault was the enum.
- **A grammar needs a LANGUAGE before it will accept a word.** `ResetGrammar`
  with the recognizer's LANGID, or SAPI has no lexicon to validate against.
- **`SPEVENT` cannot be imported.** Its first two fields are 16-bit C bitfields
  and Zig's translate-c yields `opaque {}`, which cannot be instantiated. It is
  declared by hand, and a guard asserts its size and every field offset — because
  a wrong layout would look like "nothing is ever recognised" rather than like a
  layout bug.

### What VC3 did NOT do

- **No transcription**, by measurement.
- **No microphone guard.** `HearMicrophoneFor` is implemented and reachable, but
  nothing asserts it: CI has no microphone, and a guard that needs someone to
  speak is not a guard. It is exercised by hand.
- **No per-language recognizer selection.** There is one recognizer here, so
  choosing among several is unexercised and therefore unbuilt.
- **No semantic bridge.** VC4.

### Plane totals

**467 Ring assertions across fourteen guards**; 13 Zig tests across `voice.zig`
and `listen.zig`, plus 108 in the sound modules.

---

## VC4 STATUS — 2026-08-14. The bridge holds, and it uncovered a use-after-free

`base/sound/stzEarcons.ring` gains `Say`, `ToSoundOfSaying`, the queue and its
counters; `engine/src/soundgraph.zig` and `engine/src/audiodev.zig` gain
address-stable tables. Guard: `base/test/sound/sound_saybridge_narrated.ring`
(**24**), plus 2 new Zig tests. Demo: `sound_saybridge_demo.ring`, six audible
scenes.

### The kill criterion, answered with numbers

> *if a phrase and an earcon cannot be composed without the earcon being masked
> or the phrase being clipped, the bridge is two systems sharing a speaker and
> should be documented as such rather than presented as one.*

They compose, and the reason is a design choice rather than luck: **the earcon
and the phrase are laid into ONE BUFFER**, sequentially, by `ToSoundOfSaying`.
Two independent players sharing a speaker can overlap — the phrase starting
under the earcon's tail — and where they overlap they sum and can clip. Laid out
in one buffer nothing overlaps by construction, so the peak is the LOUDER of the
two rather than their sum:

| | duration | peak |
|---|---|---|
| the earcon alone | 0.180 s | 0.267 |
| the composite | 4.854 s | **0.688** |
| the earcon's own span *inside* the composite | 0.180 s | **0.267** — unchanged |
| clipped samples in the composite | | **0** |

The earcon is neither masked nor ducked: its span measures **exactly** what it
measured alone. A separate scene plays cue, phrase, and composite back to back;
the composite's peak (0.60) equals the phrase's (0.60), which is the claim made
audible.

**The composite is DATA, not a playback.** It needs no device, which is what
lets the guard measure all of this on a machine that cannot play a sound.

### The one place speech parts company with earcons, and a correction

§4 decided that **a displaced cue is DROPPED and a displaced phrase is QUEUED**,
because dropping a phrase loses the only statement of what occurred while
delaying it merely makes it late.

The first cut of `Say` got this backwards in a way that read as correct: a
higher-priority phrase **cleared every queued phrase quieter than itself**. It
passed a naive reading of "higher priority cancels lower-priority speech" — but
that sentence is about the phrase being SPOKEN, not about the ones waiting.
Rewritten to insert by priority without clearing. Measured: `Say(:Success)`,
`Say(:Info)`, `Say(:Danger)` → **queued 3, drops 0**, danger at the head. A
danger jumps the queue; the success behind it is still spoken.

Cancellation of the phrase in progress is real and is COUNTED: a danger arriving
1.4 s into a long success sentence stops it mid-word, `SpeechDrops` goes to 1,
and the queue still drains. A program that cuts people off silently cannot be
told from one that never spoke.

`:Muted` enqueues nothing, and `LastReason()` says why — *"muted renders as
silence, in every channel."* The vocabulary is still exactly five.

### THE REAL FINDING: two devices killed the process, and it was not the voice

Scene 5 wants the earcon pool and a spoken phrase alive together. That crashed —
`integer does not fit in destination type`, from inside `stz_sound.dll`. It
reduces to six lines with no voice and no earcons in them at all:

```ring
t1 = new stzSoundTransport(g1)   t1.PlayFor(2.0)
t2 = new stzSoundTransport(g2)   t2.PlayFor(0.5)   # <- process dies
```

**Three tables had the same use-after-free**, in two DLLs:

| table | who holds a raw pointer into it | what growing it did |
|---|---|---|
| `soundgraph.streams` | the producer thread, for its whole life | freed the slot it was reading |
| `soundgraph.graphs` | the same producer thread | freed the graph it was rendering |
| `audiodev.sinks` | miniaudio, as `pUserData` **and** as `&sk.device` | freed the device under its own callback |

Every one is an `ArrayList` that reallocates on growth. So creating a second
graph, or opening a second stream, or opening a second device, freed memory a
live thread was reading — and the failure surfaced as an `@intCast` panic and
then a segfault, which read like bounds bugs and were nothing of the kind.
`audiodev.sinks` is the worst of the three: `ma_device` sits inline in the slot
and miniaudio keeps pointers back into it, so moving it is fatal even without
the concurrency.

The fix is the same in all three: **reserve the table to a cap once, and REFUSE
past it.** 64 graphs, 16 streams, 8 output devices, 8 inputs. Reserving makes
every address permanent for the life of the slot; the cap is what keeps the
guarantee from being conditional. All three tables already reuse dead slots
first, so the cap bounds LIVE objects rather than objects ever created — and a
counted refusal names the problem in a way a crash never does.

Two Zig tests hold it: a second stream must leave the first producing its own
signal bit-exact with **zero underruns**, and the table must refuse past its cap
rather than grow "just this once".

**This was reachable from ordinary code and had nothing to do with speech.** Two
`stzSoundTransport`s is a reasonable thing to write. VC4 found it only because a
spoken phrase and an earcon pool are two transports by nature.

### A guard bug worth recording, because it looked like a product bug

The gap assertion failed first, and the composite looked wrong. It was not: the
earcon renders at **48000** and the voice at **22050**, and the composite adopts
the phrase's rate. `oEar.Frames()` therefore names a *different instant* in each
buffer — 3969 frames of composite, not 8640 — so the measurement landed a third
of a second late, inside the speech. **Seconds are the only index two buffers
of different rates agree on.** Recorded because the first instinct was to
distrust the composite.

### A SECOND defect, found by the author listening to the demo

*"The voice generated is so quick I could not recognise what it says."*

Not the voice's rate setting. **Every sound was playing at the device's rate
instead of its own.** `playbackOpen` asked miniaudio for `sampleRate = 0` —
"let the device pick" — on the strength of a comment saying *the graph must
already match it*. Nothing enforced that, and nothing could: the ring carried
`channels` and `capacity` but **not its rate**, so the consumer had no way to
ask.

| | rate | outcome |
|---|---|---|
| earcons | 48000 | matched the device by luck — correct, and hid the bug |
| speech | **22050** | played at 44100: **exactly twice as fast** |

Measured before and after, on 10.604 s of synthesised speech:

| | wall clock |
|---|---|
| before | **5.59 s** |
| after | **11.26 s** (the excess is device start-up) |

**No counter could ever have seen this.** Not one frame was lost, so
`underruns` stayed at 0 and every guard passed. It is inaudible to
instrumentation and obvious to a listener — which is the entire argument for
shipping a hearable demo with every phase, and the reason this was caught by
the author's ears rather than by 526 assertions.

The fix: the **ring carries its own sample rate** (`sr.Ring.rate`, VERSION
bumped to 2 so a mismatched DLL pair is refused rather than misread), and both
`playbackOpen` and `captureOpen` open the device for it. Capture had the same
line and the same fault, in the other direction: a recogniser handed the wrong
rate mishears everything.

Guarded in `sound_transport_narrated.ring` by the only instrument that can see
it — **a wall clock**. A 22050 Hz buffer must take its own duration to play, not
half of it.

### What VC4 did NOT do

- **No ducking.** Lowering a bed under a phrase needs a per-bus gain node; that
  is SS3 and it is still open. Nothing here overlaps, so nothing needs ducking
  yet.
- **No barge-in.** Speaking while listening (VC3) is untested; the two own
  different devices and the interaction is unmeasured.
- **No fix for exit-without-`Release`.** A process that exits with a device
  callback still live segfaults — **and it does so with a SINGLE transport**, so
  it predates this work and is independent of it. Every guard and demo releases.
  Recorded, not fixed: the safe fix is a teardown hook, and a wrong one runs
  inside the loader lock.
- **No speech in the Rule 18 path**, and §4 says why. Nothing here changes it.

### Plane totals

**527 Ring assertions across fifteen guards** (VC4 adds 24, plus the wall-clock
assertion above). **67 Zig tests**
across `sound.zig`, `soundgraph.zig`, `soundring.zig`, `sounddsp.zig`,
`soundanalysis.zig`, `soundwasm.zig` and `audiodev.zig`, plus **13** across
`voice.zig` and `listen.zig` — counted from those files, so a later reader can
reproduce the figure rather than inherit it.
