load "../max/stzmax.ring"

/*--- NODES, ITEMS, AND BRANCHES

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

/*--- GETTING SPECIFIC NODE(S)

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

/*--- BRANCHES AND NODES

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

/*--- FINDING NODE(S)
*/
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

/*--- FINDING AND GETTING A NODE

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

/*--- FINDING AND GETTING MANY NODES

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

/*---

pr()

? IsValidNodePath('[:root][:node3]')
#--> TRUE

? IsValidItemPath('[:root][:node3][1]')
#--> TRUE

? IsListOfValidNodesPaths([ '[:root][:node3]', '[:root][:node3][:node31]' ])
#--> TRUE

? IsListOfValidItemsPaths([ '[:root][:node3][1]', '[:root][:node2][3]' ])
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

? IsValidNodePath('[:root][:node2][2]')
#--> FALSE

? IsValidNodePath('[:root][:node2][:node21]')
#--> TRUE

? IsValidItemPath('[:root][:node2][2]')
#--> TRUE

? IsValidItemPath('[:root][:node2][:node21]')
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- FINDING AND GETTING AN ITEM

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

/*---

pr()

o1 = new stzList([ "X", [ 1, "Y", 2, [ 3, "X"] ], 4, "Y" ])
o1.DeepRemoveMany([ "X", "Y" ])
? @@( o1.Content() )
#--> [ [ 1, 2, [ 3 ] ], 4 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
