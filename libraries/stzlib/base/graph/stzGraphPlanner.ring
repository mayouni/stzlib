#============================================#
#  stzGraphPlanner - Enhanced Version
#============================================#

class stzGraphPlanner
	@oGraph
	@aPlans  
	@cCurrentPlan
	@aProfiles  # Predefined optimization profiles

	@aHistory  # Historical plan executions

	def init(poGraph)
		if NOT @IsStzGraph(poGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		
		@oGraph = poGraph
		@aPlans = []
		@aHistory = []
		This._InitProfiles()
	
	#-----------------------#
	#  PROFILES             #
	#-----------------------#
	
	def _InitProfiles()
		@aProfiles = [
			:fastest = [
				[:property = "time", :direction = "minimize", :weight = 0.7],
				[:property = "distance", :direction = "minimize", :weight = 0.3]
			],
			:safest = [
				[:property = "danger", :direction = "minimize", :weight = 0.8],
				[:property = "risk", :direction = "minimize", :weight = 0.2]
			],
			:cheapest = [
				[:property = "cost", :direction = "minimize", :weight = 0.8],
				[:property = "distance", :direction = "minimize", :weight = 0.2]
			],
			:shortest = [
				[:property = "distance", :direction = "minimize", :weight = 1.0]
			],
			:balanced = [
				[:property = "time", :direction = "minimize", :weight = 0.4],
				[:property = "cost", :direction = "minimize", :weight = 0.3],
				[:property = "distance", :direction = "minimize", :weight = 0.3]
			],
			:efficient = [
				[:property = "energy", :direction = "minimize", :weight = 0.6],
				[:property = "time", :direction = "minimize", :weight = 0.4]
			]
		]

	def Profile(cProfile)
		cProfile = lower(cProfile)
		if HasKey(@aProfiles, cProfile)
			return @aProfiles[cProfile]
		ok
		return []

	#-----------------------#
	#  PLAN MANAGEMENT      #
	#-----------------------#
	
	def AddPlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		pcPlanName = lower(pcPlanName)
		@aPlans + [pcPlanName, ["", "", "", [], [], "", [], []]]  # Added slots for explored and alternatives

		This.SetCurrentPlan(pcPlanName)

	def Plan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		pcName = lower(pcPlanName)
		return @aPlans[pcPlanName]

	def SetCurrentPlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				stzraise("Incorrect param type! pcPlanName must be a string!")
			ok
		ok

		pcPlanName = lower(pcPlanName)

		if NOT HasKey(@aPlans, pcPlanName)
			stzraise("Inexistant plan (" + pcPlanName + ")!")
		ok

		@cCurrentPlan = pcPlanName

		def WorkOnPlan(pcPlanName)
			This.SetCurrentPlan(pcPlanName)

	def CurrentPlan()
		return @cCurrentPlan

	def RemovePlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				stzraise("Incorrect param type! pcPlanName must be a string!")
			ok
		ok

		pcPlanName = lower(pcPlanName)

		if NOT HasKey(@aPlans, pcPlanName)
			stzraise("Inexistant plan (" + pcPlanName + ")!")
		ok

		nLen = len(@aPlans)
		if nLen = 1
			stzraise("Can't remove the only plan we have!")
		ok

		if pcPlanName = This.CurrentPlan()
			stzraise("Can't remove the current plan we are working on! Set another plan as current first.")
		ok

		n = 0
		for i = 1 to nLen
			if @aPlans[i][1] = pcPlanName
				n = i
				exit
			ok
		next

		if n > 0
			del(@aPlans, n)
		ok

	#----------------------#
	#  CONFIGURING A PLAN  #
	#----------------------#

	def Walk(pcFrom, pcTo)
		This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

		def WalkFrom(pcFrom, pcTo)
			This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

		def WalkFromNode(pcFrom, pcTo)
			This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

	def WalkXT(pcPlanName, pcFrom, pcTo)
		if CheckParams()
			if isList(pcFrom) and StzListQ(pcFrom).IsFromOrFromNodeNamedParam()
				pcFrom = pcFrom[2]
			ok
			if isList(pcTo) and StzListQ(pcTo).IsToOrToNodeOrUntilReachFNamedParam()
				pcTo = pcTo[2]
			ok
	
			if isFunction(pcTo)
				This.FromXT(pcPlanName, pcFrom)
				This.ToReachXTF(pcPlanName, pcTo)
				return
			ok
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][1] = pcFrom
		@aPlans[nPos][2][2] = pcTo

		def WalkIn(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

		def WalkInPlan(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

	def From(pcFrom)
		This.FromXT(This.CurrentPlan(), pcFrom)

		def FromNode(pcFrom)
			This.From(pcFrom)

	def FromXT(pcPlanName, pcFrom)
		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][1] = pcFrom

		def FromNodeXT(pcPlanName, pcFrom)
			This.FromXT(pcPlanName, pcFrom)

	def To(pcTo)
		This.ToXT(This.CurrentPlan(), pcTo)

		def ToNode(pcTo)
			This.To(pcTo)

	def ToXT(pcPlanName, pcTo)
		if isFunction(pcTo)
			This.ToReachFXT(pcPlanName, pcTo)
			return
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][2] = pcTo

		def ToNodeXT(pcPlanName, pcTo)
			This.ToXT(pcPlanName, pcTo)
	
	def ToF(pGoalFunc)
		This.ToFXT(This.CurrentPlan(), pGoalFunc)

		def ToReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		def ReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		def UntilReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		def UntilYouReachF(pGoalFunc)
			This.ToF(pGoalFunc)

	def ToFXT(pcPlanName, pGoalFunc)
		if CheckParams()
			if NOT isFunction(pGoalFunc)
				StzRaise("Incorrect param type! pGoalFunc must be a function.")
			ok
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][3] = pGoalFunc

		def ToReachFXT(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def ReachFXT(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def UntilReachFXT(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def UntilYouReachFXT(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def ToXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def ToReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def ReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def UntilReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def UntilYouReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

	#--

	def Using(pProfile)
		This.UsingXT(pProfile, This.CurrentPlan())

		def UsingProfile(pProfile)
			This.UsingXT(pProfile, This.CurrentPlan())

	def UsingXT(pProfile, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and StzListQ(pcPlanName).IsInPlanNamedParam()
				pcPlanName = pcPlanName[2]
			ok
		ok

		aProfileCriteria = []
		
		if isString(pProfile)
			cProfile = lower(pProfile)
			if left(cProfile, 1) = ":"
				cProfile = substr(cProfile, 2)
			ok
			aProfileCriteria = This.Profile(cProfile)
			if len(aProfileCriteria) = 0
				stzraise("Unknown profile: " + pProfile)
			ok
		but isList(pProfile)
			aProfileCriteria = pProfile
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		
		@aPlans[nPos][2][4] = aProfileCriteria

		def UsingProfileXT(pProfile, pcPlanName)
			This.UsingXT(pProfile, pcPlanName)

	#--

	def Minimize(pcProperty)
		This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimise(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimising(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimizing(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def MinimizeFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def MinimiseFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def MinimisingFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def MinimizingFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

	def MinimizeXT(pcProperty, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and StzListQ(pcPlanName).IsInPlanNamedParam()
				pcPlanName = pcPlanName[2]
			ok
		ok
		This.MinimizeIn(pcPlanName, pcProperty)

		def MinimiseXT(pcProperty, pcPlanName)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimizingXT(pcProperty, pcPlanName)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimisingXT(pcProperty, pcPlanName)
			This.MinimizeIn(pcPlanName, pcProperty)

	def MinimizeIn(pcPlanName, pcProperty)
		if CheckParams()
			if isList(pcPlanName) and StzListQ(pcPlanName).IsPlanOrInPlanNamedParam()
				pcPlanName = pcPlanName[2]
			ok
			if isList(pcProperty) and StzListQ(pcProperty).IsForNamedParam()
				pcProperty = pcProperty[2]
			ok
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][4] + [:property = pcProperty, :direction = "minimize", :weight = 1]

		def MinimiseIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimizingIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimisingIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimizeInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimiseInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimizingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimisingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

	def Maximize(pcProperty)
		This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximise(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximizing(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximising(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximizeFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximiseFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximizingFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximisingFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

	def MaximizeXT(pcProperty, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and StzListQ(pcPlanName).IsInPlanNamedParam()
				pcPlanName = pcPlanName[2]
			ok
		ok
		This.MaximizeIn(pcPlanName, pcProperty)

		def MaximiseXT(pcProperty, pcPlanName)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximizingXT(pcProperty, pcPlanName)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximisingXT(pcProperty, pcPlanName)
			This.MaximizeIn(pcPlanName, pcProperty)

	def MaximizeIn(pcPlanName, pcProperty)
		if CheckParams()
			if isList(pcPlanName) and StzListQ(pcPlanName).IsPlanOrInPlanNamedParam()
				pcPlanName = pcPlanName[2]
			ok
			if isList(pcProperty) and StzListQ(pcProperty).IsForNamedParam()
				pcProperty = pcProperty[2]
			ok
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][4] + [:property = pcProperty, :direction = "maximize", :weight = 1]

		def MaximiseIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximizingIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximisingIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximizeInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximiseInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximizingInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		def MaximisingInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

	#--

	def Execute()
		This.ExecuteXT(This.CurrentPlan())

		def Run()
			This.Execute()

		def ExecuteCurrentPlan()
			This.Execute()

		def RunCurrentPlan()
			This.Execute()

	def ExecuteXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		
		aPlanData = @aPlans[nPos][2]
		cStartNode = aPlanData[1]
		cGoalNode = aPlanData[2]
		pGoalFunc = aPlanData[3]
		aOptimize = aPlanData[4]
		aConstraints = aPlanData[5]
		
		if cStartNode != ""
			cStartNode = lower(cStartNode)
		ok
		if cGoalNode != ""
			cGoalNode = lower(cGoalNode)
		ok
		
		if cStartNode = "" or NOT @oGraph.NodeExists(cStartNode)
			stzraise("Invalid start node!")
		ok
		
		aResult = ""
		if cGoalNode != ""
			pHeuristic = This._SelectHeuristic(cStartNode, cGoalNode)
			aResult = This._AStar(cStartNode, cGoalNode, pHeuristic, aOptimize, aConstraints)
		but pGoalFunc != ""
			aResult = This._GoalSearch(cStartNode, pGoalFunc, aOptimize, aConstraints)
		else
			stzraise("Either goal node or goal function must be specified!")
		ok
		
		@aPlans[nPos][2][6] = aResult
		
		# Store in history
		This._AddToHistory(pcPlanName, aResult, aOptimize)
		
		def ExecutePlan(pcPlanName)
			This.ExecuteXT(pcPlanName)

		def RunXT(pcPlanName)
			This.ExecuteXT(pcPlanName)

		def RunPlan(pcPlanName)
			This.ExecuteXT(pcPlanName)

	#-----------------------#
	#  PLAN ACCESSORS       #
	#-----------------------#
	
	def Cost()
		return This.CostXT(This.CurrentPlan())

		def CostOfCurrentPlan()
			return This.CostXT(This.CurrentPlan())

		def CostInCurrentPlan()
			return This.CostXT(This.CurrentPlan())

	def CostXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[2]

		def CostOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(pcPlanName).IsOfOrOfPlanNamedParam()
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.CostXT(pcPlanName)

		def CostOfPlan(pcPlanName)
			return This.CostXT(pcPlanName)

		def CostIn(pcPlanName)
			return This.CostXT(pcPlanName)

		def CostInPlan(pcPlanName)
			return This.CostXT(pcPlanName)

	def Route()
		return This.RouteXT(This.CurrentPlan())

		def RouteOfCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		def RouteInCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		#--

		def States()
			return This.RouteXT(This.CurrentPlan())

		def StatesOfCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		def StatesInCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

	def RouteXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[3]

		def RouteOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(pcPlanName).IsOfOrOfPlanOrInOrInPlanNamedParam()
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.RouteXT(pcPlanName)

		def RouteOfPlan(pcPlanName)
			return This.RouteXT(pcPlanName)

		def RouteIn(pcPlanName)
			return This.RouteXT(pcPlanName)

		def RouteInPlan(pcPlanName)
			return This.RouteXT(pcPlanName)

		#--

		def StatesXT(pcPlanName)
			return This.RouteXT(pcPlanName)

		def StatesOf(pcPlanName)
			return This.RouteOf(pcPlanName)

		def StatesOfPlan(pcPlanName)
			return This.RouteXT(pcPlanName)

		def StatesIn(pcPlanName)
			return This.RouteXT(pcPlanName)

		def StatesInPlan(pcPlanName)
			return This.RouteXT(pcPlanName)


	def Actions()
		return This.ActionsXT(This.CurrentPlan())

		def ActionsOfCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

		def ActionsInCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

	def ActionsXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[1]
	
		def ActionsIn(pcPlanName)
			return This.ActionsXT(pcPlanName)

		def ActionsOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(pcPlanName).IsOfOrOfPlanOrInOrInPlanNamedParam()
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.ActionsXT(pcPlanName)

		def ActionsOfPlan(pcPlanName)
			return This.ActionsXT(pcPlanName)

	def Explain()
		return This.ExplainXT(This.CurrentPlan())

		def ExplainCurrentPlan()
			return This.ExplainXT(This.CurrentPlan())

	def ExplainXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[4]
	
		def ExplainPlan(pcPlanName)
			return This.ExplainXT(pcPlanName)

	#-----------------------#
	#  EXPLANATION METHODS  #
	#-----------------------#

	def ExplainCostBreakdown()
		return This.ExplainCostBreakdownXT(This.CurrentPlan())

	def ExplainCostBreakdownXT(pcPlanName)
		aActions = This.ActionsXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aOptimize = @aPlans[nPos][2][4]
		
		cExplanation = "=== COST BREAKDOWN ===" + NL + NL
		
		nLen = len(aActions)
		for i = 1 to nLen
			aAction = aActions[i]
			cExplanation += "Step " + i + ": " + aAction[:from] + " -> " + aAction[:to] + NL
			
			nStepTotal = 0
			if len(aOptimize) > 0
				nLen2 = len(aOptimize)
				for j = 1 to nLen2
					aCriterion = aOptimize[j]
					cProp = aCriterion[:property]
					nWeight = aCriterion[:weight]
					cDir = aCriterion[:direction]
					
					pValue = @oGraph.EdgeProperty(aAction[:from], aAction[:to], cProp)
					if pValue = "" or pValue = NULL
						pValue = 1
					ok
					
					nContribution = 0
					if cDir = "minimize"
						nContribution = nWeight * pValue
					else
						nContribution = -nWeight * pValue
					ok
					
					nStepTotal += nContribution
					
					cExplanation += "  • " + cProp + ": " + pValue + " × " + nWeight
					cExplanation += " (" + cDir + ") = " + nContribution + NL
				next
			ok
			
			cExplanation += "  Total: " + nStepTotal + NL + NL
		next
		
		return trim(cExplanation)

	def ExplainWhy(cAspect)
		return This.ExplainWhyXT(cAspect, This.CurrentPlan())

		def ExplainWhyThis(cAspect)
			return This.ExplainWhy(cAspect)

	def ExplainWhyXT(cAspect, pcPlanName)
		cAspect = lower(cAspect)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aResult = aPlanData[6]
		aExplored = aPlanData[7]
		aOptimize = aPlanData[4]
		
		cExplanation = "This route was selected because:" + NL
		cExplanation += "• Total cost: " + aResult[2] + NL
		cExplanation += "• Explored " + len(aExplored) + " nodes to find it" + NL
		
		if len(aOptimize) > 0
			cExplanation += "• Optimized for: "
			nLen = len(aOptimize)
			for i = 1 to nLen
				aCrit = aOptimize[i]
				cExplanation += aCrit[:direction] + " " + aCrit[:property]
				if i < nLen
					cExplanation += ", "
				ok
			next
			cExplanation += NL
		ok
		
		return trim(cExplanation)

	def ExplainAlternatives()
		return This.ExplainAlternativesXT(This.CurrentPlan())

	def ExplainAlternativesXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aAlternatives = aPlanData[8]
		
		if len(aAlternatives) = 0
			return "No alternatives were recorded during planning."
		ok
		
		cExplanation = "Key decisions made:" + NL
		
		nLen = len(aAlternatives)
		for i = 1 to nLen
			aAlt = aAlternatives[i]
			cExplanation += "• At '" + aAlt[:node] + "', chose '" + aAlt[:chosen] + "'"
			if HasKey(aAlt, :reason)
				cExplanation += " (" + aAlt[:reason] + ")"
			ok
			cExplanation += NL
		next
		
		return trim(cExplanation)

	def ExplainEfficiency()
		return This.ExplainEfficiencyXT(This.CurrentPlan())

	def ExplainEfficiencyXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aResult = aPlanData[6]
		aExplored = aPlanData[7]
		
		nPathLength = len(aResult[3])
		nExplored = len(aExplored)
		nRatio = nExplored / nPathLength
		
		cExplanation = "Explored " + nExplored + " nodes for " + nPathLength + "-node path"
		cExplanation += " (" + nRatio + ":1 ratio"
		
		if nRatio < 1.5
			cExplanation += " - very efficient)"
		but nRatio < 2.5
			cExplanation += " - efficient)"
		but nRatio < 4
			cExplanation += " - moderate)"
		else
			cExplanation += " - explored many alternatives)"
		ok
		
		return (cExplanation)

	#-----------------------#
	#  COMPARISON METHODS   #
	#-----------------------#

	def CompareTo(pcOtherPlan)
		return This.CompareToXT(This.CurrentPlan(), pcOtherPlan)

		def CompareWith(pcOtherPlan)
			return This.CompareTo(pcOtherPlan)

	def CompareToXT(pcPlan1, pcPlan2)
		aResult1 = This._GetResult(pcPlan1)
		aResult2 = This._GetResult(pcPlan2)
		
		return new stzPlanComparison(This, pcPlan1, pcPlan2, aResult1, aResult2)

	def ExplainDifference(pcOtherPlan)
		return This.ExplainDifferenceXT(This.CurrentPlan(), pcOtherPlan)

	def ExplainDifferenceXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXT(pcPlan1, pcPlan2)
		return oComp.Explain()

	def ShowTradeoffs(pcOtherPlan)
		return This.ShowTradeoffsXT(This.CurrentPlan(), pcOtherPlan)

	def ShowTradeoffsXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXT(pcPlan1, pcPlan2)
		return oComp.ShowTradeoffs()

	def WhichIsCheaper(pcOtherPlan)
		return This.WhichIsCheaperXT(This.CurrentPlan(), pcOtherPlan)

	def WhichIsCheaperXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXT(pcPlan1, pcPlan2)
		return oComp.WhichIsCheaper()

	def CostSavings(pcOtherPlan)
		return This.CostSavingsXT(This.CurrentPlan(), pcOtherPlan)

	def CostSavingsXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXT(pcPlan1, pcPlan2)
		return oComp.CostSavings()

	#---------------------------------#
	#  MULTI-PLAN COMPARISON          #
	#---------------------------------#

	def CompareMultiple(acPlanNames)
		if CheckParams()
			if isList(acPlanNames) and NOT isList(acPlanNames[1])
				# Good - list of plan names
			else
				stzraise("Parameter must be a list of plan names!")
			ok
		ok
	
		aAllResults = []
		nLen = len(acPlanNames)
		for i = 1 to nLen
			cPlan = acPlanNames[i]
			# Check if plan was executed
			nPos = This._FindPlan(cPlan)
			if nPos > 0 and @aPlans[nPos][2][6] != ""
				aResult = This._GetResult(cPlan)
				aAllResults + [cPlan, aResult]
			ok
		next
	
		return new stzMultiPlanComparison(This, acPlanNames, aAllResults)
	
		def CompareAll(acPlanNames)
			return This.CompareMultiple(acPlanNames)

	def RankPlansBy(cCriterion)
		return This.RankPlansByXT(cCriterion, :all)

	def RankPlansByXT(cCriterion, pPlans)
		acPlanNames = []
		
		if isString(pPlans) and lower(pPlans) = "all"
			nLen = len(@aPlans)
			for i = 1 to nLen
				cPlanName = @aPlans[i][1]
				# Only include executed plans
				if @aPlans[i][2][6] != ""
					acPlanNames + cPlanName
				ok
			next
		but isList(pPlans)
			acPlanNames = pPlans
		ok
	
		if len(acPlanNames) = 0
			return []
		ok
	
		oMultiComp = This.CompareMultiple(acPlanNames)
		return oMultiComp.RankBy(cCriterion)

	#---------------------------------#
	#  HISTORICAL COMPARISON          #
	#---------------------------------#

	def History()
		return @aHistory

	def HistoryCount()
		return len(@aHistory)

	def CompareWithHistory()
		return This.CompareWithHistoryXT(This.CurrentPlan())

	def CompareWithHistoryXT(pcPlanName)
		aCurrentResult = This._GetResult(pcPlanName)
		
		if len(@aHistory) = 0
			return "No historical data available for comparison."
		ok

		return new stzHistoricalComparison(This, pcPlanName, aCurrentResult, @aHistory)

	def HistoricalAverage(cCriterion)
		if len(@aHistory) = 0
			return 0
		ok

		cCriterion = lower(cCriterion)
		nSum = 0
		nCount = 0

		nLen = len(@aHistory)
		for i = 1 to nLen
			aHistItem = @aHistory[i]
			aResult = aHistItem[2]
			
			if cCriterion = "cost"
				nSum += aResult[2]
				nCount++
			but cCriterion = "steps" or cCriterion = "length"
				nSum += len(aResult[3])
				nCount++
			ok
		next

		if nCount = 0
			return 0
		ok

		return nSum / nCount

	def BestHistoricalPlan(cCriterion)
		if len(@aHistory) = 0
			return ""
		ok

		cCriterion = lower(cCriterion)
		cBestPlan = ""
		nBestValue = 999999

		nLen = len(@aHistory)
		for i = 1 to nLen
			aHistItem = @aHistory[i]
			cPlanName = aHistItem[1]
			aResult = aHistItem[2]
			
			nValue = 0
			if cCriterion = "cost"
				nValue = aResult[2]
			but cCriterion = "steps" or cCriterion = "length"
				nValue = len(aResult[3])
			ok

			if nValue < nBestValue
				nBestValue = nValue
				cBestPlan = cPlanName
			ok
		next

		return cBestPlan

	def WorstHistoricalPlan(cCriterion)
		if len(@aHistory) = 0
			return ""
		ok
	
		cCriterion = lower(cCriterion)
		cWorstPlan = ""
		nWorstValue = -999999
	
		nLen = len(@aHistory)
		for i = 1 to nLen
			aHistItem = @aHistory[i]
			cPlanName = aHistItem[1]
			aResult = aHistItem[2]
			
			nValue = 0
			if cCriterion = "cost"
				nValue = aResult[2]
			but cCriterion = "steps" or cCriterion = "length"
				nValue = len(aResult[3])
			ok
	
			if nValue > nWorstValue
				nWorstValue = nValue
				cWorstPlan = cPlanName
			ok
		next
	
		return cWorstPlan

	def ClearHistory()
		@aHistory = []

	#---------------------------------#
	#  CONSTRAINT-BASED FILTERING     #
	#---------------------------------#

	def FilterPlans(paConstraints)
		acAllPlans = []
		nLen = len(@aPlans)
		for i = 1 to nLen
			acAllPlans + @aPlans[i][1]
		next

		return This.FilterPlansXT(acAllPlans, paConstraints)

	def FilterPlansXT(acPlanNames, paConstraints)
		acFiltered = []

		nLen = len(acPlanNames)
		for i = 1 to nLen
			cPlan = acPlanNames[i]
			
			if This._PlanMeetsConstraints(cPlan, paConstraints)
				acFiltered + cPlan
			ok
		next

		return new stzPlanFilter(This, acFiltered, paConstraints)

	def PlansWithin(nPercentage, cBasePlan)
		if CheckParams()
			if isList(cBasePlan) and StzListQ(cBasePlan).IsOfOrOfPlanNamedParam()
				cBasePlan = cBasePlan[2]
			ok
		ok

		aBaseResult = This._GetResult(cBasePlan)
		nBaseCost = aBaseResult[2]
		nMaxCost = nBaseCost * (1 + nPercentage/100)

		return This.FilterPlans([:maxCost = nMaxCost])

	def PlansAvoiding(cNode)
		return This.FilterPlans([:avoid = cNode])

		def PlansThatAvoid(cNode)
			return This.PlansAvoiding(cNode)

	def PlansRequiring(cNode)
		return This.FilterPlans([:requires = cNode])

		def PlansThatRequire(cNode)
			return This.PlansRequiring(cNode)

	#-----------------------#
	#  DISPLAY METHODS      #
	#-----------------------#

	def Show()
		This.ShowXT(This.CurrentPlan())

		def ShowCurrentPlan()
			This.ShowXT(This.CurrentPlan())

	def ShowXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		? "Plan: " + pcPlanName
		? "  Total Cost: " + aResult[2]
		? "  Steps: " + len(aResult[1])
		? ""
		? "Actions:"
		nLen = len(aResult[1])
		for i = 1 to nLen
			aAction = aResult[1][i]
			? "  " + aAction[:from] + " -> " + aAction[:to]
			if HasKey(aAction, :cost)
				? "    Cost: " + aAction[:cost]
			ok
		next
		? ""
		? "Explanation:"
		? aResult[4]
	
		def ShowPlan(pcPlanName)
			This.ShowXT(pcPlanName)

	#-----------------------#
	#  HELPERS              #
	#-----------------------#
	
	def _FindPlan(pcPlanName)
		pcPlanName = lower(pcPlanName)
		nLen = len(@aPlans)
		for i = 1 to nLen
			if lower(@aPlans[i][1]) = pcPlanName
				return i
			ok
		next
		return 0
	
	def _GetResult(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		aResult = @aPlans[nPos][2][6]
		if aResult = ""
			stzraise("Plan has not been executed!")
		ok
		return aResult
	
	#-----------------------#
	#  A* ALGORITHM         #
	#-----------------------#
	
	def _AStar(cStart, cGoal, pHeuristic, aOptimize, aConstraints)
		aOpen = [[cStart, 0, call pHeuristic(@oGraph, cStart, cGoal)]]
		aClosedSet = []
		aGScore = [[cStart, 0]]
		aParent = []
		aExplored = []
		aAlternatives = []
		
		while len(aOpen) > 0
			nMinIdx = 1
			nMinF = aOpen[1][3]
			nLen = len(aOpen)
			for i = 2 to nLen
				if aOpen[i][3] < nMinF
					nMinF = aOpen[i][3]
					nMinIdx = i
				ok
			next
			
			cCurrent = aOpen[nMinIdx][1]
			del(aOpen, nMinIdx)
			
			aExplored + cCurrent
			
			if cCurrent = cGoal
				aResult = This._ReconstructPlan(aParent, cCurrent, aGScore, aOptimize)
				This._StoreExplorationData(cStart, cGoal, aExplored, aAlternatives)
				return aResult
			ok
			
			aClosedSet + cCurrent
			
			aNeighbors = @oGraph.Neighbors(cCurrent)
			nLen = len(aNeighbors)
			
			if nLen > 1
				aAlternatives + [:node = cCurrent, :chosen = aNeighbors[1], :total_options = nLen]
			ok
			
			for i = 1 to nLen
				cNeighbor = aNeighbors[i]
				if ring_find(aClosedSet, cNeighbor) > 0
					loop
				ok
				
				nCurrentG = This._GetScore(aGScore, cCurrent)
				nTransitionCost = This._CalculateTransitionCost(cCurrent, cNeighbor, aOptimize)
				nTentativeG = nCurrentG + nTransitionCost
				
				nNeighborG = This._GetScore(aGScore, cNeighbor)
				if nNeighborG = -1 or nTentativeG < nNeighborG
					This._SetScore(aGScore, cNeighbor, nTentativeG)
					nH = call pHeuristic(@oGraph, cNeighbor, cGoal)
					nF = nTentativeG + nH
					
					This._SetParent(aParent, cNeighbor, cCurrent)
					
					bInOpen = FALSE
					nLen2 = len(aOpen)
					for j = 1 to nLen2
						aNode = aOpen[j]
						if aNode[1] = cNeighbor
							bInOpen = TRUE
							aNode[2] = nTentativeG
							aNode[3] = nF
							exit
						ok
					next
					
					if NOT bInOpen
						aOpen + [cNeighbor, nTentativeG, nF]
					ok
				ok
			next
		end
		
		This._StoreExplorationData(cStart, cGoal, aExplored, aAlternatives)
		return [[], 0, [], "No path found"]
	
	def _GoalSearch(cStart, pGoalFunc, aOptimize, aConstraints)
		aOpen = [[cStart, 0]]
		aClosedSet = []
		aCostSoFar = [[cStart, 0]]
		aParent = []
		aExplored = []
		aAlternatives = []
		
		while len(aOpen) > 0
			nMinIdx = 1
			nMinCost = aOpen[1][2]
			nLen = len(aOpen)
			for i = 2 to nLen
				if aOpen[i][2] < nMinCost
					nMinCost = aOpen[i][2]
					nMinIdx = i
				ok
			next
			
			cCurrent = aOpen[nMinIdx][1]
			del(aOpen, nMinIdx)
			
			aExplored + cCurrent
			
			aNode = @oGraph.Node(cCurrent)
			if call pGoalFunc(aNode)
				aResult = This._ReconstructPlan(aParent, cCurrent, aCostSoFar, aOptimize)
				This._StoreExplorationData(cStart, cCurrent, aExplored, aAlternatives)
				return aResult
			ok
			
			aClosedSet + cCurrent
			
			aNeighbors = @oGraph.Neighbors(cCurrent)
			nLen = len(aNeighbors)
			
			if nLen > 1
				aAlternatives + [:node = cCurrent, :chosen = aNeighbors[1], :total_options = nLen]
			ok
			
			for i = 1 to nLen
				cNeighbor = aNeighbors[i]
				if ring_find(aClosedSet, cNeighbor) > 0
					loop
				ok
				
				nCurrentCost = This._GetScore(aCostSoFar, cCurrent)
				nTransitionCost = This._CalculateTransitionCost(cCurrent, cNeighbor, aOptimize)
				nNewCost = nCurrentCost + nTransitionCost
				
				nNeighborCost = This._GetScore(aCostSoFar, cNeighbor)
				if nNeighborCost = -1 or nNewCost < nNeighborCost
					This._SetScore(aCostSoFar, cNeighbor, nNewCost)
					This._SetParent(aParent, cNeighbor, cCurrent)
					
					bInOpen = FALSE
					nLen2 = len(aOpen)
					for j = 1 to nLen2
						aNode = aOpen[j]
						if aNode[1] = cNeighbor
							bInOpen = TRUE
							aNode[2] = nNewCost
							exit
						ok
					next
					
					if NOT bInOpen
						aOpen + [cNeighbor, nNewCost]
					ok
				ok
			next
		end
		
		This._StoreExplorationData(cStart, "", aExplored, aAlternatives)
		return [[], 0, [], "No goal state found"]

	def _StoreExplorationData(cStart, cGoal, aExplored, aAlternatives)
		nPos = This._FindPlan(This.CurrentPlan())
		if nPos > 0
			@aPlans[nPos][2][7] = aExplored
			@aPlans[nPos][2][8] = aAlternatives
		ok

	def _ReconstructPlan(aParent, cGoal, aGScore, aOptimize)
	    acPath = [cGoal]
	    cCurrent = cGoal
	    
	    while TRUE
	        cParent = This._GetParent(aParent, cCurrent)
	        if cParent = ""
	            exit
	        ok
	        acPath + cParent
	        cCurrent = cParent
	    end
	    
	    acReversed = []
	    nLen = len(acPath)
	    for i = nLen to 1 step -1
	        acReversed + acPath[i]
	    next
	    
	    # Get total cost from accumulated g-score (weighted cost from A*)
	    nTotalCost = This._GetScore(aGScore, cGoal)
	    
	    # Build action list with individual transition costs
	    aActions = []
	    nLen = len(acReversed)
	    for i = 1 to nLen - 1
	        cFrom = acReversed[i]
	        cTo = acReversed[i + 1]
	        
	        # Calculate this transition's weighted cost
	        nTransitionCost = This._CalculateTransitionCost(cFrom, cTo, aOptimize)
	        
	        aActions + [:from = cFrom, :to = cTo, :cost = nTransitionCost]
	    next
	    
	    cExplanation = This._GenerateExplanation(aActions)
	    
	    return [aActions, nTotalCost, acReversed, cExplanation]

	def _CalculateTransitionCost(cFrom, cTo, aOptimize)
		if len(aOptimize) = 0
			return 1
		ok
		
		nCost = 0
		nLen = len(aOptimize)
		for i = 1 to nLen
			aCriterion = aOptimize[i]
			cProperty = aCriterion[:property]
			nWeight = iif(HasKey(aCriterion, :weight), aCriterion[:weight], 1)
			cDirection = aCriterion[:direction]
			
			pValue = @oGraph.EdgeProperty(cFrom, cTo, cProperty)
			if pValue = ""
				pValue = 1
			ok
			
			if cDirection = "minimize"
				nCost += nWeight * pValue
			else
				nCost -= nWeight * pValue
			ok
		next
		
		return nCost
	
	def _SelectHeuristic(cStart, cGoal)
		aStartNode = @oGraph.Node(cStart)
		aGoalNode = @oGraph.Node(cGoal)
		
		if HasKey(aStartNode[:properties], :x) and HasKey(aGoalNode[:properties], :x)
			return func(poGraph, cFrom, cTo) {
				aFrom = poGraph.Node(cFrom)
				aTo = poGraph.Node(cTo)
				nX1 = aFrom[:properties][:x]
				nY1 = aFrom[:properties][:y]
				nX2 = aTo[:properties][:x]
				nY2 = aTo[:properties][:y]
				return sqrt(pow(nX2-nX1, 2) + pow(nY2-nY1, 2))
			}
		ok
		
		return func(poGraph, cFrom, cTo) {
			if cFrom = cTo
				return 0
			ok
			return 1
		}
	
	def _GenerateExplanation(aActions)
		if len(aActions) = 0
			return "No actions required"
		ok
		
		cExplanation = ""
		nLen = len(aActions)
		for i = 1 to nLen
			aAction = aActions[i]
			cExplanation += "Step " + i + ": " + aAction[:from] + " -> " + aAction[:to]
			if HasKey(aAction, :cost)
				cExplanation += " (cost: " + aAction[:cost] + ")"
			ok
			cExplanation += NL
		next
		
		return trim(cExplanation)
	
	def _GetScore(aScores, cNode)
		nLen = len(aScores)
		for i = 1 to nLen
			aScore = aScores[i]
			if aScore[1] = cNode
				return aScore[2]
			ok
		next
		return -1
	
	def _SetScore(aScores, cNode, nValue)
		nLen = len(aScores)
		for i = 1 to nLen
			if aScores[i][1] = cNode
				aScores[i][2] = nValue
				return
			ok
		next
		aScores + [cNode, nValue]
	
	def _GetParent(aParent, cNode)
		nLen = len(aParent)
		for i = 1 to nLen
			aEntry = aParent[i]
			if aEntry[1] = cNode
				return aEntry[2]
			ok
		next
		return ""
	
	def _SetParent(aParent, cNode, cParentNode)
		nLen = len(aParent)
		for i = 1 to nLen
			if aParent[i][1] = cNode
				aParent[i][2] = cParentNode
				return
			ok
		next
		aParent + [cNode, cParentNode]

	def _AddToHistory(cPlanName, aResult, aOptimize)
		cTimestamp = date() + " " + time()
		@aHistory + [cPlanName, aResult, aOptimize, cTimestamp]

	def _PlanMeetsConstraints(cPlanName, paConstraints)
		aResult = []
		try
			aResult = This._GetResult(cPlanName)
		catch
			return FALSE
		done
	
		nLen = len(paConstraints)
		for i = 1 to nLen
			aConstraint = paConstraints[i]
			
			if NOT isList(aConstraint)
				loop
			ok
			
			cKey = aConstraint[1]
			pValue = aConstraint[2]
	
			if cKey = :maxCost
				if aResult[2] > pValue
					return FALSE
				ok
	
			but cKey = :minCost
				if aResult[2] < pValue
					return FALSE
				ok
	
			but cKey = :avoid
				acStates = aResult[3]
				cNodeToAvoid = lower(pValue)
				if ring_find(acStates, cNodeToAvoid) > 0
					return FALSE
				ok
	
			but cKey = :requires
				acStates = aResult[3]
				cRequiredNode = lower(pValue)
				if ring_find(acStates, cRequiredNode) = 0
					return FALSE
				ok
	
			but cKey = :maxSteps
				if len(aResult[3]) > pValue
					return FALSE
				ok
			ok
		next
	
		return TRUE

#======================================#
#  stzPlanComparison Helper Class      #
#======================================#

class stzPlanComparison
	@oPlanner
	@cPlan1
	@cPlan2
	@aResult1
	@aResult2

	def init(poPlanner, pcPlan1, pcPlan2, paResult1, paResult2)
		@oPlanner = poPlanner
		@cPlan1 = pcPlan1
		@cPlan2 = pcPlan2
		@aResult1 = paResult1
		@aResult2 = paResult2

	def Explain()
		cExplanation = "PATH ANALYSIS:" + NL
		
		aStates1 = @aResult1[3]
		aStates2 = @aResult2[3]
		
		if @@(aStates1) = @@(aStates2)
			cExplanation += "Plans use SAME route" + NL
			cExplanation += "  " + @@(aStates1) + NL
		else
			cExplanation += "Plans use DIFFERENT routes" + NL
			cExplanation += "  Plan 1: " + @@(aStates1) + NL
			cExplanation += "  Plan 2: " + @@(aStates2) + NL
			
			nDiverge = 0
			nLen = Min([ len(aStates1), len(aStates2) ])
			for i = 1 to nLen
				if aStates1[i] != aStates2[i]
					nDiverge = i
					exit
				ok
			next
			if nDiverge > 0
				cExplanation += NL + "  Paths diverge at step " + nDiverge + NL
			ok
		ok
		
		cExplanation += NL + "COST ANALYSIS:" + NL
		cExplanation += "  Plan 1 cost: " + @aResult1[2] + NL
		cExplanation += "  Plan 2 cost: " + @aResult2[2] + NL
		
		if @aResult1[2] < @aResult2[2]
			cExplanation += "  ✓ Plan 1 is cheaper" + NL
		but @aResult1[2] > @aResult2[2]
			cExplanation += "  ✓ Plan 2 is cheaper" + NL
		else
			cExplanation += "  = Plans have equal cost" + NL
		ok
		
		return (cExplanation)

	def ShowTradeoffs()
		cOutput = "CRITERION COMPARISON:" + NL
		
		nCost1 = @aResult1[2]
		nCost2 = @aResult2[2]
		nLen1 = len(@aResult1[3])
		nLen2 = len(@aResult2[3])
		
		cOutput += "  Cost:        "
		if nCost1 < nCost2
			cOutput += "Plan 1 wins (saves " + (nCost2 - nCost1) + ")" + NL
		but nCost1 > nCost2
			cOutput += "Plan 2 wins (saves " + (nCost1 - nCost2) + ")" + NL
		else
			cOutput += "Tie" + NL
		ok
		
		cOutput += "  Path Length: "
		if nLen1 < nLen2
			cOutput += "Plan 1 wins (" + nLen1 + " vs " + nLen2 + " steps)" + NL
		but nLen1 > nLen2
			cOutput += "Plan 2 wins (" + nLen2 + " vs " + nLen1 + " steps)" + NL
		else
			cOutput += "Tie" + NL
		ok
		
		cOutput += NL + "RECOMMENDATION:" + NL
		if nCost1 < nCost2
			cOutput += "  → Choose Plan 1 for cost optimization" + NL
		but nCost2 < nCost1
			cOutput += "  → Choose Plan 2 for cost optimization" + NL
		else
			cOutput += "  → Plans are equivalent in cost" + NL
		ok
		
		return trim(cOutput)

	def WhichIsCheaper()
		if @aResult1[2] < @aResult2[2]
			return "Plan " + @cPlan1
		but @aResult1[2] > @aResult2[2]
			return "Plan " + @cPlan2
		else
			return "Both plans have equal cost"
		ok

	def CostSavings()
		nDiff = abs(@aResult1[2] - @aResult2[2])
		return nDiff

	def PathLengthDifference()
		return abs(len(@aResult1[3]) - len(@aResult2[3]))

#======================================#
#  stzMultiPlanComparison Class        #
#======================================#

class stzMultiPlanComparison
	@oPlanner
	@acPlanNames
	@aResults

	def init(poPlanner, pacPlanNames, paResults)
		@oPlanner = poPlanner
		@acPlanNames = pacPlanNames
		@aResults = paResults

	def RankBy(cCriterion)
		cCriterion = lower(cCriterion)
		aRanking = []
		
		nLen = len(@aResults)
		for i = 1 to nLen
			cPlan = @aResults[i][1]      # First element of pair
			aResult = @aResults[i][2]    # Second element of pair
			
			nValue = 0
			if cCriterion = "cost"
				nValue = aResult[2]
			but cCriterion = "steps" or cCriterion = "length"
				nValue = len(aResult[3])
			ok
	
			aRanking + [cPlan, nValue]
		next
	
		# Sort ascending
		nLen = len(aRanking)
		for i = 1 to nLen-1
			for j = i+1 to nLen
				if aRanking[j][2] < aRanking[i][2]
					aTemp = aRanking[i]
					aRanking[i] = aRanking[j]
					aRanking[j] = aTemp
				ok
			next
		next
	
		return aRanking

	def ShowRankingTable()
		? "=== PLAN RANKING TABLE ==="
		? ""
		? "Rank | Plan Name          | Cost  | Steps"
		? "-----+--------------------+-------+------"
	
		aRankedByCost = This.RankBy("cost")
		
		nLen = len(aRankedByCost)
		for i = 1 to nLen
			cPlan = aRankedByCost[i][1]
			nCost = aRankedByCost[i][2]
			
			# Find steps
			nSteps = 0
			nLen2 = len(@aResults)
			for j = 1 to nLen2
				if @aResults[j][1] = cPlan
					nSteps = len(@aResults[j][2][3])
					exit
				ok
			next
	
			# Format with padding
			cRank = "" + i
			cPlanPadded = cPlan + copy(" ", 18 - len(cPlan))
			cCostStr = "" + nCost
			cCostPadded = cCostStr + copy(" ", 5 - len(cCostStr))
			
			? cRank + "    | " + cPlanPadded + " | " + cCostPadded + " | " + nSteps
		next
	
	def BestBy(cCriterion)
		aRanking = This.RankBy(cCriterion)
		if len(aRanking) > 0
			return aRanking[1][1]
		ok
		return ""
	
	def WorstBy(cCriterion)
		aRanking = This.RankBy(cCriterion)
		nLen = len(aRanking)
		if nLen > 0
			return aRanking[nLen][1]
		ok
		return ""

	def CompareAll()
		cOutput = "=== COMPARING " + len(@acPlanNames) + " PLANS ===" + NL + NL
	
		nLen = len(@aResults)
		for i = 1 to nLen
			cPlan = @aResults[i][1]      # First element of pair
			aResult = @aResults[i][2]    # Second element of pair
			
			cOutput += "Plan: " + cPlan + NL
			cOutput += "  Cost: " + aResult[2] + NL
			cOutput += "  Steps: " + len(aResult[3]) + NL
			cOutput += "  Route: " + @@(aResult[3]) + NL + NL
		next
	
		cOutput += "Best by cost: " + This.BestBy("cost") + NL
		cOutput += "Best by steps: " + This.BestBy("steps") + NL
	
		return trim(cOutput)

#======================================#
#  stzHistoricalComparison Class       #
#======================================#

class stzHistoricalComparison
	@oPlanner
	@cCurrentPlan
	@aCurrentResult
	@aHistory

	def init(poPlanner, pcCurrentPlan, paCurrentResult, paHistory)
		@oPlanner = poPlanner
		@cCurrentPlan = pcCurrentPlan
		@aCurrentResult = paCurrentResult
		@aHistory = paHistory

	def Explain()
		cOutput = "=== HISTORICAL COMPARISON ===" + NL + NL
		cOutput += "Current Plan: " + @cCurrentPlan + NL
		cOutput += "  Cost: " + @aCurrentResult[2] + NL
		cOutput += "  Steps: " + len(@aCurrentResult[3]) + NL + NL

		nAvgCost = @oPlanner.HistoricalAverage("cost")
		nAvgSteps = @oPlanner.HistoricalAverage("steps")

		cOutput += "Historical Average:" + NL
		cOutput += "  Cost: " + nAvgCost + NL
		cOutput += "  Steps: " + nAvgSteps + NL + NL

		nCurrentCost = @aCurrentResult[2]
		if nCurrentCost < nAvgCost
			nImprovement = ((nAvgCost - nCurrentCost) / nAvgCost) * 100
			cOutput += "✓ Current plan is " + nImprovement + "% better than average" + NL
		but nCurrentCost > nAvgCost
			nDegradation = ((nCurrentCost - nAvgCost) / nAvgCost) * 100
			cOutput += "✗ Current plan is " + nDegradation + "% worse than average" + NL
		else
			cOutput += "= Current plan matches historical average" + NL
		ok

		cBestPlan = @oPlanner.BestHistoricalPlan("cost")
		if cBestPlan != ""
			cOutput += NL + "Best historical plan: " + cBestPlan + NL
		ok

		return trim(cOutput)

	def IsImprovement()
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		return @aCurrentResult[2] < nAvgCost

	def ImprovementPercentage()
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		if nAvgCost = 0
			return 0
		ok
		return ((nAvgCost - @aCurrentResult[2]) / nAvgCost) * 100

#======================================#
#  stzPlanFilter Class                 #
#======================================#

class stzPlanFilter
	@oPlanner
	@acFilteredPlans
	@aConstraints

	def init(poPlanner, pacFiltered, paConstraints)
		@oPlanner = poPlanner
		@acFilteredPlans = pacFiltered
		@aConstraints = paConstraints

	def Plans()
		return @acFilteredPlans

	def Count()
		return len(@acFilteredPlans)

	def Show()
		? "=== FILTERED PLANS ===" + NL
		? "Constraints applied: " + @@(@aConstraints) + NL
		? "Plans matching: " + len(@acFilteredPlans) + NL

		nLen = len(@acFilteredPlans)
		for i = 1 to nLen
			cPlan = @acFilteredPlans[i]
			aResult = @oPlanner._GetResult(cPlan)
			
			? "" + i + ". " + cPlan
			? "   Cost: " + aResult[2]
			? "   Steps: " + len(aResult[3])
			? "   Route: " + @@(aResult[3])

		next

	def BestBy(cCriterion)
		if len(@acFilteredPlans) = 0
			return ""
		ok

		oMultiComp = @oPlanner.CompareMultiple(@acFilteredPlans)
		return oMultiComp.BestBy(cCriterion)

	def ShowRankingTable()
		if len(@acFilteredPlans) = 0
			? "No plans match the filters."
			return
		ok

		oMultiComp = @oPlanner.CompareMultiple(@acFilteredPlans)
		oMultiComp.ShowRankingTable()
