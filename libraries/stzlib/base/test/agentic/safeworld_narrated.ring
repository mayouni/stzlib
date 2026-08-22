# THE SAFE WORLD, BOUND TO THE AGENTS -- ruling 3.2 made runnable
#
# `Agents That Cannot Hurt You` said: build a safe world and let ordinary
# agents loose inside it. The safe world existed (stzVirtualFileSystem,
# stzUpdatePlan) and no agent had ever been handed it. This suite is the
# introduction, checked:
#
#   Scene 1  REVERSIBILITY is R4b's sixth declarable contract, and it
#            survives a .zgov round trip
#   Scene 2  the REGISTRATION GATE refuses in the engine's own words --
#            one rule, two doors, same sentences (AGENTLOOP-R4 / R5)
#   Scene 3  posture x reversibility: the whole composition table
#   Scene 4  the .pia v2 court: a ring: clause carries a posture or the
#            file is refused -- and v1 is still read, the stated
#            migration state
#   Scene 5  what a v2 file declares lands in the agent's OWN governance
#   Scene 6  the WORKBENCH: an agent's ring: function writes a file, the
#            disk does not move, the tick's only export is a plan, and a
#            committing actor -- not the agent -- changes reality
#   Scene 7  the roster as first consumer: ledger-roll rehearses the
#            SAME relocation it used to perform directly, the plan
#            commits it, and the ledger comes out identical
#
# Everything here is deterministic, offline, and seconds long. Fixtures
# are built by the script and deleted at the end.
#
# THE HELPERS AND RING-FUNCTIONS LIVE AFTER pf() -- Ring runs top-level
# code only up to the first `func`.

load "../../stzBase.ring"

nPass = 0
nFail = 0

cHere = StzReplace(WorkingDirectory(), "\", "/")
cFx = cHere + "/_safeworld-fixture"
$cSafeworldOut = cFx + "/scribble.txt"

if StzDirExists(cFx)
	StzDirDeleteAll(cFx)
ok
StzDirCreatePath(cFx)

pr()

#=====================================================================#
? "-- Scene 1: reversibility is the SIXTH declarable contract --"
#=====================================================================#

oGov = new stzGovernance("safeworld-regime")
chk("an undeclared subject has no class -- absence is answerable",
	oGov.ReversibilityOf("roll-ledger") = "")

oGov.DeclareReversibility("roll-ledger", :Compensable)
chk("a declared class reads back", oGov.ReversibilityOf("roll-ledger") = "compensable")

oGov.DeclareReversibility("roll-ledger", :Reversible)
chk("re-declaring UPDATES rather than duplicates",
	oGov.ReversibilityOf("roll-ledger") = "reversible")

bRaised = 0
try
	oGov.DeclareReversibility("roll-ledger", "undoable-ish")
catch
	bRaised = 1
done
chk("a word outside the three-class vocabulary RAISES -- the .pia words " +
    "are the contract's whole vocabulary", bRaised = 1)

# the contract travels with the regime it composes against
oGov.DeclarePosture("RollRelocateMonths", :Trusted)
cZgov = cFx + "/safeworld-regime.zgov"
oGov.Save(cZgov)
oBack = new stzGovernance("reloaded")
oBack.LoadFrom(cZgov)
chk("a .zgov round trip carries the sixth contract",
	oBack.ReversibilityOf("roll-ledger") = "reversible")
chk("...beside the posture it composes with",
	oBack.PostureOf("RollRelocateMonths") = "trusted")

? ""
#=====================================================================#
? "-- Scene 2: the registration gate, in the engine's own words --"
#=====================================================================#
# MayProceed gates ACTS; MayRegister gates EXISTENCE IN THE LOOP, asked
# before any tick. The sentences are agentloop.zig's refusals quoted
# verbatim (minus the engine's slot number), so a caller meeting the
# refusal in either door reads the same law.

chk("no coverage statement -> refused", oGov.MayRegister("mystery-bot", "", "reversible") = 0)
chk("...as AGENTLOOP-R4", len(StzFind("AGENTLOOP-R4", oGov.Why())) > 0)
chk("...in the engine's sentence",
	len(StzFind("nothing schedules what nobody has stated the reach of", oGov.Why())) > 0)

chk("no reversibility class -> refused",
	oGov.MayRegister("mystery-bot", "covers something real", "") = 0)
chk("...as AGENTLOOP-R5", len(StzFind("AGENTLOOP-R5", oGov.Why())) > 0)
chk("...in the engine's sentence",
	len(StzFind("cannot be scheduled by something that cannot undo it", oGov.Why())) > 0)

chk("a class outside the vocabulary is the ABSENCE of a class, refused the same way",
	oGov.MayRegister("mystery-bot", "covers something real", "mostly") = 0)

chk("coverage stated and reversal declared -> registration is free",
	oGov.MayRegister("mystery-bot", "covers something real", :Compensable) = 1)

? ""
#=====================================================================#
? "-- Scene 3: posture x reversibility -- the whole table --"
#=====================================================================#
# the harder an act is to undo, the more trusted the code performing it
# must be. One sentence rules it, and this scene walks every cell.

chk("trusted covers reversible",     StzPostureReversibilityRefusal("trusted", "reversible") = "")
chk("trusted covers compensable",    StzPostureReversibilityRefusal("trusted", "compensable") = "")
chk("trusted covers irreversible",   StzPostureReversibilityRefusal("trusted", "irreversible") = "")
chk("external covers reversible",    StzPostureReversibilityRefusal("external", "reversible") = "")
chk("external covers compensable",   StzPostureReversibilityRefusal("external", "compensable") = "")
chk("external does NOT cover irreversible",
	StzPostureReversibilityRefusal("external", "irreversible") != "")
chk("sandboxed covers reversible",   StzPostureReversibilityRefusal("sandboxed", "reversible") = "")
chk("sandboxed does NOT cover compensable",
	StzPostureReversibilityRefusal("sandboxed", "compensable") != "")
chk("sandboxed does NOT cover irreversible",
	StzPostureReversibilityRefusal("sandboxed", "irreversible") != "")
chk("...and a refusal says WHY in the one ruled sentence",
	len(StzFind("the harder an act is to undo",
		StzPostureReversibilityRefusal("sandboxed", "irreversible"))) > 0)

# the same rule through the governed door: a declared executor judged
# against a class it may not touch
oGov.DeclarePosture("SketchyHelper", :Sandboxed)
chk("MayExecuteFor composes the declared posture with the class",
	oGov.MayExecuteFor("SketchyHelper", "compensable") = 0)
chk("...quoting the same sentence",
	len(StzFind("the harder an act is to undo", oGov.Why())) > 0)
chk("...and allows what the posture covers",
	oGov.MayExecuteFor("SketchyHelper", "reversible") = 1)
chk("an executor with NO declared posture never executes at all",
	oGov.MayExecuteFor("NeverDeclared", "reversible") = 0)

? ""
#=====================================================================#
? "-- Scene 4: the .pia v2 court -- a ring: clause carries a posture --"
#=====================================================================#

cV2Good = "pia: 2
name: scribbler
kind: pi
coverage: writes one probe file into its workbench and records that it did
reversibility: compensable
schedule:
  timer: 20
skills:
  - name: scribble
    when: always
    does: ring:SafeworldScribble
    verify: fact note was scribbled
    posture: trusted
"
oD = StzAgentDeclarationQ(cV2Good)
chk("a v2 skill with ring: AND posture is admitted", oD.IsValid() = 1)
chk("...and the build reports the version it read", oD.FormatVersion() = 2)

cNoPost = StzReplace(cV2Good, "    posture: trusted" + char(10), "")
oD2 = StzAgentDeclarationQ(cNoPost)
chk("the same file WITHOUT the posture is refused", oD2.IsValid() = 0)
chk("...naming the rule", len(StzFind("pia-posture", oD2.CiteFindings())) > 0)
chk("...and saying what the posture adds over the name check",
	len(StzFind("on what TERMS it may run", oD2.CiteFindings())) > 0)

oD3 = StzAgentDeclarationQ(StzReplace(cV2Good, "posture: trusted", "posture: cozy"))
chk("a posture word the vocabulary does not know is refused", oD3.IsValid() = 0)

cNoRing = StzReplace(cV2Good, "does: ring:SafeworldScribble",
	"does: learn note was scribbled")
oD4 = StzAgentDeclarationQ(cNoRing)
chk("a posture on a skill with NO ring: clause governs nothing -- refused",
	oD4.IsValid() = 0)

# the composition, at the court: an irreversible agent may not hand its
# does: slot to sandboxed code
cIrrev = StzReplace(StzReplace(cV2Good, "reversibility: compensable",
	"reversibility: irreversible"), "posture: trusted", "posture: sandboxed")
oD5 = StzAgentDeclarationQ(cIrrev)
chk("sandboxed code acting for an irreversible agent is refused AT LOAD",
	oD5.IsValid() = 0)
chk("...in the composition rule's own sentence",
	len(StzFind("the harder an act is to undo", oD5.CiteFindings())) > 0)

# the migration state, stated and checked
cV1 = StzReplace(cNoPost, "pia: 2", "pia: 1")
oD6 = StzAgentDeclarationQ(cV1)
chk("a v1 file with a bare ring: clause is STILL admitted -- the stated " +
    "migration state", oD6.IsValid() = 1)
oD7 = StzAgentDeclarationQ(StzReplace(cV2Good, "pia: 2", "pia: 1"))
chk("but v1's vocabulary did not grow: posture in a v1 file is an unknown key",
	oD7.IsValid() = 0 and len(StzFind("pia-unknown-key", oD7.CiteFindings())) > 0)
oD8 = StzAgentDeclarationQ(StzReplace(cV2Good, "pia: 2", "pia: 3"))
chk("a version this build does not know is refused, naming what it does know",
	oD8.IsValid() = 0 and len(StzFind("1 and 2", oD8.CiteFindings())) > 0)

? ""
#=====================================================================#
? "-- Scene 5: what the file declares lands in the agent's governance --"
#=====================================================================#

oScrib = oD.ToAgent()
chk("the agent's own governance holds the sixth contract",
	oScrib.GovernanceQ().ReversibilityOf("scribbler") = "compensable")
chk("...and the ring function's posture",
	oScrib.GovernanceQ().PostureOf("SafeworldScribble") = "trusted")
chk("...so MayExecuteFor answers for the code the file named",
	oScrib.GovernanceQ().MayExecuteFor("SafeworldScribble", "compensable") = 1)

# the v1-built twin records the ABSENCE: its ring functions stand in
# governance with no posture, and execution is refused rather than assumed
oV1Ag = oD6.ToAgent()
chk("a v1 agent's ring function has NO declared posture -- MayExecute refuses",
	oV1Ag.GovernanceQ().MayExecute("SafeworldScribble") = 0)
chk("...but its reversibility class still lands -- contract 6 does not " +
    "depend on the version bump",
	oV1Ag.GovernanceQ().ReversibilityOf("scribbler") = "compensable")

? ""
#=====================================================================#
? "-- Scene 6: the workbench -- rehearse, export a plan, and only a --"
? "             committing actor changes reality --"
#=====================================================================#

oScrib.GiveWorkbench()
chk("outside a tick there is no ambient workbench", StzInWorkbench() = 0)

chk("one cycle fires the skill and verifies it", oScrib.Cycle() = 1)
chk("...the ambient was restored on the way out", StzInWorkbench() = 0)
chk("...the memory fact is written -- expression was free",
	oScrib.MemoryQ().Fact("note", "was", "scribbled") = 1)
chk("...and THE DISK DID NOT MOVE -- the write landed in the twin",
	StzFileExists($cSafeworldOut) = 0)
chk("...where it is readable", oScrib.WorkbenchQ().ContentOf($cSafeworldOut) = "scribbled-by-agent")

oPlan = oScrib.GenerateUpdatePlan()
chk("the tick's only export is a PLAN, carrying the rehearsed operation",
	oPlan.NumberOfOperations() = 1)
chk("...that narrates itself, naming the file",
	len(StzFind("scribble.txt", oPlan.Narration())) > 0)

# an LLM cannot be the committing actor -- the capability gate answers
# BEFORE anything is attempted
oPlan.SetExecutor(LLMActor("eager-llm"))
aMay = oPlan.MayCommit()
chk("an LLM executor cannot commit -- MayCommit says no before any attempt",
	aMay[1] = 0)
chk("...naming the missing capability", len(StzFind("effectful", aMay[2])) > 0)

# a scope that does not cover the path refuses the crossing
oPlan2 = oScrib.GenerateUpdatePlan()
oPlan2.SetExecutor(PIActor("scoped-committer"))
oScope2 = new stzCommitScope()
oScope2.AllowUnder("/somewhere/else")
oPlan2.SetScope(oScope2)
aRes = oPlan2.Execute()
chk("a scope that does not cover the path commits NOTHING", aRes[1][2] = 0)
chk("...and the disk still did not move", StzFileExists($cSafeworldOut) = 0)

# the committing actor, in scope: reality changes HERE and only here
oPlan3 = oScrib.GenerateUpdatePlan()
oPlan3.SetExecutor(PIActor("the-committer"))
oScope3 = new stzCommitScope()
oScope3.AllowUnder(cFx)
oPlan3.SetScope(oScope3)
aRes = oPlan3.Execute()
chk("the committing actor commits it", aRes[1][2] = 1)
chk("...NOW the file is real", StzFileExists($cSafeworldOut) = 1)
chk("...with the rehearsed content", StzFileRead($cSafeworldOut) = "scribbled-by-agent")
chk("...and the plan's audit trail names actor and outcome",
	oPlan3.NumberOfAuditEntries() = 1 and oPlan3.AuditTrail()[1][2] = "committed")

? ""
#=====================================================================#
? "-- Scene 7: the roster, rehearsing the relocation it used to do --"
#=====================================================================#
# ledger-roll's ring functions now reach files through the safe-world
# door. Same functions, same .pia shape (bumped to v2 with the posture),
# a workbench under them -- and the estate's ledger does not move until
# the plan is committed. The outcome must be IDENTICAL to what the
# direct path produces, which roster_narrated.ring pins.

cEstate = cFx + "/central"
StzDirCreatePath(cEstate + "/dashboard")
StzDirCreatePath(cEstate + "/journal")
SetEnvVar("STZ_SOFTANZA_ROOT", cEstate)

cOld = "2000-01"
cCur = _StzRosterCurrentMonth()
StzFileWrite(cEstate + "/journal/" + cOld + "-scar.md", "an old journal entry" + char(10))
StzFileWrite(cEstate + "/journal/" + cCur + "-fresh.md", "this month's entry" + char(10))
StzFileWrite(cEstate + "/dashboard/SESSION-LOG.md",
	"# SESSION-LOG" + char(10) +
	char(10) +
	cOld + "-15 09:00 | someone | something that happened long ago" + char(10) +
	cCur + "-01 09:00 | someone | something happening this month" + char(10))

cRollV2 = "pia: 2
name: ledger-roll
kind: pi
coverage: moves journal and session-log months before the current one into archive and leaves a pointer in the live file
reversibility: reversible
schedule:
  event: roll
governance:
  authority: delegated
  risks:
    relocate-evidence: 2
  grants:
    - relocate-evidence
skills:
  - name: relocate
    when: always
    does: ring:RollRelocateMonths
    verify: fact archive holds month
    effect: relocate-evidence
    posture: trusted
  - name: pointer
    when: fact archive holds month
    does: ring:RollWritePointer
    verify: fact ledger holds pointer
    effect: relocate-evidence
    posture: trusted
"
oRollD = StzAgentDeclarationQ(cRollV2)
chk("the v2 ledger-roll declaration is admitted", oRollD.IsValid() = 1)

oRoll = oRollD.ToAgent()
oRoll.GiveWorkbench()
chk("one cycle relocates AND writes the pointer IN THE TWIN -- both verified",
	oRoll.Cycle() = 2)

chk("the real journal file DID NOT MOVE",
	StzFileExists(cEstate + "/journal/" + cOld + "-scar.md") = 1)
chk("...and no real archive appeared",
	StzFileExists(cEstate + "/journal/archive/" + cOld + "-scar.md") = 0)
chk("...the real SESSION-LOG is untouched",
	len(StzFind("Rolled ", StzFileRead(cEstate + "/dashboard/SESSION-LOG.md"))) = 0)

oRollPlan = oRoll.GenerateUpdatePlan()
chk("the rehearsal exported a plan with the whole relocation in it",
	oRollPlan.NumberOfOperations() >= 5)
chk("...whose risk ranking flags the source delete",
	len(oRollPlan.Risks()) >= 1)

oRollPlan.SetExecutor(PIActor("roll-committer"))
oScopeR = new stzCommitScope()
oScopeR.AllowUnder(cEstate)
oRollPlan.SetScope(oScopeR)
aRoll = oRollPlan.Execute()
chk("the committing actor commits every operation", aRoll[2][2] = 0)

cSlAfter = StzFileRead(cEstate + "/dashboard/SESSION-LOG.md")
chk("NOW the old journal file is gone from the live folder",
	StzFileExists(cEstate + "/journal/" + cOld + "-scar.md") = 0)
chk("...and whole in the archive -- relocation, not retention",
	StzFileRead(cEstate + "/journal/archive/" + cOld + "-scar.md") =
		"an old journal entry" + char(10))
chk("...this month's journal file was left alone",
	StzFileExists(cEstate + "/journal/" + cCur + "-fresh.md") = 1)
chk("...the old SESSION-LOG line is in its month's archive",
	len(StzFind("something that happened long ago",
		StzFileRead(cEstate + "/dashboard/archive/SESSION-LOG-" + cOld + ".md"))) > 0)
chk("...and gone from the live file",
	len(StzFind("something that happened long ago", cSlAfter)) = 0)
chk("...which kept this month's line",
	len(StzFind("something happening this month", cSlAfter)) > 0)
chk("...and carries the pointer where the next reader will see it",
	len(StzFind("Rolled ", cSlAfter)) > 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

StzDirDeleteAll(cFx)

pf()

func chk(cWhat, bCond)
	if bCond = 1
		nPass++
		? "  [OK] " + cWhat
	else
		nFail++
		? "  [FAIL] " + cWhat
	ok

# The probe scribbler: what a ring: function looks like when it lives in
# the safe world -- it asks for the ambient workbench and rehearses.
func SafeworldScribble(poMemory)
	StzActiveWorkbenchQ().WriteFile($cSafeworldOut, "scribbled-by-agent")
	poMemory.Learn("note", "was", "scribbled")
