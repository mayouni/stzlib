# Narrative
# --------
# NODES, ITEMS, AND BRANCHES
#
# Extracted from stzTreeTest.ring, block #1.

load "../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@( o1.Nodes() ) + NL
#--> [ "root", "node1", "node11", "node2", "node3" ]

? @@( o1.Items() ) + NL
#--> [ "X", "A", "B", "C", "D", "X", 1, 2, 3, "X", 4, 5 ]

? @@NL( o1.Branches() )
#--> [
#	"[:root]",
#	"[:root][:node1]",
#	"[:root][:node1][:node11]",
#	"[:root][:node2]",
#	"[:root][:node3]"
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
