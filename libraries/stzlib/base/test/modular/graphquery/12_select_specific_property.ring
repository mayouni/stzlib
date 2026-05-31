# Narrative
# --------
# Select specific property
#
# Extracted from stzgraphquerytest.ring, block #12.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

StzGraphQueryQ(oGraph) {

	# Design the query
	MatchQ([:node = "n"])
	SelectQ("n.name")

	# Get the query definition
	? @@NL( Definition() ) + NL # Or Query() or AST()
	#--> [
	# 	[
	# 		"match_patterns",
	# 		[
	# 			[
	# 				[ "type", "node" ],
	# 				[ "alias", "n" ],
	# 				[ "label", "" ],
	# 		
	# 		[ "props", [  ] ]
	# 			]
	# 		]
	# 	],
	# 	[ "where_conditions", [  ] ],
	# 	[
	# 		"select_fields",
	# 		[ "n.name" ]
	# 	],
	# 	[ "create_patterns", [  ] ],
	# 	[ "set_operations", [  ] ],
	# 	[ "delete_targets", [  ] ],
	# 	[ "order_by", [  ] ],
	# 	[ "skip", 0 ],
	# 	[ "limit", 0 ],
	# 	[ "distinct", 0 ]
	# ]

	# Execute the query
	if Executed()
		aResult = Result()

		? len(aResult)
		#--> 2
		
		? @@( aResult[1]["n.name"] )
		#--> "Alice"
	else
		"Query execution has failed!"
	ok
}

pf()
# Executed in 0.01 second(s) in Ring 1.25
