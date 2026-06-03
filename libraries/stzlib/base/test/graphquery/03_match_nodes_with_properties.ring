# Narrative
# --------
# Match nodes with properties
#
# Extracted from stzgraphquerytest.ring, block #3.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30, :city = "Paris"])
	AddNodeXTT("bob", "Person", [:age = 25, :city = "London"])
	AddNodeXTT("carol", "Person", [:age = 30, :city = "Paris"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :where = [:age, "=", 30]]).
	Select("*")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

#--------------------------#
#  RELATIONSHIP MATCHING   #
#--------------------------#
