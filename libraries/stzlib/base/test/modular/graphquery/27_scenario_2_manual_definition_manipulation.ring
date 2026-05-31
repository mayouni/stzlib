# Narrative
# --------
# Scenario 2: Manual definition manipulation
#
# Extracted from stzgraphquerytest.ring, block #27.

load "../../../stzBase.ring"


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

	aDef = Definition()
	aDef["limit"] = 3  # Modify directly
	SetDefinition(aDef)
	? @@NL(aDef)
	#--> [
	# 	[
	# 		"match_patterns",
	# 		[
	# 			[
	# 				[ "type", "node" ],
	# 				[ "alias", "n" ],
	# 				[ "label", "" ],
	# 				[ "props", [  ] ]
	# 			]
	# 		]
	# 	],
	# 	[ "where_conditions", [  ] ],
	# 	[
	# 		"select_fields",
	# 		[ "n.id" ]
	# 	],
	# 	[ "create_patterns", [  ] ],
	# 	[ "set_operations", [  ] ],
	# 	[ "delete_targets", [  ] ],
	# 	[ "order_by", [  ] ],
	# 	[ "skip", 0 ],
	# 	[ "limit", 3 ],
	# 	[ "distinct", 0 ]
	# ]

	Execute()

	? @@NL(Result())
	#--> [
	# 	[
	# 		[ "n.id", "alice" ]
	# 	],
	# 	[
	# 		[ "n.id", "bob" ]
	# 	],
	# 	[
	# 		[ "n.id", "carol" ]
	# 	]
	# ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.26
