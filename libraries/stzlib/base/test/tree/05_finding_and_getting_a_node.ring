# Narrative
# --------
# FINDING AND GETTING A NODE
#
# Extracted from stzTreeTest.ring, block #5.

load "../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)


? o1.FindNode(:node2)
#--> [:root][:node2]

? @@( o1.Node(:node2) )
#--> [ 1, 2, 3 ]

? @@( o1.NodeAt('[:root][:node2]') )
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
