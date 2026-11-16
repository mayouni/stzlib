# The agent door

What a coding agent calls to write Softanza code with the library's own knowledge. How an agent uses it, and how to
connect it over MCP, is in [AGENTS.md](AGENTS.md).

| file | what it is |
|---|---|
| `door.haro` | the door: `find <words>`, `methods <class> [words]`, `run <file of code>`, `serve` (MCP over stdio) |
| `door_run.haro` | the runner `run` starts as a child process: loads Softanza, runs the code, prints the value |
| `door_index.haro` | builds `index.tsv` from the library: 45,572 definitions, each with its description, parameters, return value and warning read from its comment block, and 13,488 narrated examples, in about three seconds |

Build the index once, after a checkout and after the library changes:

    haro door_index.haro

`find` answers in about a quarter of a second and loads nothing but the index. `run` loads Softanza in its child
process; haro.exe caches the compiled library, so a run after the first costs well under a second.

`STZ_DOOR_HOLDOUT`, set to a benchmark's `bench.tsv`, makes `find` leave out the examples of the narrated files the
benchmark's tasks come from. The code benchmark (`base/test/codebench`) measures agents through the door this way.

`run` executes from haro.exe's image cache, and a cached program's `Eval` accepts some earlier spellings that a fresh
compile refuses (`:key = value`, a built-in in another case). An answer that `run` accepts is judged by the code
benchmark in a fresh compile, so write it in Haro's own forms, as AGENTS.md gives them.
