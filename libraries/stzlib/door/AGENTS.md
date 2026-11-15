# Writing Softanza code -- for coding agents

Softanza is a library of near-natural programming in Haro. Copy this file into the root of a project that uses
Softanza, and connect the door below: it gives an agent the library's own vocabulary and a runtime to check against.

## The door

Three tools, one program (`libraries/stzlib/door/door.haro`):

- **find** -- the library's real functions and methods for some words, with their class, signature, comment and
  file, and the narrated examples that use them, each with the value it gives.
- **methods** -- the methods one class defines (`stzString`, `stzList`, `stzNumber`...), narrowed by words.
- **run** -- runs Haro code with Softanza loaded and answers what it printed, then `=== value` and the value as
  Softanza shows it, or `=== error` and the error.

As an MCP server (stdio), in the project's `.mcp.json`:

```json
{
  "mcpServers": {
    "softanza": {
      "command": "<haro.exe>",
      "args": ["<stzlib>/libraries/stzlib/door/door.haro", "serve"],
      "env": { "STZ_ENGINE_DIR": "<the engine folder>" }
    }
  }
}
```

From a shell, the same tools:

    haro door.haro find <words>
    haro door.haro methods <class> [words]
    haro door.haro run <file of code>

## How to work

1. **Look a name up before you write it.** Softanza's vocabulary is large and regular, and a guessed name is the
   most common wrong answer: `find` with what you want to do ("remove many items from a list") or with the name you
   expect ("ManyRemoved").
2. **Read the examples `find` returns.** They are the library's own narrated checks: the code and the value it
   gives. To see what an object offers, ask `methods` for its class.
3. **Run the answer before you give it.** `run` answers in well under a second once the library is cached.

## Haro, in the lines an agent most often gets wrong

- A local's name starts with its type's letter, then a capital: `tName` text, `nCount` number, `vItems` list,
  `mAges` map, `oStr` object, `bDone` boolean. A loop counter `i` is the one exception.
- A block ends with `end`: `if ... elseif ... else ... end`, `for i = 1 to n ... end`, `while ... end`,
  `try ... catch ... end`. `loop` goes to the next turn of a loop.
- `true`, `false` and `null` are written in small letters; built-in functions keep their exact spelling (`Len`,
  `Left`, `Right`, `SubStr`, `Lower`, `Upper`, `String`, `Read`, `Write`).
- A function with no parameters is defined without brackets: `func Main`.
- Haro refuses the earlier spellings outright: a pair is a list, `[ "key", value ]`, never `:key = value`; a text
  joins a number through `String(n)`; `TRUE`, `FALSE` and `NULL` are `true`, `false` and `null`.
- The library's source files keep an earlier spelling (`ok`, `next`, `TRUE`, `cName`, `aList`). Method and function
  names are the same in Haro: write the name as `find` gives it, in Haro's syntax.

## Softanza, in a few lines

- `Q(value)` gives the value's Softanza object -- `Q("text")` a stzString, `Q([1, 2])` a stzList, `Q(5)` a
  stzNumber -- and its methods chain: `Q("hello world").Words()`.
- A method's name says what it does, verb first, and its form says what it gives: `RemoveMany()` changes the
  object, `ManyRemoved()` gives a changed copy, a `Q` at the end (`UppercaseQ()`) gives the object back to chain.
- `CS` at the end of a name takes a case-sensitivity flag: `FindCS(tNeedle, false)`.
- Text is Unicode: use the library's text functions (`StzFind`, `StzReplace`, `StzSplit`, `StzLen`) rather than
  byte-level ones.
