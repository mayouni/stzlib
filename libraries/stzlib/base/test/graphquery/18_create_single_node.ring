# Narrative
# --------
# Create single node
#
# Extracted from stzgraphquerytest.ring, block #18.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("test")

StzGraphQueryQ(oGraph) {
	Create([:node, :labeled = "Person", :props = [:name = "Alice"]])
	Select("*")
	? GraphQ().NodeCount()
	#--> 1
}

pf()
# Executed in almost 0 second(s) in Ring 1.26
