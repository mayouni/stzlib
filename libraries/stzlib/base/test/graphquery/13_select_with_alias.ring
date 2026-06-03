# Narrative
# --------
# Select with alias
#
# Extracted from stzgraphquerytest.ring, block #13.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30])
	AddNodeXTT("bob", "Employee", [:age = 25])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	Select(["n.age", :as = "years"])

? @@( aResults[1]["years"] )
#--> 30

? @@( aResults ) #-->
#--> [ [ [ "years", 30 ] ], [ [ "years", 25 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.25
