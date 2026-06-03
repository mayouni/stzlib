# Narrative
# --------
# Match edge with properties
#
# Extracted from stzgraphquerytest.ring, block #5.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXTT("alice", "bob", "KNOWS", [:since = 2020])
	ConnectXTT("alice", "carol", "KNOWS", [:since = 2022])
}

aResults = StzGraphQueryQ(oGraph).
	MatchEdgeQ([:from = "a", :to = "b", :where = [:since, "=", 2020]]).
	Select(["a", "b"])

? len(aResults) 
#--> 1

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

#-------------------#
#  WHERE FILTERING  #
#-------------------#
