# Narrative
# --------
# CONSTRAINT: Cycle Prevention in Directed Graphs (DAG)
#
# Extracted from stzgraphtest.ring, block #62.

load "../../../stzBase.ring"


pr()

RegisterRuleInGroup(:DAG_RULES_GROUP, "NO_CYCLES", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and HasKey(paOp, :to)
			# Would create cycle if path exists in reverse
			if oGraph.PathExists(paOp[:to], paOp[:from])
				return [TRUE, "Would create a cycle"]
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Cycles not allowed",
	:severity = :error
])

oGraph = new stzGraph("MyDAG")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	UseRulesFrom(:DAG_RULES_GROUP)
	
	# Build chain: a→b→c
	ConnectInSequence(["a", "b", "c"])
	
	# Try closing the loop
	? @@NL( CheckConstraintRules([:from = "c", :to = "a"]) )
}
#--> [
# 	FALSE,
# 	[
# 		[
# 			[ "rule", "NO_CYCLES" ],
# 			[ "message", "Would create a cycle" ], #TODO Not clear!
# 			[ "severity", "error" ],
# 			[
# 				"params",
# 				[
# 					[ "from", "c" ],
# 					[ "to", "a" ]
# 				]
# 			]
# 		]
# 	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.25
