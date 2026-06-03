# Narrative
# --------
# FINDING AND GETTING MANY NODES
#
# Extracted from stzTreeTest.ring, block #6.

load "../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@NL( o1.FindNodes() ) + NL # Or FindAllNodes()
#--> [
#	"[:root]",
#	"[:root][:node1]",
#	"[:root][:node1][:node11]",
#	"[:root][:node2]",
#	"[:root][:node3]"
# ]

? @@( o1.FindTheseNodes([:node2, :node3 ]) )
#--> [ "[:root][:node2]", "[:root][:node3]" ]

? @@( o1.TheseNodes([:node2, :node3 ]) )
#--> [ [ 1, 2, 3 ], [ "X", 4, 5 ] ]

? @@( o1.NodesAt([ '[:root][:node2]', '[:root][:node3]' ]) )
#--> [ [ 1, 2, 3 ], [ "X", 4, 5 ] ]

pf()
# Executed in 0.08 second(s) in Ring 1.22
