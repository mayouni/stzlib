# R3b DEEPENING -- the conversational door gets RICH.
# The floor proved the loop runs (gap -> question -> governed admission ->
# checkpoint -> .zknw). This proves the four deferrals:
#   THE FRAME      -- a question carries illocutionary FORCE (:which when the
#                     domain knows candidates, :what when open); the force
#                     drives the phrasing, and the frame comes back as data.
#   REGISTER 1     -- offered OPTIONS are answerable by NUMBER (or numbers);
#                     an out-of-range pick refuses instead of guessing.
#   CHECKPOINT TTL -- a refusal a human never cleared stops haunting the
#                     session, without losing the audit record.
#   FLUENCY        -- :neural rephrases through a loaded model, and NEVER
#                     claims the upgrade when no model is there (LAW 3).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the question is a FRAME -- force opens it, slots fill it --"
# SCOPED: this session elicits into its OWN graph, never a global world
oCv = new stzConversation("frame")
oCv.KnowledgeQ().Know("pizza1", "dish")
oCv.GoalQ().RequireEach("dish", "topping")

aQ = oCv.NextQuestionXT()
chk("with nothing known yet, the force is OPEN (:what)", aQ[:force] = "what")
chk("... so no options are offered", len(aQ[:options]) = 0)
chk("... and the phrasing follows the force", StzLeft(aQ[:question], 4) = "What")
chk("the frame still names its slots + why",
	aQ[:subject] = "pizza1" and aQ[:relation] = "topping" and
	len(StzFind("why:", aQ[:question])) > 0)
oCv.Reply("cheese")

oCv.KnowledgeQ().Know("pizza2", "dish")
aQ2 = oCv.NextQuestionXT()
chk("once the domain KNOWS a value, the force closes to a choice (:which)",
	aQ2[:force] = "which")
chk("... the known value is OFFERED as an option",
	ring_find(aQ2[:options], "cheese") > 0)
chk("... the phrasing follows the new force", StzLeft(aQ2[:question], 5) = "Which")
chk("... and the option is NUMBERED in the text",
	StzFindFirst(aQ2[:question], "(1) cheese") > 0)

? ""
? "-- Scene 2: REGISTER 1 -- answer an option by its number --"
aV = oCv.Reply(1)
chk("a NUMBER picks the offered option", aV[:admitted][1] = "cheese")
chk("the pick is really grounded in the graph",
	oCv.KnowledgeQ().Query([ "pizza2", "topping", "?o" ])[1] = "cheese")

oCv.KnowledgeQ().Know("pizza3", "dish")
oCv.NextQuestion()
oCv.Reply("olives")
oCv.KnowledgeQ().Know("pizza4", "dish")
aQ4 = oCv.NextQuestionXT()
chk("both known values are now on the table", len(aQ4[:options]) = 2)
aV4 = oCv.Reply([ 1, 2 ])
chk("a LIST of numbers picks several options at once", len(aV4[:admitted]) = 2)

oCv.KnowledgeQ().Know("pizza5", "dish")
oCv.NextQuestion()
aV5 = oCv.Reply(99)
chk("an out-of-range pick REFUSES -- it never guesses a value",
	len(aV5[:refused]) = 1 and len(aV5[:admitted]) = 0)
chk("... and the refusal reaches a human checkpoint",
	len(oCv.Checkpoints()) >= 1)

? ""
? "-- Scene 3: a checkpoint has a LIFETIME (it stops haunting) --"
oT = new stzConversation("ttl")
oT.GoalQ().RequireOne("kitchenT", "led-by")
oT.NextQuestion()
oT.Reply(7)                       # nothing offered -> refused + checkpointed
chk("the refusal is checkpointed", len(oT.AllCheckpoints()) = 1)
chk("by default a checkpoint NEVER expires (TTL 0)", len(oT.Checkpoints()) = 1)

oT.CheckpointTTL(1)
oT.NextQuestion()
oT.NextQuestion()
chk("with a TTL, the stale checkpoint leaves the LIVE list",
	len(oT.Checkpoints()) = 0)
chk("... but the audit record still holds it (nothing is deleted)",
	len(oT.AllCheckpoints()) = 1)
chk("... and the expiry is reported", oT.NumberOfExpiredCheckpoints() = 1)
bTTL = 0
try
	oT.CheckpointTTL(-3)
catch
	bTTL = 1
done
chk("a negative TTL REFUSES", bTTL = 1)

? ""
? "-- Scene 4: FLUENCY upgrades honestly, or not at all --"
oF = new stzConversation("fluency")
chk("the deterministic floor is the default", oF.FluencyMode() = "plain")
oF.Fluency(:neural)
chk("asking for neural fluency is recorded", oF.FluencyMode() = "neural")
chk("but the upgrade is only CLAIMED when a model is really loaded (LAW 3)",
	oF.IsFluencyNeural() = StzHasGenerativeModel())
bFl = 0
try
	oF.Fluency(:singing)
catch
	bFl = 1
done
chk("an unknown fluency mode REFUSES", bFl = 1)

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
