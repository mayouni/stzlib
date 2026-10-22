# Wave 16, model-flow classes: defects and divergences found while probing (not fixed)

Classes: stzFaculty, stzFlow, stzParcel, stzRequirement, stzModelPlan, stzModelRegistry (base/faculty/).
Every probe used stand-in functions (plain Ring functions and library functions such as StzFindLast); no model, no
service, no network. The code was not changed. Each warning below is also written in the block of the method it concerns.

## D1. StzRunImplementation writes the merged parameters back into the caller's list  (real defect)

- Where: `StzRunImplementation` (faculty/stzFaculty.ring), the line `paParams = _StzMergeParams($aStzFaculties[_iF_][:params], paParams)`.
- Symptom: Ring passes a list argument BY REFERENCE, so the assignment overwrites the list the caller handed in. The caller's
  list becomes "faculty defaults merged with the call's own keys", and it is merged AGAIN on the next call.
  - With defaults that are `[ key, value ]` pairs the merge replaces by key, so it is idempotent and nothing shows
    (every guard in test/faculty uses pairs, which is why none sees it).
  - With defaults that are not pairs the list GROWS on every call.
- Cause: a by-reference list parameter reassigned inside the function (the same family as the `_local_ = @aMember` notes in CLAUDE.md,
  from the other side: here the write goes OUT).
- Evidence (run 2026-10-22, library at HEAD edfb6d00a, Ring 1.27):
  - `StzFacultyQ("posd")` with `SetParams([ "a", "b", "c", "b" ])` and floor `StzFindLast`; `aCall = [ ]`;
    `RunWith("last", "c", aCall)` answers 3 and leaves `aCall = [ "a", "b", "c", "b" ]`; the next identical call answers 7 and the
    third `b` call answers 12, `aCall` now holds 12 items.
  - `StzScoreImplementation` therefore scores the floor `StzFindLast` at 0 on the goldens (`b`->2, `c`->3) where 0.5 is right
    (the golden loop reuses one list): `RunGoldens` writes a wrong measurement for any faculty whose default params are not pairs.
  - Flow: `StzFlowQ("f1").AddStage("s", :clean, [])` shows `Stages()[1][:params] = [ ]`; after `Run("x")` it shows
    `[ [ "keep", 1 ] ]`, the faculty's default, because the stage's own list was overwritten.
- Effect on the docs: warnings on `RunWith`, `Run` (faculty), `Run` (flow), `Stages`, `SetParams`, `RunGoldens`.
- Fix direction (not applied): build the merged list in a fresh local (`_aMerged_`) and use it; never assign to the parameter.

## D2. Run and RunWith answer the findings list on a refusal, the comment said an empty list  (divergence)

- `stzFaculty.Run` carried the comment "an empty list when it was refused (use RunQ to see why)". The code returns
  `parcel.Value()`, and a refusal parcel's value is the findings list (`_MakeRefusal` sets `@vValue = paFindings`).
  Evidence: `StzFacultyQ(:zzz).Run("a", [])` (no floor) returns `[ [ [ "rule", "floor-missing" ], ... ] ]`; same for `stzFlow.Run`
  on an empty flow (`empty-flow`) and on a pinned unknown implementation (`unknown-implementation`).
- A caller that tests `len(result) = 0` for "refused" is wrong, and a caller that gets a list back from a faculty whose output type
  is a list cannot tell a refusal from an answer without RunQ. The blocks state the real behaviour. Either the comment or the
  code should change; the author decides.

## D3. RequireLatency and RequireLocality are recorded and never read  (unbuilt feature)

- `StzResolveFaculty` reads quality, memory, languages, licence, deterministic and refusebelow only. `latency` and `locality` appear
  nowhere outside stzRequirement.ring (grep of the whole base, 2026-10-22). Design section 5.1 lists locality among the hard filters
  and latency in the ranking.
- Evidence: a requirement with `RequireLatency("batch")` and `RequireLocality("allow-service")` resolves to the same plan; a service
  stays unselected (it is never implicit regardless).
- The blocks of both methods say so in a warning.

## D4. Declaration is not "judged at declaration" as the file header says  (divergence)

- The header of stzFaculty.ring: "a missing floor, an unknown type, an implementation whose types disagree, all raise before anything
  runs". Observed: only an unknown payload type, a repeated implementation id, kind floor via AddImplementation, a missing id or fn and an
  unknown kind raise. A missing floor is reported by `Problems()` / `IsComplete()`, never raised. Implementation types are not
  declared per implementation, so they cannot disagree.
- `SetFloor`, `AddImplementation` accept the name of a function that does not exist; the error appears only when the implementation runs
  (an implementation-failed refusal "Calling Function without definition").
- `SetGoldenChecker("bogus")` is accepted and then no answer agrees: every implementation scores 0, the floor included, with
  conformance 1 (so nothing looks wrong).

## D5. Smaller points (each also written in the block of its method)

- `AddImplementation` leaves the licence "unstated", and the default requirement (permissive) rejects "unstated": an implementation
  declared without a licence is never chosen by the registry, and the only sign is a line in the plan's Rejected list.
- `RequireQuality(1.5)` is accepted (the error text says "a number from 0 to 1" but only words are checked), and then no model can qualify.
- `RequireLanguages("fr")` (a text) is stored as given and read letter by letter by the language filter.
- `RequireLicence`: any word other than `permissive` lifts the filter, spelling mistakes included.
- `stzFaculty` on a name that was never declared: `Name` works, `Run` / `RunWith` / `ResolvePlan` answer with an unknown-faculty
  refusal, and every reader raises `Array Access (Index out of range)` R2.
- `SaveMeasurements` joins fields with a vertical bar and does not escape it; a note containing a bar is cut on `LoadMeasurements`.
  The note can only be set through the global `StzRecordMeasurement` (the registry's own methods record an empty note).
- `stzModelPlan.init` accepts any list: an empty list gives readers that return empty values.

## Not exercised with a real model (read from the code)

The model branch of `StzRunImplementation` (`StzEnsureModelResident`, `StzNeuralModelQ` for an implementation carrying a `:needle`) and
the file lookup `StzModelFileFor` against a real models directory were not run: every stand-in implementation had `:needle = ""`,
which counts as installed and loads nothing. The methods whose blocks carry the sentence "not exercised with a real model: the answer
shape is read from the code": `stzFaculty.AddImplementation`, `stzFaculty.RunWith`, `stzFaculty.Run`, `stzFlow.Run`,
`stzModelRegistry.RunGoldens`, `stzModelRegistry.RunGoldensFor`. The stand-in path of all six was run.

## Unperceived

Nothing in these classes has been judged by a person for the quality of a model's output. Scores, certainties, goldens and
conformance are computed by the classes; the blocks say so.
