#============================================#
#  stzGraphPlanner - Simplified Single Class
#============================================#

class stzGraphPlanner
	@oGraph
	@aPlans  # [ [name, [startNode, goalNode, goalFunc, criteria, constraints, result]], ... ]
	@cCurrentPlan

	def init(poGraph)
		if NOT @IsStzGraph(poGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		
		@oGraph = poGraph
		@aPlans = []
	
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
		@aPlans + [pcPlanName, ["", "", "", [], [], ""]]

		if len(@aPlans) = 1
			This.SetCurrentPlan(pcPlanName)
		ok

	def Plan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		ocName = lower(pcPlanName)
		return @aPlan[pcPlanName]

	def SetCurrentPlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				stzraise("Incorrect param type! pcPlanName must be a string!")
			ok
		ok

		pcPlanName = lower(pcPlanName)

		if NOT HasKey(@aPlans, pcPlanName)
			stzraise("Inexistant plan (" + @pcPlanName + ")!")
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
			stzraise("Inexistant plan (" + @pcPlanName + ")!")
		ok

		nLen = len(@aPlans)
		if nLen = 1
			stzraise("Can't remove the only plan we have!")
		ok

		if pcPlanName = This.CurrentPlan()
			stzraise("Can't remove the current plan we are working on! You can do it if yu set an other plan as current.")
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
		@aPlans[nPos][2][1] = pcFrom  # startNode
		@aPlans[nPos][2][2] = pcTo     # goalNode
	

		def WalkIn(pcPlanName, pcFrom, pcTo)
			This.WalkXt(pcPlanName, pcFrom, pcTo)

		def WalkInPlan(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

	#--

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

	#--

	def To(pcTo)
		This.ToXT(This.CurrentPlan(), pcTo)

		def ToNode(pcTo)
			This.To(pcTo)

	def ToXT(pcPlanName, pcTo)
		if isFunction(pcTo)
			This.ToReachF(pcPlanName, pcTo)
			return
		ok

		nPos = This._FindPlan(pcPlanName)
		if nPos = 0
			stzraise("Plan not found!")
		ok
		@aPlans[nPos][2][2] = pcTo

		def ToNodeXT(pcPlanName, pcTo)
			This.ToXT(pcPlanName, pcTo)
	
	#--

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
		if CheckParam()
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
			This.ToF(pcPlanName, pGoalFunc)

		def UntilYouReachFXT(pcPlanName, pGoalFunc)
			This.ToF(pcPlanName, pGoalFunc)

		#--

		def ToXTF(pcPlanName, pGoalFunc)
			This.ToF(pcPlanName, pGoalFunc)

		def ToReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def ReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		def UntilReachXTF(pcPlanName, pGoalFunc)
			This.ToF(pcPlanName, pGoalFunc)

		def UntilYouReachXTF(pcPlanName, pGoalFunc)
			This.ToF(pcPlanName, pGoalFunc)

	#--

	def Minimize(pcProperty)
		This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimise(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimising(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		def Minimizing(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		#--

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

		#--

		def MinimizeInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimiseInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimizingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		def MinimisingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

	#--

	def Maximize(pcProperty)
		This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximise(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximizing(pcPropert)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def Maximising(pcPropert)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		#--

		def MaximizeFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximiseFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximizingFor(pcPropert)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		def MaximisingFor(pcPropert)
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

		#--

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
		
		# Normalize
		if cStartNode != ""
			cStartNode = lower(cStartNode)
		ok
		if cGoalNode != ""
			cGoalNode = lower(cGoalNode)
		ok
		
		# Validate
		if cStartNode = "" or NOT @oGraph.NodeExists(cStartNode)
			stzraise("Invalid start node!")
		ok
		
		# Execute
		aResult = ""
		if cGoalNode != ""
			pHeuristic = This._SelectHeuristic(cStartNode, cGoalNode)
			aResult = This._AStar(cStartNode, cGoalNode, pHeuristic, aOptimize, aConstraints)
		but pGoalFunc != ""
			aResult = This._GoalSearch(cStartNode, pGoalFunc, aOptimize, aConstraints)
		else
			stzraise("Either goal node or goal function must be specified!")
		ok
		
		# Store result
		@aPlans[nPos][2][6] = aResult
		
		def ExecutePlan(pcPlanName)
			This.ExecuteXT(pcPlanName)

		def RunXT(pcPlanName)
			This.ExecuteXt(pcPlanName)

		def RunPlan(pcPlanName)
			This.ExecuteXt(pcPlanName)

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
		return aResult[2]  # nTotalCost

		def CostOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(ocPlanName).IsOforOfPlanNamedParam()
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

	#--

	def States()
		return This.StatesXT(This.CurrentPlan())

		def StatesOfCurrentPlan()
			return This.StatesXT(This.CurrentPlan())

		def StatesInCurrrentPlan()
			return This.StatesXT(This.CurrentPlan())

	def StatesXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[3]  # aStates

		def StatesOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(ocPlanName).IsOforOfPlanOrInOrInPlanNamedParam()
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.StatesXT(pcPlanName)

		def StatesOfPlan(pcPlanName)
			return This.StatesXT(pcPlanName)

		def StatesIn(pcPlanName)
			return This.StatesXT(pcPlanName)

		def StatesInPlan(pcPlanName)
			return This.StatesXT(pcPlanName)

	#--

	def Actions()
		return This.ActionsXT(This.CurrentPlan())

		def ActionsOfCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

		def ActionsInCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

	def ActionsXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[1]  # aActions
	
		def ActionsIn(pcPlanName)
			return This.ActionsXT(pcPlanName)

		def ActionsOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and StzListQ(ocPlanName).IsOforOfPlanOrInOrInPlanNamedParam()
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.ActionsXT(pcPlanName)

		def ActionsOfPlan(pcPlanName)
			return This.ActionsXT(pcPlanName)

	#--

	def Explain()
		return This.ExplainXT(This.CurrentPlan())

		def ExplainCurrentPlan()
			return This.ExplainXT(This.CurrentPlan())

	def ExplainXT(pcPlanName)
		aResult = This._GetResult(pcPlanName)
		return aResult[4]  # cExplanation
	
		def ExplainPlan(pcPlanName)
			return This.ExplainXT(pcPlanName)

	#--

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
		nLen = len(@aPlans)
		for i = 1 to nLen
			if @aPlans[i][1] = pcPlanName
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
			
			if cCurrent = cGoal
				return This._ReconstructPlan(aParent, cCurrent, aGScore, aOptimize)
			ok
			
			aClosedSet + cCurrent
			
			aNeighbors = @oGraph.Neighbors(cCurrent)
			nLen = len(aNeighbors)
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
		
		return [[], 0, [], "No path found"]
	
	def _GoalSearch(cStart, pGoalFunc, aOptimize, aConstraints)
		aOpen = [[cStart, 0]]
		aClosedSet = []
		aCostSoFar = [[cStart, 0]]
		aParent = []
		
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
			
			aNode = @oGraph.Node(cCurrent)
			if call pGoalFunc(aNode)
				return This._ReconstructPlan(aParent, cCurrent, aCostSoFar, aOptimize)
			ok
			
			aClosedSet + cCurrent
			
			aNeighbors = @oGraph.Neighbors(cCurrent)
			nLen = len(aNeighbors)
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
		
		return [[], 0, [], "No goal state found"]
	
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
	    
	    aActions = []
	    nTotalCost = 0
	    nLen = len(acReversed)
	    for i = 1 to nLen - 1
	        cFrom = acReversed[i]
	        cTo = acReversed[i + 1]
	        
	        # Get edge cost based on optimization criteria
	        nCost = 1
	        if len(aOptimize) > 0
	        	cProperty = aOptimize[1][:property]
	        	pEdgeCost = @oGraph.EdgeProperty(cFrom, cTo, cProperty)
	        	if pEdgeCost != "" and pEdgeCost != NULL
	        		nCost = pEdgeCost
	        	ok
	        else
	        	# No optimization criteria, try default properties
	        	pEdgeCost = @oGraph.EdgeProperty(cFrom, cTo, "distance")
	        	if pEdgeCost = "" or pEdgeCost = NULL
	        		pEdgeCost = @oGraph.EdgeProperty(cFrom, cTo, "cost")
	        	ok
	        	if pEdgeCost = "" or pEdgeCost = NULL
	        		pEdgeCost = @oGraph.EdgeProperty(cFrom, cTo, "weight")
	        	ok
	        	if pEdgeCost != "" and pEdgeCost != NULL
	        		nCost = pEdgeCost
	        	ok
	        ok
	        
	        nTotalCost += nCost
	        aActions + [:from = cFrom, :to = cTo, :cost = nCost]
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
		
		return cExplanation
	
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
