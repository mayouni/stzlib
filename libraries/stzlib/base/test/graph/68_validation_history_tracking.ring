# Narrative
# --------
# VALIDATION: History Tracking
#
# Extracted from stzgraphtest.ring, block #68.
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

oGraph = new stzGraph("MyHistory")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	# First validation
	? ValidateXT(:DAG_RULES_GROUP)[:status]
	#--> pass
	
	# Note: Adding cycle now would be blocked by constraint
	# so we disable constraints temporarily for demo

	DisableConstraints()
	Connect("b", "a")
	EnableConstraints()
	
	# After creating cycle (constraint bypassed)
	? ValidateXT(:DAG_RULES_GROUP)[:status]
	#--> pass

	? @@NL( Violations() )
	#--> []
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

#=======================================================================#
#  GRAPH (SINGLE AND MULTIPLE) COMPARAISON, ANALYSIS AND VISUALIZATION  #
#=======================================================================#

#---------------------------------------#
#  GRAPH COMPARISON - IDENTICAL GRAPHS  #
#---------------------------------------#
