# Narrative
# --------
# DERIVATION: Manager Access Rights
#
# Extracted from stzgraphtest.ring, block #63.

load "../../stzBase.ring"


pr()

RegisterRuleInGroup(:ACCESS_RULES_GROUP, "MANAGER_SEES_REPORTS", [
	:type = :Derivation,
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []
		aEdges = oGraph.Edges()
		
		for aEdge in aEdges
			if aEdge[:label] = "manages"
				cManager = aEdge[:from]
				cEmployee = aEdge[:to]
				cReport = cEmployee + "_report"
				
				if oGraph.NodeExists(cReport)
					if NOT oGraph.EdgeExists(cManager, cReport)
						aNewEdges + [cManager, cReport, "can_view", []]
					ok
				ok
			ok
		next
		return aNewEdges
	},
	:params = [],
	:message = "Manager access granted",
	:severity = :info
])

oGraph = new stzGraph("MyCompany")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("bob_report")
	
	AddEdgeXT("alice", "bob", "manages")

	# Before validation alice → bob_report path does not exist
	? PathExists("alice", "bob_report")
	#--> FALSE

	# Let's do the validation

	UseRulesFrom(:ACCESS_RULES_GROUP)
	? @@NL( ApplyDerivationRulesXT() ) + NL
}
#--> [
# 	[
# 		"edgesadded",
# 		[
# 			[
# 				"alice",
# 				"bob_report",
# 				"can_view",
# 				[  ]
# 			]
# 		]
# 	],
# 	[
# 		"rulesapplied",
# 		[
# 			[
# 				[ "name", "MANAGER_SEES_REPORTS" ],
# 				[ "type", "derivation" ],
# 				[ "function", "_ring_anonymous_func_1797244" ],
# 				[ "params", [  ] ],
# 				[ "message", "Manager access granted" ],
# 				[ "severity", "info" ]
# 			]
# 		]
# 	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.25
