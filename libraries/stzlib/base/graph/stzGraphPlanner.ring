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
	
			if @IsFunction(pcTo)
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
		if @IsFunction(pcTo)
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
			if NOT @IsFunction(pGoalFunc)
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
		return [
			:plan = pcPlanName,
			:actions = aResult[1],
			:total_cost = aResult[2],
			:route = aResult[3],
			:steps = len(aResult[1])
		]
	
		def ExplainPlan(pcPlanName)
			return This.ExplainXT(pcPlanName)

	#-----------------------#
	#  EXPLANATION METHODS  #
	#-----------------------#

	def CostBreakdown()
		return This.CostBreakdownXT(This.CurrentPlan())

		def ExplainCostBreakdown()
			return This.CostBreakdown()

	def CostBreakdownXT(pcPlanName)
		aActions = This.ActionsXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aOptimize = @aPlans[nPos][2][4]
		
		aBreakdown = []
		nLen = len(aActions)
		for i = 1 to nLen
			aAction = aActions[i]
			aStep = [
				:step = i,
				:from = aAction[:from],
				:to = aAction[:to],
				:criteria = []
			]
			
			nStepTotal = 0
			if len(aOptimize) > 0
				nLen2 = len(aOptimize)
				for j = 1 to nLen2
					aCriterion = aOptimize[j]
					cProp = aCriterion[:property]
					nWeight = aCriterion[:weight]
					cDir = aCriterion[:direction]
					
					pValue = @oGraph.EdgeProperty(aAction[:from], aAction[:to], cProp)
					if pValue = ""
						pValue = 1
					ok
					
					nContribution = 0
					if cDir = "minimize"
						nContribution = nWeight * pValue
					else
						nContribution = -nWeight * pValue
					ok
					
					nStepTotal += nContribution
					
					aStep[:criteria] + [
						:property = cProp,
						:value = pValue,
						:weight = nWeight,
						:direction = cDir,
						:contribution = nContribution
					]
				next
			ok
			
			aStep + [:total = nStepTotal]
			aBreakdown + aStep
		next
		
		return aBreakdown

		def ExplainCostBreakdownXT(pcPlanName)
			return This.CostBreakdownXT(pcPlanName)

	def Why(cAspect)
		return This.WhyXT(cAspect, This.CurrentPlan())

		def ExplainWhy(cAspect)
			return This.Why(cAspect)

	def WhyXT(cAspect, pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aResult = aPlanData[6]
		aExplored = aPlanData[7]
		aOptimize = aPlanData[4]
		
		aCriteria = []
		nLen = len(aOptimize)
		for i = 1 to nLen
			aCrit = aOptimize[i]
			aCriteria + [
				:direction = aCrit[:direction],
				:property = aCrit[:property]
			]
		next
		
		return [
			:plan = pcPlanName,
			:total_cost = aResult[2],
			:nodes_explored = len(aExplored),
			:optimized_for = aCriteria,
			:route = aResult[3]
		]

		def ExplainWhyXT(cAspect, pcPlanName)
			return This.WhyXT(cAspect, pcPlanName)

	def Alternatives()
		return This.AlternativesXT(This.CurrentPlan())

		def ExplainAlternatives()
			return This.Alternatives()

	def AlternativesXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aAlternatives = aPlanData[8]
		
		return [
			:plan = pcPlanName,
			:decision_points = aAlternatives
		]

		def ExplainAlternativesXT(pcPlanName)
			return This.ExplainAlternativesXT(pcPlanName)

	def Efficiency()
		return This.ExplainEfficiencyXT(This.CurrentPlan())

		def ExplainEfficiency()
			return This.Efficiency()

	def EfficiencyXT(pcPlanName)
		nPos = This._FindPlan(pcPlanName)
		aPlanData = @aPlans[nPos][2]
		aResult = aPlanData[6]
		aExplored = aPlanData[7]
		
		nPathLength = len(aResult[3])
		nExplored = len(aExplored)
		nRatio = nExplored / nPathLength
		
		cAssessment = ""
		if nRatio < 1.5
			cAssessment = "very efficient"
		but nRatio < 2.5
			cAssessment = "efficient"
		but nRatio < 4
			cAssessment = "moderate"
		else
			cAssessment = "explored many alternatives"
		ok
		
		return [
			:plan = pcPlanName,
			:nodes_explored = nExplored,
			:path_length = nPathLength,
			:ratio = nRatio,
			:assessment = cAssessment
		]

		def ExplainEfficiencyXT(pcPlanName)
			return This.EfficiencyXT(pcPlanName)

	#-----------------------#
	#  COMPARISON METHODS   #
	#-----------------------#

	def CompareTo(pcOtherPlan)
		return This.CompareToQ(pcOtherPlan).Explain()

		def CompareWith(pcOtherPlan)
			return This.CompareTo(pcOtherPlan)

		def CompareToQ(pcOtherPlan)
			return This.CompareToXTQ(This.CurrentPlan(), pcOtherPlan)

			def CompareWithQ(pcOtherPlan)
				return This.CompareToQ(pcOtherPlan)

	def CompareToXT(pcOtherPlan)
		return This.CompareToXTQ(pcOtherPlan).Explain()

		def CompareWithXT(pcOtherPlan)
			return This.CompareToXT(pcOtherPlan)

		def CompareToXTQ(pcPlan1, pcPlan2)
			aResult1 = This._GetResult(pcPlan1)
			aResult2 = This._GetResult(pcPlan2)
		
			return new stzPlanComparison(This, pcPlan1, pcPlan2, aResult1, aResult2)

			def CompareWithXTQ(pcPlan1, pcPlan2)
				return This.CompareToXTQ(pcPlan1, pcPlan2)

	def Difference(pcOtherPlan)
		return This.DifferenceXT(This.CurrentPlan(), pcOtherPlan)

		def DifferenceWith(pcOtherPlan)
			return This.Difference(pcOtherPlan)

		def ExplainDifference(pcOtherPlan)
			return This.Difference(pcOtherPlan)

		def ExplainDifferenceWith(pcOtherPlan)
			return This.Difference(pcOtherPlan)

	def DifferenceXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXTQ(pcPlan1, pcPlan2)
		return oComp.Explain()

		def DifferenceWithXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

		def ExplainDifferenceXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

		def ExplainDifferenceWithXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

	def Tradeoffs(pcOtherPlan)
		return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def TradeoffsOf(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def TradeoffsAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainTradeoffs(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainTradeoffsOf(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainTradeoffsAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		#--

		def Compromises(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def CompromisesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def CompromisesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def Compromizes(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def CompromizesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def CompromizesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromises(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromisesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromisesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromizes(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromizesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		def ExplainCompromizesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)


	def TradeoffsXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXTQ(pcPlan1, pcPlan2)
		return oComp.Tradeoffs()

		def TradeoffsOfXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def TradeoffsAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainTradeoffsXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainTradeoffsOfXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainTradeoffsAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		#--
		def CompromisesXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def CompromisesWithXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def CompromisesAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def CompromizesXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def CompromizesWithXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def CompromizesAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromisesXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromisesWithXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromisesAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromizesXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromizesWithXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

		def ExplainCompromizesAgainstXT(pcPlan1, pcPlan2)
			return This.TradeoffsXT(pcPlan1, pcPlan2)

	def WhichIsCheaper(pcOtherPlan)
		return This.WhichIsCheaperXT(This.CurrentPlan(), pcOtherPlan)

	def WhichIsCheaperXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXTQ(pcPlan1, pcPlan2)
		return oComp.WhichIsCheaper()

	def CostSaving(pcOtherPlan)
		return This.CostSavingXT(This.CurrentPlan(), pcOtherPlan)

	def CostSavingXT(pcPlan1, pcPlan2)
		oComp = This.CompareToXTQ(pcPlan1, pcPlan2)
		return oComp.CostSaving()

	#---------------------------------#
	#  MULTI-PLAN COMPARISON          #
	#---------------------------------#

	def CompareMany(acPlanNames)
		return This.CompareManyQ(acPlanNames).CompareAll()

		def CompareAll(acPlanNames)
			return This.CompareMany(acPlanNames)

		def CompareMultiple(acPlanNames)
			return This.CompareMany(acPlanNames)

		def CompareManyQ(acPlanNames)
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
		
			def CompareAllQ(acPlanNames)
				return This.CompareManyQ(acPlanNames)
	
			def CompareMultipleQ(acPlanNames)
				return This.CompareManyQ(acPlanNames)

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
	
		oMultiComp = This.CompareMultipleQ(acPlanNames)
		return oMultiComp.RankBy(cCriterion)

	#---------------------------------#
	#  HISTORICAL COMPARISON          #
	#---------------------------------#

	def History()
		return @aHistory

	def HistoryCount()
		return len(@aHistory)

		def HistorySize()
			return len(@aHistory)

	def CompareWithHistory()
		return This.CompareWithHistoryXT(This.CurrentPlan())

		def CompareWithHistoryQ()
			return This.CompareWithHistoryXTQ(This.CurrentPlan())
	
	def CompareWithHistoryXT(pcPlanName)
		return This.CompareWithHistoryXTQ(pcPlanName).Explain()

		def CompareWithHistoryXTQ(pcPlanName)
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

		def HistoAverage()
			return This.HistoricalAverage()

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

		def BestHistoPlan(cCriterion)
			return This.BestHistoricalPlan(cCriterion)

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

		def WortsHistoPlan(cCriterion)
			return This.WorstHistoricalPlan(cCriterion)

	def ClearHistory()
		@aHistory = []

	#---------------------------------#
	#  CONSTRAINT-BASED FILTERING     #
	#---------------------------------#

	def FilterPlans(paConstraints)
		return This.FilterPlansQ(paConstraints).Plans()

		def FilterPlansQ(paConstraints)
			acAllPlans = []
			nLen = len(@aPlans)
			for i = 1 to nLen
				acAllPlans + @aPlans[i][1]
			next
			
			return This.FilterPlansXTQ(acAllPlans, paConstraints)
	
	def FilterPlansXT(acPlanNames, paConstraints)
		return This.FilterPlansXTQ(acPlanNames, paConstraints).Plans()

		def FilterPlansXTQ(acPlanNames, paConstraints)
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
		return This.PlansWithinQ(nPercentage, cBasePlan).Plans()

		def PlansWithinQ(nPercentage, cBasePlan)
			if CheckParams()
				if isList(cBasePlan) and StzListQ(cBasePlan).IsOfOrOfPlanNamedParam()
					cBasePlan = cBasePlan[2]
				ok
			ok
	
			aBaseResult = This._GetResult(cBasePlan)
			nBaseCost = aBaseResult[2]
			nMaxCost = nBaseCost * (1 + nPercentage/100)
	
			return This.FilterPlansQ([ :maxCost = nMaxCost ])

	def PlansAvoinding(cNode)
		return This.PlansAvoidingQ(cNode).Plans()

		def PlansThatAvoid(cNode)
			return This.PlansAvoiding(cNode)

		def PlansAvoidingQ(cNode)
			return This.FilterPlansQ([ :avoid = cNode ])
	
			def PlansThatAvoidQ(cNode)
				return This.PlansAvoidingQ(cNode)

	def PlansRequiring(cNode)
		return This.PlansRequiringQ(cNode).Plans()

		def PlansThatRequire(cNode)
			return This.PlansRequiring(cNode)

	def PlansRequiringQ(cNode)
		return This.FilterPlansQ([ :requires = cNode ])

		def PlansThatRequireQ(cNode)
			return This.PlansRequiringQ(cNode)

	#-----------------------#
	#  DISPLAY METHODS      #
	#-----------------------#

	def Show()
		This.ShowXT(This.CurrentPlan())

		def ShowCurrentPlan()
			This.ShowXT(This.CurrentPlan())

	def ShowXT(pcPlanName)
		try
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
		catch
			? "Plan '" + pcPlanName + "' not found or not executed."
		done
	
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
		#WARNING // TODO
		# This method checks for :x property but many examples in 
		# stzGraphPlannerTest.ring file don't define coordinates,
		# falling back to constant heuristic (returns 1).
		# This affects A* efficiency claims.

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
? @@NL(paConstraints)	
		nLen = len(paConstraints)
		for i = 1 to nLen
			aConstraint = paConstraints[i]
			
			if NOT isList(aConstraint)
				loop
			ok
			
			cKey = lower(aConstraint[1])
			pValue = aConstraint[2]
	
			if cKey = "maxcost"
				if aResult[2] > pValue
					return FALSE
				ok
	
			but cKey = "mincost"
				if aResult[2] < pValue
					return FALSE
				ok
	
			but cKey = "avoid"
				acStates = aResult[3]
				cNodeToAvoid = lower(pValue)
				nLen3 = len(acStates)
				for k = 1 to nLen3
					if lower(acStates[k]) = cNodeToAvoid
						return FALSE
					ok
				next
	
			but cKey = "requires"
				acStates = aResult[3]
				cRequiredNode = lower(pValue)
				if ring_find(acStates, cRequiredNode) = 0
					return FALSE
				ok
	
			but cKey = "maxsteps"
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
		aStates1 = @aResult1[3]
		aStates2 = @aResult2[3]
		
		bSamePath = (@@(aStates1) = @@(aStates2))
		nDivergeStep = 0
		
		if NOT bSamePath
			nLen = Min([ len(aStates1), len(aStates2) ])
			for i = 1 to nLen
				if aStates1[i] != aStates2[i]
					nDivergeStep = i
					exit
				ok
			next
		ok
		
		cCheaper = ""
		if @aResult1[2] < @aResult2[2]
			cCheaper = @cPlan1
		but @aResult1[2] > @aResult2[2]
			cCheaper = @cPlan2
		else
			cCheaper = "equal"
		ok
		
		return [
			:plan1 = @cPlan1,
			:plan2 = @cPlan2,
			:same_path = bSamePath,
			:route1 = aStates1,
			:route2 = aStates2,
			:diverge_at_step = nDivergeStep,
			:cost1 = @aResult1[2],
			:cost2 = @aResult2[2],
			:cheaper = cCheaper
		]
	
	def Tradeoffs()
		nCost1 = @aResult1[2]
		nCost2 = @aResult2[2]
		nLen1 = len(@aResult1[3])
		nLen2 = len(@aResult2[3])
		
		cCostWinner = ""
		nCostSaving = 0
		if nCost1 < nCost2
			cCostWinner = @cPlan1
			nCostSaving = nCost2 - nCost1
		but nCost1 > nCost2
			cCostWinner = @cPlan2
			nCostSaving = nCost1 - nCost2
		else
			cCostWinner = "tie"
		ok
		
		cLengthWinner = ""
		nLengthDiff = 0
		if nLen1 < nLen2
			cLengthWinner = @cPlan1
			nLengthDiff = nLen2 - nLen1
		but nLen1 > nLen2
			cLengthWinner = @cPlan2
			nLengthDiff = nLen1 - nLen2
		else
			cLengthWinner = "tie"
		ok
		
		cRecommendation = ""
		if cCostWinner != "tie"
			cRecommendation = "Choose " + cCostWinner + " for cost optimization"
		else
			cRecommendation = "Plans are equivalent in cost"
		ok
		
		return [
			:plan1 = @cPlan1,
			:plan2 = @cPlan2,
			:cost_winner = cCostWinner,
			:cost_savings = nCostSaving,
			:length_winner = cLengthWinner,
			:length_difference = nLengthDiff,
			:recommendation = cRecommendation
		]

		def Compromises()
			return This.Tradeoffs()

		def Compromizes()
			return This.Tradeoffs()

	def WhichIsCheaper()
		if @aResult1[2] < @aResult2[2]
			return @cPlan1
		but @aResult1[2] > @aResult2[2]
			return @cPlan2
		else
			return [ @cPlan1, @cPlan2 ]
		ok

		def Cheaper()
			return This.WhichIsCheaper()

		def WhichIsCheaperPlan()
			return This.WhichIsCheaper()

		def CheaperPlan()
			return This.WhichIsCheaper()

	def CostSaving()
		nDiff = abs(@aResult1[2] - @aResult2[2])
		return nDiff
		
		def HowMutchCheaper()
			return This.CostSaving()

	def PathLengthDifference()
		return abs(len(@aResult1[3]) - len(@aResult2[3]))

		def PathLenDiff()
			return abs(len(@aResult1[3]) - len(@aResult2[3]))

		def PathLengthDiff()
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

	def RankingTable()
	
		aTable = []
		
		# Optional header
		add(aTable, ["Rank", "Plan", "Cost", "Steps"])
		
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
			
			# Add row as pure data
			add(aTable, [i, cPlan, nCost, nSteps])
			
		next
		
		return aTable

	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
	
	def BestBy(cCriterion)
		aRanking = This.RankBy(cCriterion)
		if len(aRanking) > 0
			return aRanking[1][1]
		ok
		stzraise("No ranks returned by this criterion : " + cCriterion + "!")
	
	def WorstBy(cCriterion)
		aRanking = This.RankBy(cCriterion)
		nLen = len(aRanking)
		if nLen > 0
			return aRanking[nLen][1]
		ok
		stzraise("No ranks returned by this criterion : " + cCriterion + "!")

	def CompareAll()
		aAllPlans = []
		
		nLen = len(@aResults)
		for i = 1 to nLen
			cPlan = @aResults[i][1]
			aResult = @aResults[i][2]
			
			aAllPlans + [
				:plan = cPlan,
				:cost = aResult[2],
				:steps = len(aResult[3]),
				:route = aResult[3]
			]
		next
		
		return [
			:total_plans = len(@acPlanNames),
			:plans = aAllPlans,
			:best_by_cost = This.BestBy("cost"),
			:best_by_steps = This.BestBy("steps")
		]

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
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		nAvgSteps = @oPlanner.HistoricalAverage("steps")
		nCurrentCost = @aCurrentResult[2]
		nCurrentSteps = len(@aCurrentResult[3])
		
		cObservation = ""
		nPercentDiff = 0
		
		if nCurrentCost < nAvgCost
			nPercentDiff = ((nAvgCost - nCurrentCost) / nAvgCost) * 100
			cObservation = "✓ Current plan is " + nPercentDiff + "% better than average"
		but nCurrentCost > nAvgCost
			nPercentDiff = ((nCurrentCost - nAvgCost) / nAvgCost) * 100
			cObservation = "✗ Current plan is " + nPercentDiff + "% worse than average"
		else
			cObservation = "= Current plan matches historical average"
		ok
		
		return [
			:current_plan = @cCurrentPlan,
			:cost = nCurrentCost,
			:steps = nCurrentSteps,
			:historical_average_cost = nAvgCost,
			:historical_average_steps = nAvgSteps,
			:observation = cObservation,
			:best_historical_plan = @oPlanner.BestHistoricalPlan("cost")
		]

	def IsImprovement()
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		return @aCurrentResult[2] < nAvgCost

	def Improvement()
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		if nAvgCost = 0
			return 0
		ok
		return ((nAvgCost - @aCurrentResult[2]) / nAvgCost)

		def ImprovementRatio()
			return This.Improvement()

	def ImprovementPercentage()
		nAvgCost = @oPlanner.HistoricalAverage("cost")
		if nAvgCost = 0
			return 0
		ok
		return ((nAvgCost - @aCurrentResult[2]) / nAvgCost) * 100

		def Improvement100()
			return This.ImprovementPercentage()

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

		def FilteredPlans()
			return @acFilteredPlans

	def Count()
		return len(@acFilteredPlans)

		def NumberOfPlans()
			return len(@acFilteredPlans)

		def NumberOfFilteredPlans()
			return len(@acFilteredPlans)

		def HowManyPlans()
			return len(@acFilteredPlans)

		def HowManyFilteredPlans()
			return len(@acFilteredPlans)

	def PlansXT()

		aDetails = []

		nLen = len(@acFilteredPlans)
		for i = 1 to nLen
			cPlan = @acFilteredPlans[i]
			aPlanResult = @oPlanner._GetResult(cPlan)
			
			aPlanInfo = []
			aPlanInfo + [ "plan", cPlan ]
			aPlanInfo + [ "cost", aPlanResult[2] ]
			aPlanInfo + [ "steps", len(aPlanResult[3]) ]
			aPlanInfo + [ "route", aPlanResult[3] ]

			aDetails + aPlanInfo

		next

		aResult = [
			:constrains_applied = @aConstraints,
			:plans_matching_count = len(@acFilteredPlans),
			:plans_matching_details = aDetails
		]

		return aResult

		def FilteredPlansXT()
			return This.PlansXT()

	def Show()
		? @@NL( This.PlansXT() )


	def BestBy(cCriterion)
		if len(@acFilteredPlans) = 0
			return ""
		ok

		oMultiComp = @oPlanner.CompareMultipleQ(@acFilteredPlans)
		return oMultiComp.BestBy(cCriterion)

	def RankingTable()
		if len(@acFilteredPlans) = 0
			? "No plans match the filters."
			return
		ok

		oMultiComp = @oPlanner.CompareManyQ(@acFilteredPlans)
		return oMultiComp.RankingTable()

	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
