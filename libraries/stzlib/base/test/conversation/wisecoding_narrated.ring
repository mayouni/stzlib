# R3b ACCEPTANCE -- conversation/: WISE CODING runs
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 0.2 door 4 + 0.3 + R3b)
# The system asks (gap-born, accountable questions); the answer
# protocol governs admission; refusals reach a checkpoint; the session
# ends by WRITING the knowledgebase. Deterministic -- no model needed.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the goal declares the shape; gaps generate questions --"
StzKnow("margherita", "dish")
StzKnow("tiramisu", "dish")

oCv = new stzConversation("restaurant-setup")
oCv.GoalQ().RequireEach("dish", "contains")
chk("the gap is computed from the graph", len(oCv.Gaps()) = 2)

aQ = oCv.NextQuestionXT()
chk("the question is SYSTEM-LED and names its subject",
	aQ[:subject] = "margherita" and aQ[:relation] = "contains")
chk("the question is ACCOUNTABLE (it says why it asks)",
	aQ[:why] = "every dish needs 'contains'")

? ""
? "-- Scene 2: the answer protocol -- registers in, governed admission --"
aV = oCv.Reply("tomato-sauce and mozzarella")
chk("natural phrasing admits (register 4: 'X and Y')",
	len(aV[:admitted]) = 2)
oCv.NextQuestion()
aV2 = oCv.Reply([ "mascarpone", "espresso" ])
chk("a data structure admits (register 2)", len(aV2[:admitted]) = 2)
chk("admissions are grounded in the graph (AreRelated sees them)",
	AreRelated("tiramisu", "espresso") = "contains")

? ""
? "-- Scene 3: refusal is governed AND checkpointed (G7) --"
oCv3 = new stzConversation("staffing")
oCv3.GoalQ().RequireOne("kitchen3", "led-by")
oCv3.NextQuestion()
StzConstrainRelation("led-by", :Unique)
StzKnowRelation("kitchen3", "led-by", "mario")
aR = oCv3.Reply("giovanni")
chk("the :Unique law refuses through the conversation",
	len(aR[:refused]) = 1)
chk("the refusal reaches a human checkpoint with context",
	len(oCv3.Checkpoints()) = 1 and oCv3.Checkpoints()[1][:attempted] = "giovanni")

? ""
? "-- Scene 4: the session ends by WRITING the knowledgebase --"
chk("gaps closed", len(oCv.Gaps()) = 0)
chk("Conclude writes the .zknw", oCv.Conclude("t_wise_world") = 1)
chk("the transcript reads as dialogue",
	len(StzFind("SOFTANZA:", oCv.Transcript())) > 0)
cF = oCv.Save("t_wise_conv")
chk("the conversation persists (*.stzconv)",
	len(StzFind("conversation ", read(cF))) > 0)
remove("t_wise_world.zknw")
remove(cF)

bRefuse = 0
oCv5 = new stzConversation("early")
oCv5.GoalQ().RequireOne("nowhere", "nothing")
try
	oCv5.Conclude("x")
catch
	bRefuse = 1
done
chk("concluding with open gaps REFUSES (LAW 3)", bRefuse = 1)

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
