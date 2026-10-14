# Wave 15, group 2 -- defects found while documenting (not fixed)

## common/stzCounter.ring
- `stzCounter.Counting`: every number is 0 when the options carry neither `:WhenYouReach` nor `:AfterYouSkip`, whatever `:StartAt` and `:Step` say. Evidence: `[ :StartAt = 1 ]` Counting(12) -> twelve 0; `[ :StartAt = 1, :Step = 2 ]` Counting(6) -> six 0; `[ :Step = 3 ]` Counting(6) -> six 0. With a cycle option the output is right (`[ :StartAt = 1, :WhenYouReach = 4, :RestartAt = 0 ]` -> 1,2,3,0,1,...). Cause: `_CountingHandle` passes mode 0 to `StzEngineIntSeqCreateCycle` when no cycle option is set, and the engine's mode 0 yields zeros.

## common/stzConstraint.ring
- `stzConstraint.init`: no object can be built. `IsConstraint(pObject, pcConstraint)` calls `RemoveFirstBoundQ` on a string; stzString has no such method (only in `string/archive/stzString_monolithic.ring`), so R14 `Calling Method without definition: removefirstboundq` is raised for every (object, text) pair. Evidence: string object + braced text, string object + unbraced text, list object + braced text.
- `stzConstraint.Expression`: raises R24 `Using uninitialized variable: _cconstraint_` -- the body reads the local `_cConstraint_`, never assigned (the field is `@cConstraint`). Run on a subclass that sets the fields itself.
- `stzConstraint.CheckConstraint`: always 0, because the `eval(This.Expression())` sits in a try and Expression raises. Evidence: object that obeys the condition and one that does not both answer 0.
- `stzConstraint.Name`: always empty; `@cConstraintName` is never assigned.

## common/stzEngineTimeline.ring
- `stzEngineTimeline.Duration`: always 0. Evidence: events at 100/200/300, at 1000/5000, at 2.5/9 and at 1700000000/1700000060, called before and after EventsSorted, all answer 0. Cause not located in Ring (the body only forwards to `StzEngineTimelineDuration()`, in the engine DLL).
- `stzEngineTimeline.RemoveEvent`: an unknown label is silently ignored; the `Event 'x' not found!` raise (`_nResult_ < 0`) never fires, so the engine does not return a negative code.
- `stzEngineTimeline.EventsSorted`: returns the number of events; the order read back by EventLabel/EventTime is still the insertion order after the call.

## common/stzOccurrences.ring
- `stzOccurrences.SubString` and `.String` always answer an empty text: `init` stores `@pcSubStr` / `@pcStr`, the readers return `@cSubStr` / `@cStr`.
- `stzOccurrences.Removed` (and `RemovedCS`): R14 `Calling Method without definition: removesubstringatpositionscsq`; stzString has no such method. Also reads `This.Occurrences` without parentheses.
- `stzOccurrences.ReplacedWithCS`, `.Uppercased`, `.Lowercased`: empty bodies (unfinished stubs).

## common/stzStateMachine.ring
- `Send` with an event that has no transition from the current state, `SetState` with an unknown state, and `AddTransition` naming an unknown state are all silently ignored; the three raise branches (`_nResult_ < 0`) never fire. Evidence: Send('lock') from state open stays open and returns "open"; SetState('nowhere') keeps the state; AddTransition('open','x','ghost') leaves NumberOfTransitions at 1. Also AddState of an existing name counts twice (NumberOfStates 3 -> 4).

## common/stzValidator.ring
- A rule added with `AddRequiredRule` never rejects: `CheckLength('req', 0)`, `CheckLength('req', 4)`, `CheckInt('req', 0)`, `CheckInt('req', 7)` and `CheckStringLength('req', '')` all answer 1.
- `CheckInt`/`CheckLength` against a rule of the other family (`CheckLength('min', 2)` on a min-value rule) answer 1 without complaint.

## cluster/stzNodeApp.ring
- `On`, `Requires`, `Boot`, `AtHost`, `AtPort` before any `Node(name)` call raise R2 `Array Access (Index out of range)` (they index `@aSpecs[@nCurrent]` with `@nCurrent = 0`). Evidence: `new stzNodeApp("x").On("a","return 1")`, `.Requires("x")`, `.AtPort(1)`. By design the fluent chain starts with Node(); the error carries no hint.

## cluster/stzRequestClassifier.ring
- `AddKeyword` returns nothing, unlike every other setter of the class (they return the classifier); only `AddKeywordQ` chains. Not a fault of the logic; noted for the reader.

## extercode/stzImageToAscii.ring
- The file does not parse in Ring 1.27: loading it alone reports C27 Syntax Error at lines 41, 55, 56, 58 and `Brackets ']' is missing` at line 79 (braces after `if`, one-line `def x() { ... }`, a malformed loop in Execute). No file of the library loads it, so `stzImgToAscii` does not exist in a session. Also `EnsureDirs` reads `@cOutputDir`, a field never defined (the field is `@cOutDir`), and calls `dir_create`, which Ring does not have; the tool `../tools/im2ansi/im2ansi.exe` is not in the library.
- Extractor limitation met here: `def init(pcImage = "")` is recorded with the parameter name `pcImage = ""`, so a role written as `pcImage` (what the applier writes) is not matched and check 3 (params) fails for `stzImgToAscii.init`. Writing the key with the default (`pcImage = ""`) did not match either. Not fixable without changing the code (drop the default) or the extractor.

## extercode (stzPythonCode, stzJuliaCode, stzPrologCode, stzRCode)
- `stzRCode.Execute` always raises with R 4.5.1: the R translator in `extercode/stzExterCodeTransFuncs.ring` uses the identifier `_items_`, which R rejects (`unexpected symbol`). Evidence: `res <- 1 + 2` run through Rscript from a scratch folder, log quoted in the error.
- The default program paths of Python (`d:/python/python-3.13.7/python.exe`), Julia and Prolog do not exist on this machine; Python ran only after `$aStzLibConfig[:PythonPath]` was set, with the 8.3 form of the path (a folder name with a space breaks the unquoted run script) and with `NoDefaultCurrentDirectoryInExePath` unset for the child Ring process (it is 1 in this session's environment, which makes every Execute fail with 'Result file not created. Log file not found').
- `Result()`, `Code()` and `Log()` on a NEW object read the files left in the current folder by an earlier run (stale answer).

## extercode/stzQmlCode.ring
- `Code(pcQml)` is a setter, while `Code()` of every sibling external-code class returns the text.
- `IsRuntimeAvailable` is TRUE for any non-empty path, including one that does not exist.
- `Trace` returns the last output, not a history.
- The factories `StzQmlCodeQ()` / `XQml()` use paren-less `new`, which skips `Init`, so the temp folder is not created until Execute or EnsureDirectories; `WriteSource` alone raises R35.

## system/stzBuilder.ring
- `TargetHost` clears only the triple: after `TargetWeb()` then `TargetHost()`, `IsWeb()` stays 1, the optimisation stays `small`, and `Args()` still carries `-nostdlib` and the `--export` linker flags with the default output `.exe`. Evidence: `w = new stzBuilder("app"); w.TargetWeb(); w.TargetHost()` -> IsWeb 1, Target "", Args ends with the freestanding flags.
- `SetTarget` after `TargetWeb` keeps `IsWeb` (same cause: the web flag has no off switch).
- `EmitLib` gives a default output with no extension on Windows (`app`, `z`), not `.dll`; `_DefaultExt` only adds `.exe` for an executable.
- `SetOptimization` with an unknown word, `SetLanguage` with an unknown word and `SetTarget` with a value that is neither an object nor a text are silently accepted or ignored (debug, cc, no change).

## system/stzProcess.ring and the engine build of the worktree
- In the `_wtd` worktree the engine binary `engine/zig-out/bin/stz_system.dll` (2026-10-04) predates `engine/src/ring_bridge_system.zig` and `system.zig` (2026-10-05): it lacks `StzEngineProcessWaitFor` and `StzEngineProcessSpawnArgv`, so `stzProcess.WaitFor`, `IsRunning` and `SpawnIn` raise R3 `Calling Function without definition`. The main checkout's stz_system.dll lacks them too; the `_wtt` build has them. These methods were run against the `_wtt` engine, read-only, and behaved as documented. Not a code defect: a stale binary.

## cluster/stzNode.ring (safety note)
- Building a `stzNode` binds a TCP port. The class-block receiver was run once by my example checker before I excluded it (loopback, ephemeral port 0, the process ended at once); nothing connected to it.
