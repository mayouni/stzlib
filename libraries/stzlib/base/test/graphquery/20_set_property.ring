# Narrative
# --------
# Set property
#
# Extracted from stzgraphquerytest.ring, block #20.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("test")
oGraph.AddNodeXTT("alice", "Person", [:age = 30])

StzGraphQueryQ(oGraph) {
	Match([:node = "n", :where = [:id, "=", "alice"]])
	Set("n.age", [:to = 31])
	Select("n")
	
	? GraphObject().NodeProperty("alice", "age")
	#--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.26
