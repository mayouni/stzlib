# The Softanza code benchmark

Writing Softanza solutions in Softanza code and style is the first need of Softanza's intelligence work. This
benchmark measures it: a task asks for Haro code that uses Softanza to produce a value, and haro.exe is the judge.

## Where the tasks come from

The narrated suites state each assertion as `Then(description, actual, expected)`. The Atelier's harvest
(`atelier/checks.json`) keeps every such line whose two expressions stand on their own. `build.haro` turns them into
tasks:

- both expressions are evaluated on haro.exe, and a check is kept only when they print the same: every task has a
  reference answer that passes on today's runtime;
- a check whose expressions raise in the earlier spelling is written to `_port/refs.ring`;
  `python <haro>/port/haroport.py apply _port --out _ported` ports it, and the next build uses the ported pair;
- a check whose reference writes the expected value itself, or calls nothing, is dropped;
- a task gives its scenario, its description, the literal inputs its reference uses, and the value to produce;
- each task carries its test topic and the site area of that topic, so one run scores every area at once;
- `value` tasks are the headline score; `flag` tasks (an expected 0, 1, "" or [ ]) are scored apart, since an answer
  can match them without doing the work;
- at most 2 tasks per scenario, and per topic 30 value and 10 flag tasks.

## Run it

From this folder, with `STZ_ENGINE_DIR` set as for any run of the library:

    HARO_NOCACHE=1 haro build.haro           writes bench.tsv, tasks.txt, tasks_value.txt, gold_misses.tsv
    HARO_NOCACHE=1 haro judge.haro reference                 scores the reference answers: every task passes
    HARO_NOCACHE=1 haro judge.haro <answers> <label> [...]   scores answer files, writes results/<label>.txt

An answers file holds one block per task: a line `=== <task id>`, then the code. The judge runs every answer in one
process (about 3 seconds for the 298 tasks, after the library's compile) and gives each a verdict: pass, fail, error,
refused or none.

`haro check` names the two `Eval` calls of the judge and the builder (`haro/text-run-as-code`): running an answer's
text is what a judge does, and the two calls are the only ones.

## Results

`results/` holds one file per scored run, `answers/` the answers it scored. Built from the Atelier harvest of
eb394a58d: 1,156 checks, 970 whose reference passes on haro.exe (103 of them after `haroport` moved their spelling),
298 tasks kept (166 value, 132 flag); and `authored.tsv`, 69 tasks written for the seven areas the narrations cannot
reach -- regex, geo, gui, gpu (the kernel maker's CPU side), sound, performance, governance -- each verified on
haro.exe. 367 tasks in all, 235 value and 132 flag. The reference passes all 367.

**Build and judge with `HARO_NOCACHE=1`.** A program served from haro.exe's image cache lets `Eval` accept spellings
that a fresh compile refuses (`:key = value`, a built-in in another case), so the same answer could pass from the
cache and fail fresh. Every score below is from one fresh run of the judge, the strict reading.

### One agent, five ways (Claude Opus 5.5, 2026-11-15)

Scored on the 150 value tasks that every arm answered (the arms were run while the task list grew from 160 to 166
value tasks):

| arm | what the agent may use | passed | errors | cost |
|---|---|---|---|---|
| cold | the task text only | 102 | 41 | 135 k tokens, 3 tool calls |
| source | the library's source, not its tests; runs nothing | 140 | 4 | 164 k tokens, 27 tool calls |
| door v0.1, find | AGENTS.md and `find`; runs nothing | 138 | 8 | 252 k tokens, 41 tool calls |
| door v0.2, find | AGENTS.md, `find` and `methods`; runs nothing | 136; 141; 146 | 4; 4; 2 | 213 k / 45 calls; 238 k / 62; 218 k / 54 |
| door, find and run | AGENTS.md, `find` and `run` | 147 | 3 | 218 k tokens, 48 tool calls |

The arms going through the door (`libraries/stzlib/door`) run with `STZ_DOOR_HOLDOUT` set, so `find` serves no
example from a narrated file a task comes from. The second and third v0.2 runs had `find`'s fallback examples; the
third was also told that the judge refuses the earlier spellings, and made 2 errors where the others made 4 to 8 --
AGENTS.md now says so to every agent.

- **The cold arm guesses Softanza's vocabulary**: its 41 errors are names the library does not have (`stzMoney`,
  `StzIsUuid`, `ExactAdd`). Reading the source, or asking the door, removes them.
- **The door's `find` gives what reading the source gives** -- 136, 141 and 146 against 140 -- with no file of the
  library read: the service an agent working in another project needs. It costs more tokens than reading the source.
- **`run` adds the check**: 147 of 150. The agent reports four of its answers as fitted to the expected value rather
  than calling the function the task names; a value judge counts them.
- **v0.1 against v0.2**: 138 against 136, 141 and 146 -- a spread of ten tasks between runs of one version, wider
  than any difference between the versions.
- The flag tasks were answered by the cold arm only.

### The seven authored areas, through the door

The same agent, `find` and `methods` only, on the 69 authored tasks: 51 pass.

| regex | geo | gui | gpu | sound | performance | governance |
|---|---|---|---|---|---|---|
| 6 / 9 | 9 / 10 | 10 / 10 | 0 / 10 | 10 / 10 | 9 / 10 | 7 / 10 |

- **gpu, 0 of 10**: every answer named its kernel maker `oK`, which Haro reads as the keyword `ok`. AGENTS.md now
  says that a name reading as a keyword in any case is refused.
- **regex, three errors**: `find` served narrated examples calling `Nbx`, a helper one test file defines for itself.
  The index now leaves out every example calling a function its own test file defines (5,081 of 18,569).
- The agent reports what the door did not show: how to construct `stzGovernance` and `stzFieldTags`, the shape of
  an argument (`EvaluateOn`'s bindings, a polygon's points), and what a function returns.
- These tasks were written by the same family of model that answers them; the door arm, which may not read the
  source, is the measurement they serve.

### Local models, through the same door

`local.haro` runs a model of the engine on every fourth value task, greedy, 120 new tokens at most, in three arms:
cold, door (the task with what `find` answers for its words), and doorrun (as door, then one repair with what the
answer printed). On the 38 tasks all of them answered:

| model | cold | door | doorrun | seconds a task (door) |
|---|---|---|---|---|
| qwen2.5-coder 1.5B instruct, Q8 | 1 * | 5 | 4 * | 12 |
| Bolt E4B, Q4_K_M | 7 | 3 | -- | 28 |
| *Claude Opus 5.5, for scale* | *25* | *36 (find)* | *37 (find and run)* | |

\* the 1.5B model's cold and doorrun arms ran before the extraction learned to strip inline backticks (and doorrun
before `find`'s fallback examples); its door row is the re-run with both.

- The door that brings Claude to 36 of these 38 brings the 1.5B coder from 1 to 5 and Bolt from 7 to 3: Bolt follows
  the door's definitions into names of its own (`MorphologicalAdverb`), the 1.5B model repeats a method name until its
  tokens run out. One repair from the printed result changed no answer.
- A local model writes Softanza code once it has learned the vocabulary: training a small model on the Haro copy of
  the corpus is the step these numbers call for, and this benchmark is how it will be judged.
