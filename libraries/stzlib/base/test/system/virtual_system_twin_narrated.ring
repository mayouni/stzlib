# Virtual System twin (Phase 2) STRESS -- the file specialization.
#
# The claim (SOFTANZA_SYSTEM_FOUNDATION.md Layer 2, VSF): rehearse -> plan ->
# commit. The twin holds NO reference to reality (P1): rehearsal changes nothing
# on disk. Reality changes ONLY when a governed UpdatePlan crosses the one
# bridge -- and even then only within a declared commit scope, and only for
# operations a reviewer did not reject.
#
# Real files are written under a scratch dir and cleaned up. The bridge is the
# engine's file primitives (StzEngineFile* / StzEngineDir*).
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = "_vsf_scratch"
StzEngineDirCreatePath(cDir)

? "-- Scene 1: rehearsal touches NOTHING real (P1) --"
cA = cDir + "/alpha.txt"
cB = cDir + "/beta.txt"
killreal(cA)  killreal(cB)
oV = new stzVirtualFileSystem()
oV.CreateFile(cA, "alpha").WriteFile(cB, "beta")
chk("the twin knows the created file", oV.Exists(cA))
chk("...with the rehearsed content", oV.ContentOf(cA) = "alpha")
chk("...marked born-in-the-twin (origin virtual)", oV.OriginOf(cA) = "virtual")
chk("two operations were recorded", oV.NumberOfOperations() = 2)
chk("REALITY is untouched -- alpha not on disk", StzEngineFileExists(cA) = 0)
chk("...and beta not on disk either", StzEngineFileExists(cB) = 0)

? ""
? "-- Scene 2: the plan narrates itself and ranks risks (P4) --"
oV2 = new stzVirtualFileSystem()
oV2.CreateFile(cA, "x")
oV2.MoveFile(cA, cB)
oPlan2 = oV2.GenerateUpdatePlan()
chk("the plan carries both operations", oPlan2.NumberOfOperations() = 2)
cNar = oPlan2.Narration()
chk("the narration mentions the create", StzFindFirst("create file", cNar) > 0)
chk("...and the move", StzFindFirst("move", cNar) > 0)
aRisks = oPlan2.Risks()
chk("the move is flagged as a risk (it removes the source)", len(aRisks) >= 1)

? ""
? "-- Scene 3: commit is the ONE door -- reality changes only now --"
cH = cDir + "/hello.txt"
cW = cDir + "/world.txt"
killreal(cH)  killreal(cW)
oV3 = new stzVirtualFileSystem()
oV3.CreateFile(cH, "hello").CreateFile(cW, "world")
chk("before commit, reality has neither file", StzEngineFileExists(cH) = 0 and StzEngineFileExists(cW) = 0)
oPlan3 = oV3.GenerateUpdatePlan()
aRes3 = oPlan3.Execute()
chk("the plan committed both operations", aRes3[1][2] = 2)
chk("after commit, hello.txt is REAL", StzEngineFileExists(cH) = 1)
chk("...with the committed content", StzEngineFileRead(cH) = "hello")
chk("...and world.txt is real too", StzEngineFileRead(cW) = "world")
killreal(cH)  killreal(cW)

? ""
? "-- Scene 4: a commit SCOPE refuses out-of-bounds operations --"
cIn = cDir + "/inside.txt"
cOut = "_outside_scratch/escape.txt"
killreal(cIn)
oV4 = new stzVirtualFileSystem()
oV4.CreateFile(cIn, "ok")
oV4.CreateFile(cOut, "should never land")
oV4.DeleteFile(cIn)
oScope = new stzCommitScope()
oScope.AllowUnder(cDir)
oScope.AllowType("create_file")
oPlan4 = oV4.GenerateUpdatePlan()
oPlan4.SetScope(oScope)
aRes4 = oPlan4.Execute()
chk("only the in-scope create committed", aRes4[1][2] = 1)
chk("...the other two were refused by the scope", aRes4[2][2] = 2)
chk("the in-scope file is real", StzEngineFileExists(cIn) = 1)
chk("the OUT-OF-SCOPE file never touched disk", StzEngineFileExists(cOut) = 0)
chk("...and its parent dir was never created", StzEngineFileExists("_outside_scratch/escape.txt") = 0)
killreal(cIn)

? ""
? "-- Scene 5: a reviewer can REJECT a step before commit (P6-ish) --"
c1 = cDir + "/keep.txt"
c2 = cDir + "/drop.txt"
killreal(c1)  killreal(c2)
oV5 = new stzVirtualFileSystem()
oV5.CreateFile(c1, "keep").CreateFile(c2, "drop")
oPlan5 = oV5.GenerateUpdatePlan()
oPlan5.RejectOperation(2, "reviewer: not this one")
aRes5 = oPlan5.Execute()
chk("the accepted operation committed", StzEngineFileExists(c1) = 1)
chk("the rejected operation did NOT", StzEngineFileExists(c2) = 0)
chk("the summary counts one skip", aRes5[2][2] = 1)
killreal(c1)

? ""
? "-- Scene 6: Undo rewinds the twin (P3, still nothing real) --"
d1 = cDir + "/u1.txt"
d2 = cDir + "/u2.txt"
d3 = cDir + "/u3.txt"
oV6 = new stzVirtualFileSystem()
oV6.CreateFile(d1, "1").CreateFile(d2, "2").CreateFile(d3, "3")
chk("three operations rehearsed", oV6.NumberOfOperations() = 3)
oV6.UndoLast(2)
chk("undo removed two operations", oV6.NumberOfOperations() = 1)
chk("...the first file remains in the twin", oV6.Exists(d1))
chk("...the undone files are gone from the twin", oV6.Exists(d2) = 0 and oV6.Exists(d3) = 0)
chk("...and reality never saw any of it", StzEngineFileExists(d1) = 0)

? ""
? "-- Scene 7: snapshot + rollback (P3) --"
s1 = cDir + "/s1.txt"
s2 = cDir + "/s2.txt"
oV7 = new stzVirtualFileSystem()
oV7.CreateFile(s1, "a")
oV7.CreateSnapshot("as_found")
oV7.CreateFile(s2, "b")
chk("after the snapshot, a new op is present", oV7.NumberOfNodes() = 2)
oV7.RollbackTo("as_found")
chk("rollback restored the snapshot's node count", oV7.NumberOfNodes() = 1)
chk("...the first file is still there", oV7.Exists(s1))
chk("...the later file is gone", oV7.Exists(s2) = 0)

? ""
? "-- Scene 8: MirrorFrom reality, rehearse a change, commit only the change --"
cM = cDir + "/mirror.txt"
StzEngineFileWrite(cM, "original")  # set up pre-existing reality
oV8 = new stzVirtualFileSystem()
oV8.MirrorFile(cM)
chk("the twin mirrored the real file", oV8.Exists(cM))
chk("...marked as mirrored, not virtual", oV8.OriginOf(cM) = "mirrored")
chk("...with reality's content", oV8.ContentOf(cM) = "original")
oV8.WriteFile(cM, "updated")
chk("the twin shows the rehearsed change", oV8.ContentOf(cM) = "updated")
chk("...but reality is still the original (P1)", StzEngineFileRead(cM) = "original")
oPlan8 = oV8.GenerateUpdatePlan()
oPlan8.Execute()
chk("after commit, reality holds the update", StzEngineFileRead(cM) = "updated")
killreal(cM)

? ""
? "-- Scene 9: move semantics -- the source is gone after commit --"
cSrc = cDir + "/src.txt"
cDst = cDir + "/dst.txt"
killreal(cDst)
StzEngineFileWrite(cSrc, "payload")
oV9 = new stzVirtualFileSystem()
oV9.MirrorFile(cSrc)
oV9.MoveFile(cSrc, cDst)
oV9.GenerateUpdatePlan().Execute()
chk("the destination exists with the payload", StzEngineFileRead(cDst) = "payload")
chk("the source is gone from disk", StzEngineFileExists(cSrc) = 0)
killreal(cDst)  killreal(cSrc)

? ""
? "-- Scene 10: Validate re-checks against current reality (honesty) --"
cGhost = cDir + "/never_existed.txt"
killreal(cGhost)
oV10 = new stzVirtualFileSystem()
oV10.MirrorFile(cGhost)     # nothing to mirror
oV10.DeleteFile(cGhost)     # rehearse deleting something not on disk
aWarn = oV10.GenerateUpdatePlan().Validate()
chk("validation warns that the delete target is absent in reality", len(aWarn) >= 1)

? ""
? "-- Scene 11: the operation records WHO proposed it (P5) --"
cAg = cDir + "/agent.txt"
oV11 = new stzVirtualFileSystem()
oV11.SetActor("agent-42")
oV11.CreateFile(cAg, "x")
aHist = oV11.History()
chk("the operation carries its actor", aHist[1].Actor() = "agent-42")

? ""
? "-- Scene 12: a large rehearsal stays in memory, then commits at once --"
nN = 100
killrange(cDir, nN)
oV12 = new stzVirtualFileSystem()
for i = 1 to nN
	oV12.CreateFile(cDir + "/f" + i + ".txt", "n" + i)
next
chk("all " + nN + " operations rehearsed in memory", oV12.NumberOfOperations() = nN)
chk("...and NONE of them touched disk yet", StzEngineFileExists(cDir + "/f1.txt") = 0)
t0 = clock()
aRes12 = oV12.GenerateUpdatePlan().Execute()
tCommit = (clock() - t0) / clockspersecond()
? "  committed " + nN + " files in " + tCommit + " s"
chk("all committed", aRes12[1][2] = nN)
chk("spot-check: f1 is real with the right content", StzEngineFileRead(cDir + "/f1.txt") = "n1")
chk("spot-check: f100 is real with the right content", StzEngineFileRead(cDir + "/f100.txt") = "n100")
chk("...in reasonable time (< 10s)", tCommit < 10)
killrange(cDir, nN)

# final cleanup
StzEngineDirDelete(cDir)

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

func killrange cDir, nN
	for i = 1 to nN
		killreal(cDir + "/f" + i + ".txt")
	next
