# The Softanza code benchmark

Writing Softanza solutions in Softanza code and style is the first need of Softanza's intelligence work. This
benchmark measures it: a task asks for Haro code that uses Softanza to produce a value, and haro.exe is the judge.

## Where the tasks come from

The narrated suites state each assertion as `Then(description, actual, expected)`. The Atelier's harvest
(`atelier/checks.json`) keeps every such line whose two expressions stand on their own. `build.haro` turns them into
tasks:

- both expressions are evaluated on haro.exe, and a check is kept only when they print the same: every task has a
  reference answer that passes on today's runtime;
- a check whose reference writes the expected value itself, or calls nothing, is dropped;
- a task gives its scenario, its description, the literal inputs its reference uses, and the value to produce;
- each task carries its test topic and the site area of that topic, so one run scores every area at once;
- `value` tasks are the headline score; `flag` tasks (an expected 0, 1, "" or [ ]) are scored apart, since an answer
  can match them without doing the work;
- at most 2 tasks per scenario, and per topic 30 value and 10 flag tasks.

## Run it

From this folder, with `STZ_ENGINE_DIR` set as for any run of the library:

    haro build.haro                          writes bench.tsv, tasks.txt, tasks_value.txt
    haro judge.haro reference                scores the reference answers: every task passes
    haro judge.haro <answers file> <label>   scores an answers file, writes results/<label>.txt

An answers file holds one block per task: a line `=== <task id>`, then the code. The judge runs every answer in one
process (about 3 seconds for the 279 tasks, after the library's load) and gives each a verdict: pass, fail, error,
refused or none.

`haro check` names the two `Eval` calls of the judge and the builder (`haro/text-run-as-code`): running an answer's
text is what a judge does, and the two calls are the only ones.

## Results

`results/` holds one file per scored run, `answers/` the answers it scored. Built at stzlib b7c8ebd23 from the harvest
of eb394a58d: 1,156 checks, 879 whose reference passes on haro.exe, 279 tasks kept (160 value, 119 flag).

First measurement, 2026-11-15: one agent (Claude Opus 5.5) in two arms, each answering without running any code.

| arm | what the agent may read | value tasks passed | errors | cost |
|---|---|---|---|---|
| reference | -- | 160 / 160 | 0 | -- |
| cold | the task text only | 108 / 160 | 41 | 135 k tokens, 3 tool calls |
| source | the library's source, not its tests | 148 / 160 | 2 | 164 k tokens, 27 tool calls |

Each arm's answer file covers 156 of the 160 tasks: four tasks became value tasks when the builder unwrapped `@@( )`
references after the arms had answered.

- The cold arm's errors are names the library does not have (`stzMoney`, `StzIsUuid`, `ExactAdd`): the agent knows
  Softanza's shape and guesses its vocabulary. Reading the source removes them (41 errors to 2).
- By area, reading the source lifts system 1 to 8 of 8, numeric 22 to 33 of 35, nlp 14 to 17 of 17; string is 28 of
  30 in both arms.
- The flag tasks were answered by the cold arm only: 56 of 119.

The next arm, (C), is the same agent through the agent door (AGENTS.md and an MCP server): the door's measure is the
source arm's score at a fraction of its search, and the same score for a small local model behind it.
