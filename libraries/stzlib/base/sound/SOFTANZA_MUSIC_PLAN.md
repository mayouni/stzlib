# SOFTANZA MUSIC PLAN — the field, read closely, and how this library embraces it (MU0–MU7)

Status: **PLAN OF RECORD, written 2026-09-25, before any phase has run.** Third
door on the sound plane, beside `SOFTANZA_SOUND_PLAN.md` (SN0–SN6, SS1–SS5) and
`SOFTANZA_VOICE_PLAN.md` (VC0–VC6). It inherits their discipline verbatim —
measure before believing anything including this document, kill criteria before
numbers, guards that assert the mechanism, a bounded record that counts what it
drops, engine-first, CI with no hardware — **and one law those planes earned the
hard way and this one cannot live without:** `CENTRAL-PERCEPTGATE-01`. *Every
phase ships something a person listens to, and the record says who listened.*
Music is the purest case of a channel whose last consumer is a person; a green
suite here proves delivery and nothing else.

**The brief, in the author's words:** *a professional grade, yet dead simple and
very fun design experience of any musical style, any voice and instrument, in any
cultural universe.* Four claims — professional, simple, fun, universal — and the
last one is the one nobody in the field has delivered. That is where this plan
spends its ambition.

---

## 0. The door was closed "until asked", and it has now been asked

`SOFTANZA_SOUND_PLAN.md` §4 lists, under scope gravity: *"OUT until asked, in
writing: MIDI, music notation, 3D/HRTF spatial audio, time-stretching, and
VST/CLAP hosting."* Unlike the speech exclusion the voice plan had to overturn
as a category error, this one was correctly hedged — it was a boundary against
drift, not a judgement that music was somebody else's. The author has asked.

What this plan claims is the same shape the voice plan claimed: **music is not a
new plane. It is a third door on the plane that exists.** The graph renders
sound; the transport keeps time; the pool fires voices; the analysis reads
onsets and tempo; the wasm seam makes one arithmetic serve two tiers. Music
needs a **scheduler** on top of the transport, **pitch** the graph cannot yet
change per note, **instrument models** richer than four waveforms, and a
**vocabulary of cultural universes** declared as data. Nothing in that list is a
new sink, a new clock, or a new ring.

What stays out, in writing: **VST/CLAP hosting, MIDI hardware I/O, time-stretching,
3D spatial audio, and neural generation** (Suno/Udio-class text→song). The last
is named because a session asked for "any musical style" will feel its pull.
Neural generation makes a plausible song; this plan makes an **exact, auditable,
reproducible** one from a declaration, and the two are different products with
different owners.

---

## 1. The field, read closely

Read for what each system got RIGHT and what it costs, because this plan
borrows from all of them and copies none.

### 1.1 Live coding — where "vibing" comes from

| system | the idea worth taking | what it costs |
|---|---|---|
| **TidalCycles** (Haskell) | **A pattern is a function of time**, cyclic, and patterns compose algebraically: `fast 2`, `rev`, `every 3`, `jux`, `off 0.25`. The **mini-notation** — `"bd ~ sn [hh hh]"`, `<a b>` alternation, `a*2`, `a?` chance — is the most expressive rhythm DSL in existence, and it is a STRING | Haskell. A musician learns the mini-notation in an hour and the host language never |
| **Strudel** (JS) | Tidal's pattern algebra and mini-notation, **in a browser**, on WebAudio, with no install. Proves the browser tier is enough for live music and that a pattern language survives a language port intact | Same algebra, so the same abstraction ceiling; a browser tab is its whole world |
| **Sonic Pi** (Ruby) | **Dead simple is a design target, measured on children.** `play 60`, `sleep 0.5`, `live_loop :beat do ... end`. The first line makes a sound. `live_loop` is the unit of liveness: redefine it and the change lands at the loop's next turn, never mid-bar. `use_synth`, `sample`, `with_fx` are three verbs and they are enough | Imperative time (`sleep`) reads naturally and composes badly; two loops that must interlock need care |
| **SuperCollider** | The engine under half the field. `SynthDef` (an instrument) is separate from `Pbind` (a score), and **`Scale` and `Tuning` are first-class objects** with dozens of non-Western tunings shipped | The steepest thing in this table; professional and proud of it |
| **ChucK** | **Strongly timed**: `now` is a variable, `1::second => now` advances it, and concurrency is `spork`. The clearest model of *time as a value* in any language | Its own language, its own VM |
| **Orca** | A grid where letters are operators and time flows down. Nothing to read: you *watch* it. Proof that a music interface can be a picture | Esoteric by design; not a foundation |
| **Extempore / Overtone / FoxDot / Gibber** | Each is "live coding in language X" — Scheme, Clojure, Python, JS. The lesson is that **the pattern layer ports and the host does not matter** | — |

**What live coding settled, and this plan adopts without argument:**

1. **The unit of liveness is a loop, and a change lands on a boundary.** Sonic
   Pi's `live_loop` and Tidal's `d1 $` both replace a running pattern at its next
   cycle. Never mid-bar. This is the same rule SN6's transport has for pausing
   (fade first, then silence) applied to structure.
2. **Rhythm is a string.** The mini-notation is the field's one genuine
   invention, it is learnable in an hour, and this library is built around string
   faces. `"bd ~ sn ~"` is a `stzString` waiting for a parser.
3. **Patterns compose.** `fast`, `slow`, `rev`, `every`, `off`, `jux` — an algebra
   over time-functions. Softanza's chaining (`.FastQ(2).EveryQ(3, :Rev)`) is that
   algebra's natural surface.
4. **Instrument and score are separate concerns** (Csound's orchestra/score,
   SuperCollider's SynthDef/Pbind). A pattern says *when* and *what*; an
   instrument says *how it sounds*. Conflating them is how a system ends up with
   one sound.

### 1.2 Composition and notation — where "professional" comes from

| system | the idea worth taking |
|---|---|
| **Euterpea** (Haskell) | Music as an **algebraic data type**: a primitive, or `:+:` (sequential), or `:=:` (parallel), or a modifier. Everything — a note, a chord, a symphony — is one type. Analysis and transformation are pattern-matching on it. **This is the shape of `stzScore`** |
| **Csound** | The oldest orchestra/score split, and the **score is a table of events**: instrument, start, duration, parameters. Fifty years old and still the right data model for a scheduler |
| **LilyPond / ABC / MusicXML** | Notation is a *rendering* of a score, not the score. ABC is a one-line text format a folk musician can type; MusicXML is what every notation program exchanges. Both are outputs of the data model, never inputs to the design |
| **Alda** | `piano: c d e f g` — notation as a typed line. Proof that text-first composition can be humane |
| **Music21** (Python) | The analysis side: key finding, chord labelling, interval vectors, corpus study. **The `sound → data` direction for music**, and a reminder that a score is DATA before it is anything else |
| **Faust** | Functional DSP that compiles to every target. The lesson: **an instrument is arithmetic**, and arithmetic belongs in the seam |

### 1.3 Where the entire field is weak — and this plan is not

**The default of every system above is Western twelve-tone equal temperament.**
Microtonality is bolted on: a Scala `.scl` file loaded into a slot, a `Tuning`
object nobody's tutorial mentions, a cents offset per note. **The cultural
universe is an afterthought in all of them**, and it shows in what they cannot
express:

| tradition | what it needs that a "tuning file" cannot carry |
|---|---|
| **Maqam** (Arabic / Turkish / Persian dastgah) | Quarter tones, yes — but a maqam is not a scale, it is a family of **jins** (three- to five-note building blocks) joined at a pivot, with a **sayr**: rules for which jins you move to and how you return. Rast is a *path*, not a set of pitches. Turkish makam uses Holdrian commas (53 per octave); regional intonation differs and is not an error |
| **Tunisian ṭubūʿ** (طبوع, sing. *ṭabʿ*) | Adapted from the Arabic maqam and **not the same thing**: the modes of the *maʿlūf*, the Andalusi-descended art repertoire, organised in **nūbāt** (suites), each in one ṭabʿ. The thirteen commonly given — Dhīl, ʿIrāq, Sīka, Ḥsīn, Raṣd, Ramal al-Māya, Nawā, Aṣbaʿayn, Raṣd al-Dhīl, Ramal, Iṣbahān, Māya, Mazmūm — share some names with Eastern maqāmāt (Sīka, ʿIrāq, Iṣbahān) and **differ in intonation and sayr even where the name is shared**, while Dhīl, Raṣd al-Dhīl, Mazmūm, Aṣbaʿayn and Ramal al-Māya are the Maghreb's own. Some Tunisian degrees do not sit cleanly on the 24-quarter-tone grid, so the tuning is declared per ṭabʿ, not inherited from the maqam row above. Rhythm is the nūba's own progression of **īqāʿāt** — btāyḥī, barwal, draj, khafīf, khatm — accelerating through the suite, and beside the art tradition the popular **mezwed** repertoire has its own cycles. **The list above is the theorists'; the listener is the gate, and for this universe the listener is nearer than for any other in this table** |
| **Raga** (Hindustani / Carnatic) | Ascending and descending scales can DIFFER (aroha/avaroha). **Gamaka** — the ornament between notes — is the identity of the raga, not decoration; a raga played without its gamakas is a different raga. Vadi/samvadi (the emphasised notes), characteristic phrases (pakad), time of day. Rhythm is **tala**: cycles of 3–16+ beats with named subdivisions, and the composition returns to *sam* (beat one) |
| **Gamelan** (Java / Bali) | **Slendro** (five near-equal steps) and **pelog** (seven unequal), and **every ensemble is tuned differently on purpose** — there is no reference pitch. Structure is **colotomic**: gongs punctuate a cycle at nested intervals. Balinese **kotekan** is two players interlocking one melody, and paired instruments are deliberately detuned to beat |
| **West and Central African** | The **timeline** (the 12/8 bell pattern) is the reference the ensemble hears, not a downbeat. Polyrhythm is the norm: 3 against 2, 4 against 3, as one texture. Talking-drum pitch follows speech tone |
| **Niger** (Hausa, Zarma-Songhai, Tuareg, Fulani/Wodaabe, Kanuri) | Five traditions in one country and **almost no written theory for any of them** — the sources are ethnomusicographers, not native theorists, so the declared set here is an outsider's transcription and the listener gate is not optional, it is the whole record. What they share: **anhemitonic pentatonic** pitch sets, but on fretless or single-string instruments (the Tuareg **imzad** and the Hausa/Zarma **goge/godji**, bowed; the Zarma **molo** and Tuareg **tehardent**, plucked), so **intonation is a curve, not a step** — the target pitches are declared and the slide between them is the ornament vocabulary, which means the plan's portamento (MU0 spike 1) is this universe's identity rather than a nicety. Rhythm: polyrhythm on the timeline as the row above says, plus Niger's own — the **takamba** (a slow, hypnotic triplet swing on tehardent and calabash), the Tuareg **tende** cycles (a mortar drum, women's ceremonies), Hausa **bori** possession rhythms, and the Wodaabe **Gerewol**'s clapped-and-stamped cycles under men's vocal polyphony. **And one thing no other row has: the Hausa kalangu** — an hourglass drum whose pitch is squeezed in real time to follow the high/low/falling tones of Hausa, a tonal language, so *a drum phrase is a sentence*. Its declaration is TEXT, and its rendering is a pitch contour |
| **Afro-Cuban / Brazilian** | **Clave** is a two-bar asymmetric key that everything aligns to, and playing "against the clave" is an error a native listener hears instantly |
| **Flamenco** | **Compás**: twelve-beat cycles with accents on 3, 6, 8, 10, 12 (soleá), and the palo (style) is defined by its compás before its harmony |
| **Chinese / Japanese** | Pentatonic modes (gong, shang, jue, zhi, yu); **guqin tablature describes the technique, not the pitch**; shakuhachi honkyoku has breath-phrases rather than bars |
| **Byzantine / Georgian / Bulgarian** | Modes with their own intervals (Byzantine echoi), asymmetric metres (7/8, 11/16), close-harmony drones |

**The common shape, and it is the design:** a cultural universe is **a tuning +
a pitch vocabulary with movement rules + a rhythmic cycle with accents + an
ornament vocabulary + an instrument set.** Five declared things. Every system in
§1.1 hard-codes the first two to 12-TET and a bar, and leaves the rest to the
performer's knowledge. **This plan makes all five a declaration**, and Rule 118's
lesson — *one vocabulary, many renderings* — is the reason it can: declare the
universe once, and the same composition, the same instrument, the same analysis
render inside it.

**And the honest limit, stated now:** a declaration carries what a tradition's
theorists have written down. Gamaka and sayr are partly oral; a declared subset
is a *starting set with a kill criterion*, exactly as SS1's motifs were, and a
musician from the tradition is the gate — `CENTRAL-PERCEPTGATE-01` with a name
attached. **And a tradition is its instruments as much as its modes**: the Tunisian
row cannot be rendered on a piano and called Tunisian. Its sound is the **mezwed**
(a goatskin bagpipe with two parallel single-reed chanters and no drone — the two
pipes beat against each other, and the bag never breathes), the **zokra** (a
double-reed conical shawm, played with circular breathing, penetrating and
outdoors), the **darbouka** (goblet drum: *dum* at the centre, *tak* at the rim,
*ka* the weaker rim, slaps and rolls) and the **bendir** (frame drum with gut
snares under the head, so every stroke carries a buzz). Two reeds and two
membranes — and none of the three synthesis engines in §3 makes a reed. That is
why §3 has a fourth.

**Niger's instruments then show that the fourth engine is not one engine but a
family of MOUTHS on one bore, and that the string engine is missing a bow.** The
Hausa **kakaki** is a two-metre metal trumpet — a lip reed, the brass excitation.
The **algaita** is a double-reed shawm, the zokra's engine exactly. The Fulani
**sarewa** is a flute — an air jet, no reed at all. So one waveguide bore with four
excitations (single reed, double reed, lip, jet) covers the mezwed, the zokra, the
kakaki, the algaita and the sarewa, and every wind in the table. On strings, the
**imzad** and the **goge/godji** are *bowed*: Karplus-Strong is a pluck and cannot
sustain, so the string waveguide needs a bow — the stick-slip friction excitation —
as its second mouth. The plucked **molo**, **tehardent** and **hoddu** are Karplus
with a gourd's resonance, the kora's engine. And the **kalangu** is a membrane whose
pitch changes *while it sounds*: that is §3's Gap 1 — `setFrequency` — applied to
a drum, which is the satisfying kind of consequence, because it means the plan's
first engine change already serves its hardest instrument. The **calabash** (the
Zarma *gaasu*, struck with ringed fingers) is the membrane engine with a shell mode
and a rattle; the **ganga** and **tende** are its plain cases.

---

## 2. The four transforms, applied

`contracts/recognition-and-synthesis.md` gives every medium four transforms and
one pivot. For music:

```
    score  ──SYNTHESISE──▶  sound        the scheduler + instruments
    score  ◀──RECOGNISE──   sound        pitch + onset → notes  (SN5 has half of this)

    data   ──RENDER────▶    score        sonification AS MUSIC: a series becomes a melody
                                         in a declared universe, not a beep per point
    data   ◀──ANALYSE───    score        key, mode, tempo, density, contour (Music21's job)
```

**The pivot holds, and it holds twice.** A score is a `stzScore` — data, an
ordinary object — and a rendered performance is a `stzSound`. So a score can be
analysed before it is heard, transposed into another universe, rendered to
notation, and the resulting sound fed to SN5's instruments or back into the
recogniser. **The loop VC6 closed for speech closes for music without a new
verb.**

**What the pivot buys that no live-coding system has:** the `RENDER` row. The
sound plane already sonifies data (SS1–SS5 turned five *meanings* into sound).
With a declared universe, a data series becomes a *melody in Rast* or *a phrase
over teental* — sonification that a listener from that culture hears as music
rather than as a meter. That is not a feature of any system in §1.

---

## 3. What the plane already has, and the three gaps — measured in the tree, not remembered

**Has, and music reuses unchanged:**
- **The graph** — oscillator (four waveforms, band-limited), source (a buffer),
  gain (ramped, atomic), mix, pan, filter (RBJ biquad), delay, envelope (ADSR).
  Eight node kinds. `soundgraph.zig` lines 164–171.
- **The transport** — play/pause/resume/stop under a state machine, a device
  clock, `DriveWith(stzReactive)` for one loop shared with everything else.
- **The voice pool** — build once, fire many, slots and steals counted, and
  since SS3 a **gain bus per voice**.
- **The trigger** — `triggerNode` resets a subtree atomically at the next block:
  rewinds a source, re-arms an envelope. `soundgraph.zig` line 729.
- **The seam** — `sounddsp.zig`, one arithmetic in both tiers, proven
  bit-identical by a generated file.
- **The instruments of analysis** — onsets, tempo (median of onset gaps, and
  honestly `-1` when it cannot say), dominant frequency, spectrogram, LUFS.
- **The voice** — SAPI synthesis to a buffer; closed-grammar recognition.
- **The browser** — an AudioWorklet playing wasm-rendered blocks at 10.0 ms.

**Gap 1 — PITCH PER NOTE does not exist, and nothing in the engine can fake it.**
`Node.hz` is set when an oscillator is added and never again: the only runtime
setter in the graph is `setGain` (line 462). `stzVoicePool.ring` line 31 says it
in its own words: *"There is no pitch-per-shot, no per-shot volume."* A pool
with one oscillator per pitch is 88 oscillators for a piano and no vibrato. So
the first engine change is **`setFrequency(node, hz, ramp_ms)`**, built exactly
as `setGain` is — an atomic target, a ramp, `currentFrequency` for a guard — and
its twin for a source node, **`setRate(node, ratio)`**, which is how a sample
becomes an instrument (one recording, any pitch). Both are the `setGain`
pattern; neither is new architecture.

**Gap 2 — there is no SCHEDULER.** The transport keeps time in *seconds* and
the pool fires *now*. Music needs events placed in the future in *beats*, at a
tempo, quantised to a grid, and delivered to the render **ahead of the ring's
329 ms** so that placement is sample-accurate however late playback is. The
scheduler is a queue of `(beat, node, params)` drained by the producer thread
into triggers and setters at exact frame offsets — which means **the producer
thread must be able to apply a trigger at a frame INSIDE a block**, and today
`applyTriggers` applies at block start (line 741). That is a 512-frame (10.7 ms)
quantisation, audible as swing on fast material. **MU0 measures whether it
matters before MU2 fixes it.**

**Gap 3 — four waveforms are not an orchestra.** The instrument question has
three known answers and this plan takes all three, cheapest first:
- **Karplus-Strong** (a delay line with a filter in the loop) gives plucked and
  struck strings — guitar, harp, kora, koto, oud, santur — in thirty lines,
  and it is *the* sound that makes people smile. Already every primitive it
  needs exists (delay, filter, noise burst).
- **FM synthesis** (two operators, an index, a ratio) gives bells, electric
  pianos, brass, gamelan metallophones — the DX7 in a dozen lines of `sounddsp`.
- **Samples with pitch** (Gap 1's `setRate`) give everything else, and the
  **SoundFont** (`.sf2`) format is the free, universal, General-MIDI-mapped
  library of them. Vendoring one is a **licence decision recorded before a byte
  moves**, as the voice plan required of neural weights.
- **A reed, and a membrane** — added for Tunisia and owed to every wind and
  percussion tradition in §1.3. A single-reed **waveguide** (a delay line, a
  reflection filter, and a nonlinear reed table driven by breath pressure — the
  classic clarinet model, some fifty lines of `sounddsp`) gives the mezwed when two
  are run slightly detuned under a bag's constant pressure, and the zokra when the
  bore is conical (all harmonics, not only the odd) and the reed is double. A
  **modal membrane** (a few damped sine modes at a struck point, plus a noise
  burst) gives *dum* and *tak* on a darbouka and, with a buzz gated by the
  membrane's decay, the bendir's snare. Samples would do both faster and teach
  nothing; the model is what makes *pressure*, *strike position* and *detune*
  parameters a pattern can drive per note. **Niger (§1.3) generalises this in
  two directions before it is built**: the reed becomes one of four excitations
  on the same bore — single reed, double reed, lip (kakaki), air jet (sarewa) —
  and the string waveguide gains a bow (imzad, goge) beside its pluck. Neither is
  a fifth engine; each is a second mouth on an engine already listed, and the
  kalangu's squeezed pitch is Gap 1's `setFrequency` on a membrane's modes.

**Not a gap, and worth saying:** timing *jitter* is separate from *latency*, and
the plane's ring gives the second and not the first. A scheduler that places
events into the stream precisely gives tight playback that is 329 ms late — fine
for composition and playback, **unplayable for a live instrument** (press a key,
hear a note). That is exactly S.5's Rule 18 finding in a new coat: natively a
note is late, in the browser it is 10 ms. **The live-performance experience is
browser-first**, and the plan says so rather than discovering it in MU5.

---

## 4. The design experience — three tests, each with a number

**"Dead simple"** — *the first line makes a sound.*

```ring
StzMusicQ().Play("c e g c5")                     # four notes, now, a piano
```

Test: a person who has never seen Ring writes one line and hears music within
ten seconds of opening the file. Sonic Pi passes this with children; nothing
less is acceptable.

**"Professional grade"** — *nothing here is a toy under the hood.*

- pitch exact to the cent, verified by FFT;
- timing exact to the sample, verified by onset measurement;
- a score is data: transposable, analysable, exportable to MusicXML and MIDI
  file (a *file*, not hardware — hardware I/O stays out);
- a performance is a `stzSound`: LUFS-measured, saveable, feedable to the
  recogniser;
- **every claim above has a guard**, and the guard's number is in the STATUS.

**"Very fun"** — *the loop is live and the defaults are generous.*

```ring
oM = StzMusicQ().Tempo(96).In(:Maqam, :Rast, :D)

oM.Loop(:melody, "d e f+ g a ~ g f+")          # the + is a half-flat, Rast's own
oM.Loop(:iqa,    "dum ~ tak ~ dum dum tak ~")   # the rhythm names itself
oM.Loop(:drone,  "d2").With(:Oud)

oM.Every(4, :melody, :Rev)                     # every fourth cycle, backwards
oM.Loop(:melody, "d e f+ g a b- a g")          # redefine -- lands on the next bar
```

Test: a change to a running loop is heard on the next cycle boundary and never
mid-bar; the console and the speakers agree (VC4 paid for that lesson); and a
listener says *it sounds like music*, not like a demo. **That last one is the
gate and it has a name on it.**

**"Any universe"** — *the same line, a different world.*

```ring
oM.In(:Raga, :Yaman).Tala(:Teental)             # 16 beats, returns to sam
oM.In(:Gamelan, :Slendro).Colotomy(:Lancaran)   # gong cycle, paired detuning
oM.In(:Tunisian, :Dhil).Iqa(:Btayhi)            # a ṭabʿ, and the nūba's own cycle
oM.Loop(:lead, "d e f+ g a ~ a g").With(:Mezwed)   # two chanters, beating, no breath
oM.Loop(:iqa,  "dum ~ tak ka dum dum tak ~").With(:Darbouka, :Bendir)
oM.In(:Niger, :Zarma).Rhythm(:Takamba)          # pentatonic targets, slides between
oM.Loop(:fiddle, "a ~ c' ~ d' c' a ~").With(:Imzad).Slide(0.3)   # the bow sustains
oM.Say(:Kalangu, "sannu da zuwa")              # Hausa tones become drum pitch
oM.In(:Major, :C)                               # the default nobody else escapes
```

Test: a phrase declared once renders differently and *correctly* in each — the
quarter tone is a quarter tone, the gong lands where the cycle says, the
gamaka is present. The gate is a listener from the tradition, and MU4's STATUS
records their name and their verdict or records that nobody has listened yet.

---

## 5. The pieces, and why each is where it is

| piece | what it is | where and why |
|---|---|---|
| `setFrequency` / `setRate` / `currentFrequency` | per-note pitch, atomic and ramped | `soundgraph.zig`, beside `setGain`, same shape, same guard style; exported to wasm |
| sub-block triggers | a trigger with a frame offset inside the block | `soundgraph.zig`, only if MU0 says the 10.7 ms grid is audible |
| **`stzScore`** | Euterpea's algebra: note, rest, sequence, parallel, transform. **Data.** | `base/sound/`, the pivot object; renders to sound, notation, MIDI file |
| **`stzPattern`** | a function of cycle time + the mini-notation parser | `base/sound/`; the string face; `Fast`, `Slow`, `Rev`, `Every`, `Off`, `Jux` as chained verbs |
| **`stzScheduler`** | beats → frames; a queue the producer drains ahead of the ring | Zig, in the stream's producer loop, because it must be ahead of the deadline by design |
| **`stzInstrument`** | Karplus-Strong, FM, sample, and the reed/membrane physical models — one face, four engines; the wind engine with four excitations (single reed, double reed, lip, jet) and the string engine with pluck and bow | arithmetic in `sounddsp.zig` so both tiers agree; the face in Ring |
| **`stzUniverse`** | tuning + pitch vocabulary + movement rules + cycle + ornaments + instruments | **declared data** in `base/sound/universes/*.ring` — never code, because a tradition is not an algorithm and the author declares it |
| **`stzMusic`** | the one-line front: `Play`, `Loop`, `In`, `Tempo`, `With` | `base/sound/`, over everything above; it is the *fun* and it owns no mechanism |
| `stz-music.js` | the same verbs in the browser, over the same wasm | `webaudio/`; where live performance actually works |

**One thing is deliberately NOT a piece: a MIDI device layer.** MIDI *file*
export is a rendering of `stzScore` and costs a page; MIDI *hardware* is a
per-OS driver surface and is out in writing.

---

## 6. Phases, each with a kill criterion

**MU0 — the measurements this plan needs before it is believed.** Four spikes,
no faces:
1. `setFrequency` as an atomic ramp: a 440→880 Hz sweep over 10 ms, measured
   for clicks by SS3's seam-step instrument (worst step over sixteen phases).
2. Trigger placement: fire twenty notes at 120 BPM with the block-start
   trigger, measure their onsets with SN5, report jitter. **Is 10.7 ms audible
   as swing?** The number decides whether sub-block triggers are built.
3. Karplus-Strong in `sounddsp.zig`: does a 30-line pluck sound like a string
   to the author? (`CENTRAL-PERCEPTGATE-01`, named listener.)
4. A quarter tone: render D at 24-TET +1 step and measure by FFT. Must be
   **50 ± 2 cents**, or the pitch machinery is not fit for §1.3.
*Kill:* if (1) cannot be made click-free at 10 ms, pitch is changed only at
note boundaries and there is no portamento or vibrato — stated, not hidden — **and the imzad, the goge and the
kalangu, whose identity IS the slide, are then out of MU1 until the ramp is
click-free**. If
(4) misses, the plan stops until the arithmetic is right.

**MU1 — pitch and the instrument.** `setFrequency`, `setRate`, `stzInstrument`
with the four engines, twenty instruments across them (piano, guitar, harp,
bell, e-piano, brass, flute, oud, koto, kora, metallophone, drum kit from
samples, and the four Tunisian ones — mezwed and zokra on the reed model,
darbouka and bendir on the membrane, and four from Niger that each prove a NEW
excitation rather than lengthen the list — kakaki for the lip, sarewa for the
jet, imzad for the bow, kalangu for a membrane whose pitch moves while it
sounds; the algaita, molo, ganga and calabash then cost nothing new). *Kill:* if a named instrument does not sound like its name to the
author, it ships under a name that does not lie (`:PluckedString`, not `:Oud`).

**MU2 — the scheduler and the score.** `stzScore` (the algebra), `stzScheduler`
(beats to frames, ahead of the ring), tempo, quantisation, swing. A score plays
sample-accurately. *Kill:* onset jitter > 1 ms across 200 notes at 180 BPM means
the scheduler is not ahead of the deadline, and it is redesigned before
anything is built on it.

**MU3 — the pattern language.** The mini-notation parser and the pattern
algebra, on `stzString`. Live loops with boundary replacement over
`stzReactive`. *Kill:* if a change ever lands mid-bar, or the console and the
speakers disagree by more than one cycle, it is not live coding and is not
called that.

**MU4 — the universes.** `stzUniverse` as declared data; eight shipped — Western
major/minor, Maqam Rast and Hijaz (24-TET with jins), **Tunisian ṭubūʿ — Dhīl, Sīka and
Raṣd al-Dhīl, each with its own declared tuning rather than the maqam's, the nūba's
five īqāʿāt, and one mezwed cycle**, **Niger — a Zarma pentatonic with declared slide
targets, the takamba cycle, a tende cycle, and one kalangu tone-sentence**, Raga Yaman (with three
declared gamakas and teental), Gamelan Slendro (with paired detuning and a
colotomic cycle), a 12/8 West African timeline, Flamenco soleá compás. The
same phrase rendered in each. *Kill:* **a listener from the tradition says it
is wrong.** Recorded by name. If no such listener has heard it, the STATUS says
*unperceived*, which is a true state, and the universe ships marked as such.

**MU5 — the voice, honestly.** Three things tried in order and each measured:
(a) SAPI with `<prosody pitch>` on a syllable per note — does it hold pitch
within 20 cents? (b) a formant vowel synth in the seam (five vowels, a pitch, a
breath) — does it read as a voice to the author? (c) **neither** → singing is
deferred to the neural tier **in writing**, and `Sing()` is present and refuses
with that reason, exactly as `toSoundOf` refuses in the browser. *Kill:* the
plan does not ship a `Sing()` that produces something the author would not call
singing.

**MU6 — the browser, where live performance lives.** `stz-music.js` over the
same wasm; a page with the live loops and a keyboard; **10 ms from key to
sound**. *Kill:* the perception law — the author plays it and says whether it
feels like an instrument. If the native path is also demoed, its 419 ms is
displayed on the page rather than hidden.

**MU7 — the convergence.** *(Niger adds a row to the four transforms: `text →
drum`. A Hausa sentence's tones — high, low, falling — become a kalangu pitch
contour, which is `synthesise` with TEXT as the declaration, exactly the pivot the
voice plane rests on. Kill: a Hausa speaker hears the sentence back from the drum,
or the row is recorded as unperceived and the verb refuses with that reason.)* Data → melody in a declared universe (SS-style
sonification that is *music*). Sound → score (pitch + onsets → `stzScore`,
confidence per note, exactly as VC3 carries confidence). Score → notation
(ABC out, MusicXML out) and → MIDI file. *Kill:* the four transforms compose on
one `stzScore` with no adapter, or the missing step is named as VC6 named its.

---

## 7. Risks, named now

- **Scope gravity is the worst in the library.** Music theory, synthesis,
  effects and ethnomusicology are each bottomless. Every phase above has a
  count, and a session that finds itself adding an instrument or a universe
  beyond the count its phase states, before that phase's kill criterion has
  been run, has drifted. *(This sentence said "a thirteenth instrument or a
  seventh universe" until 2026-09-25, and was false the same day: Tunisia made
  it sixteen and seven, Niger twenty and eight. A rule that hard-codes the number
  it guards is stale the first time the number moves for a good reason.)*
- **"Universal" invites a tourist's version of every tradition.** The guard is
  §1.3's last paragraph and MU4's kill criterion: a named listener from the
  tradition, or the word *unperceived* in the record. A universe shipped
  without that is a costume.
- **Live coding in an interpreted single thread against a Zig producer.** Ring
  re-evaluates a loop body on the main thread; the producer renders on its own.
  The seam between them is the scheduler queue and nothing else — a loop
  redefinition posts new events past the next boundary and never touches the
  graph. If a phase finds itself rebuilding the graph while playing, it has
  broken SN6's two-phase contract and must stop.
- **Samples are a licence before they are a sound.** A SoundFont is vendored
  only after its licence is read and recorded, per the neural-weights rule.
- **The fun is the first thing to be cut under pressure and the last thing the
  brief allows to be cut.** "Dead simple" is a phase gate, not a polish step:
  the one-line test in §4 runs at the close of every phase from MU1 on.

## 8. What is NOT here

No VST/CLAP, no MIDI hardware, no time-stretch, no 3D audio, no neural
generation, no DAW, no notation *editor* (rendering only), no audio *recording*
of instruments beyond what SN4 already does, and no claim that a declared
universe is a tradition — it is what a tradition's theorists wrote down, with a
listener's verdict attached or the word *unperceived* where one is missing.

---

## 9. The claim that survives

**A score is data, a performance is a sound, a universe is a declaration, and
the loop is live** — so one line makes music, the same line makes it in Rast or
Yaman or Slendro, every note is a number a guard can check, and every phase ends
with a person saying whether it sounds right and the record saying who.


---

## MU0 STATUS — 2026-09-25 21:54. Four spikes, two verdicts taken, two owed to an ear

`engine/src/soundgraph.zig` (`setFrequency`, `currentFrequency`, a per-sample
frequency ramp in the oscillator), `engine/src/sounddsp.zig` (`renderPluck`,
`pluckFrames`), `engine/src/sound.zig` (`pluckOf`), three Ring bridges. Guard:
`base/test/sound/sound_mu0_narrated.ring` (**24**), 4 new Zig tests (12 in the
seam, 57 in the graph, all green). Audible: `sound_mu0_demo.ring`, and four
WAVs written beside the guard so the artefact outlives the session.

### Spike 1 — a frequency ramp does not click. **MET.**

**The instrument had to change before the measurement meant anything.** SS3's
click instrument is the first difference, and a gain step is an amplitude
discontinuity it sees. A frequency change with continuous phase has **no
amplitude step at all** — the first difference is blind to it whether the change
is ramped or not. So the instrument here is the **second difference**, which
sees a kink in the slope, and the bound is the 880 Hz tone's own largest second
difference, `A·(2πf/rate)² = 0.0066`, derived rather than measured so it cannot
drift with the thing it judges.

| | worst kink over 16 phases |
|---|---|
| no change at all | **0.0017** — the instrument's own noise |
| jump, no ramp | **0.0290** — 4.4× the tone's curvature, a real kink |
| 10 ms ramp | **0.0066** — the tone's own curvature, indistinguishable from smooth |

The jump is **4.37×** the ramped kink. The ramp MOVES (627.7 Hz at 85 ms of a
200 ms ramp) and ARRIVES (880.000). Above Nyquist is refused; a non-oscillator
is refused.

**Verdict:** portamento and vibrato are IN — and with them the imzad, the goge
and the kalangu, whose identity is the slide. Built as `setGain` is built: an
atomic target, a ramp length released before it, a step planned once. The ramp
fields seed themselves from the declared `hz` on the first block, so no node
creation site had to change.

### Spike 2 — how late a block-start trigger lands. **Measured; the verdict is the author's.**

Twenty notes at 120 BPM, fired as the plane fires everything — a request the
render honours at the start of its next block:

| | |
|---|---|
| notes fired / onsets found | 20 / 20 |
| lateness, mean | **4.81 ms** |
| lateness, worst | **9.48 ms** (one block is 10.67) |
| onsets early | **none** — a request is never honoured before it is made |

Two instruments were refused on the way. **SN5's onset detector hops by 512
frames — its resolution IS the error being measured** — so the onsets are read
by a sample-exact threshold scanner instead. And the first cut of the
simulation fired a beat that fell *inside* the coming block at that block's
*start* — early — and reported a **negative** mean lateness, which no
request-then-honour path can produce. It was measuring the simulation, not the
mechanism; corrected, and the correction is in the guard's own comment.

**Whether 9.5 ms reads as swing is not a number.** The demo plays the render's
own grid beside a sample-exact one. **UNPERCEIVED as of this writing**; the
author's verdict goes here by name and decides whether MU2 builds sub-block
triggers.

### Spike 3 — a thirty-line pluck. **Measured; the verdict is the author's.**

Karplus-Strong in the seam, noise from a fixed linear congruential sequence so
both tiers render the same pluck to the bit. 1.5 s at 220 Hz: peak 0.999,
first 100 ms 0.999, last 100 ms **0.070** — it decays as a string does. A pitch
whose period does not fit the line is refused rather than aliased.

**Two findings came with it, and one was a prediction that a measurement
contradicted.** The averaging in the loop is **half a sample of delay**: a
240-sample line rings at 240.5, so the first cut asked for 200 Hz and got
199.58 — 3.6 cents flat. The line is now chosen for `N + 0.5 = rate/hz`. What
remains is integer quantisation, up to half a sample — **8 cents at A4 against
the plan's 2-cent bar** — so MU1 owes a fractional delay (an allpass). And the
guard's pitch instrument, an integer-lag autocorrelation, reads **217 frames,
221.20 Hz, +9.4 cents** — while a first cut of the prose beside it printed a
**+1.4-cent prediction**. One lag at 218 frames is 7.9 cents wide: the
instrument cannot see the correction it sits next to. The prediction is gone;
the resolution is stated; MU1 owes a finer instrument with the fractional
delay, because nothing in this spike can see 2 cents on a pluck.

**Whether it sounds like a string is not a number.** The demo plays A3 D4 E4 A4
at a guitar's decay and again at a harp's. **UNPERCEIVED as of this writing.**

### Spike 4 — a quarter tone is fifty cents. **MET, to 0.003 cents.**

| | asked | measured | off |
|---|---|---|---|
| D4 | 293.6648 Hz | 293.6638 Hz | −0.006 cents |
| D4 + 1 step of 24-TET | 302.2698 Hz | 302.2683 Hz | −0.009 cents |
| **the step** | 50 | **49.997 cents** | |
| a semitone, the negative sibling | 100 | **100.016 cents** | |

**The instrument's resolution is stated because the obvious instrument
cannot answer the question.** The FFT with 8192 bins is 5.86 Hz per bin — **34
cents at D4** — and reads D4 at 292.97 Hz, 4.1 cents off, inside its own bin.
The fine instrument is the period of a pure sine over the whole 2 s buffer,
read off its first and last rising zero crossings: one sample in 96 000 is
0.02 cents. The two agree to within the coarse one's resolution, which is all
the coarse one can promise.

### Found on the way, and none of it caused here

- **A red test on `origin/main`**: SS5's *every motif renders the frames it
  promised* asked for 8640 frames from an 8192 buffer and failed on a pristine
  checkout before this phase touched the file. Fixed (16384), and the commit
  says found-not-caused.
- **`zig build test` on `origin/main` does not compile**: the gpu module's
  `webgpu/webgpu.h` is present on disk and absent from the test step's include
  line. Not this plane's; the sound modules were tested directly (`zig test
  src/sounddsp.zig`, `zig test src/soundgraph.zig -I vendor/miniaudio -lc`).
- **`zig build` fails on `stz_http` and `stz_reactor`** with 117 errors, also
  not this plane's; `stz_sound.dll`, `stz_audiodev.dll` and `stz_voice.dll`
  build and are what the guard and demo load.

### What MU0 did NOT do

- **No faces.** `stzScore`, `stzPattern`, `stzInstrument`, `stzMusic` are MU1+.
- **No fractional delay** and no finer pitch instrument — MU1, and the reason
  is measured above.
- **No sub-block trigger** — the decision waits on the author's ear (spike 2).
- **No bow, reed or membrane** — MU1, as §3 orders them.
- **No wasm export** of `setFrequency` or the pluck — MU6's, where the browser
  gets them through the same seam.

### The listener's line

**UNPERCEIVED as of 2026-09-25 21:54.** Spike 2 (does 9.5 ms swing) and spike 3
(is the pluck a string) each take a name and a verdict here, or stay marked as
they are. Spikes 1 and 4 are also played, so the person the plan is written for
has heard what the numbers describe.
