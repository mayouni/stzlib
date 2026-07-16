# R5 slice 3 ACCEPTANCE -- the NATIVE STACK: Softanza consumes its own
# agentic/ module (0.3 + LAW 5). A curated roster; the wired wise-coder
# DRIVES conversation/ elicitation as an agent, governed throughout.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the curated roster is honest (wired vs reserved) --"
chk("the roster exists", len(StzNativeAgents()) = 5)
chk("wise-coder is wired", StzNativeAgentIsWired("wise-coder") = 1)
chk("the planner is reserved (not wired)", StzNativeAgentIsWired("planner") = 0)
bR = 0
try
	StzNativeAgent("ranker")
catch
	bR = 1
done
chk("a reserved agent REFUSES rather than returning a stub (LAW 3)", bR = 1)

? ""
? "-- Scene 2: the wise-coder drives R3b elicitation as an agent --"
# SCOPED: the agent elicits into a domain graph handed to it, not a world
oKB = new stzKnowledgeGraph("menu")
oKB.Know("margherita", "dish").Know("tiramisu", "dish")
oGoal = new stzGoal()
oGoal.RequireEach("dish", "contains")
answers = [ [ "margherita", "tomato-sauce" ], [ "tiramisu", "mascarpone" ] ]
oWC = StzNativeAgent("wise-coder")
aR = oWC.PursueGoal(oGoal, oKB, func subj, rel {
	for a in answers
		if a[1] = subj
			return a[2]
		ok
	next
	return ""
})
chk("the goal is filled", aR[:filled] = 1)
chk("one question per gap", aR[:asked] = 2)
chk("the answers were ADMITTED into the SCOPED graph (governed)",
	oWC.ConversationQ().KnowledgeQ().Query([ "margherita", "contains", "?o" ])[1] =
	"tomato-sauce")
chk("Why reports governed admission",
	len(StzFind("governed admission", aR[:why])) > 0)

? ""
? "-- Scene 3: the agent refuses to INVENT (leaves the gap) --"
oKB2 = new stzKnowledgeGraph("desserts")
oKB2.Know("panna-cotta", "dish")
oGoal2 = new stzGoal()
oGoal2.RequireEach("dish", "contains")
oWC2 = StzNativeAgent("wise-coder")
aR2 = oWC2.PursueGoal(oGoal2, oKB2, func subj, rel {
	if subj = "panna-cotta"
		return ""
	ok
	return "filler"
})
chk("an unanswerable gap stops the agent (never invents facts)",
	aR2[:filled] = 0)
chk("...leaving the gap explicitly for a human",
	len(StzFind("gap left for a human", aR2[:why])) > 0)

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
