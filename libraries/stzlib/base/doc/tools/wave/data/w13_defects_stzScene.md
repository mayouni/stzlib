# Wave 13 (agent w13c) -- defects found while documenting, none fixed

Classes: stzScene, stzWindow, stzMathMotion, stzMathClaim (+ stzMathClaimSet), stzForEachObject (+ stzForEachObjectOld),
stzLog, stzPerfMonitor, stzDataWrangler, stzRefinableCode, stzCountry. Each defect was seen on two sets of data unless it is
stated that the cause is plain from the code. Comments only were changed. Each is recorded as a `warning` in the method's block.

## stzScene (graphics/stzScene.ring)

- **SetLens** (and so every later **SetCamera**): a refused lens raises, but the invalid numbers stay in `Camera()` and are sent
  again. Evidence: `SetLens(60, 0, 100)` raises "near must be > 0 and far > near" and `Camera()` then answers near 0; then
  `SetLens(50, 5, 2)` raises and `Camera()` answers near 5, far 2; `SetCamera(1,1,1,0,0,0)` then raises too until `SetLens`
  is called with valid numbers. Cause: `@aCam[7..9]` is assigned before `_ApplyCamera()` validates.
- (observed, not diagnosed) **SetMaterial** with `tint * @lambert` and tint #e0a030: the cube's top renders orange but its lit
  sides render pale beige (scratch PNG scene5.png). A model read the PNG; no person has.

## stzWindow (graphics/stzWindow.ring)

- none found. NOT RUN: the class opens a window, so every method was read from the code only.

## stzMathMotion (math/stzMathMotion.ring)

- **State**: the documented tolerance for one act not wrapped in a list (`State("x", [ :Set, "b", 1 ])`) raises
  "Error (R21): Using operator with values of incorrect type". Evidence: `[ :Set, "b", 1 ]` and `[ :Set, "a", 3 ]` on a
  :Function motion. Cause: not isolated; the code meant to wrap a bare act (`_a_ = [ _a_ ]`) and that wrap is the suspect.
- (observed) **ExportTo** on StzPythagorasMotionQ: frame 1 sits in the upper right of an otherwise empty 760 x 700 picture and, in
  frame 2 (after the drag of A by +60, -30), the square b2 runs off the right edge (scratch folio/pyth_02.png).

## stzMathClaim (math/stzMathClaim.ring)

- **Check / IsTrue**: a side that evaluates to infinity makes the claim hold. Evidence: `1/0 = 5` and `1/0 = 1` both answer
  verdict 1 ("holds at 1 sampled point(s) to 1e-9"). Cause: `_HoldsAt` builds the tolerance `1e-9 * (1 + |L| + |R|)`, which is
  infinite when a side is, so `|inf - 5| <= inf` is true.
- (observed) **CheckWithLean**: one run on a true claim was stopped by the harness after 5 minutes (exit 143) while Lean loaded
  Mathlib on a cold machine, and answered proved 0. Run once; not repeated.

## stzForEachObject (common/stzFuncs.ring)

- **Exec / ExecN with a single variable**: the variable's name is not bound. Evidence: `:Zed` and `:Item` raise "Using
  uninitialized variable" when the code reads `Zed` or prints `Item` (it printed another function's output for `Item`); `v(:Zed)` works.
  Cause: the single-name branch evaluates `@acVars[1] + ' = ...'`, but `@acVars` is only set for several names, so a variable
  named after the first letter of the text NULL is assigned instead.
- **Exec on an empty list or text**: raises "Array Access (Index out of range)". Evidence: `:In = [ ]` and `:In = ""`.
  Cause: `@Iterations = 1 : len(pIn)` is `[ 1, 0 ]` for an empty list.
- **A text with a multi-byte letter**: `:In = "éa"` gives 3 iterations, the first two being the two bytes of é. Cause: the
  text is walked with `len` and byte positions.
- **@SetIterations with a position beyond the data** raises an index error at run time; `@IterateOn(1)` (a number, not a
  list) raises "Bad parameter type!" at the next Exec; **ExecN("1", code)** (a position as text) silently does nothing.

## stzLog (common/stzLog.ring)

- (observed) **Record** with a level that is not one of the six is dropped without a message (`Record("loud", ...)` leaves the
  count unchanged), while **SetLevel** with the same word raises. Written as a warning, not as a defect: the code does it on purpose.

## stzPerfMonitor (perf/stzPerfMonitor.ring)

- none found. (observed) **TraceCount** counts every trace ever recorded, so it exceeds the ring's capacity (3 after capacity 2).

## stzDataWrangler (stats/stzDataWrangler.ring)

- **ValidateDataTypes, GetDataProfile, ShowReport** on a table holding any text that is not boolean-like: raise "Bad parameter
  type!". Evidence: three different tables; `o._IsDate("a")` raises on its own. Cause: `_IsDate` calls Ring's list search
  `find(cValue, "/")` with a text first argument. A flat list or an empty dataset works.
- **ConvertDataTypes** to boolean converts true-like texts to 1 and never converts false-like ones (false, no, N, 0).
  Evidence: two tables. Cause: the converted 0 is compared with `!= ""`, which is false in Ring, so the cell is skipped.
- **GeneratePlan("analyze")** answers empty text; **QuickPrepareForAnalysis** answers empty text and **Transform** does
  nothing. Evidence: GeneratePlan and ExecutePlan on two wranglers. Cause: `$aWranglingGoals` maps analyze to
  PREPARE_FOR_ANALYSIS, whose lowercase is `prepare_for_analysis`, but the template is named `prepare_analysis`
  (which works when given by name).
- **QuickPrepareForExport / Export plan**: 3 of 4 steps record an error ("Bad parameter type!"); `_StandardizeHeaders` and
  `_CleanHeaderName` raise on their own. Cause not isolated.
- **Reset** does not restore the data despite its comment: cleaned rows stay; the log is emptied including the loading entry.
- **SetVerbose** has no lasting effect: ExecutePlan overwrites the flag with its own argument.
- **HandleMissingValues("remove")** on a table removes nothing (records issues only); **EncodeCategories("onehot")** and
  "ordinal" encode nothing; **NormalizeNumeric** with an unknown method counts the values and leaves them.

## stzRefinableCode (refine/stzRefinableCode.ring)

- **As** with an unknown posture passes every TrustFloor: `TrustFloor("vat", :trusted)` then `Refine("vat").As(:weird).To("0.3")`
  was admitted. Cause: `_PostureRank` answers 3 (trusted) for an unknown word, and the comment calls that "most permissive";
  the same rule makes `TrustFloor(point, :weird)` the strictest floor. Seen with one word, plain from the code.

## stzCountry (i18n/stzCountry.ring)

- **NativeName**: raises "Calling Function without definition: stzlocale" for every country (Niger, France, Japan). Cause: the
  body calls `StzLocale(...)`; only `StzLocaleQ` exists.
- **Script, ScriptNumber**: look for the script row whose name equals the default language and answer that row's field 2, which
  is the language name again; Niger and France answer empty text, Japan answers japanese.
- **init with a locale tag** such as fr-NE: the branch is a TODO, no country is selected, and `Name()` answers a stray "U".
