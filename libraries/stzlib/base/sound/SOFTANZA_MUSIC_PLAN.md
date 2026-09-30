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
| **Euterpea** (Haskell) | Music as an **algebraic data type**: a primitive, or `:+:` (sequential), or `:=:` (parallel), or a modifier. Everything — a note, a chord, a symphony — is one type. Analysis and transformation are pattern-matching on it. **This is the shape of `stzSoundScore`** |
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

**The pivot holds, and it holds twice.** A score is a `stzSoundScore` — data, an
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
| **`stzSoundScore`** | Euterpea's algebra: note, rest, sequence, parallel, transform. **Data.** | `base/sound/`, the pivot object; renders to sound, notation, MIDI file |
| **`stzSoundPattern`** | a function of cycle time + the mini-notation parser | `base/sound/`; the string face; `Fast`, `Slow`, `Rev`, `Every`, `Off`, `Jux` as chained verbs |
| **`stzSoundScheduler`** | beats → frames; a queue the producer drains ahead of the ring | Zig, in the stream's producer loop, because it must be ahead of the deadline by design |
| **`stzSoundInstrument`** | Karplus-Strong, FM, sample, and the reed/membrane physical models — one face, four engines; the wind engine with four excitations (single reed, double reed, lip, jet) and the string engine with pluck and bow | arithmetic in `sounddsp.zig` so both tiers agree; the face in Ring |
| **`stzSoundUniverse`** | tuning + pitch vocabulary + movement rules + cycle + ornaments + instruments | **declared data** in `base/sound/universes/*.ring` — never code, because a tradition is not an algorithm and the author declares it |
| **`stzMusic`** | the one-line front: `Play`, `Loop`, `In`, `Tempo`, `With` | `base/sound/`, over everything above; it is the *fun* and it owns no mechanism |
| `stz-music.js` | the same verbs in the browser, over the same wasm | `webaudio/`; where live performance actually works |

**One thing is deliberately NOT a piece: a MIDI device layer.** MIDI *file*
export is a rendering of `stzSoundScore` and costs a page; MIDI *hardware* is a
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

**MU1 — pitch and the instrument.** `setFrequency`, `setRate`, `stzSoundInstrument`
with the four engines, twenty instruments across them (piano, guitar, harp,
bell, e-piano, brass, flute, oud, koto, kora, metallophone, drum kit from
samples, and the four Tunisian ones — mezwed and zokra on the reed model,
darbouka and bendir on the membrane, and four from Niger that each prove a NEW
excitation rather than lengthen the list — kakaki for the lip, sarewa for the
jet, imzad for the bow, kalangu for a membrane whose pitch moves while it
sounds; the algaita, molo, ganga and calabash then cost nothing new). *Kill:* if a named instrument does not sound like its name to the
author, it ships under a name that does not lie (`:PluckedString`, not `:Oud`).

**MU2 — the scheduler and the score.** `stzSoundScore` (the algebra), `stzSoundScheduler`
(beats to frames, ahead of the ring), tempo, quantisation, swing. A score plays
sample-accurately. *Kill:* onset jitter > 1 ms across 200 notes at 180 BPM means
the scheduler is not ahead of the deadline, and it is redesigned before
anything is built on it.

**MU3 — the pattern language.** The mini-notation parser and the pattern
algebra, on `stzString`. Live loops with boundary replacement over
`stzReactive`. *Kill:* if a change ever lands mid-bar, or the console and the
speakers disagree by more than one cycle, it is not live coding and is not
called that.

**MU4 — the universes.** `stzSoundUniverse` as declared data; eight shipped — Western
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
sonification that is *music*). Sound → score (pitch + onsets → `stzSoundScore`,
confidence per note, exactly as VC3 carries confidence). Score → notation
(ABC out, MusicXML out) and → MIDI file. *Kill:* the four transforms compose on
one `stzSoundScore` with no adapter, or the missing step is named as VC6 named its.

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

- **No faces.** `stzSoundScore`, `stzSoundPattern`, `stzSoundInstrument`, `stzMusic` are MU1+.
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


---

## MU1 STATUS — 2026-09-26. Twenty instruments, in tune to hundredths of a cent, and all twenty unperceived

**Engine.** `engine/src/soundinstr.zig` — a new seam file (imports `std` only)
holding five engines, the twenty instruments, a self-tuning render and three
pitch instruments; it compiles for `wasm32-freestanding` (a 19 KB object with
the entry points exported — checked with exports, because an object with none
proves nothing: Zig never analyses what nothing references). `soundgraph.zig`:
`setRate` — a source played at a rate, by fractional read. `sound.zig`: `noteOf`,
`measurePitchOf`, `mixInto`. Fifteen Ring bridges.
**Face.** `base/sound/stzSoundInstrument.ring` — `StzSoundInstrumentQ`, `StzInstruments`,
`StzNoteToHz`; `stzSound.MixIn`.
**Guard.** `base/test/sound/sound_mu1_narrated.ring` — **37**. Zig: 5 in the
instrument seam, 2 new in the graph (59 green), 12 in `sounddsp`.
**Heard.** `sound_mu1_demo.ring` — a phrase per instrument in its own idiom, a
Tunisian and a Nigerien ensemble, 23 WAVs, a 110.6 s tour, 0 underruns.

### The one number MU1 exists to change

| A4, read by the same fine instrument | cents |
|---|---|
| MU0's integer-period pluck | **+9.404** |
| MU1's guitar — allpass fractional delay | **−0.022** |

The loop is N whole samples + ½ for the two-point average (MU0's finding) + d
for a first-order allpass, d kept in [0.5, 1.5). The plucked instruments now
need no tuning at all: their untuned error is hundredths of a cent.

### Every pitched instrument, bottom, middle and top of its range

`raw c` is the UNTUNED model's error; `tuned` is the correction the
instrument applied after listening to itself; the last three are the finished
notes, in cents.

| instrument | engine | raw c | tuned | low | mid | high |
|---|---|---|---|---|---|---|
| piano | pluck | 0.004 | 0 | −0.010 | 0.004 | −0.094 |
| guitar | pluck | −0.010 | 0 | −0.019 | −0.010 | −0.029 |
| harp | pluck | 0.025 | 0 | −0.005 | 0.025 | −0.073 |
| bell | fm | 0 | 0 | 0.001 | 0.000 | 0.000 |
| epiano | fm | 0 | 0 | −0.417 | 0.008 | −0.014 |
| brass | fm | 0 | 0 | −0.000 | −0.002 | −0.012 |
| flute | wind (jet) | **+32.9** | −32.8 | 0.041 | −0.034 | 0.054 |
| oud | pluck | −0.007 | 0 | −0.002 | −0.007 | 0.015 |
| koto | pluck | −0.000 | 0 | −0.020 | −0.000 | −0.019 |
| kora | pluck | −0.009 | 0 | −0.018 | −0.009 | −0.072 |
| metallophone | fm | 0 | 0 | −0.000 | −0.000 | 0.000 |
| mezwed | wind (single reed ×2) | +6.1 | −6.8 | 0.029 | 0.009 | 0.004 |
| zokra | wind (double reed) | −17.6 | +17.5 | −0.030 | 0.014 | 0.042 |
| darbouka | membrane | 0 | 0 | −0.001 | 0.000 | 0.000 |
| kakaki | wind (lip) | **−248.7** | **+376.7** | 0.001 | −0.010 | 0.011 |
| sarewa | wind (jet) | +32.5 | −32.3 | 0.048 | 0.175 | 0.168 |
| imzad | bow | +3.2 | −3.2 | −0.004 | −0.003 | 0.020 |
| kalangu | membrane | 0 | 0 | −0.002 | 0.000 | 0.000 |

The drum kit and the bendir are unpitched: they render and their peaks are
checked. **Worst finished note anywhere: 0.417 cents**, against the plan's bar of 2.

The kakaki's row is the argument for self-tuning in one line: the lip model
starts **two and a half semitones flat**, and the tube needed **+377 cents** of
correction to move the note +249 — because with the lips held at the asked
pitch, stretching the tube moves the note only about two-thirds of the way.

### The tuner is not its own witness

The Zig tests and Scene 4 read pitch with the same instrument the tuner tunes
by — which proves convergence, not correctness. So Scene 5 re-measures one
instrument per engine family with an instrument that shares **no code** with
the engine: an eight-pole lowpass at 1.2× the pitch, then the first and last
rising zero crossing across 0.7 s, each located between samples, in Ring.

| | asked | independently measured | cents |
|---|---|---|---|
| guitar (pluck) | 303.600 | 303.600 | **−0.000** |
| zokra (wind) | 480 | 479.937 | **−0.228** |
| imzad (bow) | 379.500 | 379.516 | **+0.073** |

The zokra rather than the mezwed, and said why in the guard: two chanters
BEAT, and a beat null flips the phase and adds a crossing that is not there.

### The engines are distinct by their physics, not by their names

Twenty names on one sound would pass every pitch check above. These cannot:

| claim | measured |
|---|---|
| a cylinder suppresses even harmonics | mezwed H2/H3 **0.015** |
| a cone does not | zokra H2/H3 **0.178** — 11.8× the cylinder's |
| a bow sustains | imzad loudness at 0.9 s / 0.3 s **1.030** |
| a pluck decays | guitar **0.427** |
| a centre stroke is led by the fundamental | dum fundamental / mode (2,1) **17.5** |
| a rim stroke by the upper mode | tak **0.739** |
| snares buzz | bendir 2.5 kHz / fundamental **0.039**, darbouka **0.000** |

### A pitch that moves, and a sample at another pitch

- **Kalangu, 150 → 220 Hz over 0.8 s**, read by the spectral instrument in an
  early and a late window: 161.763 against 162.770 expected, 201.323 against
  202.740 — and it rose **378.758 cents** between the window centres where the
  glide rises **380.148**. A plucked string asked to glide is refused.
- **`setRate`**: a 220 Hz guitar note played at 2^(7/12) reads 329.614 Hz,
  **−0.069 cents** from the fifth. At rate 1 a source is **bit-identical** to
  one whose rate was never set — 0 samples differ — so every earlier guard
  that plays a buffer is untouched.

### Found, and each one changed the design rather than a number

1. **The pitch instrument lied by an octave.** A 440 Hz sine asked about near
   220 Hz repeats perfectly every 220 Hz period, so the first version answered
   "220". I had claimed octave errors impossible by construction. It mattered
   beyond the tool: a self-tuning instrument that jumped an octave UP would have
   measured itself as correct. Now checked at half and a third of the lag.
2. **A period estimator is the wrong instrument for a drum.** The kalangu read
   18.7 cents sharp by it while its fundamental mode was exact by construction:
   inharmonic partials pull a period estimate. Drums, bells and bars are now
   read by a spectral instrument on their lowest mode — which answers where the
   mode IS; what the ear calls the drum's pitch is the listener's.
3. **The lip, as STK writes it, went silent.** Its filter passed steady pressure
   at ~40× gain, the lips snapped open, and the loop sat at a fixed point —
   exact zero after 100 ms, not a decay. Made a band-pass it could never START,
   because the area is lip² and a square has no small-signal gain at zero. Real
   lips have a rest opening; so does this one now (0.7, input gain 16 — the one
   point in a 3×4×3 scan where every test pitch sustained).
4. **The bowed string broke to its octave** above ~600 Hz at STK's default bow
   pressure (1205 Hz asked 600) — real bowed-string physics, caught by the
   octave guard. Bow pressure raised (slope 2), scanned at 400/600/800 Hz.
5. **Tuning a vibrato-free probe mistuned the flute** by 2.9 cents: a jet's pitch
   rides on its breath. The probe is now played as the note will be and read as
   an average across the vibrato.
6. **The sarewa wanders ±8 cents** for its whole note — breath, not drift. It is
   read as sixteen readings over 0.25–1.0 s; and a marginal −1.990 was traced to
   the probe's last readings landing in its RELEASE, fixed by holding the probe
   past them.
7. **The kakaki cracked.** The tuner converged on its probe and the note then
   sounded a fourth up (99 Hz asked 72): the last correction had been computed
   and never probed, and at that value the lips chose another tube mode. Now
   only a HEARD correction is ever used, and the tuner moves the tube while the
   lips stay at the asked pitch — the lips choose the mode.
8. **A proportional correction under-corrects a lip.** The kakaki ran out of
   passes 8.5 cents off; the step is now a secant, by what the last pass moved.
9. **Two of the guard's own criteria were wrong, and the failed versions are
   kept in its text.** "The cone: H2 above H3" asserted more than bore physics
   says (a cone PERMITS even harmonics; it does not rank the second over the
   third) — the replacement threshold, five times the cylinder's even content,
   was set AFTER the 11.8× measurement and the guard says so. "The glide rose
   more than 400 cents" was my arithmetic: the windows are centred 0.46 s apart,
   and the curve rises only 380 between them.

### A claim in this plan, corrected

§6's MU1 said the four Nigerien instruments *"each prove a NEW excitation rather
than lengthen the list"*. Three do — the kakaki the lip, the imzad the bow, the
kalangu a membrane whose pitch moves. **The sarewa does not**: the flute already
needed the jet, so the sarewa is the jet with more breath. And the general
list's brass is FM, not lip — the kakaki is the only lip.

### What MU1 did NOT do

- **No perception.** All twenty names are provisional, and UNPERCEIVED as of
  this writing. Each instrument's honest fallback is in the engine's table and
  printed by the guard and the demo — `:Oud` → `:DarkPluck`, `:Piano` →
  `:HammeredString` — decided before anyone listened.
- **No algaita, molo, ganga or calabash.** §3 says they "cost nothing new" and
  §7 says adding past the phase's count is drift. They are aliases waiting for a
  phase that names them.
- **No samples vendored**: the drum kit is synthesised, and a SoundFont remains a
  licence decision recorded before a byte moves.
- **No loudness between instruments.** Each note is peak-normalised to 0.7 ×
  velocity; how instruments sit in a mix is a later phase's.
- **No browser export** — the seam compiles for wasm; the exports are MU6's.
- **No scheduler.** `mixInto` lays notes on a timeline offline, and MU2 will
  build the scheduler on it.

### Found on origin/main and not caused here

- **Three older sound assertions have failed since 2026-08-22, and MU1 did not
  touch them.** Full regression: **680 passed, 3 failed** — two in
  `sound_convergence_narrated.ring` (VC6), one in `sound_ss4_narrated.ring`.
  All three assert that the COLOUR face refuses `:Muted`. Commit `fa9251708`
  (2026-08-22, *":Muted, family one's fifth value, as a TREATMENT"*) made
  `:Muted` a colour, so `StzSemanticColors()` now has seven entries and the
  refusal no longer happens. **The colour plane is arguably right**: SS4's own
  principle is that the VALUE is shared and the RENDERING is the medium's —
  silence is sound's rendering of `:Muted`, a quiet treatment is colour's. The
  sound guards asserted something about colour that colour never owed, the same
  overreach as this phase's H2-above-H3. Not changed here: it overturns a claim
  SS4 argued and this plan records, and that is the author's to rule.
- `zig build` fails `stz_http` and `stz_reactor` in a fresh checkout on a missing
  generated header, `nghttp2/nghttp2ver.h`. The three sound DLLs build and are
  what the guard and demo load.

### The listener's line

**UNPERCEIVED, all twenty, as of 2026-09-26.** One word per instrument settles
MU1: its name, or its honest name. Each verdict goes here, by name.


---

## MU2 STATUS — 2026-09-26. Every note on its frame, live: 0 frames of error across 200 notes at 180 BPM

**Engine.** `soundgraph.zig`: a ninth node kind, the **timeline** — notes placed
at a frame, mixed into its output at that frame *inside* a block, fed from any
one thread through a 512-slot lock-free table; `addTimeline`, `timelinePlace`,
`timelineNow`, `timelineCounter`. `sound.zig`: `rawView`. Four Ring bridges.
**Face.** `base/sound/stzSoundScore.ring` (`stzSoundScore`, and `stzSoundScoreRenderer`, which
renders each distinct note once), `stzSoundScheduler.ring`, `stzMusic.ring`;
`stzSoundGraph.AddTimeline`. Loaded by `stzBase.ring`.
**Guard.** `base/test/sound/sound_mu2_narrated.ring` — **33**. Zig: 6 new in the
graph (65 green in that run).
**Heard.** `sound_mu2_demo.ring` — seven pieces, each written to a WAV and then
played **live on the sound card** through the scheduler: 134 notes, **0 late,
0 frames of underrun**.

### The kill criterion — MET, from Ring and in the engine

| 200 notes at 180 BPM, through a live ring | |
|---|---|
| notes placed / late | **200 / 0** |
| worst onset error, each of the 200 read by a threshold | **0 frames** |
| the ring's output minus the offline render | **0**, every sample |
| 66.7 s of music took | 2.4–3.2 s of wall time |

The consumer drains the ring as fast as it fills, so the producer runs at full
CPU speed rather than a speaker's pace — the hard case for a scheduler that
must stay ahead of it. **The negative sibling** posts the same notes one block
ahead instead of a ring ahead: 193–194 of 200 late across three runs, the worst
by 330–403 ms, and the
engine counts every one. MU0 spike 2's block-start trigger was 4.81 ms late on
average and 9.48 ms at worst; the timeline is 0.

### How far ahead, derived rather than tuned

The producer renders up to a ring (16384 frames, 341 ms) ahead of what has been
played, and keeps doing so between two scheduler ticks. So a note must be posted
a ring plus one tick before its frame. The lookahead is the ring plus 0.5 s: a
tick may be half a second late before one note is. **Every note is rendered
before anything plays** — a wind instrument tunes itself by listening (MU1),
and rendering inside the playing loop would make that loop late by
construction.

### Beats become frames in one place

`stzSoundScore.FrameOf(beat, rate)`: quantise, then swing, then tempo. The offline
render and the live scheduler both call it, so they cannot disagree about when
a note is. Swing warps time piecewise-linearly within each pair of
subdivisions: at 2/3 the off-beat eighth lands at 16000 of 24000 frames, and a
note a quarter of the way through lands a third of the way — it moves with its
neighbours instead of jumping past one.

### The score is data, and its algebra is Euterpea's

`Note`, `Rest`, `Stroke`; `Then` (sequence), `Together` (parallel), `Repeat`;
`On(:Instrument)` (the innermost wins), `Transpose` (a stroke keeps its drum's
pitch); `Tempo`, `Quantize`, `Swing`. Stored flat as events in beats, because a
score is read far more often than it is built. `StzSoundScoreOfQ("c e g c5")` —
names one beat each, the octave carrying as Alda's does, `~` a rest.

### Found, and each one changed the design rather than a number

1. **Prime before start.** The first engine test posted nothing until the
   stream ran, and its first note was late: the producer fills the whole ring
   the instant it starts. A scheduler posts its first window, then starts the
   device.
2. **`On()` on an empty score named nothing.** It was a pure modifier, so
   `StzSoundScoreQ().On(:Drumkit)` followed by twenty strokes sent every stroke to
   the default piano, which refused them. A rule the first user breaks in the
   first line is the rule's fault: `On` now also names what is added after it.
3. **The onset instrument was blind across notes that touch.** Strokes half a
   beat long at half-beat spacing left the last note's tail above the threshold
   where the next began, so every "onset" was found at the edge of the search
   window and the guard reported 8.33 ms. The same run showed the ring's output
   equal to the offline render to the sample, so the placement could not be
   what was 400 frames off. The instrument now refuses a note that does not
   begin in silence, and the guard asserts it refused none.
4. **The live render was not deterministic.** Two overlapping parts, rendered
   live, differed from the offline render by 30 billionths on one run and 60 on
   the next. The engine summed notes in slot order, and which slot a note gets
   depends on which notes had retired when it was placed, i.e. on thread timing;
   f32 addition is not associative. The guard's first version held this to "a
   millionth" and passed, so the bound was hiding the defect. The timeline now
   sums in start order, the order the offline render uses, and the guard asks
   for **equality, twice**: 0 and 0. An engine test pins it with three values
   whose f32 sum depends on order, and **fails with the sort removed** (checked).

### A claim in this plan, corrected

§3 (Gap 2) and §5 said the fix is *"a trigger with a frame offset INSIDE a
block"* applied to any node. That would change every node kind's render loop. A
note does not need it: a note is a buffer the instrument already rendered, and
placing a buffer at frame F is an offset into the block. So MU2 built **one**
node kind and left every other untouched. **What that does NOT give:** a
`setFrequency` or a gain change at a frame inside a block. Those still land at
the top of the next block, and a portamento that has to start on the beat
inherits MU0's 10.7 ms grid. Recorded here, before a phase discovers it.

And MU0 spike 2's open question, *"is 10.7 ms audible as swing?"*, was going to
decide whether sub-block placement got built. MU2's own kill criterion decided
that instead: 1 ms cannot be met on a 10.7 ms grid however early the request
arrives.

### A phase gate that did not run, confessed

§7: *"the one-line test in §4 runs at the close of every phase from MU1 on."*
It could not run at MU1's close because there was no `StzMusicQ`, and **MU1's
STATUS did not say so.** It runs in MU2's guard: `StzMusicQ().ToSound("c e g
c5")` is ready in 0.008 s, and its four notes read back within **0.151 cents**.
The demo plays it live as its first line. A device adds its ring, 341 ms, before
the first note is heard; the browser's is 10 ms (§3).

### What MU2 did NOT do

- **No live loops.** `Loop`, `Every`, and replacing a loop on a boundary are the
  pattern language (MU3). So is rendering notes *while* playing, which a live
  loop needs and this scheduler avoids by rendering everything first.
- **No `DriveWith`** on the scheduler. A reactive-driven score comes with MU3's
  loops, and untested code would be a claim without a guard.
- **No glide in a score.** An event carries one pitch, so the kalangu's squeezed
  pitch is still `ToSoundOfGlide`, outside the score.
- **No universes.** A pitch is a note name plus cents. The mezwed piece in the
  demo uses E4−50 and is labelled *not a ṭabʿ*. That is MU4's.
- **No browser timeline.** `soundwasm.zig` has its own graph and no timeline
  node. That is MU6's.
- **No MIDI or notation export** (MU7).

### Found on the way and not caused here

- **The sample-buffer table is not address-stable under a playing stream.** A
  source node reads `snd.getSample` on the producer thread, which indexes the
  buffer table, while the Ring thread may append to that table (any new sound,
  and every note an instrument renders), and an append that grows it
  reallocates it under the reader. The graph and stream tables were made
  address-stable for exactly this reason (the comment above `MAX_GRAPHS`); the
  buffer table was not. The timeline avoids it by taking `rawView` once, on
  the placing thread. Source nodes are exposed as they have been since SN3.
  Routed, not changed here.
- `future/stzMusic.ring` holds an empty `class stzMusic` with two inspiration
  links (Glicol, Melrose). It is not loaded, so nothing collides today. Loaded
  beside `base/sound/stzMusic.ring`, the class would be defined twice.
- Regression over the sound guards: 713 passed, 3 failed. The three are MU1's: two VC6 convergence checks
  and one SS4, from `fa9251708` (2026-08-22) making `:Muted` a colour-face
  treatment. Nothing else moved, and they wait on
  `STZLIB-MUTED-CROSSPLANE-01`.

### The listener's line

**UNPERCEIVED as of 2026-09-26.** Timing is measured: 0 frames. Whether the
swung groove (`mu2_03`, against the straight `mu2_02`) *feels* like swing, and
whether 2/3 or 0.6 is the right default, is not a number. The verdict goes here
by name.


---

## MU3 STATUS — 2026-09-26. Four live redefinitions, each on its bar, and the output equal to the render sample for sample

**Face.** `base/sound/stzSoundPattern.ring`: Tidal's mini-notation (`~ [ ] [a, b] <a b>
* / ? ! @`), queried one whole cycle at a time, and the algebra `Fast`, `Slow`,
`Rev`, `Every`, `Off`, plus `ToScoreQ`, where a pattern becomes a score.
`base/sound/stzSoundLive.ring`: live loops (`LiveLoop`, `LiveLoopOn`, `LiveLoopOf`,
`Every`, `Silence`, `Hush`, `WaitCycles`, `DriveWith`, `OnCycle`) on a device,
or drained here into a sound. `stzMusic` carries the same verbs. `stzSoundScore`
gains `NoteAt`, `StrokeAt`, `SetLength`.
**Engine.** `soundgraph.zig`: a timeline note carries a TAG (its loop), and
`timelineCancel(tag, from)` withdraws that loop's notes that have not started;
a note already sounding is refused and counted, never cut. Two Ring bridges.
**Guard.** `base/test/sound/sound_mu3_narrated.ring` — **41**. Zig: 1 new (66
green).
**Heard.** `sound_mu3_demo.ring` — two live sets, each drained to a WAV and
then played **live on the card**, the console printing each cycle as it is
heard: 11 definitions and redefinitions, each landing on the cycle it
announced; late 0,
underruns 0, mid-cycle 0.

### The kill criterion — MET

**"A change never lands mid-bar."** 120 BPM, 2 loops, 10 cycles, four changes
made at chosen *heard* positions:

| change | heard at | posted up to | lands on |
|---|---|---|---|
| tune → a new phrase | 2.50 | 3 | **3** |
| beat → `Every(2, :Rev)` | 4.00 | 5 | **5** |
| beat → `bd*2 [~ sn] hh?` | 5.95 | 7 | **7** |
| tune → silence | 6.95 | 8 | **8** |

The captured output, minus a render built **independently** from the patterns
and the four landing cycles, is **0 in every sample**. The engine withdrew 16
posted notes and refused **0** withdrawals, so no change landed mid-cycle. 0
notes were late.

**"The console and the speakers agree."** Notes are posted a ring, a cycle and
0.5 s ahead, so at these changes the posted cycle was up to **2 cycles** ahead
of the heard one. A console that printed at posting time would run that far
ahead of the sound, which is VC4's disagreement. This console reads the
*heard* clock (frames the device consumed) and reports the *ledger*: what was
posted for **that** cycle, not the latest definition. All 10 lines name the
versions the speakers played, each printed at most one drain (worst 3904
frames, 81 ms) after its boundary. **The disagreement is 0 cycles.**

### Rendering while playing — measured on the card

MU2 rendered every note before it played. A live loop cannot: a new pattern's
notes are rendered while the old ones sound. `LiveLoop` renders the new
pattern's distinct notes over its period *before* it touches what is playing,
and the posting horizon (ring + cycle + 0.5 s = 2.17 s at 180 BPM) is what the
render may take. On the card, a mezwed loop (5 distinct notes, each tuning
itself by listening) rendered in 0.14–0.23 s while a kit played: 0 late, 0
underruns. **A capture drained on this thread cannot test this**, because it
stalls with the render. So the guard asks the card, and says why.

### How long a change takes to arrive, stated

A change lands on the first cycle whose start the producer has not rendered,
plus a 0.1 s margin. The producer runs up to a ring (341 ms) ahead. A change
therefore arrives between that ring-plus-margin and one full cycle more after
it is typed: up to **~2.45 s at 120 BPM** on the native path. The browser's ring
is 10 ms (§3), and its live page is MU6's.

### Found, and each one changed the design

1. **The transport's `DriveWith` has never worked** (found, not caused; see
   below). Ring's anonymous functions see no locals, so a callback that uses a
   captured `_me_` fails on its first tick. `stzSoundLive.DriveWith` registers the
   session **by pointer in a global list**, and the timer calls one global
   function. The guard drives a session through `stzReactive` for 3.2 s and a
   redefinition made from a timer lands on its cycle.
2. **A redefinition changed the order of a sum.** Two loops that start notes on
   the same frame were summed in placement order, and a redefined loop is
   posted again later, so after a change the live output differed from the
   render in the last bit. The timeline now breaks start-frame ties by TAG,
   then placement. **Removing the tag tie-break turns scene 4's check red**
   (checked, and restored).
3. **`?` kept 2 of 12.** The first hash was a sum mod a prime and one multiply,
   read from its low digits. It is now folded input by input and decided from
   the high end: 1999 of 4000, and the same text keeps the same notes.
4. **The demo hid a refusal.** Its reed phrase reached B♭5 (932 Hz), above the
   mezwed's 900 Hz range. The redefinition was refused, the old phrase kept
   playing (correct), and the console showed `reed v1` for four more cycles
   while the script believed it had changed. The demo now prints every
   change's landing or its refusal.
5. **Ring traps, each met in this phase:**
   - `loop` is a keyword, so the plan's `oM.Loop(...)` cannot be written. It is
     `LiveLoop`, Sonic Pi's word.
   - `new stzSoundLive` without parentheses does not run `init`.
   - `oR` is the keyword `or`.
   - `x = [ :fast, x, k ]` produced a node missing its last element, so it now
     goes through a temporary.
   - An object handed to `init` is copied, so the renderer never saw a later
     tempo. `SetTempo` makes a new renderer, and refuses once loops exist.

### Claims in this plan, corrected

- §4 `oM.Loop(:melody, ...)` → `oM.LiveLoop(:melody, ...)`, because `loop` is a
  Ring keyword; `oM.Loop(:drone, "d2").With(:Oud)` →
  `oM.LiveLoopOn(:drone, "d2", :Oud)`.
- §6 MU3 says the parser is built *"on stzString"*. It is a character walk of
  its own. `stzString` is another plane's file, and a pattern parser needs
  nothing from it. Recorded, not hidden.
- The kill criterion allowed the console and speakers to disagree by *up to*
  one cycle. They disagree by **0**, because the console is fed from the
  heard clock. The one-cycle allowance was never needed.

### What MU3 did NOT do

- **No `jux`** (§1.1): it is a stereo copy, and the timeline mixes every note
  to all channels with no pan per note. That is an engine change.
- **No euclidean rhythms** `bd(3,8)`, fractional `*`/`/` factors, or sample
  banks: not in MU3's count.
- **No live tempo change**, and **no swing in live loops**. `SetTempo` is
  refused once loops exist.
- **No typing surface.** Here the "live coder" is a script of redefinitions
  paced by `WaitCycles` or `stzReactive` timers. A text box that re-evaluates
  on Enter is the browser page's (MU6).
- **No universe** (MU4): the set in `mu3_01` is labelled *not a ṭabʿ*.

### Found on the way and not caused here

- **`stzSoundTransport.DriveWith` fails on its first tick.** It calls
  `RunEvery(0.02, ...)`, but `RunEvery` takes **milliseconds**, and its
  callback uses a local `_me_` that Ring's anonymous functions cannot see.
  Reproduced: "Using uninitialized variable: _me_". No guard ever drove a
  transport reactively. Routed as `STZLIB-TRANSPORT-DRIVEWITH-01`, not changed
  here.
- `STZLIB-SNDTABLE-RACE-01` (MU2) is still open. `stzSoundLive` uses the timeline,
  which takes raw views and is not exposed to it.
- Regression over the sound guards: 754 passed, 3 failed: MU2's 713 plus MU3's 41, and
  the three are MU1's `:Muted` cross-plane failures (VC6 x2, SS4 x1). Nothing
  else moved.

### The listener's line

**UNPERCEIVED as of 2026-09-26.** Every change lands on its bar, and that is
measured. Two questions are not numbers: does it *feel* live, and is a change
that arrives up to a bar and a third after it is typed quick enough, or does
it feel like typing into a letterbox? The verdict goes here by name.


---

## NAMES — 2026-09-26, before MU4. A class carries its domain; the generic name is kept for the abstraction

**The author's rule:** a class whose name is a concept every domain has
(pattern, score, scheduler, instrument, universe) but whose body is about ONE
domain carries that domain in its name. The generic name is kept for an
abstract class any domain can reuse. So, in this plane:

| was (MU1–MU3) | is | abstract counterpart |
|---|---|---|
| `stzPattern` | `stzSoundPattern` | **`stzPattern`** — built now, `base/common/stzPattern.ring` |
| `stzScore`, `stzScoreRenderer` | `stzSoundScore`, `stzSoundScoreRenderer` | `stzScore` — planned, not built |
| `stzScheduler` | `stzSoundScheduler` | `stzScheduler` — planned, not built |
| `stzInstrument` | `stzSoundInstrument` | none: no domain-free "instrument" was found worth a class |
| `stzLive` | `stzSoundLive` | `stzLive` — planned, not built |
| `stzUniverse` (MU4, not yet written) | `stzSoundUniverse` | decided when MU4 is built |

The constructors follow (`StzSoundPatternQ`, `StzSoundScoreQ`,
`StzSoundScoreOfQ`, `StzSoundSchedulerQ`, `StzSoundInstrumentQ`,
`StzSoundInstruments`, `StzSoundLiveQ`), and so do the files. `stzMusic` and
`StzNoteToHz` already name their domain and are unchanged. The earlier STATUS
sections above now read with the new names. The memos and CONCLUSIONS lines of
MU1–MU3 keep the old ones, because they are the record of what was true then.

**What was built, and why only one.** `stzPattern` holds the whole grammar, the
cycle query and the algebra (Fast, Slow, Rev, Every, Off). None of it knew what
a word meant; only three methods did (`_Value`, `_Shift`, and the octave that
carries). Those three are now hooks, and `stzSoundPattern from stzPattern`
overrides them. The abstraction was already sitting in working code, so
extracting it was a cut, not a design. MU3's guard proves the base is one:
scene 10 defines a light-cue pattern from another domain in eight lines,
inheriting everything else.

The other three counterparts (`stzScore` as Euterpea's domain-free algebra of
timed events; `stzScheduler` as "post ahead of a consumer's clock and count
what is late"; `stzLive` as a loop redefined on a cycle boundary) are real
abstractions. But each is a design to extract and prove, not a rename, so they
are in the library-wide plan below and not half-built here. **No hollow
abstract class was written**: a generic name with nothing behind it would
claim a reuse nobody has shown.

**The rest of the library** was surveyed for the same defect. The findings, and
the plan to fix them, are Central's prompt 50
(`softanza/prompts/50-stzlib-domain-names.md`), to be executed later, plane by
plane, by each plane's own session.


---

## MU4 STATUS — 2026-09-26. Eight universes declared as data, the thin parts left thin, and all eight UNPERCEIVED

**Face.** `base/sound/stzSoundUniverse.ring` reads a declaration and renders a
phrase inside it: pitch by direction, ornaments, accents, the cycle's layers.
It adds `Check` (movement rules), `SentenceQ` (a tonal language, drummed) and
`NoCycle`; `stzSoundDegreePattern` is the MU3 grammar with degrees as words;
`StzMusicQ().In(universe, mode, tonic)` with `PhraseToSound` and `PlayPhrase`.
`stzSoundScore` gains `GlideAt`, a note whose pitch moves over its length.
**Data.** `base/sound/universes/*.ring`, eight files. Each is a Ring list and
nothing else: the guard asserts **0 lines of logic** across all eight. Each
carries `:sources`, a `:confidence` per part, and `:listener = "UNPERCEIVED"`.
**Guard.** `base/test/sound/sound_mu4_narrated.ring` — **32**.
**Heard.** `sound_mu4_demo.ring`: the same phrase in every universe, plus the
kalangu sentence. 14 WAVs, each played live.
**Engine.** Unchanged: the glides MU1 built (bow, wind, membrane) were enough.

### The eight, and what each declaration rests on

| universe | modes | cycles | sources | confidence |
|---|---|---|---|---|
| western | major, minor | four, waltz | 12-TET, by definition | high |
| maqam | rast, hijaz | maqsum | maqamworld; Marcus (1989) | medium: textbook 24-TET, no regional intonation |
| tunisian | dhil, sika, sika_hijaz, rasdaldhil | btayhi, barwal, draj, khafif, khatm, fazzani | Snoussi (2003) and d'Erlanger vol. 5, via Beyhom & Makhlouf (2021); CNRS/Zghonda (1992) | skeletons high, **cents derived not measured**, strokes low or **absent** |
| niger | zarma | tende, takamba | Schmidt (2018); Newman (1996, 2007); Surugue (1973) | tende high, tones medium-high, **scale low** |
| raga | yaman | teental | Bor's *Raga Guide* via Wikipedia; ragakosh | swaras high, tuning medium (a textbook just reading) |
| gamelan | slendro (30-gamelan average), kanyutmesem, slendro_paired | lancaran | Surjodiningrat et al. (measured); Lindsay (1992) | measured; the pairing is a stated combination |
| westafrican | **none**: a rhythm | standard bell | Toussaint; Agawu; A. M. Jones | high |
| flamenco | phrygian | solea | standard | high for the compás |

The sources were gathered by a research pass that was told to leave a gap
empty rather than fill it. Where it found nothing, the declaration says **not
found**, and the render plays silence or refuses. It never invents.

### Measured, not asserted

Every interval below was read by the fine pitch instrument off two notes
rendered on that universe's own instrument:

| interval | declared | measured |
|---|---|---|
| Rast's half-flat third | 350 | **350.046** |
| Hijaz's augmented second | 300 | **300.027** |
| Tunisian Sika's three-quarter step | 150 | **149.947** |
| the "Tunisian hijaz" five-quarter step | 250 | **249.986** |
| Rasd al-Dhil, e-half-flat → f-half-sharp | 200 | **199.946** |
| Yaman's tivra Ma (45/32) | 590 | **591.407** |
| slendro's **stretched** octave (30-gamelan average) | 1208 | **1208.000** |
| slendro nem, average vs. Kyai Kanyut Mesem | 18 apart | **18.000** |

Worst: 1.41 cents. Movement is checked too:

- Rast goes up through 1050 and down through 1000.
- The flamenco third is 400 going up and 300 coming down.
- Yaman's rule flags Pa taken going up.
- Rasd al-Dhil flags the fourth taken going down (Ghānim, 1932).

The cycles land where their sources put them: the bell on 1 3 5 6 8 10 12,
soleá's accents, lancaran's gong, kenong, kempul and ketuk, and the tende's
strokes and claps. Ornaments are **heard**: Yaman's meend on the flute starts
near Sa (295.8 Hz) and ends near Re (322.8 Hz). The paired slendro beats at
**6 Hz**, counted off the envelope. The kalangu speaks *sannu da zuwa* as
L H L H L, with 'nu' at 220.001 Hz and 'da' at 165.002 Hz; the long *waa* is
twice as long.

### The honest result the guard asserts instead of hiding

**Snoussi's Dhil and textbook Rast are the same seven numbers** on the
quarter-tone grid. The sources locate Dhil's difference in things no fixed
degree list carries:

- a third that *moves*: 300, 350 and 400 in Tarnān's 1932 recording;
- a "very high" seventh.

Both are declared as `:variants` and not rendered as if settled. So the
same phrase gives **seven** distinct renderings in eight universes, not eight
(the eighth, the West African timeline, refuses a melody). The one question
the sources could not answer is also the plainest one to put to the author:
**does `mu4_04` sound like Dhil, or like Rast?**

### Found, and each one changed the design

1. **A rhythm universe has no mode, so it had no tempo.** The first cut read
   tempo and melody from the mode. The West African bell then played at the
   score's default 120 rather than 360, and the score counted a refusal. They
   are now read from the universe first.
2. **The cycle clipped the melody.** Four colotomic strokes and a melody note
   on one beat peaked at 1.1. Layers now sit under the melody (0.45 against
   0.6/0.9), and every universe peaks at 0.7 or below.
3. **A claim about teental was wrong, and the data was right.** The guard's
   first version said the bass is absent on beats 9–12. The source's theka
   has khali's *dha* on 9 and *tin tin ta ta* on 10–13. The pattern followed
   the source; the sentence about it did not. It failed, was corrected, and
   the failed version is kept in the guard.
4. **The kalangu read 0 Hz.** A score renders stereo and the pitch reader
   reads mono. The guard now reads the mono sum.
5. **Ring traps.** Case-insensitivity again: `_b_` was `_B_` and `_l_` was
   `_L_`, so the first render placed no rhythm at all. `oK` is `ok` and `oN`
   is `on`, and `Lines` collided with a library function.

### Claims in this plan, corrected

- §6 MU4 asks for Tunisian ṭubūʿ *"each with its own declared tuning rather
  than the maqam's"*. From the sources found, **Dhil's is not its own on
  paper**; its own lies in intonation the sources describe but do not
  measure. Sika's own (the Tunisian ḥijāz) *is* declared.
- §6 asks for *"the nūba's five īqāʿāt"*. Their **meters** are declared.
  Strokes were found for two, on amateur pages. Three play silent.
- §6 asks for slendro *"with paired detuning"*. Pairing (ombak) is **Balinese**,
  not Javanese. It is a third mode, and the file says the combination is its
  own.
- §6 asks for *"a Zarma pentatonic"*. The only source for it is user-written.
  It is declared as a **placeholder** marked LOW, and Surugue's touched-partials
  hint is written as an inference, not a mode.
- §4's `oM.In(:Maqam, :Rast, :D)` then note names with `+` for half-flat
  became `In(...)` plus a phrase in **degrees**, so one phrase means something
  in every universe. Quarter tones by name remain `e-50`.

### What MU4 did NOT do

- **No sayr engine.** A maqam's path (which jins to move to, and how to
  return) is declared as text, and only its checkable fragments (a flat
  seventh descending, avoided degrees) are rules.
- **No kan swar, no Tunisian ornaments**: no reliable source was found, so
  none were declared.
- **No sitar, tabla, bansuri, gong or palmas.** Each stand-in is named in its
  file.
- **No text → drum verb.** `SentenceQ` renders a *declared* sentence; turning
  arbitrary Hausa text into tones is MU7's row.
- Regression over the sound guards: 793 passed, 3 failed: 761 plus MU4's 32, and the
  three are MU1's `:Muted` cross-plane failures. Nothing else moved.

### The listener's line

**UNPERCEIVED, all eight, as of 2026-09-26.** The kill criterion is a person
from each tradition, recorded by name. For Tunisia and Niger that person is
more than a check: where the sources ran out, they are the only source this
declaration has. Their corrections go into the universe files, by name.


---

## MU5 STATUS — 2026-09-27. SAPI's voice is human but cannot hold a note; retuned, it holds to 1.6 cents -- and the author heard it sing. Sing() is OPEN for it

**Engine.** In the seam (`soundinstr.zig`, std only, compiles for
wasm32-freestanding: a 4.7 KB object with an exported entry point),
`renderVowel`: a Rosenberg glottal pulse, differentiated, with a vibrato that
arrives by 0.35 s and a breath that sounds only while the folds are open,
through five parallel formant resonators. It uses the **Csound manual's
formant table** (tenor below 330 Hz, soprano above), fetched and checked
against the manual rather than remembered: the tenor "o" bandwidths I
remembered were wrong. `sound.zig`: `vowelOf`. Two bridges. It is **not** a
21st instrument: MU1's twenty are a record with their own guard, and a voice
is judged by a bar no number clears.
Also in the seam, **`retune`**: PSOLA. It tracks the glottal periods of a
spoken syllable with a short-window period tracker, marks each cycle, and lays
two-period Hann grains back down at the note's period. `sound.zig`:
`retuneOf`. Three more bridges.
**Face.** `base/sound/stzSoundFormantVoice.ring` (`Vowel`, `VowelGlide`,
`VowelsQ`, `FormantsOf`) and `base/sound/stzSoundRetunedVoice.ring`
(`Syllable`, `LineQ`, `Spoken`). Each has a **`Sing()`** gated on its own
entry in `StzSoundSingingVerdict()`, which is declared data.
**Guard.** `base/test/sound/sound_mu5_narrated.ring` — **20**. Zig: 2 new.
**One line.** `StzMusicQ().Sing("la la la", "c4 e4 g4")`: whichever voice the
author called singing, which today is the retuned one.
**Heard.** `sound_mu5_demo.ring`: eight WAVs, each played live. One is SAPI
unretuned, four are the formant voice, three are SAPI retuned.

### (a) SAPI's pitch control — it cannot hold a note (its VOICE was never the problem)

Zira (en-US), slowed to `x-slow`, `<prosody pitch>` per syllable:

| asked | got (median) | off | wander within the syllable |
|---|---|---|---|
| −6 st | 148.4 Hz | **407 cents** | 286 cents |
| −2 st | 159.5 Hz | 131 cents | 433 cents |
| +2 st | 176.1 Hz | −98 cents | 499 cents |
| +6 st | 196.0 Hz | −313 cents | 430 cents |

Asked for ±6 semitones, it moves about ±2.5. An absolute `150Hz` is ignored.
Within one syllable the pitch moves by hundreds of cents, because it is
*intoning speech*. The bar was 20 cents. The guard asserts this as a record:
if a future voice held pitch, that check would go red.

**The first version of this section called SAPI "rejected", and the author
corrected it.** Having heard it, the author said SAPI's voice is *"very close
from real human voice"* (2026-09-27). What had failed was its pitch control,
not its voice. The file is now named
`mu5_01_sapi_speaks_but_cannot_hold_a_note.wav`, and the author's words are
in the verdict data.

### (a') SAPI's own voice, retuned — HOLDS, measured

Kept the voice, took the pitch: SAPI speaks the syllable slowly, and PSOLA
holds it on the note (`vibrato 0` for the measurement).

| note | shift from SAPI's own 187 Hz | held at | spread (0.5–0.9 s) |
|---|---|---|---|
| G3 | +80 cents | 0.076 | 0.985 |
| C4 | +580 | −1.098 | 2.351 |
| E4 | +980 | −0.584 | 1.238 |
| G4 | +1280 | 0.346 | 0.985 |
| C5 | +1780 | −1.568 | 2.206 |

**Worst 1.568 cents, against (a)'s bar of 20.** The engine test proves the
same on a synthetic syllable whose pitch *falls* 180 → 140 Hz as speech does:
172 periods tracked, held at 220 Hz within 0.778 cents. What no number here
says is how large a shift can go **before it stops sounding human**:
`mu5_08` walks G3 → G5 for the author's ear. The words are SAPI's, consonants
included, which the formant voice cannot do.

### (b) the formant voice — on its pitch, and its vowels are the vowels

| | |
|---|---|
| 5 vowels × 4 pitches (110–523 Hz), no vibrato | worst **0.492 cents** (Zig: 0.218 over 147–660 Hz) |
| under a ±25-cent vibrato, read evenly over 4 cycles | centre **−0.325 cents** |
| first formants at 110 Hz, pre-emphasised | a 660 (650) · e 440 (400) · i 220 (290) · o 440 (400) · u 330 (350) |
| second formants | i **1870** (1870) · a **1100** (1080) |
| a glide 220 → 330 over 1.2 s | on the log curve within 1.4% at both readings |

At 110 Hz the harmonics are 110 Hz apart, so a formant is read to the nearest
harmonic. For **i**, the nearest reading landed on the harmonic *below* (220,
70 Hz off the table's 290) rather than the one above (330, 40 off). That is
inside the one-harmonic tolerance, and it is stated here rather than rounded
away. The five first formants fall from open **a** to closed **i**: five
vowels, not one timbre.

### (c) Sing() — OPEN for the retuned voice, by the author's word

`StzSoundSingingVerdict()` has one entry per candidate voice. **`:retuned`
reads SINGING**: *"the retuned voice is somehow singing, open Sing()"*, from
Mansour Ayouni (the Principal), 2026-09-27. Its `Sing("la la la", "c4 e4 g4")`
now sings, and the guard holds what it sings to the same bar the voice was
measured by: each note within **9.4 cents** under a 20-cent vibrato, against
20. **`:formant` still reads UNPERCEIVED**, and its `Sing()` stays shut; its
reason carries the SAPI measurement, so (a) is not tried again blind. The
author's word was *"somehow"*, and it is recorded as said: the gate is open,
and how well it sings is still an open question. One line per voice changes
a verdict:

- `:verdict = "SINGING"`, with the author's name and words, opens `Sing()`,
  which sings each syllable as its vowel. There are no consonants: "la" is
  sung as "a".
- `:verdict = "NOT SINGING"` closes it for good and defers singing to the
  neural tier, in writing, exactly as the plan's (c) says.

### Found, and each one changed the design or the reading

1. **The pitch reader was biased by the vibrato, not the voice.** Sixteen
   readings 50 ms apart sample a 5.5 Hz vibrato unevenly and reported up to
   8 cents the voice does not have. Vibrato depth is now a parameter: the
   pitch is proven with it off, and the centre is read evenly over whole
   vibrato cycles.
2. **A formant is not the loudest harmonic.** Without pre-emphasis, the
   loudest harmonic of **i** and **o** was the second, because the glottal
   source's own spectrum falls with frequency. Formant analysis pre-emphasises
   by +6 dB per octave for exactly this reason; the guard now does, says so,
   and keeps the failed version in its text.
3. **A glide spans its whole note.** The guard's first check asked for 330 Hz
   at 1.05 s; the curve is due at 314 there. Each reading is now held to the
   curve at its own moment.
4. **The escaped-newline trap** (MU1's) turned a `\n` in a heredoc into a
   real newline inside a Zig string. Fixed by hand, again.
5. **Ring died with no message.** `return _o_.ToMonoQ()` inside a method (the
   Q form returns `This` of a LOCAL object) ended the process with exit 1 and
   nothing printed. In place, then return the object.
6. **A release would have freed the note it returned.** `_r_ =
   _o_.ResampleToQ(...)` followed by `_o_.Release()`: the Q form returns the
   same object, so the release frees the buffer `_r_` holds. Found by reading
   the code while fixing 5, not by a crash, and fixed the same way.
7. **The disk was full: 10 GB free, and builds need 10.** The shared
   checkout's `.zig-cache` held 56.5 GB. Only entries untouched for two days
   were deleted (55.1 GB), because other sessions may be building in that tree.
   Free space is now 65 GB.

### Claims in this plan, corrected

- §6's (a) asks whether SAPI *"holds pitch within 20 cents"*. It is not
  close: a 20-cent bar against a 400-cent miss and a 500-cent wander. The
  plan's wording suggested a near miss; the measurement is not one.
- §6's (b) *"does it read as a voice to the author?"* is kept exactly as
  written: no number here answers it, and `Sing()` waits for the answer.

### Found on the way and not caused here

- **SAPI fails after the audio device has been probed in the same process.**
  `CoInitializeEx` returns 0x80010106 (RPC_E_CHANGED_MODE), because the device
  DLL has already initialised COM in another threading mode, and the voice
  then reports **no voices at all**. The demo's first run skipped (a)
  **silently** for this reason. The demo now creates the voice first and
  prints a refusal if (a) cannot be heard. The fix belongs in `voice.zig`
  (treat RPC_E_CHANGED_MODE as "COM is available, do not uninitialise"). Routed
  as `STZLIB-VOICE-COMODE-01`, not changed here.
- The Tunisian universe's listener line was false ("UNPERCEIVED") after the
  Principal heard its examples on 2026-09-26. It now records who heard it and
  what they said, and MU4's guard checks it.
- Regression over the sound guards: 813 passed, 3 failed: 793 plus MU5's 20, and the three
  are MU1's `:Muted` cross-plane failures. Nothing else moved.

### The listener's line

- **SAPI's timbre, HEARD 2026-09-27** by the author: *"very close from real
  human voice"*.
- **SAPI retuned (`mu5_06` to `mu5_08`): HEARD 2026-09-27** by the author:
  *"the retuned voice is somehow singing, open Sing()"*. **Sing() is open.**
  Still owed: in `mu5_08`, where does it stop sounding human?
- **The formant voice (`mu5_02` to `mu5_05`): UNPERCEIVED.** Its `Sing()`
  stays shut until the author rules on it.


---

## MU6 STATUS — 2026-09-27. The same notes in the browser, sample for sample; 58 ms from key to sound -- and the author played it: "it feels like an instrument"

**Engine.** `stz_wasm_entry.zig`: the twenty instruments exported to `stz.wasm`
(`stz_snd_note`, `_note_frames`, `_scratch_frames`, `_inst_*`,
`_measure_hz`). The caller owns the buffers: the module's heap is 8 KiB, so
`stz-music.js` grows the JS-owned memory and passes a region above everything
the module uses. `build.zig`: the wasm stack is **set** to 1 MiB, not assumed,
because two engines keep 16 KiB delay lines on it. The module's minimum memory
stays at 19 pages, under the 32 the existing pages allocate.
**Browser.** `webaudio/stz-music.js`: notes through wasm; the mini-notation
**ported line for line** (grammar, per-cycle query, the deterministic `?`, the
carrying octave, `StzNoteToHz`); live loops posted a whole cycle ahead of
WebAudio's clock; the browser's own latency, reported.
`webaudio/music.html` is **the instrument**: a keyboard (A–L = degrees 1–9 of
any declared universe and mode, in its own tuning), three live loops you
redefine while they play, and the latency next to the native path's.
**Guard.** Native half: `sound_mu6_narrated.ring` — **4**. It *writes* the
browser's answers: `mu6_notes_expect.json`, `mu6_patterns_expect.json` and
`mu6_universes.json`. Browser half: `webaudio/mu6_guard.html` — **8**, run in
the built-in browser.

### The two tiers agree

| | |
|---|---|
| twenty instruments, wasm vs native | **20/20** same frame count; **20/20 identical to 12 decimal places** at every compared sample (6 per note + a 97-step sum) |
| the JavaScript pattern port vs the Ring classes | **12/12** patterns, cycles 0–3: onsets, lengths, names, Hz, and which `?` notes survive |
| a wasm piano A4, read back in the browser | **−0.011 cents** |
| isolated strokes scheduled offline (`bd ~ sn ~`) | **0 frames** of onset error |
| the dense loop (`bd hh sn hh`), whole 4 s render vs a hand-placed mix | worst difference **1.4e-8**; the same mix one frame late differs by **0.63**, so the check can see a single frame |
| SS5's earcon guard, re-run on the new `stz.wasm` | **26/26**: the new exports and the stack broke nothing |

"12 decimal places", not "bit-identical": the fixture prints samples to 12
places, which cannot pin a float32 near zero, so that is the claim made.

### The latency, as the browser reports it

| | |
|---|---|
| **this machine, the built-in browser pane** | base **10.0 ms** + output **48.0 ms** = **58 ms** key to sound |
| the key handler itself (JS, key → `start()`) | **0.10 ms** |
| the native path (S.5) | **~419 ms**: a 341 ms ring plus the device |

**The plan's §6 said "10 ms from key to sound", and on this machine that is
not what the browser reports.** The base latency is 10 ms; the output stage
(the OS mixer and device) adds 48. That is **7× faster than native**, and the
page shows both numbers side by side as §6 asked. Whether 58 ms *feels like
an instrument* is the kill criterion, and it is the author's. Other browsers
and exclusive-mode audio devices may report less; this page reports whatever
they say.

### Found, and each one changed the design or the reading

1. **A note is megabytes; the wasm heap is 8 KiB.** The caller owns the
   buffers, in pages it grows itself.
2. **The stack was a default nobody had read.** Two engines keep 16 KiB delay
   lines on it; the stack is now declared (1 MiB), and the module's minimum
   memory was checked (19 pages) so the older pages still load.
3. **MU2's lesson, met again in the browser.** Notes that touch leave a tail
   above the threshold where the next begins, and the first onset check read
   "400 frames", the edge of its search window. Two instruments now: isolated
   onsets by threshold, and the whole dense render against a hand-placed mix,
   with the one-frame shift proving the comparison can see a frame.
4. **The guard's first identity claim was stronger than its fixture.** 12
   printed decimals cannot certify float32 bits near zero; it says "12
   decimal places".

### Claims in this plan, corrected

- §6 MU6: *"10 ms from key to sound"* became **58 ms reported** on this
  machine's built-in browser (10 base + 48 output). The part §6 controls,
  having no ring, is met; the output stage belongs to the machine.
- §5's `stz-music.js` *"the same verbs in the browser, over the same wasm"*:
  the **notes** are the same wasm, and the **pattern language** is a port, held
  to Ring by a fixture rather than shared, because the grammar is Ring code
  and not seam arithmetic. A port is a second author, and the fixture is what
  keeps it honest.

### What MU6 did NOT do

- **No universes' rhythm cycles on the page**, only their tunings on the
  keyboard: the cycles' drum layers are Ring declarations not yet exported.
- **No Sing() in the browser**: the retuned voice is SAPI, which is Windows.
- **No AudioWorklet for the loops.** WebAudio's `start(when)` is
  sample-accurate on its own, and notes are pre-rendered buffers. The worklet
  path (SS5, SN6) remains for the graph.
- **No MIDI keyboard** (hardware is out, §5). The computer keyboard and the
  pointer are the instrument.
- Regression over the sound guards: 817 passed, 3 failed: 813 plus MU6's native 4, and the
  three are MU1's `:Muted` failures. The browser half, `mu6_guard.html`: 8/8.

### The listener's line

**HEARD AND PLAYED 2026-09-27 by Mansour Ayouni (the Principal): "it feels
like an instrument".** That is MU6's kill criterion, met by the only judge
§6 names, and at 58 ms, not the 10 the plan wrote. The latency the plan
feared was not the one that mattered: the 341 ms ring is. To play it, serve
`base/test/sound/webaudio/` (or the untracked copy the author was given,
`base/test/sound/mu6_play/`), open `music.html`, and press *Start sound*.


---

## MU7 STATUS — 2026-09-27. The four transforms on one stzSoundScore, no adapter -- and the author heard the sonified series: "it is music". Text → drum refuses until a Hausa speaker hears it

**Engine.** In the seam, `detectPitch`: McLeod's normalised square
difference over the whole range asked (50–2000 Hz), with **no guess**. It
takes the first peak within 0.9 of the highest (which keeps it off the octave
below) and returns its clarity as `last_clarity`. `sound.zig`: `pitchOf`. Two
bridges.
**Face.**

- `stzSoundUniverse.SonifyQ` (RENDER). A series becomes a melody: the lowest
  value on degree 1, the highest two octaves up, or fewer when the instrument
  is short.
- `ToneSyllables`, `DrumTonesQ`, `SayOnDrum` (text → drum).
- `stzSoundTranscriber` (RECOGNISE).
- `stzSoundScore.PitchedEvents`, `RangeInCents`, `Density`, `Contour` and
  `BestModes` (ANALYSE).
- `stzSoundNotation.ToABC`, `ToMusicXML`, `ToMidiFile` and `Losses`
  (NOTATE).

**Guard.** `base/test/sound/sound_mu7_narrated.ring` — **25**. Zig: 1 new.
**Heard.** `sound_mu7_demo.ring`: one series in Rast, the West and slendro,
the Rast melody heard back from its own sound and played again, the kalangu
saying *sannu da zuwa*, and the heard-back score as ABC, MusicXML and MIDI.

### The kill criterion — MET, and the missing steps named

`data → SonifyQ → stzSoundScore → ToSound → stzSound → TranscribeQ →
stzSoundScore → BestModes / Contour / ToABC / ToMusicXML / ToMidiFile`.
Every arrow takes what the last one returned, unchanged. There is **no
adapter**.

| the round trip, ten notes of Rast | |
|---|---|
| notes rendered / heard back | **10 / 10** |
| worst onset error | **0.042 ms** |
| worst pitch error, the half-flat third included | **1.869 cents** |
| lowest confidence (the reader's clarity) | **0.948** |
| the contour | **identical**: U D U D U D U D U |
| best-fitting declared modes | **Rast and Dhil, tied** at 0.31 cents off (MU4's "the same seven numbers on paper", found again from the SOUND) |
| the nearest Western mode | 15.25 cents off |
| noise | **0** pitched notes transcribed |

**The missing steps, named as VC6 named its:**

1. Sound → score cannot say **which** drum stroke a hit was. An unpitched
   onset is kept (`Unpitched`) with its time, and never guessed into a dum
   or a tak.
2. The transcriber is **monophonic**: it hears one *new* note at a time, and
   a chord comes back as its loudest new pitch.
3. ABC and MusicXML cannot carry slendro or a just-intoned Yaman. Such
   pitches are written at the nearest quarter tone and **counted** in
   `Losses`. MIDI carries them: a slendro score survives MIDI within **0.072
   cents**, and its MusicXML reports *"a pitch sits 24 cents from the
   nearest quarter tone"*.

### Notation, checked by something other than its writer

- **ABC**: Rast's half-flat third is written `_/E`, ABC 2.1's own
  quarter-tone mark.
- **MusicXML**: well-formed by the guard's own check **and by Python's XML
  parser** (11 notes, 3 measures, `<alter>-0.5</alter>`).
- **MIDI**: read back by a reader written apart from the writer (it handles
  running status, which the writer never uses): 10 notes, 96 BPM, every pitch
  (key plus bend) within 1 cent. **Python confirms** the file's three track
  chunks account for all 585 bytes.

### Text → drum (Niger's row) — GATED, by the plan's own words

*"sànnu dà zuwàa"*, tone-marked as Newman's dictionary marks it (no mark =
High, grave = Low, circumflex = Falling), is read as `san:L nu:H da:L zu:H
waa:L`, heavy *waa* two units. That is the declared sentence's contour
exactly, and the kalangu plays it at 220.001 / 165.002 Hz. **Everyday Hausa,
which marks no tones, is refused**: read as all-High it would lie. And
**`SayOnDrum` refuses**, because the plan says text → drum is speech only if a
Hausa speaker hears it back. `DrumTonesQ`, the contour honestly named, is
what is offered until one has.

### Found, and each one changed the design

1. **SN5's onsets were the wrong instrument, again** (MU0's finding). Spectral
   flux with a 43 ms window missed the first note, skipped others, and put the
   rest up to a window early, so pitches were read inside the previous note.
   Onsets now come from the first difference's energy in 5 ms hops, refined
   to the sample.
2. **Two notes ringing together are periodic at their common period.** C4
   under G4 repeats at 130.8 Hz, and the first transcription read G4 as C3:
   right about the mixture, wrong about the note. Each reading and its
   multiples are now scored by which harmonics GAINED energy at the onset.
3. **A level threshold placed notes 6 ms early** over a ringing tail. The
   refinement now reads the attack's edge (the first difference), not its
   level.
4. **The sonifier asked the oud for a note it cannot play** (degree 14 of Rast,
   959 Hz, against the oud's 700). It was refused and the melody came out one
   short. `SonifyQ` now fits its span to the instrument.
5. **The analysis ignored a mode's descending form.** A Rast melody that came
   down through Rast's own flat seventh (as MU4 declares it must) scored 3.4
   cents off Rast. `BestModes` now reads both directions. **Stated plainly:**
   that is also what now separates Rast (0.4) from Dhil (3.4) on the demo's
   descending series, and it rests on a textbook rule in the maqam file, not
   on Tunisian evidence about Dhil.
6. **The MIDI writer packed six controller messages into one event** with a
   single delta time. The independent reader then read everything after it
   wrong (a note lost, every pitch shifted). Each message is now its own event.
7. **MusicXML printed a quarter tone as `-0.500`**, which is valid but not
   what anyone reads as one. It now writes `-0.5`.
8. **Ring traps**: `new X()` *with* parentheses calls `init` and fails if
   there is none; `_aT_` is `_at_`; and `oR` is `or`, for the third phase
   running.

### Claims in this plan, corrected

- §6's MU7 lists *"Sound → score (pitch + onsets…)"* as if SN5 supplied the
  onsets. It could not at this precision, and the transcriber carries its own.
- §2's *"The loop VC6 closed for speech closes for music without a new verb"*
  needed new verbs after all: `SonifyQ`, `TranscribeQ`, `BestModes`, and the
  three writers. What holds is the part that mattered: **no new type**. Every
  verb reads and returns the same `stzSoundScore`.

### What MU7 did NOT do

- **No polyphonic transcription, and no drum-stroke recognition** (missing
  steps 1 and 2).
- **No MIDI input** (the plan keeps hardware out). MIDI *files* are written,
  not read, except by the guard's own reader.
- **No arbitrary Hausa text**: it must carry tone marks. A lexicon or a model
  that restores tone is beyond this plan.
- Regression over the sound guards: 842 passed, 3 failed: 817 plus MU7's 25, and the
  three are MU1's `:Muted` failures -- the ruling still owed.

### The listener's line

- **The sonified series, HEARD 2026-09-27** by Mansour Ayouni (the Principal):
  *"the sonified series is music, close MU7"*. The RENDER row, a series
  heard as music rather than a meter in costume, was the plan's claim no
  number could make, and the author made it.
- **The talking drum, UNPERCEIVED.** Does the kalangu *say* "sannu da zuwa" to
  a Hausa speaker (`mu7_06`)? That verdict, and only that one, opens
  `SayOnDrum`, by the plan's own words.

---

## THE PLAN, AT ITS END — MU0 to MU7, 2026-09-25 → 27

§9's claim was: *"a score is data, a performance is a sound, a universe is a
declaration, and the loop is live — so one line makes music, the same line
makes it in Rast or Yaman or Slendro, every note is a number a guard can
check, and every phase ends with a person saying whether it sounds right and
the record saying who."*

- **A score is data**: `stzSoundScore`, which every transform makes and reads.
- **A performance is a sound**: MU1's twenty instruments; MU2's scheduler, 0
  frames of error.
- **A universe is a declaration**: MU4's eight, with sources, and the thin
  parts left thin.
- **The loop is live**: MU3 natively, and MU6 in the browser, where the
  author said *"it feels like an instrument"*.
- **Every note is a number a guard can check**: the sound regression stands
  at the figure above, and the three failures it carries are the `:Muted`
  ruling still owed.
- **And the record says who.** The author heard and ruled on:
  - SAPI's timbre: *"very close from real human voice"*;
  - the retuned voice: *"somehow singing"*, and `Sing()` is open;
  - the browser: *"it feels like an instrument"*;
  - the sonified series: *"it is music"*;
  - the Tunisian examples: *"far from being qualified"*.

  Still UNPERCEIVED: MU0's swing and pluck, MU1's twenty instrument names,
  MU2's swing, MU3's liveness, the other seven universes, the formant voice,
  and the talking drum. The record says so, by phase.

---

## MU8 STATUS — 2026-09-28. Added after the plan closed, on the Principal's ask: MIDI and ABC read back into the same stzSoundScore

**Why it exists.** MU7 wrote a score as ABC, MusicXML and MIDI, and read none
of them back. Its only MIDI reader was the guard's own test tool. The recap
said "NOTATE" without a direction, and the Principal read it as both ways. The
correction said so, and the Principal asked for the readers.

**Face.** `base/sound/stzSoundNotationReader.ring`:

- `StzSoundNotationReaderQ()`, with `FromMidiFileQ`, `FromMidiBytesQ`,
  `FromAbcQ`, `Losses`, `LastError`, `Title` and `Voices`
- the one-call forms `StzSoundScoreFromMidiQ` and `StzSoundScoreFromAbcQ`
- and in `stzSoundNotation.ring`, `StzSoundGmTable` and
  `StzSoundGmInstrument`

No engine change: both readers are pure Ring, and both return the
stzSoundScore that every transform reads.

**Guard.** `base/test/sound/sound_mu8_narrated.ring`: **43**.
**Heard.** `sound_mu8_demo.ring`: a Rast phrase written by hand in ABC is read,
played on the oud, written to a MIDI file, read back and played again. The
two WAVs match in length, and the MIDI copy reads back as the same 29 notes.
UNPERCEIVED, but nothing here rests on an ear: a reader is right or wrong by
numbers.

### What is read

- **MIDI**:
  - formats 0 and 1, all tracks merged in time order;
  - running status, a note-on at velocity 0 read as a note-off, SysEx skipped;
  - **pitch = key + bend**, at the bend range each channel's RPN 0 sets (2
    semitones until a file says otherwise), so a quarter tone or a slendro
    degree written as a bend comes back as its frequency;
  - a bend that moves during a note becomes a glide;
  - channel 10 is read as strokes.
- **ABC 2.1**:
  - header fields up to K:, and `%%MIDI program`;
  - accidentals, including the microtones `^/` `_/` `^n/m`;
  - octave marks, every length form, ties, broken rhythm, tuplets `(3` and
    `(p:q:r`, chords, and the rests `z x Z X`;
  - key signatures in all modes, plus `exp` and added accidentals;
  - bar accidentals that hold to the barline and for their octave only;
  - voices, inline fields, and **repeats played out** (`|: :|`, `::`, and
    endings `|1 :|2` and `[1 [2`).

### The numbers

| | |
|---|---|
| Rast, MIDI round trip | 10/10 notes, every onset on its tick, worst pitch **0.049 cents** (the bend's own step), tempo exact |
| a mixed score, MIDI round trip | 25/25 events: an oud on a channel a guitar used, a chord, a kalangu glide (ends **0.002 cents** from 165 Hz), darbouka and kit strokes |
| slendro from a MIDI **file** | within **0.072 cents** |
| Rast, ABC round trip | every pitch **exact**: `_/E` is a quarter tone, read as one |
| ABC → MIDI → ABC | the **same text**, character for character |

### Checked by more than the writer

- **A MIDI file assembled by hand**, byte by byte from the standard, not by
  the writer: 112 bytes, read as the standard prescribes. It includes running
  status, a note-off sent as a velocity-0 note-on, a SysEx message, bends at
  the default range and at an RPN-set range of 12, a snare, a triangle that
  maps to no stroke, a tempo change, and a note never released.
- **Two ABC tunes written for the guard**, each checked note by note against
  values worked out from the ABC 2.1 standard:
  - a 6/8 tune in D with a repeat and two endings;
  - a 4/4 tune in G with two voices, carried and cancelled accidentals, a
    triplet, broken rhythm, a chord, a quarter tone, octave marks, a
    whole-bar rest and a tie across a barline.
- **Nine key signatures**, and the repeat forms `::` and `[1 [2`.
- **Every check was shown able to fail.** Seven mutations were each run
  against the guard: removing the instrument name, putting the glide's last
  bend on the note-off, writing hat as key 39, keeping accidentals across
  barlines, ignoring endings, ignoring the bend range, and not rounding the
  tempo. Each one turned at least one check red. The tempo mutation at first
  passed unnoticed, so a check was added that catches it.

### Found, and each one changed the design

1. **The MIDI writer lost the instrument.** It changed the program only when
   the PROGRAM changed. An oud played after a guitar on the same channel (both
   GM 24) therefore left no trace. The writer now names the instrument in a
   text event (`stz:inst 3 oud`), and the reader prefers that name. Any other
   reader skips the text.
2. **A glide's arrival belonged to no note.** Its last bend sat on the note-off
   tick, and a note-off sorts before a bend on the same tick. The last bend is
   now one tick inside the note.
3. **"hat", the score's alias, was written as key 39**, a hand clap. It is now
   42, the closed hihat.
4. **MIDI cannot write 90 BPM.** Tempo is stored as microseconds per beat:
   666667, which reads back as 89.99995, and the ABC writer's `floor` then
   printed `Q:1/4=89`. The reader now rounds to a thousandth, and the ABC and
   MusicXML writers round instead of flooring.
5. **The ABC writer closed on an empty bar** (`| |]`) when a voice ended on a
   barline. It now closes that bar.

### What is refused, and what is counted

- **Refused**, with the reason in `LastError`:
  - a file that is not MIDI;
  - MIDI format 2;
  - SMPTE timing;
  - a track that stops partway through a message;
  - ABC with no K: line;
  - an empty text.
- **Counted** in `Losses`:
  - from MIDI: a tempo change (the first tempo is kept), the sustain pedal,
    SysEx, a drum key with no stroke here, a note never released, a GM
    program with no instrument here;
  - from ABC: chord symbols, decorations, grace notes, lyrics, the parts
    order (P:), a voice whose name is no instrument here, and a tie that leads
    nowhere.

### What MU8 did NOT do

- **MusicXML is not read**: it was not asked for.
- **Vibrato is flattened.** A bend that moves and comes back is read as a
  glide to where it ended, and that is counted.
- **No nested repeats, and no P: parts order.** One tune per text.
- Regression over the sound guards: **885 passed, 3 failed**: MU7's 842 plus MU8's 43. The three are the `:Muted` failures across planes (STZLIB-MUTED-CROSSPLANE-01), unchanged.

---

## MU9 STATUS — 2026-09-30. MusicXML read back, on the Principal's ask; and every sound item pending since MU1 closed on their delegation

**Why.** After MU8, MusicXML was the one format still write-only. The
Principal asked for it together with *"do any pending task on my behalf"*.

**Face.** In `stzSoundNotationReader.ring`:

- `FromMusicXMLQ` and `FromMusicXMLFileQ`, and `StzSoundScoreFromMusicXMLQ`
- a small XML reader of the library's own, which handles elements,
  attributes, text, entities (named and numeric), comments, CDATA,
  processing instructions and a DOCTYPE

No engine change for the reader.

**Guard.** `sound_mu9_narrated.ring`: **24**.
**Heard.** `sound_mu9_demo.ring` writes MU8's Rast phrase as a MusicXML file,
reads it back (29 notes, no losses) and plays it on the oud.

### What is read

What SOUNDS, and only that:

- `<pitch>` with its decimal `<alter>`, so the writer's `-0.5` is a quarter
  tone again;
- `<duration>` over `<divisions>`, `<chord/>`, and `<backup>` and `<forward>`
  (voices within a part);
- `<tie>`: the sounding tie, not the drawn `<tied>`;
- `<transpose>`: a clarinet's written D5 sounds C5;
- `<sound tempo>` and `<metronome>`, `<sound dynamics>` and a note's
  `dynamics` (a percentage of forte, where forte is MIDI 90);
- unpitched notes, by their instrument's `<midi-unpitched>` key;
- **repeats played out**: forward and backward, `times="n"`, and endings.

The key signature is not needed, because MusicXML writes every alteration on
its note. Instruments are read by part name or instrument name first, then
by `<midi-program>`, which MusicXML counts from 1.

### Checked by more than the writer

- **The writer's own files**:
  - Rast comes back exact;
  - the two-voice score (a chord, and a ten-beat note written as tied
    pieces) comes back note for note;
  - MusicXML → score → MusicXML gives the **same text**.
- **A score written by hand from the MusicXML 4.0 rules**, and checked
  against values worked out by hand:
  - three parts: a 'Traverso' found by its `<midi-program>74</midi-program>`,
    a clarinet in B♭, and percussion;
  - a DOCTYPE, a comment and an `&amp;` entity;
  - a chord, a triplet (8 of 24 divisions), a second voice by `<backup>`, a
    grace note, a lyric, `<harmony>`, and a trill;
  - repeats with two endings (measures played 1 2 3 2 4 5), a tie from
    ending 2 across the barline, `<sound dynamics>`, and a tempo change.
- **Every format through every other.** MusicXML → MIDI → MusicXML and
  ABC → MusicXML → ABC each give the same text.
- **Nine mutations**, and each one turned at least one check red: chord
  ignored, transpose ignored, repeat not played, ties ignored, backup ignored,
  alter ignored, program counted from 0, the entity left undecoded, endings
  always skipped.

### Found

1. **Beats summed as floats drift.** Three triplet thirds of 8/24 add up to
   3.0000000000000004, not 3, and a check then saw voice 2 start after its
   measure. Positions are now counted in whole divisions and divided once.
2. **`number("0" + text)`**, a way to default an empty field, turns "-2"
   into "0-2", which is not a number. It crashed on the clarinet's transpose.
   A helper, `_Num0`, now handles it.

### Refused, and counted

- **Refused**:
  - text that is not XML, or XML that is not well-formed;
  - `score-timewise`;
  - a compressed `.mxl` ("unzip it first");
  - XML that is not a score;
  - a duration before any `<divisions>`.
- **Counted in Losses**: grace notes, lyrics, `<harmony>`, ornaments and
  articulations, glissandos (read as their first pitch), jumps (D.C., D.S.,
  coda), tempo changes, an unpitched note with no stroke here, and a part
  named after no instrument here.

### The pending items, closed on the Principal's delegation (2026-09-30)

Each was shown to fail before its fix and to pass after it.

- **STZLIB-TRANSPORT-DRIVEWITH-01** (found by MU3).
  - The defect: `DriveWith` captured a local that Ring's anonymous
    functions cannot see, and gave `RunEvery` 0.02 where it counts
    milliseconds, so it crashed on its first tick. The guard's "reactive"
    scene called `RunToEnd`, so nothing caught it.
  - The fix: a driven transport is now registered by pointer, and one global
    function ticks it (stzSoundLive's shape). A transport leaves the list
    when it stops or is released.
  - The proof: the new Scene 6b shows the reactive loop ticking it 32 times,
    and the transport stopping itself at 0.811 s. The old code crashes there
    with "uninitialized variable: _me_".
- **STZLIB-VOICE-COMODE-01** (found by MU5).
  - The defect: after the audio device had been probed, SAPI found no voices.
    miniaudio sets COM to multithreaded, and the voice treated
    RPC_E_CHANGED_MODE as a failure.
  - The fix: `voice.zig` now accepts that code. SpVoice works in either
    mode.
  - The proof: a new guard, `sound_voicecom_narrated.ring`, runs the
    forbidden order. Before the fix it scored 0 of 3 (0x80010106, no voices);
    after, 3 of 3 (2 voices, "hello" spoken, the retuned voice usable). The
    "voice first" warnings in `stzMusic.Sing` and `stzSoundRetunedVoice`
    are retired.
- **STZLIB-SNDTABLE-RACE-01** (found by MU2).
  - The defect: source nodes read the sample-buffer table from the audio
    thread while Ring could grow it, and a growing ArrayList reallocates.
  - The fix: the whole capacity (65536 slots, about 2.6 MB) is reserved on
    the first buffer, and the table refuses to grow past it. Its address
    never changes. Freed slots are reused, so the limit is on buffers alive
    at once.
  - The proof: a Zig test shows the table at the same address after a
    thousand buffers. With the old append it moved (FAIL). All 17 of
    `sound.zig`'s tests pass.
- **STZLIB-MUTED-CROSSPLANE-01**, ruled by Central on the Principal's
  delegation.
  - The ruling: `:Muted` is ONE value, and each medium renders it in its own
    terms. Colour renders it as a treatment of a status (fa9251708: a muted
    danger stays a dusty red, #D6A199, and a muted success a dusty green,
    #8DA38A). Sound renders it as silence.
  - The consequence: the sound guards were written when colour refused
    `:Muted`, and had been red since 2026-08-22. They now follow the colour
    plane's decision rather than overruling it. The convergence scene reads
    **5 of 5** values in both channels.

### Regression

The sound regression is **919 passed, 0 failed** over 30 guard files. It is
the first fully green run since MU1, where the `:Muted` three turned red.
