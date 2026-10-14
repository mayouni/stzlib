# Wave 15 (agent w15g3) defects: stzBpmnDiagram, stzErDiagram, stzGraphGoal, stzGraphView, stzGridNav and the classes after them

Found by calling every root method with real data; each was confirmed with a second dataset or a second call. Nothing was fixed. Each is recorded as a warning in the doc block of the method.

## stzGridNav (graph/stzGridNav.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | `new stzGridNav(name, rows, cols)` always raises `Can't create stzGridNav! Engine returned error.` | the Ring wrapper calls `StzEngineGridCreate(cName, nRows, nCols)` and every later `StzEngineGrid*` with the name first; the engine bridge (engine/src/ring_bridge_gridnav.zig) takes `(rows, cols)` and keeps ONE global grid with no name, so the text is read as 0 rows and the call returns -1 | `new stzGridNav("g5", 5, 5)` and `("probe_grid", 3, 4)` raise; `StzEngineGridCreate(3, 4)` called directly returns 0 and `StzEngineGridCreate("a", 3, 4)` returns -1 |
| every other method | cannot be reached, and would read shifted arguments | `SetPosition` passes `(name, row, col)` to a 2-argument engine function, `IsValidPosition` the same, `DistanceTo` passes 3 arguments to a 4-argument function | on an object made without init (`new stzGridNav` with no parentheses) after `StzEngineGridCreate(3, 4)`: `SetPosition(2, 3)` left the position at 0,2; `IsValidPosition(1, 1)` and `DistanceTo(1, 1)` answered from shifted arguments |
| MoveDirection, MoveUp, MoveDown, MoveLeft, MoveRight | the class direction constants disagree with the engine | the class defines 0 up, 1 down, 2 left, 3 right; the engine reads 0 up, 1 right, 2 down, 3 left (engine/src/gridnav.zig) | read from the code; not reachable |
| SetPosition | the intended `Out of bounds` error can never fire | the engine `stz_grid_set_pos` returns nothing and checks no bound | read from the code |
| ResetPosition | clears the grid size as well as the position | `stz_grid_reset` sets rows and cols to 0 | read from the code |

## stzNetworkDiagram (graph/stzNetworkDiagram.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Link (LinkXT) | linking a pair that is already linked, in the same order, raises the stzGraph error `There is already an edge from 'a' to 'b'. stzGraph is a SIMPLE graph`, yet the link is kept in Links() and NeighboursOf() | `LinkXT` appends to `@aLinks` BEFORE it calls `AddEdgeXTT`, which refuses the parallel edge | `Link("a","b")` twice: after the raise Links() has 2 entries, NeighboursOf("a") 2 entries, the graph and AsRuleGraph() 1 edge; a second dataset (sw, pc) gave 6 links against 5 edges |

## stzMaterialGraph (graphics/stzMaterialGraph.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Compile | a node that reads the same node in two of its inputs raises the stzGraph error `There is already an edge from 'a' to 'b'. stzGraph is a SIMPLE graph -- parallel edges are refused` | the dependency graph is built with one `AddEdge(producer, consumer)` for each input occurrence, and stzGraph refuses a second edge between one pair; the class header promises that a node consumed twice is emitted once | `Multiply [ :a, :a ]` and `Add [ :tex, :tex ]` both raise at Compile; `Add [ :a, :b ]` with a also read by b compiles and ToW emits one `let n_a` |

## stzFlowParser (graph/stzWorkflow.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Parse (and ParseFile, ImportFlow) | a duration or sla of two or more digits is read as TEXT, not as a number | `_ParseValue` tests `isdigit(_cValue_)` and Ring's isdigit looks at one character, so `"30"` is not a digit | duration 5 gives the number 5; durations 12, 30 and 100 give the texts "12", "30" and "100" (isNumber is 0); the rule sla_compliance then skips the step, since it requires isNumber |
| Parse | an `assignedTo:` line, which is the spelling `ToWorkflow` writes, is ignored; `assignedto:` is read | `_AddStep` compares the key with `"assignedto"` and Ring compares text case by case (`"assignedTo" = "assignedto"` is 0) | `ToWorkflow()` then `Parse()` of a workflow with `AssignStepTo("pack", "ana")` gives a step with assignedto empty; the same text with `assignedto: bob` gives bob |

## stzWorkflowSimulation (graph/stzWorkflow.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| OptimizeStep, ReassignStep, ParallelizeSteps | each raises `R24 Using uninitialized variable: @achanges` | the class never declares `@aChanges` and has no init; `new stzWorkflowSimulation()` with parentheses raises R19 | all three raise on an object made without parentheses, and again on one made with `new stzWorkflowSimulation(oWf)` |

## stzMetricFamily (perf/stzMetricFamily.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| HasOverflowed | answers 1 for a family that has never overflowed | `init` creates the reserved overflow child eagerly, and the method tests only whether the overflow key is among `Keys()` | a new `StzMetricFamily("http.checkout.ms", :Timer, [...])` has ChildCount 1, Keys `[ "_overflow|_overflow" ]` and HasOverflowed 1; a family of at most 3 with two children of its own (a, b) also answered 1 before any label set was refused |

## stzOtelBatch (perf/stzOtelBatch.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, ToJson | a service name holding a double quote or a backslash makes ToJson produce invalid JSON | the name is concatenated into `"stringValue":"..."` without escaping, while the span names of a stopwatch are escaped by `_JsonStr` | `StzOtelBatch('res"to\lean').ToJson()` fails a strict JSON parse (Expecting ',' delimiter at char 95), with and without a span added |

## stzPerfSentinel (perf/stzPerfSentinel.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Explain, Show | raise `Error (R41) : Invalid numeric string` whenever at least one rule is in breach; they work while nothing is breached | `_cState_ = ring_len(@aBreached) + " active breach(es)"` adds a number to a text, which Ring refuses | two datasets: a gauge above its bound (queue.depth 150 against at most 100) and a second monitor (q = 1 against at most 0) each left ActiveBreaches non-empty, and Explain and Show raised on both; after the breach cleared Explain printed `Sentinel watchdog -- 4 check(s), all expectations met.` |

## stzSla (perf/stzSla.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Passed | answers 0 when the only breach is an advisory one, although the gate is sound | `Passed` is `@nBreaches = 0` and `CheckAgainst` counts warnings as breaches | one expectation softened with AsWarning and breached: findings 1 with severity warning, Passed 0, BreachCount 1, while stzRuleReport.Ingest of the findings gave IsSound 1 (a documentation note, not a failure of the gate) |

## stzSoundLadder (sound/stzSoundLadder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | a mode name the universe does not declare is accepted silently and the ladder shows the universe's DEFAULT mode, with IsUsable 1 and no LastError | `stzSoundUniverse.Mode` refuses an unknown name by setting its own error and keeping the previous mode, and the ladder never reads that error | `StzSoundLadderQ(:tunisian, :nomode)` and `(:tunisian, :rast)` gave ModeName dhil (the universe declares dhil, sika, sika_hijaz, rasdaldhil); `StzSoundLadderQ(:maqam, :zzz)` and `(:maqam, :nahawand)` gave rast (the universe declares rast and hijaz) |

## stzSoundRetunedVoice (sound/stzSoundRetunedVoice.ring) -- a stale comment, not a code defect

The class header says `Sing` is REFUSED until the author rules, but `StzSoundSingingVerdict()` (in stzSoundFormantVoice.ring) records the retuned voice as SINGING, ruled by the Principal on 2026-09-27, and `Sing` returns a sound. Recorded in the Sing block.

## Minor findings, recorded in the blocks and not called broken

| class | finding | evidence |
|---|---|---|
| stzReactorPool | `init` with a value that is not a number raises R41 Invalid numeric string (`_n_ < 1` compares a text with a number) instead of a message | `StzReactorPool("x")` |
| stzWorldGraph | the class is not loaded by stzlib.ring or stzBase.ring: `new stzWorldGraph(...)` raises R11 class not found until `graph/stzWorldGraph.ring` is loaded by hand | probe with only `load "stzlib.ring"` |
| stzTimerManager | a callback that stops a repeating timer stops the callback's copy, not the manager's: Ring copies objects on assignment, so a loop with a repeating timer runs until Stop or StopAllTimers is called on the manager itself | a probe that stopped the manager from a callback through a global copy never ended and its Ring process was killed by PID |
| stzScreenReaderBridge, stzMicrophone, stzVoicePool, stzLoadDriver, stzReactiveHttp, stzHttpTask, stzReactorPool | not exercised on their device or network paths by rule: no window, audio device, microphone or network was used | see the `not run` marks in the blocks |
