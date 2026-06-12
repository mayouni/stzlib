# Narrative
# --------
# How to use .stzrulz file format?
#
# Extracted from stzgraphtest.ring, block #84.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

#TODO Review the file formats feature to cope with the
# new design of the rule system!

# Loading rules...
oGraph = new stzGraph("org")
oGraph.LoadFromStzRulz("../_data/bceao_banking.stzrulz")

? "Rules loaded: " + len(oGraph.RulesSummary()[:constraints])

pf()

#---------------------------------------#
#  3. custom_functions.stzrulf          #
#     Custom rule function definitions  #
#=======================================#

# Example of a .stzrulf file format
#----------------------------------
`
# Banking-specific custom functions
# This is pure Ring code that gets loaded

func CustomFunc_ManagerApproval()
	return func(oGraph, paRuleParams) {
		aNewEdges = []
		aNodes = oGraph.Nodes()
		
		_nNodes2Len_ = len(aNodes)
		for _iLoopNodes2_ = 1 to _nNodes2Len_
			aNode = aNodes[_iLoopNodes2_]
			if oGraph.NodeProperty(aNode[:id], "role") = "manager"
				cManager = aNode[:id]
				aSubordinates = oGraph.Neighbors(cManager)
				
				_nSubordinates1Len_ = len(aSubordinates)
				for _iLoopSubordinates1_ = 1 to _nSubordinates1Len_
					cSub = aSubordinates[_iLoopSubordinates1_]
					cApprovalNode = cSub + "_approval"
					if oGraph.NodeExists(cApprovalNode)
						if NOT oGraph.EdgeExists(cManager, cApprovalNode)
							aNewEdges + [cManager, cApprovalNode, "can_approve", []]
						ok
					ok
				next
			ok
		next
		
		return aNewEdges
	}

func CustomFunc_NoBackdating()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom) and oGraph.NodeExists(cTo)
				dFromDate = oGraph.NodeProperty(cFrom, "date")
				dToDate = oGraph.NodeProperty(cTo, "date")
				
				if isString(dFromDate) and isString(dToDate)
					if dToDate < dFromDate
						return [TRUE, "Cannot backdate transactions"]
					ok
				ok
			ok
		ok
		return [FALSE, ""]
	}

func CustomFunc_BalancedTeams()
	return func(oGraph, paRuleParams) {
		nMinSize = paRuleParams[:minSize]
		nMaxSize = paRuleParams[:maxSize]
		
		aNodes = oGraph.Nodes()
		
		_nNodes1Len_ = len(aNodes)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			aNode = aNodes[_iLoopNodes1_]
			if oGraph.NodeProperty(aNode[:id], "role") = "manager"
				nTeamSize = len(oGraph.Neighbors(aNode[:id]))
				
				if nTeamSize < nMinSize
					return [FALSE, "Team " + aNode[:id] + " too small (" + nTeamSize + ")"]
				but nTeamSize > nMaxSize
					return [FALSE, "Team " + aNode[:id] + " too large (" + nTeamSize + ")"]
				ok
			ok
		next
		
		return [TRUE, ""]
	}

# Register these as built-in style functions
RegisterRuleInGroup(:banking, "manager_approval_rights", [
	:type = :derivation,
	:function = CustomFunc_ManagerApproval(),
	:params = [],
	:message = "Manager approval rights derived",
	:severity = :info
])

RegisterRuleInGroup(:banking, "no_backdating", [
	:type = :constraint,
	:function = CustomFunc_NoBackdating(),
	:params = [],
	:message = "Backdating not allowed",
	:severity = :error
])

RegisterRuleInGroup(:hr, "balanced_teams", [
	:type = :validation,
	:function = CustomFunc_BalancedTeams(),
	:params = [:minSize = 3, :maxSize = 8],
	:message = "Teams must be balanced",
	:severity = :warning
])
`
