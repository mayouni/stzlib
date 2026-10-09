# Wave 10 defects (classes stzApp, stzPlatform, stzEarcons, stzWorkflow, stzAppCluster, stzHttpClient, stzDeploymentSite)

Recorded, not fixed. Each was reproduced with two different inputs before being written down.

## stzPlatform.SetPurposes -- a single text, symbol or number is stored as [ [ [ ] ] ]

- method: `stzPlatform.SetPurposes(paPurposes)` (platform/stzPlatform.ring)
- symptom: `AddCapabilityQ(:a).SetPurposes("one purpose")`, `.SetPurposes(:sym)` and `.SetPurposes(42)` each leave `Admissions()` showing `[ "a", [ [ [ ] ] ] ]`; a list argument (`["x","y"]`) is stored correctly.
- cause: the method widens a non-list with `paPurposes = [ paPurposes ]`, reassigning its own parameter to a list that contains the parameter (the shape CLAUDE.md rule 6 warns about); the stored value is a self-containing list. Building the list in a fresh variable, as `IsMadeOfCS` does, avoids it.
- evidence: scratch run p3.ring of wave 10 (three different non-list kinds, same result; the list form works).

## stzApp.AddReaches -- a single text or symbol is stored as [ [ ] ], and Explain then raises

- method: `stzApp.AddReaches(paSurfaces)` (app/stzApp.ring); its Q twin `AddReachesQ` forwards to it
- symptom: `AddReaches("web")` and `AddReaches(:mobile)` each leave `Surfaces()` holding `[ [ [ ] ] ]` for that entry (a list argument such as `["desktop","tv"]` is stored correctly). With such an entry present, `Explain()` raises `R21 Using operator with values of incorrect type` in `_Join`, and `stzPlatform.Generate(:all)` raises the same error on that world.
- cause: the same shape as stzPlatform.SetPurposes: the parameter is widened with `paSurfaces = [ paSurfaces ]`, which makes the parameter a list containing itself. A fresh variable (CLAUDE.md rule 6) avoids it.
- evidence: scratch runs a1.ring and a2.ring of wave 10 (text "web" and symbol :mobile, two kinds of input; the list form works and Explain prints `reaches web, desktop`).

## stzPlatform.Generate -- creates the .stzapp/shells folders before it refuses an unknown reach

- method: `stzPlatform.Generate(pWhat)` (platform/stzPlatform.ring)
- symptom: a call that raises (for example for a reach of the broken shape above) has already created `.stzapp/shells` in the current folder; the run left an empty folder tree in base/test/reflect, removed by hand.
- cause: `StzMakeDir(".stzapp")` and `StzMakeDir(_cDir_)` run before the loop that validates each surface.
- evidence: wave 10 run a2.ring, then `ls .stzapp` showed `shells`. Harmless but untidy.

## stzDeploymentSite.ConfigJson / SaveConfigTo -- quotes and backslashes are not escaped

- method: `stzDeploymentSite.ConfigJson()` (system/stzDeployment.ring), and `SaveConfigTo` which writes it
- symptom: a launch command `run "x" now` gives `"launch": "run "x" now"`; an endpoint `host "main"` gives `"endpoint": "host "main""`; a storage path `C:\stage\api` gives `"storage": "C:\stage\api"`. All three are invalid JSON, so a saved site config cannot be read back by a JSON parser.
- cause: the values are concatenated between double quotes without escaping.
- evidence: wave 10 runs d2.ring (launch command) and d3.ring (endpoint and a Windows path), three different inputs.

## stzDeploymentSite.Rollback -- on a local site with no storage location, the paths become the drive root (read from the code, NOT run)

- method: `stzDeploymentSite.Rollback()` (system/stzDeployment.ring)
- symptom (expected from the code, not executed): with `SetStoreAt` never called, the local branch deletes `/deploy.json` and writes `/.stzsite` at the root of the current drive; `Store`, `Launch` and `Status` all guard an empty storage location, `Rollback` does not.
- cause: `StzFileDelete(@cStorage + "/deploy.json")` and `write(@cStorage + "/.stzsite", ...)` run with `@cStorage = ""`.
- evidence: reading the code only; not run, because the call would write outside any scratch folder.

## stzWorkflow.CriticalPath (and ViewCriticalPath) -- raises R24 when no path has a duration above zero, and always for a state machine

- method: `stzWorkflow.CriticalPath()` (graph/stzWorkflow.ring); `ViewCriticalPath` calls it first and fails the same way
- symptom: `Error (R24) : Using uninitialized variable: _accriticalpath_` for an empty workflow, for a two-step workflow with no durations set, and for a statemachine-type workflow with states and transitions (three different inputs). With a duration set on a step the same call returns `[ [path, ...], [duration, 15] ]`.
- cause: `_acCriticalPath_` is assigned only inside `if _nDuration_ > _nLongest_`, and is read in the returned list; when every path sums to 0, or the type is not sequential so the loop never runs, it was never assigned.
- evidence: wave 10 runs w1.ring, w2.ring and w4.ring.

## stzWorkflow.AddState -- the :isInitial and :isFinal fields of the stored state stay 0

- method: `stzWorkflow.AddStateXTT(pcId, pcLabel, paProps)` (graph/stzWorkflow.ring), the form behind `AddState`
- symptom: `AddStateXTT("locked", "Locked", [ :isFinal = 1 ])` leaves `State("locked")` showing `[ isfinal, 0 ]`; the flag exists only in the properties list and in the node type.
- cause: the record is built with `:isInitial = 0, :isFinal = 0` and never updated from paProps. Low impact (the diagram node type is right); recorded because a reader of State() would believe the state is not final.
- evidence: wave 10 run w2.ring (isFinal with the final state, and isInitial the same).
