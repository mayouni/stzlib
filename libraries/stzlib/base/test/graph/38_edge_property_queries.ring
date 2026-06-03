# Narrative
# --------
# Edge Property Queries
#
# Extracted from stzgraphtest.ring, block #38.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("EdgePropTest")
oGraph {
	AddNodeXTT("a", "Node A", [ :status = "complete" ])
	AddNodeXTT("b", "Node B", [ :status = "inprogress" ])
	AddNode("c")
	AddNodeXTT("d", "Node D", [ :status = "complete" ])

	AddEdgeXTT("a", "b", "fast", [:speed = 100])
	AddEdgeXTT("b", "c", "slow", [:speed = 10])
	AddEdgeXTT("c", "d", "fast-again", [:speed = 120])

	#--

	? BoxRound("PROPERTY QUERY")

	? @@( Find("edges").Where("speed", "=", 100).Run() )
	#--> [ [ "a", "b" ] ]

	# Or more expressively:
	# ? @@( EdgesWhere("speed", "=", 100) ) + NL # Or EdgesByProperty

	#--

	? @@( Find("edges").Where("speed", "between", [ 80, 120 ]).Run() ) + NL
	#--> [ [ "a", "b" ] ]

	# Or more expressively:
	# ? @@( EdgesWhere("speed", :Between, [ 80, 120 ]) )

	? BoxRound("FUNCTION QUERY")

	? @@NL( NodesWF( func(aNode) { return aNode[:properties][:status] = "complete" } ) )
	#--> [ "a", "d" ]

	? @@NL( EdgesWF( func(aEdge) { return aEdge[:properties][:speed] >= 100 }  ) )
	#--> [
	# 	[ "a", "b" ],
	# 	[ "c", "d" ]
	# ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  SECTION 10: properties OPERATIONS
#============================================#
