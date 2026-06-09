# Narrative
# --------
# Explain query execution plan
#
# Extracted from stzgraphquerytest.ring, block #24.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("test")
oGraph.AddNodeXT("alice", "Person")

aExplanation = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Person"]).
	WhereQ([:age, ">", 25]).
	OrderByQ("age", "ASC").
	LimitQ(10).

	Explain()

? @@NL(aExplanation)
#--> [
# 	[
# 		[ "step", "match" ],
# 		[
# 			"description",
# 			[
# 				"Scan all nodes, bind to variable 'node' with label 'Person'"
# 			]
# 		]
# 	],
# 	[
# 		[ "step", "where" ],
# 		[
# 			"description",
# 			[ "Filter bindings using: node.age > 25" ]
# 		]
# 	],
# 	[
# 		[ "step", "orderby" ],
# 		[
# 			"description",
# 			[ "Sort by: age ASC" ]
# 		]
# 	],
# 	[
# 		[ "step", "limit" ],
# 		[
# 			"description",
# 			[ "Return maximum 10 results" ]
# 		]
# 	]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.26

#-------------------------#
#  OPENCYPHER CONVERSION  #
#-------------------------#
