# Narrative
# --------
# Create edge
#
# Extracted from stzgraphquerytest.ring, block #19.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

StzGraphQueryQ(oGraph) {
	Match([:node = "a", :where = [:id, "=", "alice"]])
	Match([:node = "b", :where = [:id, "=", "bob"]])
	Create([:edge, :from = "a", :to = "b", :labeled = "KNOWS"])

	? len(Select("a"))
	#--> 1

	? GraphQ().EdgeCount()
	#--> 1
}

pf()
# Executed in 0.01 second(s) in Ring 1.26

#-------------------#
#  UPDATE PATTERNS  #
#-------------------#
