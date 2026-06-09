# Narrative
# --------
# COMPLETE: Dev Project Workflow
#
# Extracted from stzgraphtest.ring, block #66.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Constraint: Block invalid dependencies
RegisterRuleInGroup(:DEV_RULES_GROUP, "NO_REVERSE_DEPS", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and HasKey(paOp, :to)
			if oGraph.NodeExists(paOp[:from]) and oGraph.NodeExists(paOp[:to])
				if oGraph.NodeProperty(paOp[:from], "type") = "feature" and
				   oGraph.NodeProperty(paOp[:to], "type") = "test"
					return [TRUE, "Features can't depend on tests"]
				ok
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Invalid dependency",
	:severity = :error
])

# Derivation: Auto-create test nodes
RegisterRuleInGroup(:DEV_RULES_GROUP, "AUTO_TESTS", [
	:type = :Derivation,
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []
		aNodes = oGraph.Nodes()
		
		_nNodes2Len_ = ring_len(aNodes)
		for _iLoopNodes2_ = 1 to _nNodes2Len_
			aNode = aNodes[_iLoopNodes2_]
			if oGraph.NodeProperty(aNode[:id], "type") = "feature"
				cTest = aNode[:id] + "_test"
				if NOT oGraph.NodeExists(cTest)
					oGraph.AddNodeXTT(cTest, "Test: " + aNode[:label], [:type = "test"])
				ok
				if NOT oGraph.EdgeExists(aNode[:id], cTest)
					aNewEdges + [aNode[:id], cTest, "requires", []]
				ok
			ok
		next
		return aNewEdges
	},
	:params = [],
	:message = "Tests auto-generated",
	:severity = :info
])

# Validation: Check coverage
RegisterRuleInGroup(:DEV_RULES_GROUP, "FULL_COVERAGE", [
	:type = :Validation,
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
		nFeatures = 0
		nTests = 0
		
		_nNodes1Len_ = ring_len(aNodes)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			aNode = aNodes[_iLoopNodes1_]
			cType = oGraph.NodeProperty(aNode[:id], "type")
			if cType = "feature"
				nFeatures++
			but cType = "test"
				nTests++
			ok
		next
		
		if nTests < nFeatures
			return [FALSE, "Coverage: " + nTests + "/" + nFeatures]
		ok
		return [TRUE, ""]
	},
	:params = [],
	:message = "Incomplete coverage",
	:severity = :warning
])

oGraph = new stzGraph("MyDevProject")
oGraph {
	AddNodeXTT(:@login, "Login", [ :type = "feature" ])
	AddNodeXTT(:@profile, "Profile", [ :type = "feature" ])
	
	# Initial nodes
	#--------------

	? NodeCount()
	#--> 2

	UseRulesFrom(:DEV_RULES_GROUP)
	aResult = ApplyDerivationRulesXT()
	
	# After derivation
	#-----------------

	? NodeCount()
	#--> 4

	# Tests added
	? @@NL( aResult[:edgesAdded] )
	#--> [
	# 	[
	# 		"@login",
	# 		"@login_test",
	# 		"requires",
	# 		[  ]
	# 	],
	# 	[
	# 		"@profile",
	# 		"@profile_test",
	# 		"requires",
	# 		[  ]
	# 	]
	# ]

	# Validation
	? ValidateXT(:dev)[:status]
	#--> pass

	# Try invalid dependency
	Connect("login", "profile_test")
	#--> ERROR: Cannot add edge: one or both nodes do not exist!
}

pf()
# Executed in 0.01 second(s) in Ring 1.25
