# Process/Environment twin (Phase 3) STRESS -- same rehearse -> plan -> commit
# machinery as the file twin, now over env vars, the working directory, and a
# queue of process spawns.
#
# The claim: env/process effects are invisible until they happen -- so the twin
# is where they become visible BEFORE they happen. Rehearsal sets no real var,
# changes no real dir, spawns no child (P1). Reality changes only on
# plan.Execute(), only within a declared commit scope, only for un-rejected ops.
#
# The bridge is stzEnvironment's effectful verbs + the global SpawnProcess.
# Spawns are proven-not-run by a marker file they would create. Real env vars
# and the cwd are restored at the end.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oReal = new stzEnvironment()
cCwd0 = oReal.Cwd()
cScratch = cCwd0 + "/_venv_scratch"
StzEngineDirCreatePath(cScratch)
scrub("STZ_VE_A")  scrub("STZ_VE_B")  scrub("STZ_VE_MIR")  scrub("STZ_VE_OK")  scrub("STZ_VE_OTHER")

? "-- Scene 1: rehearsing env changes touches NOTHING real (P1) --"
oE = new stzVirtualEnvironment()
oE.SetVar("STZ_VE_A", "alpha").SetVar("STZ_VE_B", "beta")
chk("the twin holds the rehearsed var", oE.Var("STZ_VE_A") = "alpha")
chk("...marked born-in-the-twin", oE.OriginOfVar("STZ_VE_A") = "virtual")
chk("two operations recorded", oE.NumberOfOperations() = 2)
chk("the REAL environment does not have it", realHas("STZ_VE_A") = 0)

? ""
? "-- Scene 2: MirrorReality reads the live environment in --"
oE2 = new stzVirtualEnvironment()
oE2.MirrorReality()
chk("the twin mirrored many real vars", oE2.NumberOfVars() > 0)
chk("...including PATH", oE2.HasVar("PATH") or oE2.HasVar("Path"))
chk("...marked mirrored, not virtual", oE2.OriginOfVar("PATH") = "mirrored" or oE2.OriginOfVar("Path") = "mirrored")
chk("the twin knows the real working directory", len(oE2.Cwd()) > 2)

? ""
? "-- Scene 3: rehearse a change ON TOP of the mirror (still nothing real) --"
oE2.SetVar("STZ_VE_MIR", "on-top")
chk("the twin shows the new var", oE2.Var("STZ_VE_MIR") = "on-top")
chk("...but the real environment still does not", realHas("STZ_VE_MIR") = 0)

? ""
? "-- Scene 4: commit sets the real environment variable --"
oE4 = new stzVirtualEnvironment()
oE4.SetVar("STZ_VE_A", "committed-value")
chk("before commit, the real var is absent", realHas("STZ_VE_A") = 0)
oE4.GenerateUpdatePlan().Execute()
chk("after commit, the real var is set", realVar("STZ_VE_A") = "committed-value")
scrub("STZ_VE_A")
chk("...and unset cleans it back up", realHas("STZ_VE_A") = 0)

? ""
? "-- Scene 5: a queued spawn does NOT run until commit (P1) --"
cMark = cScratch + "/ran.txt"
killreal(cMark)
oE5 = new stzVirtualEnvironment()
oE5.Spawn("cmd.exe /c echo ran> " + cMark)
chk("the spawn is queued in the twin", oE5.NumberOfPendingSpawns() = 1)
chk("...and nothing ran -- the marker is absent", StzEngineFileExists(cMark) = 0)
oE5.GenerateUpdatePlan().Execute()
chk("after commit, the command ran -- the marker exists", StzEngineFileExists(cMark) = 1)
killreal(cMark)

? ""
? "-- Scene 6: a commit SCOPE refuses out-of-bounds env/process ops --"
cScopeMark = cScratch + "/scope_ran.txt"
killreal(cScopeMark)
oE6 = new stzVirtualEnvironment()
oE6.SetVar("STZ_VE_OK", "in")
oE6.SetVar("STZ_VE_OTHER", "out")
oE6.Spawn("cmd.exe /c echo x> " + cScopeMark)
oScope = new stzCommitScope()
oScope.AllowType("set_var")
oScope.AllowUnder("STZ_VE_OK")
oPlan6 = oE6.GenerateUpdatePlan()
oPlan6.SetScope(oScope)
aRes6 = oPlan6.Execute()
chk("only the in-scope var committed", aRes6[1][2] = 1)
chk("...the other two were refused", aRes6[2][2] = 2)
chk("the in-scope var is really set", realVar("STZ_VE_OK") = "in")
chk("the out-of-scope var never touched the environment", realHas("STZ_VE_OTHER") = 0)
chk("the refused spawn never ran", StzEngineFileExists(cScopeMark) = 0)
scrub("STZ_VE_OK")

? ""
? "-- Scene 7: the plan narrates and flags process/env risks --"
oE7 = new stzVirtualEnvironment()
oE7.SetVar("STZ_VE_A", "x").UnsetVar("STZ_VE_A").Spawn("cmd.exe /c echo hi")
oPlan7 = oE7.GenerateUpdatePlan()
cNar = oPlan7.Narration()
chk("the narration mentions setting a var", StzFindFirst("set env var", cNar) > 0)
chk("...and spawning", StzFindFirst("spawn process", cNar) > 0)
aRisk = oPlan7.Risks()
chk("the unset and the spawn are both flagged as risks", len(aRisk) = 2)

? ""
? "-- Scene 8: a reviewer can reject an operation before commit --"
oE8 = new stzVirtualEnvironment()
oE8.SetVar("STZ_VE_A", "keep").SetVar("STZ_VE_B", "drop")
oPlan8 = oE8.GenerateUpdatePlan()
oPlan8.RejectOperation(2, "reviewer: leave STZ_VE_B alone")
oPlan8.Execute()
chk("the accepted var committed", realVar("STZ_VE_A") = "keep")
chk("the rejected var did NOT", realHas("STZ_VE_B") = 0)
scrub("STZ_VE_A")

? ""
? "-- Scene 9: undo and snapshot rewind the twin (nothing real) --"
oE9 = new stzVirtualEnvironment()
oE9.SetVar("STZ_VE_A", "1")
oE9.CreateSnapshot("as_found")
oE9.SetVar("STZ_VE_B", "2").Spawn("cmd.exe /c echo z")
chk("three operations rehearsed", oE9.NumberOfOperations() = 3)
oE9.UndoLast(1)
chk("undo dropped the last op", oE9.NumberOfOperations() = 2 and oE9.NumberOfPendingSpawns() = 0)
oE9.RollbackTo("as_found")
chk("rollback returned to the snapshot", oE9.NumberOfOperations() = 1 and oE9.HasVar("STZ_VE_B") = 0)
chk("...and the real environment saw none of it", realHas("STZ_VE_A") = 0)

? ""
? "-- Scene 10: commit a working-directory change, then restore --"
oE10 = new stzVirtualEnvironment()
oE10.Cd(cScratch)
chk("before commit, the real cwd is unchanged", StzFindFirst("_venv_scratch", realCwd()) = 0)
oE10.GenerateUpdatePlan().Execute()
chk("after commit, the real cwd moved into the scratch dir", StzFindFirst("_venv_scratch", realCwd()) > 0)
oRestore = new stzEnvironment()
oRestore.ChangeDirectory(cCwd0)
chk("...and we can restore the original cwd", StzFindFirst("_venv_scratch", realCwd()) = 0)

? ""
? "-- Scene 11: 'this will spawn 3 children' -- queued, then all commit --"
cM1 = cScratch + "/c1.txt"
cM2 = cScratch + "/c2.txt"
cM3 = cScratch + "/c3.txt"
killreal(cM1)  killreal(cM2)  killreal(cM3)
oE11 = new stzVirtualEnvironment()
oE11.Spawn("cmd.exe /c echo 1> " + cM1)
oE11.Spawn("cmd.exe /c echo 2> " + cM2)
oE11.Spawn("cmd.exe /c echo 3> " + cM3)
chk("three spawns queued", oE11.NumberOfPendingSpawns() = 3)
chk("...none has run yet", StzEngineFileExists(cM1) = 0 and StzEngineFileExists(cM3) = 0)
aRes11 = oE11.GenerateUpdatePlan().Execute()
chk("all three committed", aRes11[1][2] = 3)
chk("...and all three children ran", StzEngineFileExists(cM1) = 1 and StzEngineFileExists(cM2) = 1 and StzEngineFileExists(cM3) = 1)
killreal(cM1)  killreal(cM2)  killreal(cM3)

? ""
? "-- Scene 12: the operation records WHO proposed it (P5) --"
oE12 = new stzVirtualEnvironment()
oE12.SetActor("deploy-bot")
oE12.SetVar("STZ_VE_A", "x")
chk("the operation carries its actor", oE12.History()[1].Actor() = "deploy-bot")

# final cleanup
scrub("STZ_VE_A")  scrub("STZ_VE_B")  scrub("STZ_VE_MIR")  scrub("STZ_VE_OK")  scrub("STZ_VE_OTHER")
StzEngineDirDelete(cScratch)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func killreal cPath
	if StzEngineFileExists(cPath) = 1
		StzEngineFileDelete(cPath)
	ok

func scrub cVarName
	oEnvX = new stzEnvironment()
	if oEnvX.Has(cVarName)
		oEnvX.UnsetVar(cVarName)
	ok

# Real-environment reads, wrapped so the call sites avoid the inline
# new-then-call form (R13).
func realHas cName
	oEnvR = new stzEnvironment()
	return oEnvR.Has(cName)

func realVar cName
	oEnvR = new stzEnvironment()
	return oEnvR.Var(cName)

func realCwd
	oEnvR = new stzEnvironment()
	return oEnvR.Cwd()
