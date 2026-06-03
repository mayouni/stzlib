# Narrative
# --------
# FINDING NODE(S)
#
# Extracted from stzTreeTest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@NL( o1.NodesZ() ) + NL # Or NodesAndTheirBranches()
#--> [
#	[ "root", "[:root]" ],
#	[ "node1", "[:root][:node1]" ],
#	[ "node11", "[:root][:node1][:node11]" ],
#	[ "node2", "[:root][:node2]" ],
#	[ "node3", "[:root][:node3]" ]
# ]

? @@( o1.FindNode(:node1) ) + NL
#--> "[:root][:node1]"

? @@NL( o1.FindTheseNodes([ :node1, :node3 ]) ) + NL
#--> [ "[:root][:node1]", "[:root][:node3]" ]

? @@NL( o1.FindNodes() ) # Or FindAllNodes()
#--> [
#	"[:root]",
#	"[:root][:node1]",
#	"[:root][:node1][:node11]",
#	"[:root][:node2]",
#	"[:root][:node3]"
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
