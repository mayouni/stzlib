# Narrative
# --------
# Scenario 1: Normal fluent API
#
# Extracted from stzgraphquerytest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


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

StzGraphQueryQ(oGraph) {
    Match([:node = "n"])
    Select("n.id")

    if Executed()
        ? @@NL(Result()) #ERR
    ok
}
#--> [
#	[
#		[ "n.id", "alice" ]
#	],
#	[
#		[ "n.id", "bob" ]
#	],
#	[
#		[ "n.id", "carol" ]
#	],
#	[
#		[ "n.id", "dave" ]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.26
