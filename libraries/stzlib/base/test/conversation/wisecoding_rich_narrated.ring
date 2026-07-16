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
# the KNOWLEDGE SPACE holds the session; the session grows the space
oKB = new stzKnowledgeGraph("pizzeria")
oKB.Know("pizza1", "dish")
oKB.Converse("frame")
oKB.ConversationQ("frame").GoalQ().RequireEach("dish", "topping")

aQ = oKB.AskInXT("frame")
chk("with nothing known yet, the force is OPEN (:what)", aQ[:force] = "what")
chk("... so no options are offered", len(aQ[:options]) = 0)
chk("... and the phrasing follows the force", StzLeft(aQ[:question], 4) = "What")
chk("the frame still names its slots + why",
	aQ[:subject] = "pizza1" and aQ[:relation] = "topping" and
	len(StzFind("why:", aQ[:question])) > 0)
oKB.ReplyIn("frame", "cheese")

oKB.Know("pizza2", "dish")
aQ2 = oKB.AskInXT("frame")
chk("once the domain KNOWS a value, the force closes to a choice (:which)",
	aQ2[:force] = "which")
chk("... the known value is OFFERED as an option",
	ring_find(aQ2[:options], "cheese") > 0)
chk("... the phrasing follows the new force", StzLeft(aQ2[:question], 5) = "Which")
chk("... and the option is NUMBERED in the text",
	StzFindFirst(aQ2[:question], "(1) cheese") > 0)

? ""
? "-- Scene 2: REGISTER 1 -- answer an option by its number --"
aV = oKB.ReplyIn("frame", 1)
chk("a NUMBER picks the offered option", aV[:admitted][1] = "cheese")
chk("the pick is really grounded in the graph",
	oKB.Query([ "pizza2", "topping", "?o" ])[1] = "cheese")

oKB.Know("pizza3", "dish")
oKB.AskIn("frame")
oKB.ReplyIn("frame", "olives")
oKB.Know("pizza4", "dish")
aQ4 = oKB.AskInXT("frame")
chk("both known values are now on the table", len(aQ4[:options]) = 2)
aV4 = oKB.ReplyIn("frame", [ 1, 2 ])
chk("a LIST of numbers picks several options at once", len(aV4[:admitted]) = 2)

oKB.Know("pizza5", "dish")
oKB.AskIn("frame")
aV5 = oKB.ReplyIn("frame", 99)
chk("an out-of-range pick REFUSES -- it never guesses a value",
	len(aV5[:refused]) = 1 and len(aV5[:admitted]) = 0)
chk("... and the refusal reaches a human checkpoint",
	len(oKB.ConversationQ("frame").Checkpoints()) >= 1)

? ""
? "-- Scene 3: a checkpoint has a LIFETIME (it stops haunting) --"
oKT = new stzKnowledgeGraph("ttl-space")
oKT.Converse("ttl")
oKT.ConversationQ("ttl").GoalQ().RequireOne("kitchenT", "led-by")
oKT.AskIn("ttl")
oKT.ReplyIn("ttl", 7)                       # nothing offered -> refused + checkpointed
chk("the refusal is checkpointed", len(oKT.ConversationQ("ttl").AllCheckpoints()) = 1)
chk("by default a checkpoint NEVER expires (TTL 0)", len(oKT.ConversationQ("ttl").Checkpoints()) = 1)

oKT.ConversationQ("ttl").CheckpointTTL(1)
oKT.AskIn("ttl")
oKT.AskIn("ttl")
chk("with a TTL, the stale checkpoint leaves the LIVE list",
	len(oKT.ConversationQ("ttl").Checkpoints()) = 0)
chk("... but the audit record still holds it (nothing is deleted)",
	len(oKT.ConversationQ("ttl").AllCheckpoints()) = 1)
chk("... and the expiry is reported", oKT.ConversationQ("ttl").NumberOfExpiredCheckpoints() = 1)
bTTL = 0
try
	oKT.ConversationQ("ttl").CheckpointTTL(-3)
catch
	bTTL = 1
done
chk("a negative TTL REFUSES", bTTL = 1)

? ""
? "-- Scene 4: FLUENCY upgrades honestly, or not at all --"
oKF = new stzKnowledgeGraph("fluency-space")
oKF.Converse("fluency")
oF = oKF.ConversationQ("fluency")
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
