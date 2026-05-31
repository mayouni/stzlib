# Narrative
# --------
# FINDING AND GETTING AN ITEM
#
# Extracted from stzTreeTest.ring, block #9.

load "../../../stzBase.ring"


pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@( o1.Items() ) + NL
#--> [ "X", "A", "B", "C", "D", "X", 1, 2, 3, "X", 4, 5 ]

? @@( o1.ItemAt('[:root][:node3][1]') ) + NL
#--> "X"

? @@( o1.ItemsInNode(:node3) ) + NL
#--> [ "X", 4, 5 ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

#=== FINDING ITEMS

pr()

o1 = new stzTree(
	:root = [
		:node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
		:node2 = [ 1, 2, 3 ],
		:node3 = [ "X", 4, 5 ]
	]
)

? @@NL( o1.FindItem("X") ) + NL
#--> [
#	"[:root][:node1][1]",
#	"[:root][:node1][:node11][5]",
#	"[:root][:node3][1]"
# ]

? @@NL( o1.FindTheseItems([ "X", "C", 2, 5 ]) ) + NL
#--> [
#	"[:root][:node3][1]",
#	"[:root][:node3][1]",
#	"[:root][:node3][1]",
#	"[:root][:node1][:node11][3]",
#	"[:root][:node2][2]",
#	"[:root][:node3][3]"
# ]

? @@NL( o1.FindItems() ) + NL # Or FindAllItems()
#--> [
#	"[:root][:node1][1]",
#	"[:root][:node1][:node11][5]",
#	"[:root][:node3][1]",
#	"[:root][:node1][:node11][1]",
#	"[:root][:node1][:node11][2]",
#	"[:root][:node1][:node11][3]",
#	"[:root][:node1][:node11][4]",
#	"[:root][:node2][1]",
#	"[:root][:node2][2]",
#	"[:root][:node2][3]",
#	"[:root][:node3][2]",
#	"[:root][:node3][3]"
# ]

? @@NL( o1.ItemsZ() ) # Or ItemsAndTheirPaths()
#--> [
#	[
#		"X",
#		[
#			"[:root][:node1]",
#			"[:root][:node1][:node11]",
#			"[:root][:node3]"
#		]
#	],
#	[
#		"A",
#		[ "[:root][:node1][:node11]" ]
#	],
#	[
#		"B",
#		[ "[:root][:node1][:node11]" ]
#	],
#	[
#		"C",
#		[ "[:root][:node1][:node11]" ]
#	],
#	[
#		"D",
#		[ "[:root][:node1][:node11]" ]
#	],
#	[
#		"X",
#		[ ]
#	],
#	[
#		1,
#		[ "[:root][:node2]" ]
#	],
#	[
#		2,
#		[ "[:root][:node2]" ]
#	],
#	[
#		3,
#		[ "[:root][:node2]" ]
#	],
#	[
#		"X",
#		[ ]
#	],
#	[
#		4,
#		[ "[:root][:node3]" ]
#	],
#	[
#		5,
#		[ "[:root][:node3]" ]
#	]
# ]

pf()
# Executed in 0.42 second(s) in Ring 1.22

#===== REMOVING ITEMS AND NODES
