# Narrative
# --------
# CONSTRAINT: Block Invalid Ops (Rule runs BEFORE operations)
#
# Extracted from stzgraphtest.ring, block #61.

load "../../../stzBase.ring"

pr()

# Register: No one approves their own work
RegisterRuleInGroup(:WORKFLOW_RULES_GROUP, "NO_SELF_APPROVAL", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and HasKey(paOp, :to) and HasKey(paOp, :label)
			if paOp[:from] = paOp[:to] and paOp[:label] = "approves"
				return [TRUE, "Cannot approve your own work"]  # BLOCKED
			ok
		ok
		return [FALSE, ""]  # ALLOWED
	},
	:params = [],
	:message = "Self-approval blocked",
	:severity = :error
])

oGraph = new stzGraph("MyWorkflow")
oGraph {
	AddNode("john")
	AddNode("mary")
	UseRulesFrom(:WORKFLOW_RULES_GROUP)
	
	# Valid: John approves Mary
	AddEdgeXT("john", "mary", "approves")
	? NumberOfEdges()
	#--> 1

	# Invalid: John approves John
	AddEdgeXT("john", "john", "approves")
	#--> Cannot add edge - constraint violation:
	# Cannot approve your own work

}

pf()
# Executed in almost 0 second(s) in Ring 1.25
