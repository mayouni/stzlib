# Narrative
# --------
# RULE MANAGEMENT & Introspection
#
# Extracted from stzgraphtest.ring, block #65.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


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

oGraph = new stzGraph("Test")
oGraph {

	# Initial: no active rules
	? len(ActiveRules())
	#--> 0
	
	UseRulesFrom(:DAG_RULES_GROUP)
	UseRulesFrom(:WORKFLOW_RULES_GROUP)

	# After loading the rules
	? @@NL( ActiveRules() )
	#--> [
	# 	[ "constraint", "NO_CYCLES" ],
	# 	[ "constraint", "NO_SELF_APPROVAL" ]
	# ]

	? HasRule("NO_CYCLES")
	#--> TRUE

	RemoveRule("NO_CYCLES")
	? HasRule("no_cycles")
	#--> FALSE

	ClearRules()
	? len(ActiveRules())
	#--> 0
}

pf()
# Executed in almost 0 second(s) in Ring 1.25
