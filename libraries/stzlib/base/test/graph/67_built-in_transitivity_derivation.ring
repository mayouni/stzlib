# Narrative
# --------
# BUILT-IN: Transitivity Derivation
#
# Extracted from stzgraphtest.ring, block #67.

load "../../stzBase.ring"


pr()

RegisterRuleInGroup(:ACCESS_RULES_GROUP, "TRANSITIVE", [
	:type = :Derivation,
	:function = DerivationFunc_Transitivity(),
	:params = [],
	:message = "Transitive access",
	:severity = :info
])

oGraph = new stzGraph("MyAccessSystem")
oGraph {
	AddNode("alice")
	AddNode("folder")
	AddNode("file")
	
	Connect("alice", "folder")
	Connect("folder", "file")
	
	# Before: alice → file?
	? EdgeExists("alice", "file")
	#--> FALSE

	UseRulesFrom(:ACCESS_RULES_GROUP)
	ApplyDerivationRules()
	
	# After: alice → file?
	? EdgeExists("alice", "file")
	#--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.25
