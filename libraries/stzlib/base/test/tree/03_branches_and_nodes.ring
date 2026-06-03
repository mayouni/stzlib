# Narrative
# --------
# BRANCHES AND NODES
#
# Extracted from stzTreeTest.ring, block #3.

load "../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@NL( o1.Branches() ) + NL
#--> #--> [
#	"[:root]",
#	"[:root][:node1]",
#	"[:root][:node1][:node11]",
#	"[:root][:node2]",
#	"[:root][:node3]"
# ]

? @@( o1.NodeAt('[:root][:node2]') ) + NL
#--> [ 1, 2, 3 ]

? @@NL( o1.NodesAt([ '[:root][:node2]', '[:root][:node3]' ]) )
#--> [
#	[ 1, 2, 3 ],
#	[ "X", 4, 5 ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
