# The area-cluster benchmark

Softanza's intelligence is capable in each of its areas in two ways (`base/doc/design/SOFTANZA_INTELLIGENCE_NEEDS.md`,
directive 2): it writes the area's code -- the code benchmark in `../codebench` scores that, area by area -- and it
brings the area's own faculty. This benchmark scores the faculty: ten checkable tasks for each of the six clusters of
areas.

| cluster | areas | the faculty its ten tasks ask for |
|---|---|---|
| text | string, regex, nlp, i18n, documentation | a lemma, sentences counted, a language and a script named, a summary chosen, a pattern chosen, a word translated from Arabic and from Hausa, a Darija word read, code points counted |
| data | collections, numeric, tables, stats, binary | a table read, a statistic chosen, a sum, a conversion, a binary number read, a percentage, a sort, a chart chosen |
| agents | agents, neural, meta, governance, testing | a tool chosen, UNKNOWN answered where the text is silent, the evidence line cited, steps ordered, a rule applied, a claim checked against a log |
| seeing | graphics, diagramming, gui, geo | a colour, a count, a position, a shape, a written number and word, a trend, read from ten pictures stzCanvas draws |
| systems | system, concurrency, web, security, performance, files, extensibility, gpu | a failing component found in a log, a cause chosen for an error, a bounded fix chosen, a stack trace read |
| hearing | sound | eight sentences transcribed, five in French and three in English, with their key words (a time, a price, a city, a date, a library term); the language of two recordings named |

The recordings are spoken by the Windows voices (`_rig/speak.ps1`, 16 kHz mono), the French ones by the French voice.

## Run it

From this folder, with `STZ_ENGINE_DIR` set as for any run of the library:

    HARO_NOCACHE=1 haro pictures.haro                         draws the ten pictures into pictures/
    HARO_NOCACHE=1 haro run.haro <label> <model file>         a text model answers the forty tasks without a picture
    HARO_NOCACHE=1 haro run.haro <label> smolvlm256           the house's vision model answers the ten with one
    HARO_NOCACHE=1 haro run.haro <label> <ggml-small.bin>     Whisper hears the ten recordings
    HARO_NOCACHE=1 haro run.haro <label> <ggml-small.bin> setting_words.txt
                                                              the same, Whisper first reading the setting's words
    HARO_NOCACHE=1 haro run.haro score <answers file> <label> scores replies written by any other means

A reply is read by its task's kind: `choice`, the first capital A to D standing alone; `number`, the first number;
`word`, an accepted word among the first eight words, where a reply that offers a choice ("yes or no: no") before
it fails; `heard`, every group of expected words inside the transcript; `language`, the code of the language Whisper
hears, told nothing. `results/<label>.txt` holds each verdict and the score by cluster; `answers/<label>.tsv` holds the replies.

## Results

Run on 2026-11-16, each model once, greedy, on the engine's decoder (CPU). Claude answered as a separate agent, from
the questions alone, opening the pictures itself.

| model | text | data | agents | systems | the forty | seeing | hearing | seconds for the run |
|---|---|---|---|---|---|---|---|---|
| Nemotron 3.5 Bolt E4B, Q4_K_M | 9 | 10 | 10 | 10 | **39** | -- | -- | 133 * |
| Granite 4.2 3B, Q4_K_M | 7 | 9 | 8 | 9 | **33** | -- | -- | 80 |
| Qwen3 0.6B, Q8 | 3 | 6 | 5 | 8 | 22 | -- | -- | 21 |
| LFM3 1.7B, Q8 | 4 | 6 | 5 | 6 | 21 | -- | -- | 52 |
| SmolVLM 256M | -- | -- | -- | -- | -- | 7 | -- | 10 |
| SmolVLM 500M | -- | -- | -- | -- | -- | 7 | -- | 14 |
| Whisper small, f16, on `engine/src/whisper.zig` | -- | -- | -- | -- | -- | -- | **7** | 49, the library's compile included |
| the same, reading `setting_words.txt` first | -- | -- | -- | -- | -- | -- | **9** | 58, the library's compile included |
| *Claude Opus 5.5, for scale* | *10* | *10* | *10* | *10* | *40* | *10* | -- | |

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
- **The engine's Whisper agrees with its reference**: on the first recording, the numpy implementation that reads the
  same file (`_rig/whisper_reference.py`) and the engine give the same 15 tokens, and cosine 1.000000 on the log-mel,
  on the encoder's 1,152,000 values (largest difference 0.37 of 32.7: ggml's convolution runs in f16) and on the first
  step's 51,865 logits (largest difference 0.004). The engine takes 5.7 s for the encoder on four threads and 0.7 s
  for the 15 tokens; `_rig/whisper_probe.haro` repeats the check.
- LFM3 answers four of its arithmetic tasks with the working shown (`17 + 25 = 42, then 42 + 8 = 50`), against the instruction:
  the first number is read, as for every model.
- These tasks were written by the same family of model that answers the Claude arm; for that arm they measure the
  ceiling, and for the local models what each one brings.
