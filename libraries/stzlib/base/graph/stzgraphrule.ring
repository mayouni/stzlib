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
