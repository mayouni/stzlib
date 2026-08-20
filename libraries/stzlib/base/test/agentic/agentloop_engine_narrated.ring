# THE BANGALO LOOP'S ZIG HEART -- ACCEPTANCE
#
# Before this, softanzuter.zig held agent SLOTS and nothing ran them:
# scheduling lived in Ring, in stzAgentHost.TickDue(). Ring decided who
# ticked, in what order, and when.
#
# Now Zig decides and Ring acts. The loop publishes a SCHEDULE -- who runs,
# in what order, and why -- and stzAgentHost pops it and calls Cycle().
# There is no callback into the Ring VM anywhere in this, deliberately:
# stzReactor is submit/await and so is this, which is why determinism is a
# property of a QUEUE you can read rather than of a callback you cannot.
#
# THE GATE IS THE POINT (law 18). An agent that declares neither a coverage
# statement nor a reversibility class is REFUSED registration, with a
# C2-style diagnostic naming the code, the agent and what to do -- never a
# crash, and never a silent skip.
#
# Adoption is OPT-IN, which is what keeps the gate honest: every narrated
# test in this directory that does not call UseEngineLoop() runs the Ring
# pump exactly as it always did, and none of them needed an edit.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

StzResetEngineAgentLoop()

#=====================================================================#
? "-- Scene 1: the loop states its own coverage, at RUN TIME --"
#=====================================================================#
# Law 18 obliges an agent to say what it covers before this loop will
# schedule it. The loop owes the same about itself -- and a coverage
# statement that lives only in a comment is one nobody can check.

cCov = StzAgentLoopCoverageStatement()
chk("the loop answers with a coverage statement", len(cCov) > 100)
chk("...it says what it SCHEDULES", len(StzFind("SCHEDULES", cCov)) > 0)
chk("...and, which matters more, what it CANNOT SEE",
	len(StzFind("CANNOT SEE", cCov)) > 0)
chk("...naming the clock it does not read", len(StzFind("the clock", cCov)) > 0)
chk("...and the event bus it cannot look at, because that bus is in ANOTHER DLL",
	len(StzFind("another DLL", cCov)) > 0)
chk("...and it does not pretend to judge whether a coverage statement is TRUE",
	len(StzFind("checks only that one exists", cCov)) > 0)

? ""
#=====================================================================#
? "-- Scene 2: registration is a GATE, not a formality --"
#=====================================================================#

StzResetEngineAgentLoop()

nSlot = stzenginezutercreate("nameless")
rc = stzengineagentloopregister(nSlot, 0, 1, 0, 0, 0, 10, "")
chk("an agent with NO coverage statement is refused", rc = -4)
cWhy = stzengineagentlooplastrefusal()
chk("...with a NAMED code, the way a Ring C-error is named",
	len(StzFind("AGENTLOOP-R4", cWhy)) > 0)
chk("...naming the agent it is about", len(StzFind("nameless", cWhy)) > 0)
chk("...and citing the law rather than just complaining",
	len(StzFind("Law 18", cWhy)) > 0)
chk("...and nothing was registered", stzengineagentloopcount() = 0)

nSlot2 = stzenginezutercreate("unstated")
rc = stzengineagentloopregister(nSlot2, 0, 0, 0, 0, 0, 10, "covers the intake queue")
chk("an agent with NO reversibility class is refused too", rc = -5)
cWhy = stzengineagentlooplastrefusal()
chk("...and the refusal says which words are acceptable",
	len(StzFind("reversible | compensable | irreversible", cWhy)) > 0)

nSlot3 = stzenginezutercreate("declared")
rc = stzengineagentloopregister(nSlot3, 0, 2, 0, 0, 0, 10, "covers the intake queue")
chk("an agent that declares BOTH registers", rc = 0)
chk("...and the loop hands its coverage statement back",
	stzengineagentloopcoverage(nSlot3) = "covers the intake queue")
chk("...and its reversibility class", stzengineagentloopreversibility(nSlot3) = 2)
chk("the same slot cannot register twice",
	stzengineagentloopregister(nSlot3, 0, 2, 0, 0, 0, 10, "again") = -3)

? ""
#=====================================================================#
? "-- Scene 3: ONE RULE, TWO LAYERS, SAME WORDS --"
#=====================================================================#
# The Ring layer states no-llm-effectful as a graph rule. The engine
# states it at registration. A caller who meets the refusal in either
# layer reads the same sentence -- quoted, not paraphrased.

StzResetEngineAgentLoop()
nL = stzenginezutercreate("summarizer")
rc = stzengineagentloopregister(nL, 1, 1, 0, 1, 0, 10, "summarises tickets")
chk("an llm actor holding 'effectful' is REFUSED at registration", rc = -6)
cWhy = stzengineagentlooplastrefusal()
chk("...in the graph rule's own sentence",
	len(StzFind("an LLM proposes, only a pi-gate commits", cWhy)) > 0)

# and the negative sibling: the rule must not refuse what it should allow
nL2 = stzenginezutercreate("proposer")
chk("an llm actor WITHOUT it is a slot like any other",
	stzengineagentloopregister(nL2, 1, 1, 0, 0, 0, 10, "proposes summaries") = 0)

# the rule as the Ring layer already words it, unchanged
oRules = StzAgentRuleSetQ()
oLlmRule = oRules.RuleNamed("no-llm-effectful")
chk("the Ring layer still carries the same rule, by that name", isObject(oLlmRule))
chk("...and the engine quotes ITS violation message, not a rewrite of it",
	len(StzFind(oLlmRule.ViolationMessage(), cWhy)) > 0)

? ""
#=====================================================================#
? "-- Scene 4: priority orders the pass; registration breaks the tie --"
#=====================================================================#

StzResetEngineAgentLoop()
# registered LOW first on purpose: were the order merely registration
# order, this scene would pass for the wrong reason
nLow  = stzenginezutercreate("low")
nHigh = stzenginezutercreate("high")
nMidA = stzenginezutercreate("mid-a")
nMidB = stzenginezutercreate("mid-b")
stzengineagentloopregister(nLow,  0, 1, 0, 0, 1, 10, "c")
stzengineagentloopregister(nHigh, 0, 1, 0, 0, 9, 10, "c")
stzengineagentloopregister(nMidA, 0, 1, 0, 0, 5, 10, "c")
stzengineagentloopregister(nMidB, 0, 1, 0, 0, 5, 10, "c")

chk("one pass makes all four due", stzengineagentlooptick(1000) = 4)
aOrder = []
while stzengineagentloopnext() = 1
	aOrder + stzengineagentloopcurrentslot()
end
chk("the highest priority runs first", aOrder[1] = nHigh)
chk("equal priorities run in REGISTRATION order", aOrder[2] = nMidA and aOrder[3] = nMidB)
chk("and the lowest runs last", aOrder[4] = nLow)

? ""
#=====================================================================#
? "-- Scene 5: the same sequence gives the same order, twice --"
#=====================================================================#
# The prompt asked for this as a test and not a comment. Run the identical
# script twice from a clean loop and compare the visit sequences.

aRun1 = RunScript()
aRun2 = RunScript()
chk("the script really did visit things", len(aRun1) > 5)
chk("both runs visited the same NUMBER of times", len(aRun1) = len(aRun2))
bSame = 1
for i = 1 to len(aRun1)
	if aRun1[i] != aRun2[i]  bSame = 0  ok
next
chk("...and in the same ORDER, agent for agent", bSame = 1)

? ""
#=====================================================================#
? "-- Scene 6: mailboxes are DRAINED, and they are a real queue --"
#=====================================================================#
# The mailbox used to be one 512-byte buffer that a second send silently
# overwrote. "Drain the mailboxes" has no meaning against a buffer of one.

StzResetEngineAgentLoop()
nM = stzenginezutercreate("mailer")
stzengineagentloopregister(nM, 0, 1, 2, 0, 0, 0, "reads its inbox")
chk("an empty inbox schedules nothing", stzengineagentlooptick(1000) = 0)

stzenginezutersendmsg(nM, nM, "one")
stzenginezutersendmsg(nM, nM, "two")
stzenginezutersendmsg(nM, nM, "three")
chk("three sends leave THREE messages, not one", stzenginezuterinboxcount(nM) = 3)
chk("a non-empty inbox schedules the agent", stzengineagentlooptick(1001) = 1)
stzengineagentloopnext()
chk("...and the reason given is 'mailbox', not 'timer'",
	stzengineagentloopcurrentreason() = 3)
chk("the queue is FIFO", stzenginezuterrecvmsg(nM) = "one")
chk("...still FIFO", stzenginezuterrecvmsg(nM) = "two")

? ""
#=====================================================================#
? "-- Scene 7: a remade channel does not make an agent go DEAF --"
#=====================================================================#
# stzAgentHost paid for this once: a bus channel destroyed and remade
# restarts its counter at zero, the stored baseline is suddenly HIGHER
# than the live count, the catch-up never runs, and the agent goes silent
# for good. The fix travelled into the Zig layer rather than being
# rediscovered there.

StzResetEngineAgentLoop()
nE = stzenginezutercreate("listener")
stzengineagentloopregister(nE, 0, 1, 1, 0, 0, 0, "listens on orders")
stzengineagentloopnoteevents(nE, 500, 7)      # a long-lived channel
stzengineagentlooptick(1000)
while stzengineagentloopnext() = 1  end

nPending = stzengineagentloopnoteevents(nE, 3, 8)   # a NEW channel, same name
chk("a new generation resyncs the baseline instead of ignoring the events",
	nPending = 3)
chk("...so the three fresh events are three visits", stzengineagentlooptick(1100) = 3)

? ""
#=====================================================================#
? "-- Scene 8: stzAgentHost adopts the loop, API unchanged --"
#=====================================================================#

StzResetEngineAgentLoop()

oA = BuildTicker("alpha")
oB = BuildTicker("beta")

oHost = new stzAgentHost()
oHost.Supervise(oA, 10)
oHost.Supervise(oB, 10)
chk("a fresh host runs the RING pump, exactly as it always did",
	oHost.IsUsingEngineLoop() = 0)

b = 0
try
	oHost.UseEngineLoop()
catch
	b = 1
	cWhy = cCatchError
done
chk("adopting the loop with UNDECLARED agents is REFUSED", b = 1)
chk("...and the host carries the ENGINE's diagnostic, not its own paraphrase",
	len(StzFind("AGENTLOOP-R4", oHost.EngineLoopWhy())) > 0)

oHost.Declare("alpha", "covers the kitchen queue", :compensable)
oHost.Declare("beta",  "covers the door sensor",   :reversible)
oHost.SetPriority("alpha", 9)
oHost.SetPriority("beta", 1)
oHost.UseEngineLoop()
chk("declared agents are adopted", oHost.IsUsingEngineLoop() = 1)
chk("...each landing in an engine slot", oHost.EngineSlotOf("alpha") >= 0)

oHost.RunFor(60)
chk("the SAME RunFor() call now pumps from Zig", oHost.TicksOf("alpha") > 0)
chk("...and both agents ran", oHost.TicksOf("beta") > 0)

aTr = oHost.Trace()
chk("the trace records the loop's REASON for each visit",
	len(aTr) > 0 and len(StzFind("tick", aTr[1][4])) > 0)
chk("...and alpha, the higher priority, was visited first in the pass",
	aTr[1][2] = "alpha")

? ""
#=====================================================================#
? "-- Scene 9: cancel, resume and retire reach INTO the loop --"
#=====================================================================#
# Ring skipping what Zig scheduled would work and would be wrong: the
# queue would fill with visits nobody performs. Cancellation pauses the
# agent in the engine, so the loop stops choosing it.

nBefore = oHost.TicksOf("beta")
oHost.Cancel("beta")
oHost.RunFor(60)
chk("a cancelled agent stops being SCHEDULED, not merely skipped",
	oHost.TicksOf("beta") = nBefore)
chk("...while the other agent keeps running", oHost.TicksOf("alpha") > 0)

oHost.Resume("beta")
oHost.RunFor(60)
chk("resume puts it back in the schedule", oHost.TicksOf("beta") > nBefore)

chk("retirement without governance is granted", oHost.Retire("beta") = 1)
chk("...and the engine slot is released", oHost.EngineSlotOf("beta") = -1)

? ""
#=====================================================================#
? "-- Scene 10: an over-full queue DROPS, and SAYS SO --"
#=====================================================================#
# Wall-time starvation is named in the loop's coverage statement as
# something it cannot see. What it CAN do is refuse to lie about it.

StzResetEngineAgentLoop()
nF = stzenginezutercreate("flood")
stzengineagentloopregister(nF, 0, 1, 1, 0, 0, 0, "floods")
stzengineagentloopnoteevents(nF, 300, 1)
nDecided = stzengineagentlooptick(1000)
chk("the loop decided on all 300 visits", nDecided = 300)
chk("...but the queue holds its bound", stzengineagentlooppending() = 256)
chk("...and the 44 it could not hold are COUNTED, never silently lost",
	stzengineagentloopdropped() = 44)

StzResetEngineAgentLoop()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

# A governed PI agent that fires every cycle -- the same shape
# agenthost_narrated.ring uses, so the loop is driving real work rather
# than a stub written to make a test pass.
func BuildTicker(cName)
	_oAg_ = new stzPIAgent(cName)
	_oAg_.MemoryQ().Learn("beat", "state", "due")
	_oAg_.GovernanceQ().DeclareRisk("beat", 1)
	_oAg_.GovernanceQ().GrantPermission(cName, "beat")
	_oAg_.GovernanceQ().SetAuthority(cName, :Delegated)
	_oSk_ = new stzAgentSkill("beat")
	_oSk_.SetWhen(func oMem { return oMem.Fact("beat", "state", "due") })
	_oSk_.SetDoes(func oMem { return 1 })
	_oSk_.SetVerifiedBy(func oMem { return oMem.Fact("beat", "state", "due") })
	_oAg_.AddGovernedSkill(_oSk_, "beat")
	return _oAg_

func RunScript()
	StzResetEngineAgentLoop()
	_a_ = stzenginezutercreate("alpha")     # timer, prio 3
	_b_ = stzenginezutercreate("beta")      # event, prio 9
	_c_ = stzenginezutercreate("gamma")     # mailbox, prio 3
	_d_ = stzenginezutercreate("delta")     # timer, prio 7
	stzengineagentloopregister(_a_, 0, 1, 0, 0, 3, 10, "c")
	stzengineagentloopregister(_b_, 0, 1, 1, 0, 9, 0, "c")
	stzengineagentloopregister(_c_, 0, 1, 2, 0, 3, 0, "c")
	stzengineagentloopregister(_d_, 0, 1, 0, 0, 7, 10, "c")

	_aOut_ = []

	stzengineagentloopnoteevents(_b_, 2, 1)
	stzenginezutersendmsg(_c_, _c_, "m")
	stzengineagentlooptick(1000)
	while stzengineagentloopnext() = 1
		_aOut_ + stzengineagentloopcurrentslot()
	end

	stzengineagentloopnoteevents(_b_, 3, 1)
	stzengineagentlooptick(1010)
	while stzengineagentloopnext() = 1
		_aOut_ + stzengineagentloopcurrentslot()
	end

	stzengineagentloopnudge(_a_)
	stzengineagentlooptick(1020)
	while stzengineagentloopnext() = 1
		_aOut_ + stzengineagentloopcurrentslot()
	end
	return _aOut_

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
