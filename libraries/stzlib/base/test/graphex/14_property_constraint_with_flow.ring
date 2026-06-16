# Narrative
# --------
# Property constraint with flow
#
# Extracted from stzgraphextest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXTT(:a, "Task1", [:priority = 1])
	AddNodeXTT(:b, "Task2", [:priority = 5])
	AddEdgeXT(:a, :b, "depends")
}

# Match high-priority task flow
oGx = new stzGraphex("{@Node{priority:>:3} -> @Edge -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Task2 has priority 5)

pf()

#============================#
#  ENHANCEMENT 5: DEBUG & EXPLAIN TESTS
#============================#
