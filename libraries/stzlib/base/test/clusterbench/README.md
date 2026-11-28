# The area-cluster benchmark

Softanza's intelligence is capable in each of its areas in two ways (`base/doc/design/SOFTANZA_INTELLIGENCE_NEEDS.md`,
directive 2): it writes the area's code -- the code benchmark in `../codebench` scores that, area by area -- and it
brings the area's own faculty. This benchmark scores the faculty: ten checkable tasks for each of the six clusters of
areas, and ten more for hearing in the local languages.

| cluster | areas | the faculty its ten tasks ask for |
|---|---|---|
| text | string, regex, nlp, i18n, documentation | a lemma, sentences counted, a language and a script named, a summary chosen, a pattern chosen, a word translated from Arabic and from Hausa, a Darija word read, code points counted |
| data | collections, numeric, tables, stats, binary | a table read, a statistic chosen, a sum, a conversion, a binary number read, a percentage, a sort, a chart chosen |
| agents | agents, neural, meta, governance, testing | a tool chosen, UNKNOWN answered where the text is silent, the evidence line cited, steps ordered, a rule applied, a claim checked against a log |
| seeing | graphics, diagramming, gui, geo | a colour, a count, a position, a shape, a written number and word, a trend, read from ten pictures stzCanvas draws |
| systems | system, concurrency, web, security, performance, files, extensibility, gpu | a failing component found in a log, a cause chosen for an error, a bounded fix chosen, a stack trace read |
| hearing | sound | eight sentences transcribed, five in French and three in English, with their key words (a time, a price, a city, a date, a library term); the language of two recordings named |
| hearing-local | sound | five recordings in Arabic and five in Hausa, read by native speakers: the language of six named, the key words of four heard |

The `hearing` recordings are spoken by the Windows voices (`_rig/speak.ps1`, 16 kHz mono), the French ones by the
French voice. The `hearing-local` recordings are the first five of the test split of FLEURS (Conneau et al., 2022,
Google, CC BY 4.0) for Arabic (`ar_eg`, Modern Standard Arabic read in Egypt) and for Hausa (`ha_ng`), with FLEURS' own
transcriptions as the question column; `python -I _rig/fleurs_fetch.py` fetches them into `recordings/fleurs/`, reading
a few MB of Google's archives as a stream. Their key words were fixed before any model heard them.

## Run it

From this folder, with `STZ_ENGINE_DIR` set as for any run of the library:

    HARO_NOCACHE=1 haro pictures.haro                         draws the ten pictures into pictures/
    HARO_NOCACHE=1 haro run.haro <label> <model file>         a text model answers the forty tasks without a picture
    HARO_NOCACHE=1 haro run.haro <label> smolvlm256           the house's vision model answers the ten with one
    HARO_NOCACHE=1 haro run.haro <label> <ggml-small.bin>     Whisper hears the ten recordings
    HARO_NOCACHE=1 haro run.haro <label> <ggml-small.bin> setting_words.txt
                                                              the same, Whisper first reading the setting's words
    HARO_NOCACHE=1 haro run.haro score <answers file> <label> scores replies written by any other means
    HARO_NOCACHE=1 haro measure.haro                          measures the two hearing faculties (STZ_MODELS_DIR set)

A reply is read by its task's kind: `choice`, the first capital A to D standing alone; `number`, the first number;
`word`, an accepted word among the first eight words, where a reply that offers a choice ("yes or no: no") before
it fails; `heard`, every group of expected words inside the transcript; `language`, the code of the language Whisper
hears, told nothing. `results/<label>.txt` holds each verdict and the score by cluster; `answers/<label>.tsv` holds the replies.

## Results

Run on 2026-11-16, each model once, greedy, on the engine's decoder (CPU). Claude answered as a separate agent, from
the questions alone, opening the pictures itself.

| model | text | data | agents | systems | the forty | seeing | hearing | hearing-local | seconds for the run |
|---|---|---|---|---|---|---|---|---|---|
| Nemotron 3.5 Bolt E4B, Q4_K_M | 9 | 10 | 10 | 10 | **39** | -- | -- | -- | 133 * |
| Granite 4.2 3B, Q4_K_M | 7 | 9 | 8 | 9 | **33** | -- | -- | -- | 80 |
| Qwen3 0.6B, Q8 | 3 | 6 | 5 | 8 | 22 | -- | -- | -- | 21 |
| LFM3 1.7B, Q8 | 4 | 6 | 5 | 6 | 21 | -- | -- | -- | 52 |
| SmolVLM 256M | -- | -- | -- | -- | -- | 7 | -- | -- | 10 |
| SmolVLM 500M | -- | -- | -- | -- | -- | 7 | -- | -- | 14 |
| Whisper small, f16, on `engine/src/whisper.zig` | -- | -- | -- | -- | -- | -- | **7** | **5** | 49 for hearing; 263 for both clusters |
| the same, reading `setting_words.txt` first | -- | -- | -- | -- | -- | -- | **9** | -- | 58, the library's compile included |
| *Claude Opus 5.5, for scale* | *10* | *10* | *10* | *10* | *40* | *10* | -- | -- | |

\* taken while another desk built its runtime on this machine; the scores do not depend on the clock.

- **Bolt E4B brings four clusters on the machine itself**: 39 of 40, about 3 seconds a task. Its one miss is the
  Tunisian greeting `3aslema`, written in Latin letters -- the language matrix's weakest cell again.
- **Granite 4.2 3B is the small model that serves**: 33 of 40 at a third of Bolt's size. It needs its own chat form
  (ChatML with an empty thinking block); with Granite 4.0's role markers it echoed the question and scored 20.
- **The cells to train, read across the models**: four tasks are missed by all three smaller models -- Hausa named as
  a language (Swahili, Japanese, `kina`), a claim checked against the time in a log line, the verb-first method name
  (Softanza's own convention), and the command line that names its secret rather than typing it. The last two are
  Softanza's house rules: the training material of the code benchmark carries them.
- **Seeing is 7 of 10 at both sizes of SmolVLM**: colour, shape, a written number and a written word, a count of
  three, read right; which bar is tallest and which way a line goes are the misses of both, so a chart is read by
  the library's own data before a model looks at its picture.
- **Hearing is 7 of 10 with Whisper small, run by the engine itself**: both languages named, every number, date and
  ordinary word heard. The three misses are the words of Softanza's own contexts: `semoule` heard as "ce moule", `Sfax`
  as "SFACS", `Softanza` as "soft-onsa".
- **With the setting's words read first, hearing is 9 of 10.** `setting_words.txt` is one glossary for every recording
  -- the library's names, Tunisian cities, the market's goods and its currency, as a deployment carries its own
  vocabulary -- read by the decoder behind `<|startofprev|>` (`StzEngineNeuralWhisperTranscribePrompted`). `semoule`
  and `Sfax` are now spelled right; `Softanza` comes out "Softansa", one letter off, as the English voice says it. The
  seven recordings that passed still pass and both languages are still named: the language is heard before the
  prompt is read, so a glossary never changes it. The numpy reference, given the same words (`--prompt`), spells fr03
  as the engine does.
- **Arabic is heard: 5 of 5.** Whisper small names the language of the three Arabic recordings and hears the key
  words of the other two (`عاصفة` and `الأطلسي`, a storm over the Atlantic; `النباتات`, plants), told nothing of the
  language, on recordings of 8 to 16 seconds read by Egyptian speakers. The engine reads FLEURS' 32-bit float WAV as it
  is.
- **Hausa is the hearing cell to train: 0 of 5.** Told nothing, Whisper small names the Hausa recordings Swahili,
  Amharic and Yoruba, and writes what it hears as sound-alike syllables. Told the language (`ha`), it writes
  recognisable Hausa -- "kasa, ruwa, iska" for FLEURS' "ƙasa ruwa iska" (earth, water, air) -- with most other words
  misspelled. Hausa hearing takes a model trained on Hausa speech; that is the next rung of this cluster.
- **A Whisper trained on Hausa hears Hausa: 37.8% of words wrong where Whisper small, told the language, gets 85.6%**
  (on the five FLEURS Hausa recordings, 111 words; 42.3% and 86.5% counting Hausa's hooked letters as FLEURS writes
  them). The model is EqualyzAI's `african_voices_hausa_small` (Apache-2.0, Whisper small fine-tuned on the African
  Voices Hausa recordings), converted into the engine's own Whisper form by `_rig/hf_whisper_to_ggml.py` -- the base's
  filters and vocabulary kept, its 479 tensors replaced, each within cosine 0.995 of its base -- and run by the same
  `whisper.zig`. It writes "sun kasance ƙasa ruwa iska da wuta" where FLEURS' reader says "sun kasance ƙasa ruwa iska
  da wuta". `_rig/hear_list.haro` transcribes, `_rig/wer.py` scores; transcripts in `results/hausa/`.
- **Hearing is two faculties of the library** (`base/sound/stzHearing.haro`): `:transcribe` (audio -> text, call
  parameters `:language` and `:words`) and `:spoken-language` (audio -> label), declared in every process, Whisper small
  their implementation beside a floor. `measure.haro` runs both on their golden sets and files the evidence in
  `base/sound/hearing.zmdl.txt` and `hearing.court.txt`: `:transcribe` on `hearing-v1` (the twelve key-word tasks of the
  two hearing clusters) 0.58 against 0 for the floor, 7 items gained and none lost; `:spoken-language` on
  `spoken-language-v1` (the first five FLEURS test recordings in French, English, Arabic and Hausa) 0.75 against 0.25
  for the floor that always answers French, 10 gained and none lost. The court upholds Whisper small on both, so the
  registry chooses it; about 9 seconds a recording.
- **Hausa is heard, and the registry routes it: a Hausa call goes to the model trained on Hausa, every other
  language to Whisper small.** `:transcribe`'s golden set `hearing-v3` (committed and pushed, ba0839218, before any
  model heard it) holds the twelve key-word tasks and ten fresh FLEURS recordings in each of French, English, Arabic
  and Hausa, an item agreeing when its transcript's word error rate is at most 50%; the faculty is measured per
  language. Whisper small: French 0.87, English 0.92, Arabic 0.83, Hausa 0. The Hausa model: Hausa **0.75** (9 of 12),
  the others 0 to 0.08. The court, per language: Whisper small upheld for French (13-0), English (11-0) and Arabic
  (10-0); the Hausa model upheld for Hausa over Whisper small and over the floor (9-0 each). `StzFacultyQ("transcribe")
  .Run(recording, [ [:language, "ha"] ])` runs the Hausa model; with any other language, or none, Whisper small.
- **On hearing-v2, the rule before it, the court did not rule on the Hausa model.** `:transcribe`'s golden set
  `hearing-v2` adds ten fresh Hausa recordings (FLEURS test 6 to 15, `hausa_fresh.tsv`), each judged on the three
  longest words of its transcription, all three required. The Hausa model passes 2 of the 12 Hausa items, Whisper small
  none: two items gained is within chance (p 0.25), so the registry keeps Whisper small for every language (7 items
  gained on the floor over the whole set, none lost). The model is in the catalogue as a converted file (its conversion
  replayed byte for byte) and stays measured beside Whisper small. Its word error rate says where it stands; the court
  needs more Hausa items, judged item by item on that rate, to rule on it.
- **The engine's Whisper agrees with its reference**: on the first recording, the numpy implementation that reads the
  same file (`_rig/whisper_reference.py`) and the engine give the same 15 tokens, and cosine 1.000000 on the log-mel,
  on the encoder's 1,152,000 values (largest difference 0.37 of 32.7: ggml's convolution runs in f16) and on the first
  step's 51,865 logits (largest difference 0.004). The engine takes 5.7 s for the encoder on four threads and 0.7 s
  for the 15 tokens; `_rig/whisper_probe.haro` repeats the check.
- LFM3 answers four of its arithmetic tasks with the working shown (`17 + 25 = 42, then 42 + 8 = 50`), against the instruction:
  the first number is read, as for every model.
- These tasks were written by the same family of model that answers the Claude arm; for that arm they measure the
  ceiling, and for the local models what each one brings.

## The court as a router (RADAR-ROUTERFIGURES-01, 2026-11-27)

`haro _measure_router.haro` replays the verdicts above; no model runs. Each cluster's ten tasks are split by parity:
the court decides on one half with the registry's own rule (rank by score on the golden half, then by size; keep the
first model upheld against the floor by the exact sign test at 0.05), the model it chooses answers the other half,
and the halves change places. Written to `results/router.txt`.

**Cost basis: CPU seconds on this machine**, each model's run wall time over its forty tasks (2026-11-16). No price
enters: these models run on the device. Bolt's run overlapped another desk's build.

| policy | right | wrong | refused | seconds | seconds per right answer | model calls per decision |
|---|---|---|---|---|---|---|
| always Qwen3 0.6B | 22 | 18 | 0 | 21 | 0.9 | 0 |
| always LFM3 1.7B | 21 | 19 | 0 | 52 | 2.4 | 0 |
| always Granite 4.2 3B | 33 | 7 | 0 | 80 | 2.4 | 0 |
| always Bolt E4B | 39 | 1 | 0 | 133 | 3.4 | 0 |
| the court, per cluster (golden 5) | 32 | 3 | 5 | 103 | 3.2 | 0, a lookup |
| the court, pooled (golden 20) | 39 | 1 | 0 | 133 | 3.4 | 0, a lookup |
| the oracle, which knows each answer | 40 | 0 | 0 | 53 | 1.3 | -- |

- **Pooled, the court is Bolt**: it chooses Bolt E4B on both halves, and Bolt is the best model on both served halves.
- **Per cluster, five golden items are the court's floor**: a model is upheld only at 5 of 5 (P = 1/32); at 4 of 5
  (P = 1/16) it is refused, so one served half had no model and was refused rather than answered. Where Granite
  4.2 and Bolt both scored 5 of 5 the court took the smaller, Granite, and twice it then missed one served task.
  Per right answer that is 3.2 s against Bolt's 3.4 s, for 7 fewer right answers (5 refused, 2 more wrong). It chose a model holding the served
  half's best score in 5 of 8 decisions.
- **The gap is per request**: the oracle answers all forty in 53 s, Qwen3 0.6B where it is right and a larger model
  where it is not. The court routes by faculty and has no reading of which request a small model gets right, so it
  cannot take that gap. A router that does reads every request: Microsoft's Decision 1.1 runs on Gemma 4 26B A4B, about
  4B parameters active a call, the size of the Bolt E4B answering here, so on this machine its decision would cost
  about what Bolt costs to answer.
- **The court's decision costs no model call at serve time**: it is a line of the court's file, paid for once by
  running every candidate on the golden set.

## A domain's terms, heard plain and with its word list (RADAR-DOMAINHEARING-01, 2026-11-27)

`_measure_terms.haro` hears two sets with Whisper small on the engine, the language named, PLAIN and PROMPTED with
the domain's word list read first (`domain_words_sales.txt`, behind `<|startofprev|>`). `_score_terms.haro` scores
the transcripts it saved (`results/terms/`), so a change of scoring never runs the model again.

- **DOMAIN** (`domain_sales.tsv`): twenty sentences of a sales representative's day in Tunisia -- towns, trade words,
  products, 83 term groups -- spoken by the Windows French voice (`_rig/speak_domain.ps1`, 16 kHz mono).
- **GUARD**: FLEURS' own speakers, the first 10 French and 5 English test recordings, scored against FLEURS'
  transcription: what a domain's list costs speech that is not the domain's. A product that reads the list reads it
  for every recording, so the guard is heard with the list too.

| mode | term groups missed | domain words wrong | FLEURS fr words wrong | FLEURS en words wrong |
|---|---|---|---|---|
| plain | 32 of 83 (38.6%) | 64 of 229 (27.9%) | 48 of 272 (17.6%) | 7 of 107 (6.5%) |
| prompted | 12 of 83 (14.5%) | 32 of 229 (14.0%) | 50 of 272 (18.4%) | 7 of 107 (6.5%) |

- **The word list takes term errors from 38.6% to 14.5%** and halves the domain's word error rate. Sousse, Msaken,
  Kalâa Kebira, Djerba Houmt Souk, Enfidha, Teboulba, Kairouan, harissa and levure go from misheard to right. The
  twelve still missed are names a letter or two off (Ksaar Hellal, Souss, Jemma l', Zarzi, Médiuni, Lanta), trade words heard as their
  sound (borderau, colisige, réistourne, échui) and two homophones the list cannot decide (thon / ton, pâtes / pattes).
- **The guard moves by two words of 272 in French and none in English.** One French recording takes a word from the
  list: "Caroline du Nord" is heard "Kalâa Hellal de Nord".
- **The list costs 3.1 times the hearing time.** `_rig/time_prompt.haro` heard four recordings plain, prompted,
  plain, prompted, so the machine's drift falls on both arms: 391 s plain against 1,210 s prompted in all, every
  recording 2.7 to 3.7 times (`results/terms_timing.txt`). The measurement run's own seconds (1,634 and 5,819 for 35
  recordings) were taken one mode after the other.
- **Cost basis: wall seconds on this machine**, Whisper small on the CPU, four threads, the engine built ReleaseSafe
  from stzlib c2b930b71. Tonight plain hearing took 43 to 61 s a recording, where the WHISPER-02 run of 2026-11-16 heard
  ten recordings with the list in 58 s on an engine built from 1212cb88c; `whisper.zig`'s compute did not change
  between the two. The absolute seconds are tonight's machine; the ratio is the measurement.
- **The list's cost grows with its length.** `_rig/time_words.haro` heard the bench's eight hearing recordings plain,
  with the setting's list of 82 bytes and with the domain's of 515 bytes, the order turning with each recording:
  381 s, 538 s and 1,117 s, the short list 1.41 times plain and the long one 2.93 times (`results/words_timing.txt`).
  Plain hearing took 48 s a recording on that run too, so the slowdown against 2026-11-16 holds with either list and
  without one.
- Numbers spoken as words ("douze") are written as digits ("12") in both modes; the term groups accept either, the
  word error rate counts them, equally in both modes.

### The slowdown is the machine's, not the engine's (2026-11-27, afternoon)

`_rig/time_engines.ps1` built nothing and changed nothing: it heard four of the bench's recordings (fr01, fr02, fr03,
en01) on two engines, each recording once per engine in its own process, plain and then with the setting's list, the
engines' order turning with each recording. One engine was built from stzlib 1212cb88c, the commit of the WHISPER-02
run of 2026-11-16 (`haro engine/build_engine.py --ref=1212cb88c --build stz_neural`, 1,174 s at -j2); the other is the
shared engine, built from c2b930b71 (`results/engines_timing.txt`).

| engine | plain s | setting list s | both s |
|---|---|---|---|
| 1212cb88c (2026-11-16) | 388.5 | 645.6 | 1,034.2 |
| c2b930b71 (shared) | 562.7 | 428.5 | 991.2 |

- **The two engines take the same time and hear the same words.** The 2026-11-16 engine is 4% slower in all, inside
  the run's own spread: one recording took 50 s to 254 s plain depending on when it ran, and the only pair heard while
  the machine was quiet (en01, 15:05) agrees to a second. Every transcript is the same on both engines.
- **So the eight- to elevenfold slowdown against 2026-11-16 is the machine's.** The engine that heard ten recordings
  with the list in 58 s that day takes 52 s for one plain recording today. A Haro build at -j1 and a Foundry probe
  ran beside part of this run; this machine's Windows power reading is not a measurement, and names no cause. Hearing seconds from this machine compare within one alternated run; the
  machine's share of the slowdown is this plane's next measurement.
