# Wave 12 defects -- stzPlatformProfile and the other classes of agent 12a

Found by calling each method on invented data (scratch folders only, loopback only, no model, no credential). Nothing was fixed. Each item: method, symptom, cause, evidence. "Located" means read in the code; "not located" means the cause was not traced.

## optim/stzOptimModel.ring

1. **stzOptimModel.Solve, SolveWith** -- a model with no constraint raises `stzOptimModel.Solve: the engine refused the model -- check that every coefficient row has one entry per variable`. The comment in `_SolveFloor` says "a model with no constraints still solves -- the bounds ARE the feasible region". Cause: not located; with zero rows the code passes empty `_aMat_`, `_aSense_`, `_aRhs_` to `StzEngineOptimSolve` and that answers a non-list. Evidence: three models, all raised: `x >= 0` maximize x; `0 <= x <= 7` maximize 2*x; `a in [0,2], b in [0,3]` maximize a + b. The same bounded model with one added constraint (`x <= 100`) solves (objective 14).
2. (behaviour, documented as a warning) **Solution** and **ConstraintAt** raise error R2 (index out of range) before any solve and for an index outside the list.

## table/stzPivotTable.ring

3. **stzPivotTable.Generate (Ring fallback)** -- the fallback that takes every shape the engine fast path does not (more than one column label, more than two row labels, more than one value column) drops the first source record. Cause: not located (the record count of the fallback is one short). Evidence, four datasets: Tunis/2023/10 missing from a REGION x [CITY, YEAR] pivot; a leading ("z","w","w",0) row never appears as a heading; x/p for the first record empty in a 3-row table; AVG of a/x/p with 10 and 20 gives 20, the second record alone.
4. **stzPivotTable.RowTotal, ColumnTotal, GrandTotal, ToTable (engine path)** -- for every aggregate other than SUM and COUNT the total row and total column hold the sum of the cells, not the aggregate over the rows. Cause: not located (in the engine cross-tab). Evidence: values a/x = 10 and 20, a/y = 6: AVG gives cells 15 and 6 and a row total of 21 where the average of 10, 20, 6 is 12; MAX gives total 26 where the maximum is 20; MIN, MEDIAN and PRODUCT show the same shape; on the city data AVG gives a grand total of 36.
5. **stzPivotTable.Show** -- raises for two column labels, with one of two messages: `Indexes out of range! n1 and n2 must be inside the string.` (1 row label by 2 column labels on a 3-record dataset; 2 by 2 on a 4-record dataset) or `Error (R20) : Calling function with extra number of parameters` (1 by 2 on a 4-record dataset; 2 by 2 and 1 by 2 on a 5-record dataset). Five calls on four datasets, all raised. Cause: not located. 1 by 1 and 2 by 1 display. Also cosmetic: the total row is printed below the closing border of the box.
6. **stzPivotTable.SaveToFile, LoadFromFile** -- SaveToFile writes an empty file (two datasets); LoadFromFile of that file raises `Incorrect param format! paTable must be a list`. Cause: located, `write(cFileName, list2str(_aSerializedData_))`: `list2str` of a list holding lists answers the empty text (checked: `list2str([["a",1],["b",2]])` is empty, `list2str(["a","b"])` is two lines).
7. **stzPivotTable.SetAggregateFunction** -- an unknown function name silently sums (`_AggFuncToInt` returns 0) and still names the totals after the unknown word (`FOO`). Evidence: one call.

## system/stzPlatformProfile.ring

8. **stzAppProfile.System and stzPlatformProfile.App** -- the scope is meant to be RETAINED so operations accumulate, but a result assigned to a variable is a copy (Ring copies an object on assignment). The usage block at the head of the file does exactly that (`oScope = oProfile.App(:firmware).System()`; `oScope.ReadPin(4)`): the copy records the operation, the retained scope stays empty, so `App().Scope()` and `stzLoweringBridge.Lower(App().Scope())` see nothing. Evidence: three apps, `oS = a.System(); oS.WritePin(2, 1)` leaves `a.Scope().NumberOfChecked()` at 0 while the chained `a.System().ReadPin(4)` gives 1; the same through a stzPlatformProfile part. The same copy rule applies to `oB = p.App("x")` followed by `oB.SetKind(...)`.

## governance/stzGovernance.ring

9. **stzGovernance.Save, LoadFrom** -- the .zgov file holds risks, permissions, authorities, postures, reversibility and decisions; commitments (OpenCommitment, AdvanceCommitment) and decommission contracts are not written, so they are lost on a reload. Evidence: the file written in a probe has no such section. Not necessarily unintended; recorded as a warning in the block.

## appserver/stzAppBackend.ring

10. **stzAppBackend.Dashboard** -- raises `Error (R41) : Invalid numeric string` for a part whose dataset is not a name followed by a quantity: the menu dataset (name, description, price) fed `ring_number("semolina + 7 vegetables")`. Evidence: one call on the phone part of the restolean model; the admin part's orders dataset works.
11. **stzAppBackend.Rows** -- a cell holding a comma comes back as two cells (`"slow-cooked, clay pot"` becomes two). Cause: located and documented in `_ParseRowsJson` (the reply is cut on commas). Evidence: one call.

## security/stzSecurityDrill.ring

12. **stzSecurityDrill.Explain** -- with an acquired ledger and no expectation (no Fire call) the verdict reads `MISSED: .` with an empty list. Seen on a rehearsal double, one dataset.
13. **stzDrillRemoteResponder.RotateSecret, RevokeCapability, ShedSource, QuarantinePart** -- read from the code, not run: the generated target script wires only lockaccount and revokesession on its /contain route, so these four reach `not wired` and `_ContainRemote` raises.

## What was not run, and why

- stzSecurityDrill.SpawnTarget, WaitReady (and the real _Get under every Fire method, CollectEvidence, OpenVictimSession, Contain and ContainmentHolds): they start a second process, open a port and write a generated script beside the security sources. The other methods were run in this process on a rehearsal double (a subclass that answers the target's routes from an in-process stzAuth, stzRequestSigner and ledger).
- stzAppBackend.SpawnRemote, SpawnRemoteOn, RemoteLaunchCommands, ExplainRemoteLaunch, WaitReady and the remote branch of IsReachable: they spawn a process, send requests, or write generated files beside the sources. Only the local loopback mode (Start(0), in this process) and the harmless remote-mode setters (ConnectTo, ReachAt, Stop) were run.
- stzDeclaredLLMAgent: no model was called; the tick was run with a seeded answer and without one (refused, no model loaded).
- stzFileBlobStore wrote only inside a fixture folder under the scratchpad.
