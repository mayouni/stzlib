# Narrative
# --------
# Delete node
#
# Extracted from stzgraphquerytest.ring, block #22.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

StzGraphQueryQ(oGraph) {
	Match([:node = "n", :where = [:id, "=", "alice"]])
	Delete("n")
	Select("n")
}

? oGraph.NodeCount()
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.26

#---------------------------#
#  COMPLEX PATTERN QUERIES  #
#---------------------------#
