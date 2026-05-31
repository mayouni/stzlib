# Narrative
# --------
# Find friends of friends
#
# Extracted from stzgraphquerytest.ring, block #23.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	AddNode("dave")
	
	ConnectXT("alice", "bob", "FRIEND")
	ConnectXT("bob", "carol", "FRIEND")
	ConnectXT("bob", "dave", "FRIEND")
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "a", :where = [:id, "=", "alice"]]).
	MatchEdgeQ([:from = "a", :to = "friend", :labeled = "FRIEND"]).
	MatchEdgeQ([:from = "friend", :to = "fof", :labeled = "FRIEND"]).
	Select("fof")

? len(aResults)
#--> 2 (carol and dave)

pf()
# Executed in 0.02 second(s) in Ring 1.26

#----------------------#
#  EXPLAIN QUERY PLAN  #
#----------------------#
