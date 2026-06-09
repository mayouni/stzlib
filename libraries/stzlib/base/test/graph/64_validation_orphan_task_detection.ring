# Narrative
# --------
# VALIDATION: Orphan Task Detection
#
# Extracted from stzgraphtest.ring, block #64.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

RegisterRuleInGroup(:PROJECT_RULES_GROUP, "TASKS_HAVE_NO_WONERS", [
	:type = :Validation,
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
		_nNodes1Len_ = ring_len(aNodes)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			aNode = aNodes[_iLoopNodes1_]
			if oGraph.NodeProperty(aNode[:id], "type") = "task"
				if len(oGraph.Incoming(aNode[:id])) = 0
					return [FALSE, "Task '" + aNode[:id] + "' has no owner"]
				ok
			ok
		next
		return [TRUE, ""]
	},
	:params = [],
	:message = "Orphan tasks found",
	:severity = :warning
])

oGraph = new stzGraph("Project")
oGraph {
	AddNodeXTT(:task1, "Build UI", [:type = "task"])
	AddNodeXTT(:alice, "Alice", [:type = "person"])
	
	# Before assigning owner: Orphan exists

	? @@NL( ValidateXT(:PROJECT_RULES_GROUP) ) + NL
	#--> [
	# 	[ "status", "fail" ],
	# 	[ "rulegroup", "project" ],
	# 	[ "issuecount", 1 ],
	# 	[
	# 		"issues",
	# 		[ "Task 'task1' has no owner" ]
	# 	],
	# 	[ "affectednodes", [  ] ]
	# ]

	# Assign owner

	AddEdgeXT(:alice, :task1, "owns")
	? ValidateXT(:PROJECT_RULES_GROUP)[:status]
	#--> "pass"
}

pf()
# Executed in 0.01 second(s) in Ring 1.25
