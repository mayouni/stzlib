# R3b DEEPENING -- the conversational door gets RICH, in its right place.
#
# A KNOWLEDGE SPACE HOLDS ITS CONVERSATIONS (composition): you Add them, you
# can Remove them, and the space is the door for anything needing knowledge.
# A conversation is accountable for exactly ONE goal, handed over whole with
# SetGoal(oGoal), and MONITORS it until it is FULFILLED or REVOKED.
#
# Then the four richness slices:
#   THE FRAME      -- the question carries illocutionary FORCE (:which when
#                     the domain knows candidates, :what when open).
#   REGISTER 1     -- offered OPTIONS are answerable by NUMBER; an
#                     out-of-range pick refuses instead of guessing.
#   CHECKPOINT TTL -- a refusal nobody cleared stops haunting the session,
#                     without losing the audit record.
#   FLUENCY        -- :neural upgrades only when a model is really there.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the SPACE holds its conversations (add, remove, review) --"
oKS = new stzKnowledgeGraph("space")
oKS.AddConversations([ "a", "b" ])
chk("the space holds the sessions opened in it", oKS.NumberOfConversations() = 2)
chk("... reachable by name", ring_find(oKS.Conversations(), "b") > 0)
bDup = 0
try
	oKS.AddConversation("a")
catch
	bDup = 1
done
chk("a duplicate name is REFUSED", bDup = 1)
chk("an overview reports each session's goal state",
	oKS.ConversationsXT()[1][:goal] = "none")
oKS.RemoveConversation("a")
chk("a conversation can be REMOVED", oKS.HasConversation("a") = FALSE)
oKS.RemoveAllConversations()
chk("and the space can be cleared of sessions", oKS.NumberOfConversations() = 0)

? ""
? "-- Scene 2: ONE goal, handed over, then MONITORED to its end --"
oKG = new stzKnowledgeGraph("lifecycle")
oKG.Know("d1", "dish")
oKG.AddConversation("s1")
chk("a fresh conversation carries no goal",
	oKG.ConversationQ("s1").GoalState() = "none")
bNG = 0
try
	oKG.AskIn("s1")
catch
	bNG = 1
done
chk("asking with NO goal REFUSES (the loop is goal-driven)", bNG = 1)

oKG.ConversationQ("s1").SetGoal(StzGoalQ().RequireEach("dish", "sauce"))
chk("a goal handed over -> the session is pursuing it",
	oKG.ConversationQ("s1").GoalState() = "pursuing")
b2nd = 0
try
	oKG.ConversationQ("s1").SetGoal(StzGoalQ().RequireEach("dish", "other"))
catch
	b2nd = 1
done
chk("a conversation has exactly ONE goal (a second is refused)", b2nd = 1)

oKG.AskIn("s1")
aRp = oKG.ReplyIn("s1", "pesto")
chk("the goal is MONITORED -- fulfilled the moment no gap remains",
	oKG.ConversationQ("s1").GoalState() = "fulfilled")
chk("... the verdict travels with the reply", aRp[:goalState] = "fulfilled")
chk("... and it says WHY it is fulfilled",
	len(StzFind("every required slot", oKG.ConversationQ("s1").GoalWhy())) > 0)

oKG.Know("d2", "dish")
oKG.AddConversationQ("s2").SetGoal(StzGoalQ().RequireEach("dish", "garnish"))
oKG.AskIn("s2")
oKG.ConversationQ("s2").RevokeGoal("out of scope tonight")
chk("REVOKED is the other way out", oKG.ConversationQ("s2").GoalState() = "revoked")
chk("... on the record, with its reason",
	oKG.ConversationQ("s2").GoalWhy() = "out of scope tonight")
chk("a revoked session asks nothing more", oKG.AskIn("s2") = "")
bRC = 0
try
	oKG.ConcludeIn("s2", "x")
catch
	bRC = 1
done
chk("... and it cannot conclude", bRC = 1)
chk("neither session is still open (one fulfilled, one revoked)",
	len(oKG.OpenConversations()) = 0)

? ""
? "-- Scene 3: the question is a FRAME -- force opens it, slots fill it --"
oKB = new stzKnowledgeGraph("pizzeria")
oKB.Know("pizza1", "dish").Know("pizza2", "dish").Know("pizza3", "dish")
oKB.Know("pizza4", "dish").Know("pizza5", "dish")
oKB.AddConversationQ("frame").SetGoal(StzGoalQ().RequireEach("dish", "topping"))

aQ = oKB.AskInXT("frame")
chk("with nothing known yet, the force is OPEN (:what)", aQ[:force] = "what")
chk("... so no options are offered", len(aQ[:options]) = 0)
chk("... and the phrasing follows the force", StzLeft(aQ[:question], 4) = "What")
chk("the frame names its slots + why",
	aQ[:subject] = "pizza1" and aQ[:relation] = "topping" and
	len(StzFind("why:", aQ[:question])) > 0)
oKB.ReplyIn("frame", "cheese")

aQ2 = oKB.AskInXT("frame")
chk("once the domain KNOWS a value, the force closes to a choice (:which)",
	aQ2[:force] = "which")
chk("... the known value is OFFERED as an option",
	ring_find(aQ2[:options], "cheese") > 0)
chk("... the phrasing follows the new force", StzLeft(aQ2[:question], 5) = "Which")
chk("... and the option is NUMBERED in the text",
	StzFindFirst("(1) cheese", aQ2[:question]) > 0)

? ""
? "-- Scene 4: REGISTER 1 -- answer an option by its number --"
aV = oKB.ReplyIn("frame", 1)
chk("a NUMBER picks the offered option", aV[:admitted][1] = "cheese")
chk("the pick is really grounded in the space",
	oKB.Query([ "pizza2", "topping", "?o" ])[1] = "cheese")

oKB.AskIn("frame")
oKB.ReplyIn("frame", "olives")
aQ4 = oKB.AskInXT("frame")
chk("both known values are now on the table", len(aQ4[:options]) = 2)
aV4 = oKB.ReplyIn("frame", [ 1, 2 ])
chk("a LIST of numbers picks several options at once", len(aV4[:admitted]) = 2)

oKB.AskIn("frame")
aV5 = oKB.ReplyIn("frame", 99)
chk("an out-of-range pick REFUSES -- it never guesses a value",
	len(aV5[:refused]) = 1 and len(aV5[:admitted]) = 0)
chk("... and the refusal reaches a human checkpoint",
	len(oKB.ConversationQ("frame").Checkpoints()) >= 1)

? ""
? "-- Scene 5: a checkpoint has a LIFETIME (it stops haunting) --"
oKT = new stzKnowledgeGraph("ttl-space")
oKT.AddConversationQ("ttl").SetGoal(StzGoalQ().RequireOne("kitchenT", "led-by"))
oKT.AskIn("ttl")
oKT.ReplyIn("ttl", 7)                 # nothing offered -> refused + checkpointed
chk("the refusal is checkpointed",
	len(oKT.ConversationQ("ttl").AllCheckpoints()) = 1)
chk("by default a checkpoint NEVER expires (TTL 0)",
	len(oKT.ConversationQ("ttl").Checkpoints()) = 1)

oKT.ConversationQ("ttl").SetCheckpointTTL(1)
oKT.AskIn("ttl")
oKT.AskIn("ttl")
chk("with a TTL, the stale checkpoint leaves the LIVE list",
	len(oKT.ConversationQ("ttl").Checkpoints()) = 0)
chk("... but the audit record still holds it (nothing is deleted)",
	len(oKT.ConversationQ("ttl").AllCheckpoints()) = 1)
chk("... and the expiry is reported",
	oKT.ConversationQ("ttl").NumberOfExpiredCheckpoints() = 1)
bTTL = 0
try
	oKT.ConversationQ("ttl").SetCheckpointTTL(-3)
catch
	bTTL = 1
done
chk("a negative TTL REFUSES", bTTL = 1)

? ""
? "-- Scene 6: FLUENCY upgrades honestly, or not at all --"
oKF = new stzKnowledgeGraph("fluency-space")
oKF.AddConversation("fluency")
chk("the deterministic floor is the default",
	oKF.ConversationQ("fluency").Fluency() = "plain")
oKF.ConversationQ("fluency").SetFluency(:neural)
chk("asking for neural fluency is recorded",
	oKF.ConversationQ("fluency").Fluency() = "neural")
chk("but the upgrade is only CLAIMED when a model is really loaded (LAW 3)",
	oKF.ConversationQ("fluency").IsFluencyNeural() = StzHasGenerativeModel())
bFl = 0
try
	oKF.ConversationQ("fluency").SetFluency(:singing)
catch
	bFl = 1
done
chk("an unknown fluency mode REFUSES", bFl = 1)

? ""
? "-- Scene 7: the checkpoint lifetime, across its RANGE and back again --"
#
# Scene 5 above proves a TTL of 1 expires a checkpoint. That is one point on a
# line: it cannot tell "the setting is read" from "any non-zero TTL expires
# everything". These walk the range, and then turn the knob back.
#
# Every call is CHAINED. ConversationQ() hands back a COPY -- Ring copies a list
# on assignment, objects inside it included -- so a setter called on a held
# variable mutates the copy and vanishes. Writing this the natural way
# (oC = ...ConversationQ("x") then oC.SetCheckpointTTL(1)) silently does nothing.

chk("TTL 0 never expires, however many turns pass", LiveAfter(0, 3) = 1)
chk("TTL 1 expires on the first turn after", LiveAfter(1, 1) = 0)
chk("TTL 2 survives that turn...", LiveAfter(2, 1) = 1)
chk("...and expires on the second", LiveAfter(2, 2) = 0)
chk("TTL 3 survives two...", LiveAfter(3, 2) = 1)
chk("...and expires on the third", LiveAfter(3, 3) = 0)

# THE KNOB TURNS BACK. Expiry is computed when the list is read, not stamped on
# the checkpoint, so lowering and raising the policy is not destructive -- and
# the audit record never lost the entry either way.
oBk = new stzKnowledgeGraph("ttl-back")
oBk.AddConversationQ("b").SetGoal(StzGoalQ().RequireOne("kitchenB", "led-by"))
oBk.AskIn("b")
oBk.ReplyIn("b", 7)
oBk.ConversationQ("b").SetCheckpointTTL(1)
oBk.AskIn("b")
chk("with a TTL the checkpoint has left the live list",
	len(oBk.ConversationQ("b").Checkpoints()) = 0)
oBk.ConversationQ("b").SetCheckpointTTL(0)
chk("...and setting the TTL back to 0 brings it back",
	len(oBk.ConversationQ("b").Checkpoints()) = 1)
chk("...with nothing expired any more",
	oBk.ConversationQ("b").NumberOfExpiredCheckpoints() = 0)
chk("...and the audit record never lost it",
	len(oBk.ConversationQ("b").AllCheckpoints()) = 1)

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

# How many checkpoints are still LIVE with this TTL, after this many more turns?
# One refused reply makes one checkpoint; the asks that follow age it.
func LiveAfter(pnTTL, pnAsks)
	_oK_ = new stzKnowledgeGraph("ttl-range")
	_oK_.AddConversationQ("r").SetGoal(StzGoalQ().RequireOne("kitchenR", "led-by"))
	_oK_.AskIn("r")
	_oK_.ReplyIn("r", 7)
	_oK_.ConversationQ("r").SetCheckpointTTL(pnTTL)
	for _i_ = 1 to pnAsks
		_oK_.AskIn("r")
	next
	return len(_oK_.ConversationQ("r").Checkpoints())
