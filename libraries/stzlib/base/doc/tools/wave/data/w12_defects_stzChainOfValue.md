# Wave 12 (agent w12c) -- defects found while documenting, none fixed

Classes: stzChainOfValue, stzChainOfTruth, stzListOfEntities, stzSupposition, stzReactiveObject,
stzReactiveStream, stzRegexLookaroundMaker, stzRecursiveRegexMaker, stzConditionalRegexMaker,
stzMetric, stzCodeGraph, stzStoryboard. Each defect was seen on two sets of data unless it is
stated that the cause is plain from the code. Comments only were changed.

## stzChainOfValue (natural/stzChainOfValue.ring)

- **IsANumber**: returns the chain itself for a number, a text and a list; it never answers 1 or 0.
  Cause: both branches of the body `return This`.
- **IsNotANumber**: answers 0 for 5, "x" and [1]. Cause: `NOT This.IsANumber()` negates the chain object.
- **IsAList, IsAnObject**: answer an empty text for every value. Cause: the bodies are empty.
- **ToStzObject** on a number (3 and 17): raises "Can't create the stzList object! paList must be a
  list." Cause: a number is passed to `new stzList(...)`.
- **getIsNot** is unreachable as the `IsNot` attribute: `Whatever(:v).IsNot` raises R12 "property not
  found: isnot". Cause: the attribute is declared as `_IsNot_`, the getter is `getIsNot`. Calling
  `getIsNot()` directly works.
- (not a root) **IsAStringQ**, and the other `...Q` forms of the type tests: raise R19 when the test
  fails, because `StopChain()` is called with no argument.
- **WhyCodeNotYetExecuted** on a stopped chain: answers the placeholder `Because...`, not the reason
  the chain stopped. Cause: `@aWhyCodeNotExecuted` is only set in the branch for a Since chain.

## stzChainOfTruth (natural/stzChainOfTruth.ring, frozen legacy)

- **IsNot, IsNotAn, IsNotThe**: answer 0 for "ring" against :Number / :String, :Object / :String and
  "rang" / "ring". Cause: `NOT This.Is(...)` negates the chain object. **IsNotA** raises R24
  "Using uninitialized variable: pthing" (parameter is pcThing, body reads pThing).
- **Nor**: always 0, since it calls IsNot.
- **Containing, ContainingNo**: raise "Syntax error! Check the condition ..." for a text and for a
  list. Cause: they build the condition between braces and Where sends the braces to the evaluator.
  **Where** with braces, the form its own comment shows (`'{ NumberOfItems() = 4 }'`), raises the same
  error; without braces it works. The comment also names NumberOfItems, which stzString lacks.
- **Is** with a function call such as `'LetterOf("HUSSEIN")'` raises R13 "Object is required":
  the code calls `_(...)`, which inside the class is the `_` attribute. **IsA** with the same raises R3
  "Calling Function without definition: functionnamefinishes..." (helper has another name).
- **Nth, st, nd, rd, th**: raise R13 for a number (7, 12, 21, 2, 3); same cause as Is (`_( result )`).
  `NthLetterOf(7, "HUSSEIN")` on its own answers N.
- **pvtFunctionNameFinishesWithOneOfThese** ignores its list (the endings in/of are fixed).
- **pvtFunctionParamType** raises R41 for `F(abc)`; the OBJECT answer is unreachable.
- A chain tagged false stays false (by design): reusing one chain object for a second question
  answers false.

## stzListOfEntities (natural/stzListOfEntities.ring)

- **AddEntity** refuses a new (name, type) pair as a duplicate when the name is in the list AND the
  type is in the list, even on different entities: after apple/fruit and tesla/company, adding
  apple/company raises "Can't add the same entity twice" (also seen on a/x, b/y then a/y). Cause:
  ContainsName and ContainsType are tested independently. StzKnowXT's comment names the same flaw.
- Note: RemoveEntityN and AppendEntity are written as `def` lines inside the body above them; Ring
  reads them as methods, and they work.

## stzReactiveObject (reactive/stzReactiveObject.ring)

- **BindTo**: the target gets the value at the moment of binding only. Later changes of the source
  never reach it (tried with two targets, one that already had the attribute). Cause: the binding list
  keeps a copy of the target object; `UpdateBoundAttributes` writes to that copy, so the object the
  caller passed is not changed.
- **StreamAttribute**: the stream never emits. Every change records `Watcher:attr` "Error (R24) Using
  uninitialized variable: _stream_" -- the watcher lambda reads a local of the method.
- **Batch**: after sets of 1, 2, 3 on an attribute that held 10, the watcher is told (10, 1) once while
  the attribute holds 3. Cause: `ProcessBatchChanges` notifies the first queued change of each attribute.
- **Reactivate** gives the new object `this` (a reactive object) as its engine; `StreamAttribute` on it
  raises R14 "Calling Method without definition: createstream".
- **SetAttributeValue** leaves the cache stale: `GetAttribute` keeps answering the older value for an
  attribute already cached. **Init** and **Reactivate** store the wrapped object as a copy.
- **BraceError** reaches the failure handlers of every earlier SetAsync, because the records are never
  removed.

## stzReactiveStream (reactive/stzReactiveStream.ring)

- **OnBufferFull**: handlers are stored and never called (strategies :DROP, :LATEST, :BUFFER, :BLOCK
  tested: OnOverflow handlers ran twice each, OnBufferFull none). HandleOverflow only calls the
  overflow handlers.
- **RecieveMany** on a stream with Accumulate: it concludes at once, and the auto-conclude timers
  scheduled by its Emit calls later conclude a copy of the stream taken at scheduling time, so the
  result and the OnNoMore handlers fire a second time ([6, 6], done 2) when the loop runs. A single
  Recieve then the loop gives one result.

## stzRecursiveRegexMaker (regex/stzRegexMaker.ring)

- **Pattern, SubPattern, pvtBuildPattern** raise R19 "Calling function with less number of
  parameters" for any maker that has a level (one level, three levels, with a quantifier). Cause:
  `HasKey(_level_[:quant])` has one argument. An empty maker answers an empty text.

## stzConditionalRegexMaker (regex/stzRegexMaker.ring)

- **IfCaptured** builds `(?1` / `(?<name>` instead of a conditional: IfCaptured("1").ThenMatch("a")
  .ElseMatch("b") gives `(?1a|b)`, IfCaptured("<name>").ThenMatch("a") gives `(?<name>a)`. The pair
  form [ :group, "1" ] raises R24 (the code reads `pGroupName`).
- **IfPrecededBy** with the pair form [ :pattern, "x" ] raises R24 (the code reads `pPattern`).

## stzRegexLookaroundMaker (regex/stzRegexMaker.ring)

- With a main pattern, the look-AHEAD is written before it: `MustBeFollowedBy("ing").ThenMatch("[a-z]+")`
  builds `(?=ing)[a-z]+`, which finds `ing` in walking; `[a-z]+(?=ing)` finds `walk`. So the ahead
  forms do not do what their names say once ThenMatch is used (the behind forms are right).
  MustBeFollowedByNumber().ThenMatch("[a-z]") can never match.
- **MustBePrecededByNumber, MustBePrecededBySpace** build a look-behind of variable length: `(?<=\d+)a`
  finds nothing in 12a with stzRegex (no error); `(?<=\s)a` finds the a in "x a".

## stzMetric, stzCodeGraph, stzStoryboard

- stzMetric: none found; every kind-mismatch raises a clear error by design.
- stzCodeGraph: **CheckRules, RulesAreSound** raise R14 "rawcallentries" on a Python graph (the rule set
  asks for RawCallEntries, which only the Ring graph has). The Ring subclass's **CalleesOf** takes two
  arguments (R19 with one), unlike the base's one.
- stzStoryboard, observed in the PNGs (a model reading them): frames drawn before any DragTo show the
  Euler figure in the lower right of the canvas with a wide empty band at the top and left (frame 1 of
  the sets story, also after Layout()); after an Act("DragTo") the same figure fills the canvas,
  centred. The cause is in stzMathDiagram's view, outside this class. Measure puts its length label at
  the bottom of the larger set, far from the line it measures; Callout over a set's name overlapped the
  name and the gate reported name_off_name / unsatisfied_disjoint, correctly.
