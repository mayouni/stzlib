# Softanza's intelligence -- what it is for, and in what order

*Design note, 2026-11-15. The author stated the needs in three directives; this note turns them into needs that can be
checked, and an order of work. Results are in `base/test/codebench/README.md`.*

## The three directives, in their order

1. **Writing Softanza solutions in Softanza code and style** is the first need. The library carries a large corpus of
   code samples and documents, already used in practical projects. The intelligence core leads to a developer
   experience that puts that knowledge to work.
2. **Softanza is a computational-thinking platform in many domains**, its areas. The intelligence core is capable in
   each of them.
3. **Softanza is made in Africa and the Arab world** (Tunisia, Niger) and used in France. Its intelligence is fluent in
   the social, technical, cultural and linguistic contexts it lives in, and multimodal.

## Directive 1 -- writing Softanza code

**The corpus is the asset.** Every narrated assertion -- `Then(description, actual, expected)` -- is an example that
checks itself when it runs. The labels exist by the thousand, and haro.exe is the judge.

| need | what "good" means | how it is checked |
|---|---|---|
| 1.1 find the right way | the answer names what the library's own narrations use | the agent door's `find`, scored on the code benchmark |
| 1.2 write code that runs | the code prints the expected value | the code benchmark: haro.exe runs every answer |
| 1.3 write it in Softanza style | Haro's forms and Softanza's idioms (Q-chains, verb-first names, the engine helpers) | `haro check`, the code rules |
| 1.4 review and repair | each finding explained, with a fix that keeps the output | the rules re-run, the output compared |
| 1.5 move code to Haro | the moved file runs the same | `haroport` for the mechanical part, a model for the rest |
| 1.6 explain and narrate | a narration in the house style | read by the author |
| 1.7 the developer surface | the knowledge is where the developer works | the agent door first |

**Built:**
- **The Softanza code benchmark** (`base/test/codebench`): 279 tasks from the narrated suites, each tagged with its
  area, judged on haro.exe.
- **The agent door** (`libraries/stzlib/door`): `find`, `methods` and `run`, on the command line and as an MCP server,
  with an `AGENTS.md` for coding agents.

**Measured:** a remote agent passes 108 of the 160 value tasks from what it knows, 148 reading the library's source,
145 to 154 through the door's `find`, and 160 with `find` and `run`. Small local models pass 1 to 7 of 40 with or
without the door: they have not learned the vocabulary.

**Three ways to serve it**, in this order:
- **(i) retrieval and a check loop around a model** -- the door. It needs no training, and with no model at all its
  deterministic floor (`find`, the rules, `run`) still serves a developer.
- **(ii) a small local model trained on the Haro copy of the corpus.** The local scores above are what it starts from;
  the benchmark judges it.
- **(iii) a large remote model through the door**, as an optional layer: the benchmark's ceiling and a fallback, never
  a requirement.

## Directive 2 -- capable in every area

"Capable in an area" means two things:
- **(A) writing that area's code** -- directive 1, scored per area by the benchmark's tags;
- **(B) the area's own faculty** -- reading text, reading a picture, hearing, reasoning over a table, finding a cause.

The faculties group the areas into six clusters:

| cluster | areas | what the model brings |
|---|---|---|
| text and language | string, regex, nlp, i18n, documentation | multilingual reading, morphology, segmentation, summarising |
| data and numbers | collections, numeric, tables, stats, binary | explaining and choosing; **the engine computes** |
| knowledge and agents | agents, neural, meta, governance, testing | tool use, planning, refusing over guessing, citing evidence |
| seeing | graphics, diagramming, gui, geo | reading and judging pictures, layouts and maps |
| hearing | sound | speech recognition and synthesis, local languages first |
| systems | system, concurrency, web, security, performance, files, extensibility, gpu | reading logs and errors, diagnosing, a bounded fix |

The deterministic core of each area stays the answer; the model explains, chooses and drafts. Each cluster's (B)
benchmark is therefore small: ten checkable tasks a cluster to start.

The code benchmark covers most areas today. Regex, geo, gui, gpu, sound, performance and governance get their tasks
written for them, since their narrated checks read files, devices or the clock.

## Directive 3 -- fluent in Softanza's contexts

| | Tunisia | Niger | France | technical |
|---|---|---|---|---|
| languages | Tunisian Arabic (Darija), Modern Standard Arabic, French | French; Hausa, Zarma-Songhai, Fulfulde, Tamasheq, Kanuri; Arabic | French | English |
| scripts | Arabic, Latin | Latin, Arabic (Ajami), Tifinagh | Latin | Latin |
| registers | administration, business, spoken | institutional and development work, rural and field, largely oral | business, contracts, procurement | documentation, code, standards |
| conventions | Gregorian and Hijri dates, TND | XOF, local calendars | EUR, GDPR | ISO, Unicode |

Where many people speak rather than write, the interface is voice; where paper rules, the input is a scanned form;
where the connection is weak, the model runs locally. Local first is the rule that serves all three.

**The first cells:** text in French, Modern Standard Arabic, Tunisian Darija (in Arabic and in Latin letters) and
Hausa -- understand, answer, write -- run on the local models. Speech follows the text matrix: recognition first, in
French and Hausa.

## The order

1. The code benchmark -- built.
2. The agent door, measured on the benchmark -- built, v0.2.
3. The language and context matrix, text first.
4. The Haro copy of the corpus, then a small local model trained on it, judged by the benchmark.
5. Ten checkable tasks per area cluster, for directive 2(B).
