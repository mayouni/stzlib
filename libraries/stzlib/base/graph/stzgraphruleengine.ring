#============================================#
#  stzGraphRuleEngine - Rule Executor        #
#  Applies rules to graphs                   #
#============================================#

class stzGraphRuleEngine
	@aoRuleBases = []
	@oGraph = NULL

	def init(poGraph)
		@oGraph = poGraph
	
	#-------------------#
	#  RULEBASE MGMT    #
	#-------------------#
	
	def AddRuleBase(pRuleBase)
		if isString(pRuleBase)
			# Load by name
			oRuleBase = This._LoadNamedRuleBase(pRuleBase)
			if oRuleBase != NULL
				@aoRuleBases + oRuleBase
			ok
		but isObject(pRuleBase)
			@aoRuleBases + pRuleBase
		ok
	
	def _LoadNamedRuleBase(pcName)
		cName = lower(pcName)
		
		switch cName
		on "graph"
			return new stzGraphDefaultRuleBase()
		on "diagram"
			return new stzDiagramDefaultRuleBase()
		on "orgchart"
			return new stzOrgChartDefaultRuleBase()
		on "banking"
			return new stzBankingRuleBase()
		on "bceao"
			return new stzBCEAORuleBase()
		off
		
		return NULL
	
	def RuleBases()
		return @aoRuleBases
	
	def RuleCount()
		nCount = 0
		for oBase in @aoRuleBases
			nCount += oBase.RuleCount()
		end
		return nCount
	
	#-------------------#
	#  RULE COLLECTION  #
	#-------------------#
	
	def CollectRules(pcType, pcLevel)
		aoCollected = []
		
		for oBase in @aoRuleBases
			aoRules = oBase.Rules()
			
			for oRule in aoRules
				bMatch = TRUE
				
				if pcType != "" and oRule.RuleType() != pcType
					bMatch = FALSE
				ok
				
				if pcLevel != "" and oRule.Level() != pcLevel
					bMatch = FALSE
				ok
				
				if bMatch
					aoCollected + oRule
				ok
			end
		end
		
		return aoCollected
	
	#-------------------#
	#  VALIDATION       #
	#-------------------#
	
	def Validate(pcType)
		if pcType = "" or pcType = NULL
			pcType = "validation"
		ok
		
		aoRules = This.CollectRules(pcType, "")
		aResults = []
		
		for oRule in aoRules
			oRule.SetGraph(@oGraph)
			aResult = oRule.Apply(@oGraph, pcType)
			
			if aResult[:status] = "fail"
				aResults + aResult
			ok
		end
		
		return This._AggregateResults(aResults)
	
	def ValidateDomain(pcDomain)
		aoRules = []
		
		for oBase in @aoRuleBases
			aoRules + oBase.RulesByDomain(pcDomain)
		end
		
		aResults = []
		for oRule in aoRules
			oRule.SetGraph(@oGraph)
			aResult = oRule.Apply(@oGraph, "validation")
			
			if aResult[:status] = "fail"
				aResults + aResult
			ok
		end
		
		return This._AggregateResults(aResults)
	
	def _AggregateResults(paResults)
		if len(paResults) = 0
			return [
				:status = "pass",
				:issueCount = 0,
				:issues = [],
				:affectedNodes = []
			]
		ok
		
		nTotalIssues = 0
		acAllIssues = []
		acAllAffected = []
		
		for aResult in paResults
			nTotalIssues += aResult[:issueCount]
			
			for cIssue in aResult[:issues]
				acAllIssues + cIssue
			end
			
			for cNode in aResult[:affectedNodes]
				if ring_find(acAllAffected, cNode) = 0
					acAllAffected + cNode
				ok
			end
		end
		
		return [
			:status = "fail",
			:issueCount = nTotalIssues,
			:issues = acAllIssues,
			:affectedNodes = acAllAffected,
			:results = paResults
		]
	
	#-------------------#
	#  INFERENCE        #
	#-------------------#
	
	def ApplyInference()
		aoRules = This.CollectRules("inference", "")
		nInferred = 0
		
		for oRule in aoRules
			oRule.SetGraph(@oGraph)
			nInferred += oRule.Apply(@oGraph, "inference")
		end
		
		return nInferred
	
	#-------------------#
	#  CONSTRAINTS      #
	#-------------------#
	
	def CheckConstraints()
		aoRules = This.CollectRules("constraint", "")
		aViolations = []
		
		for oRule in aoRules
			oRule.SetGraph(@oGraph)
			aResult = oRule.Apply(@oGraph, "constraint")
			
			if aResult[:status] = "fail"
				aViolations + aResult
			ok
		end
		
		return This._AggregateResults(aViolations)
	
	#-------------------#
	#  VISUAL           #
	#-------------------#
	
	def ApplyVisualRules()
		aoRules = This.CollectRules("visual", "")
		
		for oRule in aoRules
			oRule.SetGraph(@oGraph)
			oRule.Apply(@oGraph, "visual")
		end
