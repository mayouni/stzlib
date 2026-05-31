# Narrative
# --------
# Select multiple fields
#
# Extracted from stzgraphquerytest.ring, block #14.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	Select(["n.name", "n.age"])

? len(aResults)
#--> 2

? @@( aResults[1] )
#--> [["n.name", "Alice"], ["n.age", 30]]

pf()
# Executed in 0.01 second(s) in Ring 1.25
