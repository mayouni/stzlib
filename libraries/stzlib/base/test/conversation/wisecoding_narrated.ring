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
# the KNOWLEDGE SPACE is the container; a conversation happens INSIDE it
oKB = new stzKnowledgeGraph("restaurant")
oKB.Know("margherita", "dish").Know("tiramisu", "dish")
# ADD the session to the space and hand it ONE goal, in one act
oKB.AddConversationQ("restaurant-setup").
    SetGoal(StzGoalQ().RequireEach("dish", "contains"))
chk("the gap is computed from the SPACE", len(oKB.GapsIn("restaurant-setup")) = 2)

aQ = oKB.AskInXT("restaurant-setup")
chk("the question is SYSTEM-LED and names its subject",
	aQ[:subject] = "margherita" and aQ[:relation] = "contains")
chk("the question is ACCOUNTABLE (it says why it asks)",
	aQ[:why] = "every dish needs 'contains'")

? ""
? "-- Scene 2: the answer protocol -- registers in, governed admission --"
aV = oKB.ReplyIn("restaurant-setup", "tomato-sauce and mozzarella")
chk("natural phrasing admits (register 4: 'X and Y')",
	len(aV[:admitted]) = 2)
oKB.AskIn("restaurant-setup")
aV2 = oKB.ReplyIn("restaurant-setup", [ "mascarpone", "espresso" ])
chk("a data structure admits (register 2)", len(aV2[:admitted]) = 2)
chk("admissions are grounded in THE SPACE the session runs in",
	oKB.Query([ "tiramisu", "contains", "?o" ])[1] = "mascarpone")

? ""
? "-- Scene 3: refusal is governed AND checkpointed (G7) --"
oKB3 = new stzKnowledgeGraph("staffing")
oKB3.AddConversationQ("staffing-setup").
     SetGoal(StzGoalQ().RequireOne("kitchen3", "led-by"))
oKB3.AskIn("staffing-setup")
# the law is declared IN THE SPACE, and a value lands, while the question is open
oKB3.ConstrainRelation("led-by", :Unique)
oKB3.KnowRelation("kitchen3", "led-by", "mario")
aR = oKB3.ReplyIn("staffing-setup", "giovanni")
chk("the :Unique law refuses through the conversation",
	len(aR[:refused]) = 1)
chk("the refusal reaches a human checkpoint with context",
	len(oKB3.ConversationQ("staffing-setup").Checkpoints()) = 1 and
	oKB3.ConversationQ("staffing-setup").Checkpoints()[1][:attempted] = "giovanni")

? ""
? "-- Scene 4: the session ends by WRITING the knowledgebase --"
chk("gaps closed", len(oKB.GapsIn("restaurant-setup")) = 0)
chk("Conclude writes the SPACE as .zknw", oKB.ConcludeIn("restaurant-setup", "t_wise_world") = 1)
chk("the transcript reads as dialogue",
	len(StzFind("SOFTANZA:", oKB.ConversationQ("restaurant-setup").Transcript())) > 0)
cF = oKB.ConversationQ("restaurant-setup").Save("t_wise_conv")
chk("the conversation persists (*.stzconv)",
	len(StzFind("conversation ", read(cF))) > 0)
remove("t_wise_world.zknw")
remove(cF)

bRefuse = 0
oKB5 = new stzKnowledgeGraph("early")
oKB5.AddConversationQ("early-setup").
     SetGoal(StzGoalQ().RequireOne("nowhere", "nothing"))
try
	oKB5.ConcludeIn("early-setup", "x")
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
