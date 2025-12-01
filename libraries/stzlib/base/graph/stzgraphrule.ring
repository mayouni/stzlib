#============================================#
#  stzGraphRule - Core Rule Engine           #
#  Single rule implementation                #
#============================================#

func StzGraphRuleQ(pcRuleId)
	return new stzGraphRule(pcRuleId)

class stzGraphRule
	@cRuleId
	@cRuleType = "validation"    # constraint | validation | inference | visual
	@cLevel = "graph"             # graph | diagram | orgchart
	@cDomain = ""                 # sox | bceao | banking | dag ...
	@cSeverity = "error"          # error | warning | info
	@cMessage = ""
	
	# Condition
	@cConditionType = ""
	@aConditionParams = []
	
	# Effects
	@aEffects = []
	@aElseEffects = []
	
	# Context
	@oGraph = NULL

	def init(pcRuleId)
		@cRuleId = pcRuleId
	
	#-----------------#
	#  CONFIGURATION  #
	#-----------------#
	
	def SetRuleType(pcType)
		@cRuleType = lower(pcType)
		return This
	
	def SetLevel(pcLevel)
		@cLevel = lower(pcLevel)
		return This
	
	def SetDomain(pcDomain)
		@cDomain = lower(pcDomain)
		return This
	
	def SetSeverity(pcSeverity)
		@cSeverity = lower(pcSeverity)
		return This
	
	def SetMessage(pcMessage)
		@cMessage = pcMessage
		return This
	
	def SetGraph(poGraph)
		@oGraph = poGraph
		return This
	
	#--------------#
	#  CONDITIONS  #
	#--------------#
	
	def When(pcKey, pOperator, pValue)
		if isString(pOperator)
			cOp = lower(pOperator)
			
			if cOp = "equals"
				@cConditionType = :propertyequals
				@aConditionParams = [pcKey, pValue]
				
			but cOp = "notequals"
				@cConditionType = :propertynotequals
				@aConditionParams = [pcKey, pValue]
				
			but cOp = "greaterthan"
				@cConditionType = :propertygreaterthan
				@aConditionParams = [pcKey, pValue]
				
			but cOp = "lessthan"
				@cConditionType = :propertylessthan
				@aConditionParams = [pcKey, pValue]
				
			but cOp = "contains"
				@cConditionType = :propertycontains
				@aConditionParams = [pcKey, pValue]
				
			but cOp = "insection"
				@cConditionType = :propertyinsection
				@aConditionParams = [pcKey, pValue[1], pValue[2]]
				
			but cOp = "exists"
				@cConditionType = :propertyexists
				@aConditionParams = [pcKey]
				
			but cOp = "notexists"
				@cConditionType = :propertynotexists
				@aConditionParams = [pcKey]
			ok
		ok
		return This
	
	def WhenPath(pcFrom, pcTo, pcCondition)
		if lower(pcCondition) = "exists"
			@cConditionType = :pathexists
			@aConditionParams = [pcFrom, pcTo]
		but lower(pcCondition) = "notexists"
			@cConditionType = :pathnotexists
			@aConditionParams = [pcFrom, pcTo]
		ok
		return This
	
	def WhenTag(pcTag, pcCondition)
		if lower(pcCondition) = "exists"
			@cConditionType = :tagexists
			@aConditionParams = [pcTag]
		but lower(pcCondition) = "notexists"
			@cConditionType = :tagnotexists
			@aConditionParams = [pcTag]
		ok
		return This
	
	def WhenGraph(pcProperty, pcCondition)
		@cConditionType = :graphproperty
		@aConditionParams = [pcProperty, pcCondition]
		return This
	
	#----------#
	#  EFFECTS #
	#----------#
	
	def Then(pcAspect, pcAction, pValue)
		cAction = lower(pcAction)
		
		if cAction = "mustbe"
			@aEffects + [:validate, pcAspect, pValue, "mustbe"]
			
		but cAction = "mustnotbe"
			@aEffects + [:validate, pcAspect, pValue, "mustnotbe"]
			
		but cAction = "set"
			@aEffects + [:set, pcAspect, pValue]
			
		but cAction = "add"
			@aEffects + [:add, pcAspect, pValue]
			
		but cAction = "remove"
			@aEffects + [:remove, pcAspect, pValue]
			
		but cAction = "forbid"
			@aEffects + [:forbid, pcAspect, pValue]
			
		but cAction = "required"
			@aEffects + [:required, pcAspect, pValue]
		ok
		
		return This
	
	def Else_(pcAspect, pcAction, pValue)
		@aElseEffects + [pcAction, pcAspect, pValue]
		return This
	
	def ThenViolation(pcMessage)
		@aEffects + [:violation, pcMessage]
		return This
	
	def ElseViolation(pcMessage)
		@aElseEffects + [:violation, pcMessage]
		return This
	
	#-----------#
	#  GETTERS  #
	#-----------#
	
	def Id()
		return @cRuleId
	
	def RuleType()
		return @cRuleType
	
	def Level()
		return @cLevel
	
	def Domain()
		return @cDomain
	
	def Severity()
		return @cSeverity
	
	def Message()
		return @cMessage
	
	def ConditionType()
		return @cConditionType
	
	def ConditionParams()
		return @aConditionParams
	
	def Effects()
		return @aEffects
	
	def ElseEffects()
		return @aElseEffects
	
	#-----------#
	#  MATCHING #
	#-----------#
	
	def Matches(aContext)
		switch @cConditionType
		
		on :propertyequals
			cKey = @aConditionParams[1]
			pValue = @aConditionParams[2]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				return aContext["properties"][cKey] = pValue
			ok
			return FALSE
		
		on :propertynotequals
			cKey = @aConditionParams[1]
			pValue = @aConditionParams[2]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				return aContext["properties"][cKey] != pValue
			ok
			return FALSE
		
		on :propertygreaterthan
			cKey = @aConditionParams[1]
			nThreshold = @aConditionParams[2]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				nValue = aContext["properties"][cKey]
				if isNumber(nValue)
					return nValue > nThreshold
				ok
			ok
			return FALSE
		
		on :propertylessthan
			cKey = @aConditionParams[1]
			nThreshold = @aConditionParams[2]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				nValue = aContext["properties"][cKey]
				if isNumber(nValue)
					return nValue < nThreshold
				ok
			ok
			return FALSE
		
		on :propertycontains
			cKey = @aConditionParams[1]
			cSubstr = @aConditionParams[2]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				cValue = aContext["properties"][cKey]
				if isString(cValue)
					return substr(lower(cValue), lower(cSubstr)) > 0
				ok
			ok
			return FALSE
		
		on :propertyinsection
			cKey = @aConditionParams[1]
			nMin = @aConditionParams[2]
			nMax = @aConditionParams[3]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], cKey)
				nValue = aContext["properties"][cKey]
				if isNumber(nValue)
					return nValue >= nMin and nValue <= nMax
				ok
			ok
			return FALSE
		
		on :propertyexists
			cKey = @aConditionParams[1]
			
			if HasKey(aContext, "properties")
				return HasKey(aContext["properties"], cKey)
			ok
			return FALSE
		
		on :propertynotexists
			cKey = @aConditionParams[1]
			
			if HasKey(aContext, "properties")
				return NOT HasKey(aContext["properties"], cKey)
			ok
			return TRUE
		
		on :pathexists
			if @oGraph = NULL
				return FALSE
			ok
			cFrom = @aConditionParams[1]
			cTo = @aConditionParams[2]
			return @oGraph.PathExists(cFrom, cTo)
		
		on :pathnotexists
			if @oGraph = NULL
				return TRUE
			ok
			cFrom = @aConditionParams[1]
			cTo = @aConditionParams[2]
			return NOT @oGraph.PathExists(cFrom, cTo)
		
		on :tagexists
			cTag = @aConditionParams[1]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], "tags")
				return ring_find(aContext["properties"]["tags"], cTag) > 0
			ok
			return FALSE
		
		on :tagnotexists
			cTag = @aConditionParams[1]
			
			if HasKey(aContext, "properties") and HasKey(aContext["properties"], "tags")
				return ring_find(aContext["properties"]["tags"], cTag) = 0
			ok
			return TRUE
		
		on :graphproperty
			if @oGraph = NULL
				return FALSE
			ok
			
			cProp = @aConditionParams[1]
			cCondition = @aConditionParams[2]
			
			if cProp = "acyclic"
				return NOT @oGraph.CyclicDependencies()
			ok
			
			return FALSE
		
		off
		
		return FALSE
	
	#------------#
	#  EXECUTION #
	#------------#
	
	def Apply(oGraph, pcExecutionContext)
		@oGraph = oGraph
		
		switch @cRuleType
		on "constraint"
			return This._ApplyAsConstraint(oGraph)
		on "validation"
			return This._ApplyAsValidation(oGraph)
		on "inference"
			return This._ApplyAsInference(oGraph)
		on "visual"
			return This._ApplyAsVisual(oGraph)
		off
	
	def _ApplyAsConstraint(oGraph)
		# Check constraint during construction
		aViolations = []
		acAffected = []
		
		aNodes = oGraph.Nodes()
		for aNode in aNodes
			aContext = This._BuildContext(aNode)
			
			if This.Matches(aContext)
				# Check effects
				for aEffect in @aEffects
					if aEffect[1] = :forbid
						aViolations + iff(@cMessage != "", @cMessage, "Constraint violated: " + @cRuleId)
						acAffected + aNode["id"]
					ok
				end
			ok
		end
		
		return [
			:status = iif(len(aViolations) = 0, "pass", "fail"),
			:domain = @cDomain,
			:ruleId = @cRuleId,
			:issueCount = len(aViolations),
			:issues = aViolations,
			:affectedNodes = acAffected
		]
	
	def _ApplyAsValidation(oGraph)
		aViolations = []
		acAffected = []
		
		aNodes = oGraph.Nodes()
		for aNode in aNodes
			aContext = This._BuildContext(aNode)
			
			if This.Matches(aContext)
				# Check validation effects
				for aEffect in @aEffects
					if aEffect[1] = :validate
						cAspect = aEffect[2]
						pExpected = aEffect[3]
						cCheck = aEffect[4]
						
						if HasKey(aNode["properties"], cAspect)
							pActual = aNode["properties"][cAspect]
							
							if cCheck = "mustbe" and pActual != pExpected
								aViolations + iff(@cMessage != "", @cMessage, @cRuleId + ": " + cAspect + " must be " + pExpected)
								acAffected + aNode["id"]
								
							but cCheck = "mustnotbe" and pActual = pExpected
								aViolations + iff(@cMessage != "", @cMessage : @cRuleId + ": " + cAspect + " must not be " + pExpected)
								acAffected + aNode["id"]
							ok
						ok
						
					but aEffect[1] = :violation
						aViolations + aEffect[2]
						acAffected + aNode["id"]
					ok
				end
			else
				# Apply else effects
				for aEffect in @aElseEffects
					if aEffect[1] = :violation
						aViolations + aEffect[2]
						acAffected + aNode["id"]
					ok
				end
			ok
		end
		
		return [
			:status = iif(len(aViolations) = 0, "pass", "fail"),
			:domain = @cDomain,
			:ruleId = @cRuleId,
			:issueCount = len(aViolations),
			:issues = aViolations,
			:affectedNodes = acAffected
		]
	
	def _ApplyAsInference(oGraph)
		# Apply inference rules to derive new knowledge
		nInferred = 0
		
		if @cConditionType = :pathexists
			# Transitivity inference
			aNodes = oGraph.Nodes()
			for aNode1 in aNodes
				for aNode2 in aNodes
					if aNode1["id"] != aNode2["id"]
						if oGraph.PathExists(aNode1["id"], aNode2["id"])
							# Check if direct edge exists
							if NOT oGraph.EdgeExists(aNode1["id"], aNode2["id"])
								# Infer edge
								for aEffect in @aEffects
									if aEffect[1] = :add and aEffect[2] = "edge"
										oGraph.AddEdgeXT(aNode1["id"], aNode2["id"], aEffect[3])
										nInferred++
									ok
								end
							ok
						ok
					ok
				end
			end
		ok
		
		return nInferred
	
	def _ApplyAsVisual(oGraph)
		# Apply visual effects
		aNodes = oGraph.Nodes()
		
		for aNode in aNodes
			aContext = This._BuildContext(aNode)
			
			if This.Matches(aContext)
				for aEffect in @aEffects
					if aEffect[1] = :set
						oGraph.SetNodeProperty(aNode["id"], aEffect[2], aEffect[3])
					ok
				end
			else
				for aEffect in @aElseEffects
					if aEffect[1] = :set
						oGraph.SetNodeProperty(aNode["id"], aEffect[2], aEffect[3])
					ok
				end
			ok
		end
		
		return TRUE
	
	def _BuildContext(aNode)
		aContext = aNode
		
		if HasKey(aNode, "properties")
			aContext["metadata"] = aNode["properties"]
		ok
		
		return aContext
	
	#-----------#
	#  DISPLAY  #
	#-----------#
	
	def Show()
		? "Rule: " + @cRuleId
		? "  Type: " + @cRuleType
		? "  Level: " + @cLevel
		? "  Domain: " + @cDomain
		? "  Severity: " + @cSeverity
		? "  Condition: " + @cConditionType
		? "  Effects: " + len(@aEffects) + " action(s)"


#============================================#
#  stzGraphRuleBase - Rule Collection        #
#  Container for multiple rules              #
#============================================#

func StzGraphRuleBaseQ(pcName)
	return new stzGraphRuleBase(pcName)

class stzGraphRuleBase
	@cName
	@cDomain = ""
	@cLevel = "graph"
	@cVersion = "1.0"
	@cAuthor = ""
	@aoRules = []

	def init(pcName)
		@cName = pcName
	
	#-----------------#
	#  CONFIGURATION  #
	#-----------------#
	
	def SetName(pcName)
		@cName = pcName
	
	def SetDomain(pcDomain)
		@cDomain = lower(pcDomain)
	
	def SetLevel(pcLevel)
		@cLevel = lower(pcLevel)
	
	def SetVersion(pcVersion)
		@cVersion = pcVersion
	
	def SetAuthor(pcAuthor)
		@cAuthor = pcAuthor
	
	#---------------#
	#  RULE MGMT    #
	#---------------#
	
	def AddRule(oRule)
		# Inherit rulebase properties if rule doesn't have them
		if oRule.Domain() = ""
			oRule.SetDomain(@cDomain)
		ok
		
		if oRule.Level() = "graph"
			oRule.SetLevel(@cLevel)
		ok
		
		@aoRules + oRule
	
	def RemoveRule(pcRuleId)
		aNew = []
		for oRule in @aoRules
			if oRule.Id() != pcRuleId
				aNew + oRule
			ok
		end
		@aoRules = aNew
	
	def Rule(pcRuleId)
		for oRule in @aoRules
			if oRule.Id() = pcRuleId
				return oRule
			ok
		end
		return NULL
	
	def Rules()
		return @aoRules
	
	def RuleCount()
		return len(@aoRules)
	
	#-----------#
	#  FILTERS  #
	#-----------#
	
	def RulesByType(pcType)
		aoFiltered = []
		cType = lower(pcType)
		
		for oRule in @aoRules
			if oRule.RuleType() = cType
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesByLevel(pcLevel)
		aoFiltered = []
		cLevel = lower(pcLevel)
		
		for oRule in @aoRules
			if oRule.Level() = cLevel
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesByDomain(pcDomain)
		aoFiltered = []
		cDomain = lower(pcDomain)
		
		for oRule in @aoRules
			if oRule.Domain() = cDomain
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesBySeverity(pcSeverity)
		aoFiltered = []
		cSeverity = lower(pcSeverity)
		
		for oRule in @aoRules
			if oRule.Severity() = cSeverity
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	#-----------#
	#  LOADING  #
	#-----------#
	
	def LoadFromFile(pcFilename)
		oParser = new stzRuleBaseParser()
		oLoaded = oParser.ParseFile(pcFilename)
		
		# Merge loaded rules
		for oRule in oLoaded.Rules()
			This.AddRule(oRule)
		end
	
	def LoadFromString(pcContent)
		oParser = new stzRuleBaseParser()
		oLoaded = oParser.Parse(pcContent)
		
		for oRule in oLoaded.Rules()
			This.AddRule(oRule)
		end
	
	def MergeWith(oOtherRuleBase)
		for oRule in oOtherRuleBase.Rules()
			This.AddRule(oRule)
		end
	
	#-----------#
	#  GETTERS  #
	#-----------#
	
	def Name()
		return @cName
	
	def Domain()
		return @cDomain
	
	def Level()
		return @cLevel
	
	def Version()
		return @cVersion
	
	def Author()
		return @cAuthor
	
	#-----------#
	#  DISPLAY  #
	#-----------#
	
	def Show()
		? "RuleBase: " + @cName
		? "  Domain: " + @cDomain
		? "  Level: " + @cLevel
		? "  Rules: " + len(@aoRules)
		
		for oRule in @aoRules
			? "    - " + oRule.Id() + " (" + oRule.RuleType() + ")"
		end
	
	def ToHashlist()
		return [
			:name = @cName,
			:domain = @cDomain,
			:level = @cLevel,
			:version = @cVersion,
			:author = @cAuthor,
			:ruleCount = len(@aoRules)
		]


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

#============================================#
#  Pre-built Rule Bases                      #
#============================================#

#--------------------------#
#  GRAPH STRUCTURAL RULES  #
#--------------------------#

class stzGraphDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("Graph Structural Rules")
		@cDomain = "structural"
		@cLevel = "graph"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# DAG Rule
		oRule = new stzGraphRule("dag_check")
		oRule {
			SetRuleType("validation")
			SetDomain("dag")
			SetMessage("Graph contains cycles")
			WhenGraph("acyclic", "mustbe")
			ThenViolation("Graph must be acyclic (DAG)")
		}
		This.AddRule(oRule)
		
		# Reachability (checked elsewhere)
		# Completeness (decision nodes need 2+ paths)

#--------------------------#
#  DIAGRAM DEFAULT RULES   #
#--------------------------#

class stzDiagramDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("Diagram Compliance Rules")
		@cLevel = "diagram"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# SOX: Financial processes need audit trail
		oRule1 = new stzGraphRule("sox_audit_trail")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-001: Financial process missing audit trail")
			When("domain", "equals", "financial")
			Then("audittrail", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# SOX: Decisions need approval
		oRule2 = new stzGraphRule("sox_approval")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-002: Decision node lacks approval requirement")
			When("type", "equals", "decision")
			Then("requiresApproval", "required", TRUE)
		}
		This.AddRule(oRule2)

#--------------------------#
#  ORGCHART DEFAULT RULES  #
#--------------------------#

class stzOrgChartDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("OrgChart Governance Rules")
		@cLevel = "orgchart"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# BCEAO: Board required (checked separately)
		# BCEAO: Audit independence
		oRule = new stzGraphRule("bceao_audit_independence")
		oRule {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetMessage("BCEAO-002: Audit must report to Board")
			When("department", "equals", "audit")
			Then("reportsTo", "mustbe", "board")
		}
		This.AddRule(oRule)
		
		# SOD: Ops not under Treasury
		oRule2 = new stzGraphRule("sod_ops_treasury")
		oRule2 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("sod")
			SetMessage("SOD-001: Operations reports through Treasury")
			When("department", "equals", "operations")
			Then("supervisor_department", "mustnotbe", "treasury")
		}
		This.AddRule(oRule2)


#  Pre-built Domain-Specific Rule Bases
#======================================

#------------------------------#
#  BANKING RULES (ALL LEVELS)  #
#------------------------------#

class stzBankingRuleBase from stzGraphRuleBase
	def init()
		super.init("Universal Banking Rules")
		@cDomain = "banking"
		This._LoadBankingRules()
	
	def _LoadBankingRules()
		# Graph-level: No approval cycles
		oRule1 = new stzGraphRule("banking_no_approval_cycles")
		oRule1 {
			SetRuleType("constraint")
			SetLevel("graph")
			SetDomain("banking")
			SetMessage("BANK-001: Approval workflows cannot contain cycles")
			WhenGraph("acyclic", "mustbe")
		}
		This.AddRule(oRule1)
		
		# Diagram-level: Fraud before payment
		oRule2 = new stzGraphRule("banking_fraud_detection")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("banking")
			SetMessage("BANK-002: Payment missing fraud detection")
			When("operation", "equals", "payment")
			ThenViolation("Payment node must have fraud_check predecessor")
		}
		This.AddRule(oRule2)
		
		# OrgChart-level: Ops not under Treasury
		oRule3 = new stzGraphRule("banking_ops_treasury_separation")
		oRule3 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("banking")
			SetMessage("BANK-003: Operations reports through Treasury (SOD violation)")
			When("department", "equals", "operations")
			Then("supervisor_department", "mustnotbe", "treasury")
		}
		This.AddRule(oRule3)
		
		# OrgChart-level: Dual approval for large transactions
		oRule4 = new stzGraphRule("banking_dual_approval")
		oRule4 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("banking")
			SetMessage("BANK-004: Large transaction position requires 2+ approvers")
			When("transactionType", "equals", "large")
			Then("approverCount", "greaterthan", 1)
		}
		This.AddRule(oRule4)

#-------------------------------#
#  BCEAO RULES (WAEMU BANKING)  #
#-------------------------------#

class stzBCEAORuleBase from stzGraphRuleBase
	def init()
		super.init("BCEAO Governance Rules")
		@cDomain = "bceao"
		@cLevel = "orgchart"
		This._LoadBCEAORules()
	
	def _LoadBCEAORules()
		# Board required
		oRule1 = new stzGraphRule("bceao_board_required")
		oRule1 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-001: Board of Directors is mandatory")
			When("title", "contains", "board")
			Then("exists", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Audit independence
		oRule2 = new stzGraphRule("bceao_audit_independence")
		oRule2 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-002: Audit must report directly to Board")
			When("department", "equals", "audit")
			Then("reportsTo", "mustbe", "board")
		}
		This.AddRule(oRule2)
		
		# Risk function required
		oRule3 = new stzGraphRule("bceao_risk_function")
		oRule3 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-003: Dedicated Risk Management function required")
			When("department", "equals", "risk")
			Then("exists", "required", TRUE)
		}
		This.AddRule(oRule3)

#------------------------------#
#  SOX RULES (SARBANES-OXLEY)  #
#------------------------------#

class stzSOXRuleBase from stzGraphRuleBase
	def init()
		super.init("Sarbanes-Oxley Compliance")
		@cDomain = "sox"
		@cLevel = "diagram"
		This._LoadSOXRules()
	
	def _LoadSOXRules()
		# Financial processes need audit trail
		oRule1 = new stzGraphRule("sox_audit_trail")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-001: Financial process missing audit trail")
			When("domain", "equals", "financial")
			Then("audittrail", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Decisions need approval
		oRule2 = new stzGraphRule("sox_approval_required")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-002: Decision node lacks approval requirement")
			When("type", "equals", "decision")
			Then("requiresApproval", "required", TRUE)
		}
		This.AddRule(oRule2)

#--------------#
#  GDPR RULES  #
#--------------#

class stzGDPRRuleBase from stzGraphRuleBase
	def init()
		super.init("GDPR Compliance")
		@cDomain = "gdpr"
		@cLevel = "diagram"
		This._LoadGDPRRules()
	
	def _LoadGDPRRules()
		# Personal data needs consent
		oRule1 = new stzGraphRule("gdpr_consent")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("gdpr")
			SetMessage("GDPR-001: Personal data processing missing consent")
			When("dataType", "equals", "personal")
			Then("requiresConsent", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Retention policy required
		oRule2 = new stzGraphRule("gdpr_retention")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("gdpr")
			SetMessage("GDPR-002: Data node missing retention policy")
			When("dataType", "equals", "personal")
			Then("retentionPolicy", "required", TRUE)
		}
		This.AddRule(oRule2)


#============================================#
#  stzRuleBaseParser - *.stzrulz Parser      #
#  Converts text rules to rule objects      #
#============================================#

class stzRuleBaseParser
	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		oRuleBase = new stzGraphRuleBase("Parsed Rules")
		
		acLines = split(pcContent, NL)
		cSection = ""
		cRuleId = ""
		oCurrentRule = NULL
		cWhenSection = "when"  # "when" or "else"
		
		for cLine in acLines
			cLine = trim(cLine)
			
			# Skip empty and comments
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			# Ruleset metadata
			if substr(cLine, "ruleset ")
				cName = This._ExtractQuoted(cLine)
				oRuleBase.SetName(cName)
				
			but substr(cLine, "domain:")
				oRuleBase.SetDomain(This._ExtractValue(cLine))
				
			but substr(cLine, "version:")
				oRuleBase.SetVersion(This._ExtractValue(cLine))
				
			but substr(cLine, "author:")
				oRuleBase.SetAuthor(This._ExtractValue(cLine))
			
			# Rules section
			but cLine = "rules"
				cSection = "rules"
			
			# New rule
			but substr(cLine, "rule ")
				# Save previous rule
				if oCurrentRule != NULL
					oRuleBase.AddRule(oCurrentRule)
				ok
				
				cRuleId = trim(@substr(cLine, 6, len(cLine)))
				oCurrentRule = new stzGraphRule(cRuleId)
				cWhenSection = "when"
			
			# Rule properties
			but substr(cLine, "type:")
				if oCurrentRule != NULL
					oCurrentRule.SetRuleType(This._ExtractValue(cLine))
				ok
				
			but substr(cLine, "level:")
				if oCurrentRule != NULL
					oCurrentRule.SetLevel(This._ExtractValue(cLine))
				ok
				
			but substr(cLine, "severity:")
				if oCurrentRule != NULL
					oCurrentRule.SetSeverity(This._ExtractValue(cLine))
				ok
			
			# Condition/effect markers
			but cLine = "when"
				cWhenSection = "when"
				
			but cLine = "then"
				cWhenSection = "then"
				
			but cLine = "else"
				cWhenSection = "else"
				
			but substr(cLine, "message")
				# Skip to next line for message
			
			# Parse conditions (when section)
			but cWhenSection = "when" and oCurrentRule != NULL
				This._ParseCondition(cLine, oCurrentRule)
			
			# Parse effects (then section)
			but cWhenSection = "then" and oCurrentRule != NULL
				This._ParseEffect(cLine, oCurrentRule, FALSE)
			
			# Parse else effects
			but cWhenSection = "else" and oCurrentRule != NULL
				This._ParseEffect(cLine, oCurrentRule, TRUE)
			ok
		end
		
		# Add last rule
		if oCurrentRule != NULL
			oRuleBase.AddRule(oCurrentRule)
		ok
		
		return oRuleBase
	
	#-----------#
	#  HELPERS  #
	#-----------#
	
	def _ParseCondition(cLine, oRule)
		aTokens = This._Tokenize(cLine)
		
		if len(aTokens) < 2
			return
		ok
		
		# path exists from="A" to="B"
		if aTokens[1] = "path" and len(aTokens) >= 3
			cCondition = aTokens[2]
			cFrom = This._ExtractQuotedValue(cLine, 'from="')
			cTo = This._ExtractQuotedValue(cLine, 'to="')
			oRule.WhenPath(cFrom, cTo, cCondition)
			return
		ok
		
		# tag exists "critical"
		if aTokens[1] = "tag" and len(aTokens) >= 3
			cCondition = aTokens[2]
			cTag = aTokens[3]
			cTag = This._Unquote(cTag)
			oRule.WhenTag(cTag, cCondition)
			return
		ok
		
		# graph mustBe "acyclic"
		if aTokens[1] = "graph" and len(aTokens) >= 3
			cProp = aTokens[2]
			cCondition = aTokens[3]
			oRule.WhenGraph(cProp, cCondition)
			return
		ok
		
		# Standard property conditions
		# department equals "audit"
		if len(aTokens) >= 3
			cKey = aTokens[1]
			cOp = aTokens[2]
			
			if len(aTokens) = 3
				pValue = This._Unquote(aTokens[3])
			but len(aTokens) = 4
				# inSection 0,100
				if cOp = "insection"
					pValue = [0 + aTokens[3], 0 + aTokens[4]]
				else
					pValue = This._Unquote(aTokens[3])
				ok
			else
				pValue = This._Unquote(aTokens[3])
			ok
			
			oRule.When(cKey, cOp, pValue)
		ok
	
	def _ParseEffect(cLine, oRule, bIsElse)
		aTokens = This._Tokenize(cLine)
		
		if len(aTokens) < 2
			return
		ok
		
		# violation add "message"
		if aTokens[1] = "violation" and len(aTokens) >= 3
			cAction = aTokens[2]
			cMessage = This._ExtractQuoted(cLine)
			
			if bIsElse
				oRule.ElseViolation(cMessage)
			else
				oRule.ThenViolation(cMessage)
			ok
			return
		ok
		
		# Standard effects: aspect action value
		# color set "red"
		if len(aTokens) >= 3
			cAspect = aTokens[1]
			cAction = aTokens[2]
			pValue = This._Unquote(aTokens[3])
			
			if bIsElse
				oRule.Else_(cAspect, cAction, pValue)
			else
				oRule.Then(cAspect, cAction, pValue)
			ok
		ok
	
	def _Tokenize(cLine)
		# Split by spaces but preserve quoted strings
		aTokens = []
		cCurrent = ""
		bInQuote = FALSE
		
		nLen = len(cLine)
		for i = 1 to nLen
			cChar = cLine[i]
			
			if cChar = '"'
				bInQuote = NOT bInQuote
				cCurrent += cChar
			but cChar = " " and NOT bInQuote
				if cCurrent != ""
					aTokens + cCurrent
					cCurrent = ""
				ok
			but cChar = "," and NOT bInQuote
				if cCurrent != ""
					aTokens + cCurrent
					cCurrent = ""
				ok
			else
				cCurrent += cChar
			ok
		end
		
		if cCurrent != ""
			aTokens + cCurrent
		ok
		
		return aTokens
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0
			return ""
		ok
		
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		if nEnd = 0
			return ""
		ok
		
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
	
	def _ExtractValue(cLine)
		nPos = substr(cLine, ":")
		if nPos = 0
			return ""
		ok
		
		cValue = trim(@substr(cLine, nPos + 1, len(cLine)))
		return This._Unquote(cValue)
	
	def _ExtractQuotedValue(cLine, cPattern)
		nPos = substr(cLine, cPattern)
		if nPos = 0
			return ""
		ok
		
		nStart = nPos + len(cPattern)
		cRest = @substr(cLine, nStart, len(cLine))
		nEnd = substr(cRest, '"')
		if nEnd = 0
			return cRest
		ok
		
		return @substr(cRest, 1, nEnd - 1)
	
	def _Unquote(cValue)
		if left(cValue, 1) = '"' and right(cValue, 1) = '"'
			return @substr(cValue, 2, len(cValue) - 1)
		ok
		return cValue
