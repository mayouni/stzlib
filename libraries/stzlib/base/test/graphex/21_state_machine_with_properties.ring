# Narrative
# --------
# State machine with properties
#
# Extracted from stzgraphextest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("StateMachine")
oGraph {
	AddNodeXTT(:idle, "Idle", [:energy = 0])
	AddNodeXTT(:running, "Running", [:energy = 100])
	AddNodeXTT(:paused, "Paused", [:energy = 50])
	AddEdgeXT(:idle, :running, "start")
	AddEdgeXT(:running, :paused, "pause")
}

# Match high-energy states
oGx = new stzGraphex("{@Node{energy:>:40}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Running and Paused)

pf()
