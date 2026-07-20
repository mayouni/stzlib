# Governance crossing (Phase 4) STRESS -- the capstone.
#
# The claim (SOFTANZA_SYSTEM_FOUNDATION.md Layer 3): expression is free, admission
# is governed. An UpdatePlan crosses to reality only if the EXECUTING ACTOR holds
# the capability KIND each operation requires. Every reality-touching op is
# effectful; an LLM actor's effect-capability set is EMPTY -- so an LLM can
# rehearse and propose a plan in ANY domain, but can commit NOTHING. A human or
# PI actor can. This is "agents that cannot hurt you" as a property the code
# enforces, not a promise.
#
# On top of the capability gate, an optional stzGovernance adds the trust-posture
# requirement and the decision lineage. The actor's capability kinds are the
# SAME lattice that drives Phase 1b's system<->agent bridge -- one vocabulary.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cCwd0 = WorkingDirectory()
cScratch = cCwd0 + "/_gov_scratch"
StzEngineDirCreatePath(cScratch)
scrubenv("STZ_GOV_A")  scrubenv("STZ_GOV_B")

? "-- Scene 1: an actor's authority is a set of capability KINDS --"
oHuman = HumanActor("alice")
oPI = PIActor("pi-1")
oLLM = LLMActor("writer-llm")
oGuardian = GuardianActor("checker")
chk("a human can effect reality", oHuman.IsEffectful())
chk("a PI actor can too", oPI.IsEffectful())
chk("an LLM actor CANNOT -- its effect set is empty", NOT oLLM.IsEffectful())
chk("...it can only infer", oLLM.Can("inference") and NOT oLLM.Can("effectful"))
chk("a guardian can sense and compute but not effect", oGuardian.Can("sensing") and oGuardian.Can("compute") and NOT oGuardian.IsEffectful())
chk("the LLM's posture is sandboxed, the human's trusted", oLLM.Posture() = "sandboxed" and oHuman.Posture() = "trusted")
bRaised = FALSE
try
	oHuman.GrantKind("magic")
catch
	bRaised = TRUE
done
chk("an unknown capability kind is refused (closed lattice)", bRaised)

? ""
? "-- Scene 2: expression is FREE, admission is GOVERNED (an LLM's plan) --"
cF = cScratch + "/llm.txt"
killreal(cF)
oV1 = new stzVirtualFileSystem()
oV1.CreateFile(cF, "from the model")
chk("the LLM freely REHEARSED the change (the twin holds it)", oV1.Exists(cF))
oPlan1 = oV1.GenerateUpdatePlan()
oPlan1.SetExecutor(oLLM)
aMay = oPlan1.MayCommit()
chk("...but MayCommit() says it cannot cross", aMay[1] = 0)
aRes1 = oPlan1.Execute()
chk("...Execute commits NOTHING", aRes1[1][2] = 0)
chk("...refused by governance, not by scope", StzFindFirst("GOVERNANCE", aRes1[3][2][1][2]) > 0)
chk("...and reality is untouched", StzEngineFileExists(cF) = 0)

? ""
? "-- Scene 3: a human commits the very same plan --"
oV2 = new stzVirtualFileSystem()
oV2.CreateFile(cF, "from the model")
oPlan2 = oV2.GenerateUpdatePlan()
oPlan2.SetExecutor(oHuman)
chk("the human MAY commit", oPlan2.MayCommit()[1] = 1)
oPlan2.Execute()
chk("...and reality now holds the file", StzEngineFileExists(cF) = 1)
killreal(cF)

? ""
? "-- Scene 4: a guardian may sense/compute but still cannot commit --"
cG = cScratch + "/guard.txt"
killreal(cG)
oV3 = new stzVirtualFileSystem()
oV3.CreateFile(cG, "x")
oPlan3 = oV3.GenerateUpdatePlan()
oPlan3.SetExecutor(oGuardian)
aRes3 = oPlan3.Execute()
chk("the guardian commits nothing effectful", aRes3[1][2] = 0)
chk("...reality untouched", StzEngineFileExists(cG) = 0)

? ""
? "-- Scene 5: the gate holds across DOMAINS -- the env twin too --"
oE1 = new stzVirtualEnvironment()
oE1.SetVar("STZ_GOV_A", "llm-value")
oPlanE1 = oE1.GenerateUpdatePlan()
oPlanE1.SetExecutor(oLLM)
oPlanE1.Execute()
chk("an LLM cannot set a real env var either", realHas("STZ_GOV_A") = 0)
oE2 = new stzVirtualEnvironment()
oE2.SetVar("STZ_GOV_A", "human-value")
oPlanE2 = oE2.GenerateUpdatePlan()
oPlanE2.SetExecutor(oHuman)
oPlanE2.Execute()
chk("...but a human can", realVar("STZ_GOV_A") = "human-value")
scrubenv("STZ_GOV_A")

? ""
? "-- Scene 6: stzGovernance adds the trust-posture requirement --"
cP = cScratch + "/posture.txt"
killreal(cP)
oGov = new stzGovernance("deploy-ops")
oExt = SystemActor("ext-1", [ "effectful", "compute", "sensing" ])
oV4 = new stzVirtualFileSystem()
oV4.CreateFile(cP, "x")
oPlan4 = oV4.GenerateUpdatePlan()
oPlan4.SetExecutor(oExt)
oPlan4.SetGovernance(oGov)
aRes4 = oPlan4.Execute()
chk("an effectful actor with NO declared posture is refused wholesale", aRes4[1][2] = 0)
chk("...and reality is untouched", StzEngineFileExists(cP) = 0)
oGov.DeclarePosture("ext-1", :External)
oV5 = new stzVirtualFileSystem()
oV5.CreateFile(cP, "x")
oPlan5 = oV5.GenerateUpdatePlan()
oPlan5.SetExecutor(oExt)
oPlan5.SetGovernance(oGov)
oPlan5.Execute()
chk("...once a posture is declared, it may commit", StzEngineFileExists(cP) = 1)
killreal(cP)

? ""
? "-- Scene 7: every governed commit is recorded in the plan's audit trail --"
chk("the plan recorded an audit trail", oPlan5.NumberOfAuditEntries() > 0)
chk("...naming the actor and the outcome", oPlan5.AuditTrail()[1][4] = "ext-1" and oPlan5.AuditTrail()[1][2] = "committed")
chk("...and the wired governance's lineage carries it (via the plan)", oPlan5.Governance().NumberOfDecisions() > 0)

? ""
? "-- Scene 8: ONE lattice -- the same kinds gate Phase 1b's system caps --"
oEsp = DeclareSystem("esp32")
oEsp.SetOSName(:rtos)
oEsp.SetCapabilityList([ :gpio, :network, :clock, :threads ])
chk("the LLM may exercise NO system capability either (empty effect set)", len(oEsp.CapabilitiesForActorKinds(oLLM.Kinds())) = 0)
chk("...the human may exercise the effectful/sensing/compute ones", len(oEsp.CapabilitiesForActorKinds(oHuman.Kinds())) > 0)

? ""
? "-- Scene 9: no executor = unguarded (a human at the keyboard) --"
cU = cScratch + "/unguarded.txt"
killreal(cU)
oV6 = new stzVirtualFileSystem()
oV6.CreateFile(cU, "x")
oPlan6 = oV6.GenerateUpdatePlan()
chk("with no executor, MayCommit is true", oPlan6.MayCommit()[1] = 1)
oPlan6.Execute()
chk("...and the commit proceeds", StzEngineFileExists(cU) = 1)
killreal(cU)

? ""
? "-- Scene 10: the gates COMPOSE -- an LLM is refused even in scope --"
cS = cScratch + "/scoped.txt"
killreal(cS)
oV7 = new stzVirtualFileSystem()
oV7.CreateFile(cS, "x")
oScope = new stzCommitScope()
oScope.AllowUnder(cScratch)
oPlan7 = oV7.GenerateUpdatePlan()
oPlan7.SetScope(oScope)
oPlan7.SetExecutor(oLLM)
aRes7 = oPlan7.Execute()
chk("in-scope but the LLM still cannot cross", aRes7[1][2] = 0)
chk("...the refusal names governance, not scope", StzFindFirst("GOVERNANCE", aRes7[3][2][1][2]) > 0)
chk("...reality untouched", StzEngineFileExists(cS) = 0)

# cleanup
scrubenv("STZ_GOV_A")  scrubenv("STZ_GOV_B")
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

func realHas cName
	oEnvR = new stzEnvironment()
	return oEnvR.Has(cName)

func realVar cName
	oEnvR = new stzEnvironment()
	return oEnvR.Var(cName)

func scrubenv cName
	oEnvS = new stzEnvironment()
	if oEnvS.Has(cName)
		oEnvS.UnsetVar(cName)
	ok
