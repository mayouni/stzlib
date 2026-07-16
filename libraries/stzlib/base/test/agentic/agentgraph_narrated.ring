# R5 slice 2 ACCEPTANCE -- stzAgentGraph (G1 live) + stzLLMAgent
# (5.7 G1/G2 + 5.6): agents are subgraphs; governance is graph
# predicates PROVED before anything runs. LLM creativity proposes;
# a pi-gate commits.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: an ungoverned composition is REFUSED --"
oBad = new stzAgentGraph("mailer-bad")
oBad.AddLLMActor("writer")
oBad.AddEffect("send")
oBad.Proposes("writer", "send")
chk("llm-straight-to-effect is NOT sound", oBad.IsSound() = 0)
chk("multiple invariants fire", len(oBad.Violations()) >= 3)
chk("Explain names the refusal", len(StzFind("REFUSED", oBad.Explain())) > 0)

? ""
? "-- Scene 2: the governed shape passes every gate --"
oOk = new stzAgentGraph("mailer")
oOk.AddLLMActor("writer")
oOk.AddGuardian("gate")
oOk.AddEffect("send")
oOk.AddTraceSink("audit")
oOk.Proposes("writer", "gate")
oOk.Guards("gate", "send")
oOk.Feeds("gate", "send")
oOk.Traces("send", "audit")
chk("proposes -> gate -> effect -> trace is SOUND", oOk.IsSound() = 1)
chk("Explain confirms governance", len(StzFind("GOVERNED", oOk.Explain())) > 0)

? ""
? "-- Scene 3: the capability rule is structural --"
oCheck = new stzAgentGraph("cap")
oCheck.AddLLMActor("creative")
aCaps = oCheck.GraphQ().NodeProperty("creative", "capabilities")
chk("an llm actor's capabilities EXCLUDE effectful",
	ring_find(aCaps, "effectful") = 0)
chk("...and its output is tainted open_llm_text",
	oCheck.GraphQ().NodeProperty("creative", "taint") = "open_llm_text")

? ""
? "-- Scene 4: an effect with a guardian but NO trace still fails --"
oNoTrace = new stzAgentGraph("half")
oNoTrace.AddLLMActor("w")
oNoTrace.AddGuardian("g")
oNoTrace.AddEffect("e")
oNoTrace.Proposes("w", "g")
oNoTrace.Guards("g", "e")
oNoTrace.Feeds("g", "e")
aV = oNoTrace.Violations()
bTrace = 0
for i = 1 to len(aV)
	if aV[i][:invariant] = "effects-traced"
		bTrace = 1
	ok
next
chk("the missing audit witness is caught", bTrace = 1)

? ""
? "-- Scene 5: stzLLMAgent proposes, NEVER commits --"
oLLM = new stzLLMAgent("summarizer")
oF = new stzLLMFunction("sum")
oF.SetPrompt("summarize: {input}")
oF.Budget(2)
oF.SeedAnswer("hello world", "a greeting")
oLLM.SetSkillFrom(oF)
chk("it produces a candidate (a proposal)", oLLM.Propose("hello world") = "a greeting")
chk("it can NEVER hold the effectful capability", oLLM.HoldsEffectful() = 0)
chk("its kind is llm_actor", oLLM.Kind() = "llm_actor")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
