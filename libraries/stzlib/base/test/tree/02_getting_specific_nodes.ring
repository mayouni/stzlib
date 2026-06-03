# Narrative
# --------
# GETTING SPECIFIC NODE(S)
#
# Extracted from stzTreeTest.ring, block #2.

load "../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

# Getting all the nodes

? @@( o1.Nodes() ) + NL
#--> [ "root", "node1", "node11", "node2", "node3" ]

? @@( o1.Node(:node11) ) + NL
#--> [ "A", "B", "C", "D", "X" ]

? @@NL( o1.TheseNodes([ :node11, :node3 ]) )
#--> [
#	[ "A", "B", "C", "D", "X" ],
#	[ "X", 4, 5 ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
