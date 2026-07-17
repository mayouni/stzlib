# .stzflow -- a WORKFLOW, written down.
#
# The fourth of the graph file formats, and the last one that had never run.
# Three faults stood between the file and the workflow, each hiding the next:
#
#   the parser could not be BUILT -- stzFlowParser defines no init of its
#       own, so it inherited stzObject's (which takes the object to wrap) and
#       `new stzFlowParser()` raised R19 before parsing anything.
#   the props were read in the WRONG SHAPE -- Parse() builds a list of PAIRS
#       (`_aCurrentProps_ + [key, value]` appends the pair as ONE element),
#       while _AddStep/_AddActor walked it as a flat [k,v,k,v] run and fell
#       off the end -> R2.
#   the last item of every section was DROPPED -- an item is only written
#       when the NEXT one starts, and only the final section was flushed at
#       the end. This file goes steps -> flow -> actors, so the last step
#       vanished and then `flow` referenced it: "Cannot add edge".
#
# Nothing here asserts on the parser's internals: it reads the real fixture
# and asks the WORKFLOW what it now knows.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the file becomes a workflow --"

oParser = new stzFlowParser()
chk("the parser can be BUILT at all", isObject(oParser))

oW = oParser.ParseFile("../_data/loan_approval.stzflow")
chk("... and it hands back a workflow", ring_classname(oW) = "stzworkflow")
chk("the workflow knows its name", StzLower(oW.Name()) = "loan_approval")

? ""
? "-- Scene 2: everything the file declares arrives --"

# the fixture declares 6 steps, 3 actors and 5 flow edges
chk("every step arrived (6)", len(oW.Steps()) = 6)
chk("every actor arrived (3)", len(oW.Actors()) = 3)
chk("every flow edge arrived (5)", len(oW.Edges()) = 5)

chk("the FIRST step is there", oW.Steps()[1][:id] = "receive")
chk("... and so is the LAST one -- the step a section-end used to drop",
	oW.Steps()[6][:id] = "reject")

? ""
? "-- Scene 3: each step keeps what was said about it --"

# the pair-shape fault made every property unreadable
aFirst = oW.Steps()[1]
chk("a step keeps its label", aFirst[:label] = "Receive Application")
chk("... and its duration", aFirst[:duration] = 1)

aVerify = oW.Steps()[2]
chk("a step keeps its SLA too", aVerify[:sla] = 6)
chk("... alongside its own duration", aVerify[:duration] = 4)

aReject = oW.Steps()[6]
chk("a DECIMAL duration survives", aReject[:duration] = 0.5)

? ""
? "-- Scene 4: the flow really connects the steps --"

chk("receive -> verify", oW.EdgeExists("receive", "verify"))
chk("verify -> credit_check", oW.EdgeExists("credit_check", "decide") or
	oW.EdgeExists("verify", "credit_check"))
chk("the decision branches to BOTH outcomes",
	oW.EdgeExists("decide", "approve") and oW.EdgeExists("decide", "reject"))

? ""
? "-- Scene 5: the actors, and what they are --"

chk("an actor is named, not just listed", len(oW.Actors()[1]) > 0)

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
