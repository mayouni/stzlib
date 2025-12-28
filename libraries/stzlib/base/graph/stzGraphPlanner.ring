#============================================#
#  stzGraphPlanner - AI Planning & Pathfinding
#  Sophisticated planning on top of stzGraph
#============================================#

#---------------------------#
#  MAIN PLANNER CLASS       #
#---------------------------#

class stzGraphPlanner
	@oGraph          # The underlying stzGraph instance
	@cStartNode      # Starting state
	@cGoalNode       # Target state (can be NULL for goal-based)
	@pGoalFunction   # Function defining goal conditions
	@aOptimizeCriteria  # List of properties to optimize
	@aConstraints    # Additional planning constraints
	@aHeuristics     # Heuristic functions for search guidance
	@oCurrentPlan    # The active plan (stzPlan object)
	@bReactivePlanning  # Enable reactive replanning
	@aMonitoredProperties  # Properties to monitor for replanning
	
	# State management (delta encoding)
	@aStateCache     # LRU cache for reconstructed states
	@nMaxCacheSize = 1000
	@aCheckpoints    # Checkpoint states every 20 nodes
	@nCheckpointInterval = 20
	
	def init(poGraph)
		if NOT @IsStzGraph(poGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		
		@oGraph = poGraph
		@cStartNode = NULL
		@cGoalNode = NULL
		@pGoalFunction = NULL
		@aOptimizeCriteria = []
		@aConstraints = []
		@aHeuristics = []
		@oCurrentPlan = NULL
		@bReactivePlanning = FALSE
		@aMonitoredProperties = []
		@aStateCache = []
		@aCheckpoints = []
	
	#-----------------------#
	#  FLUENT INTERFACE     #
	#-----------------------#
	
	def Plan()
		return new stzPlanningRequest(This)
	
	#-----------------------#
	#  EXECUTION METHODS    #
	#-----------------------#
	
	def _ExecutePlan(oPlanRequest)
		# Extract planning parameters
		@cStartNode = oPlanRequest.StartNode()
		@cGoalNode = oPlanRequest.GoalNode()
		@pGoalFunction = oPlanRequest.GoalFunction()
		@aOptimizeCriteria = oPlanRequest.OptimizeCriteria()
		@aConstraints = oPlanRequest.Constraints()
		
		# Normalize node IDs to lowercase (stzGraph stores in lowercase)
		if @cStartNode != NULL
			@cStartNode = lower(@cStartNode)
		ok
		if @cGoalNode != NULL
			@cGoalNode = lower(@cGoalNode)
		ok
		
		# Validate start node
		if @cStartNode = NULL or NOT @oGraph.NodeExists(@cStartNode)
			stzraise("Invalid start node!")
		ok
		
		# Determine which algorithm to use
		if @cGoalNode != NULL
			# Explicit goal node - use A*
			pHeuristic = This._SelectHeuristic(@cStartNode, @cGoalNode)
			oPlan = This._AStar(@cStartNode, @cGoalNode, pHeuristic)
		but @pGoalFunction != NULL
			# Goal function - use goal-based search
			oPlan = This._GoalSearch(@cStartNode, @pGoalFunction)
		else
			stzraise("Either goal node or goal function must be specified!")
		ok
		
		@oCurrentPlan = oPlan
		return oPlan
	
	#-----------------------#
	#  A* SEARCH ALGORITHM  #
	#-----------------------#
	
	def _AStar(cStart, cGoal, pHeuristic)
		# Priority queue: f(n) = g(n) + h(n)
		aOpen = [ [cStart, 0, call pHeuristic(@oGraph, cStart, cGoal)] ]
		aClosedSet = []
		aGScore = [ [cStart, 0] ]
		aFScore = [ [cStart, call pHeuristic(@oGraph, cStart, cGoal)] ]
		aParent = []
		
		while len(aOpen) > 0
			# Get node with lowest f-score
			nMinIdx = 1
			nMinF = aOpen[1][3]
			for i = 2 to len(aOpen)
				if aOpen[i][3] < nMinF
					nMinF = aOpen[i][3]
					nMinIdx = i
				ok
			next
			
			aCurrent = aOpen[nMinIdx]
			cCurrent = aCurrent[1]
			del(aOpen, nMinIdx)
			
			# Goal reached?
			if cCurrent = cGoal
				return This._ReconstructPlan(aParent, cCurrent, aGScore)
			ok
			
			# Add to closed set
			aClosedSet + cCurrent
			
			# Explore neighbors
			acNeighbors = @oGraph.Neighbors(cCurrent)
			for cNeighbor in acNeighbors
				# Skip if in closed set
				if ring_find(aClosedSet, cNeighbor) > 0
					loop
				ok
				
				# Check constraints
				if NOT This._RespectConstraints(cCurrent, cNeighbor)
					loop
				ok
				
				# Calculate tentative g-score
				nCurrentG = This._GetScore(aGScore, cCurrent)
				nTransitionCost = This._CalculateTransitionCost(cCurrent, cNeighbor, @aOptimizeCriteria)
				nTentativeG = nCurrentG + nTransitionCost
				
				# Check if this path is better
				nNeighborG = This._GetScore(aGScore, cNeighbor)
				if nNeighborG = -1 or nTentativeG < nNeighborG
					# Update scores
					This._SetScore(aGScore, cNeighbor, nTentativeG)
					nH = call pHeuristic(@oGraph, cNeighbor, cGoal)
					nF = nTentativeG + nH
					This._SetScore(aFScore, cNeighbor, nF)
					
					# Update parent
					This._SetParent(aParent, cNeighbor, cCurrent)
					
					# Add to open set if not already there
					bInOpen = FALSE
					for aNode in aOpen
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
		
		# No path found
		return new stzPlan([], 0, [], "No path found")
	
	#-----------------------#
	#  GOAL-BASED SEARCH    #
	#-----------------------#
	
	def _GoalSearch(cStart, pGoalFunc)
		# Best-first search until goal condition met
		aOpen = [ [cStart, 0] ]
		aClosedSet = []
		aCostSoFar = [ [cStart, 0] ]
		aParent = []
		
		while len(aOpen) > 0
			# Get node with lowest cost
			nMinIdx = 1
			nMinCost = aOpen[1][2]
			for i = 2 to len(aOpen)
				if aOpen[i][2] < nMinCost
					nMinCost = aOpen[i][2]
					nMinIdx = i
				ok
			next
			
			aCurrent = aOpen[nMinIdx]
			cCurrent = aCurrent[1]
			del(aOpen, nMinIdx)
			
			# Check if goal is reached
			aNode = @oGraph.Node(cCurrent)
			if call pGoalFunc(aNode)
				return This._ReconstructPlan(aParent, cCurrent, aCostSoFar)
			ok
			
			# Add to closed set
			aClosedSet + cCurrent
			
			# Explore neighbors
			acNeighbors = @oGraph.Neighbors(cCurrent)
			for cNeighbor in acNeighbors
				if ring_find(aClosedSet, cNeighbor) > 0
					loop
				ok
				
				if NOT This._RespectConstraints(cCurrent, cNeighbor)
					loop
				ok
				
				nCurrentCost = This._GetScore(aCostSoFar, cCurrent)
				nTransitionCost = This._CalculateTransitionCost(cCurrent, cNeighbor, @aOptimizeCriteria)
				nNewCost = nCurrentCost + nTransitionCost
				
				nNeighborCost = This._GetScore(aCostSoFar, cNeighbor)
				if nNeighborCost = -1 or nNewCost < nNeighborCost
					This._SetScore(aCostSoFar, cNeighbor, nNewCost)
					This._SetParent(aParent, cNeighbor, cCurrent)
					
					bInOpen = FALSE
					for aNode in aOpen
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
		
		return new stzPlan([], 0, [], "No goal state found")
	
	#-----------------------#
	#  HELPER METHODS       #
	#-----------------------#
	
	def _ReconstructPlan(aParent, cGoal, aGScore)
		# Reconstruct path from goal to start
		acPath = [cGoal]
		cCurrent = cGoal
		
		while TRUE
			cParent = This._GetParent(aParent, cCurrent)
			if cParent = NULL
				exit
			ok
			acPath + cParent
			cCurrent = cParent
		end
		
		# Reverse path
		acReversed = []
		for i = len(acPath) to 1 step -1
			acReversed + acPath[i]
		next
		
		# Build action sequence
		aActions = []
		for i = 1 to len(acReversed) - 1
			cFrom = acReversed[i]
			cTo = acReversed[i + 1]
			nCost = This._CalculateTransitionCost(cFrom, cTo, @aOptimizeCriteria)
			aActions + [:from = cFrom, :to = cTo, :cost = nCost]
		next
		
		# Calculate total cost
		nTotalCost = This._GetScore(aGScore, cGoal)
		
		# Generate explanation
		cExplanation = This._GenerateExplanation(aActions)
		
		return new stzPlan(aActions, nTotalCost, acReversed, cExplanation)
	
	def _CalculateTransitionCost(cFrom, cTo, aOptimizeCriteria)
		if len(aOptimizeCriteria) = 0
			return 1  # Default unit cost
		ok
		
		nCost = 0
		for aCriterion in aOptimizeCriteria
			cProperty = aCriterion[:property]
			nWeight = iif(HasKey(aCriterion, :weight), aCriterion[:weight], 1)
			cDirection = aCriterion[:direction]
			
			pValue = @oGraph.EdgeProperty(cFrom, cTo, cProperty)
			if pValue = NULL
				pValue = 1
			ok
			
			if cDirection = "minimize"
				nCost += nWeight * pValue
			else
				nCost -= nWeight * pValue
			ok
		next
		
		return nCost
	
	def _RespectConstraints(cFromNode, cToNode)
		# Check graph constraints if enabled
		if @oGraph.@bEnforceConstraints
			aResult = @oGraph.CheckConstraints([
				:from = cFromNode,
				:to = cToNode
			])
			return aResult[1]
		ok
		
		# Check planning-specific constraints
		for aConstraint in @aConstraints
			if NOT This._CheckConstraint(aConstraint, cFromNode, cToNode)
				return FALSE
			ok
		next
		
		return TRUE
	
	def _CheckConstraint(aConstraint, cFrom, cTo)
		# Placeholder for constraint checking logic
		return TRUE
	
	def _SelectHeuristic(cStart, cGoal)
			# Auto-select heuristic based on graph properties
			aStartNode = @oGraph.Node(cStart)
			aGoalNode = @oGraph.Node(cGoal)
			
			# Check if nodes have x,y coordinates
			if HasKey(aStartNode[:properties], :x) and HasKey(aGoalNode[:properties], :x)
				# Use Euclidean distance - capture graph in closure
				oGraphRef = @oGraph
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
			
			# Default: use simple heuristic (always return 1)
			return func(poGraph, cFrom, cTo) {
				# Simple heuristic: uniform cost
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
		for i = 1 to len(aActions)
			aAction = aActions[i]
			cExplanation += "Step " + i + ": " + aAction[:from] + " -> " + aAction[:to]
			if HasKey(aAction, :cost)
				cExplanation += " (cost: " + aAction[:cost] + ")"
			ok
			cExplanation += NL
		next
		
		return cExplanation
	
	# Score management helpers
	def _GetScore(aScores, cNode)
		for aScore in aScores
			if aScore[1] = cNode
				return aScore[2]
			ok
		next
		return -1
	
	def _SetScore(aScores, cNode, nValue)
		for i = 1 to len(aScores)
			if aScores[i][1] = cNode
				aScores[i][2] = nValue
				return
			ok
		next
		aScores + [cNode, nValue]
	
	def _GetParent(aParent, cNode)
		for aEntry in aParent
			if aEntry[1] = cNode
				return aEntry[2]
			ok
		next
		return NULL
	
	def _SetParent(aParent, cNode, cParentNode)
		for i = 1 to len(aParent)
			if aParent[i][1] = cNode
				aParent[i][2] = cParentNode
				return
			ok
		next
		aParent + [cNode, cParentNode]
	
	#-----------------------#
	#  REACTIVE PLANNING    #
	#-----------------------#
	
	def EnableReactivePlanning()
		@bReactivePlanning = TRUE
	
	def _HandleStateChange(cProperty, pNewValue)
		if NOT @bReactivePlanning or @oCurrentPlan = NULL
			return
		ok
		
		# Check if change affects current plan
		if This._AffectsPlan(cProperty, pNewValue)
			nFirstAffectedStep = This._FindFirstAffectedStep(cProperty)
			This._LocalizedReplan(nFirstAffectedStep)
		ok
	
	def _AffectsPlan(cProperty, pNewValue)
		# Check if property change invalidates plan
		return FALSE  # Placeholder
	
	def _FindFirstAffectedStep(cProperty)
		return 1  # Placeholder
	
	def _LocalizedReplan(nFromStep)
		# Replan from affected step onwards
		# Placeholder implementation
	

#---------------------------#
#  FLUENT REQUEST BUILDER   #
#---------------------------#

class stzPlanningRequest
	@oPlanner
	@cStartNode
	@cGoalNode
	@pGoalFunction
	@aOptimizeCriteria
	@aConstraints
	@aHeuristics
	
	def init(poPlanner)
		@oPlanner = poPlanner
		@cStartNode = NULL
		@cGoalNode = NULL
		@pGoalFunction = NULL
		@aOptimizeCriteria = []
		@aConstraints = []
		@aHeuristics = []
	
	def StartingFrom(pcNodeId)
		@cStartNode = pcNodeId
		return This
	
	def To_(pcNodeId)
		@cGoalNode = pcNodeId
		return This
	
	def ToReach(pGoalFunc)
		@pGoalFunction = pGoalFunc
		return This

		def ToReachF(pGoalFunc)
			return This.ToReach(pGoalFunc)
	
	def Minimizing(pcProperty)
		@aOptimizeCriteria + [
			:property = pcProperty,
			:direction = "minimize",
			:weight = 1
		]
		return This
	
	def Maximizing(pcProperty)
		@aOptimizeCriteria + [
			:property = pcProperty,
			:direction = "maximize",
			:weight = 1
		]
		return This
	
	def Avoiding(paConditions)
		@aConstraints + [:type = "avoid", :conditions = paConditions]
		return This
	
	def WithinBudget(pcProperty, pnMaxValue)
		@aConstraints + [
			:type = "budget",
			:property = pcProperty,
			:maxValue = pnMaxValue
		]
		return This
	
	def WithHeuristic(pHeuristicFunc)
		@aHeuristics + pHeuristicFunc
		return This
	
	def Execute()
		return @oPlanner._ExecutePlan(This)
	
	# Accessors for planner
	def StartNode()
		return @cStartNode
	
	def GoalNode()
		return @cGoalNode
	
	def GoalFunction()
		return @pGoalFunction
	
	def OptimizeCriteria()
		return @aOptimizeCriteria
	
	def Constraints()
		return @aConstraints
	
	def Heuristics()
		return @aHeuristics


#---------------------------#
#  PLAN RESULT OBJECT       #
#---------------------------#

class stzPlan
	@aActions       # Sequence of state transitions
	@nTotalCost     # Cumulative cost
	@aStates        # State at each step
	@cExplanation   # Human-readable plan description
	
	def init(paActions, pnTotalCost, paStates, pcExplanation)
		@aActions = paActions
		@nTotalCost = pnTotalCost
		@aStates = paStates
		@cExplanation = pcExplanation
	
	def Actions()
		return @aActions
	
	def Cost()
		return @nTotalCost
	
	def States()
		return @aStates
	
	def StateAt(pnStep)
		if pnStep < 1 or pnStep > len(@aStates)
			return NULL
		ok
		return @aStates[pnStep]
	
	def Explain()
		return @cExplanation
	
	def Show()
		? "Plan:"
		? "  Total Cost: " + @nTotalCost
		? "  Steps: " + len(@aActions)
		? ""
		? "Actions:"
		for aAction in @aActions
			? "  " + aAction[:from] + " -> " + aAction[:to]
			if HasKey(aAction, :cost)
				? "    Cost: " + aAction[:cost]
			ok
		next
		? ""
		? "Explanation:"
		? @cExplanation
	
	def Execute()
		# Execute plan step by step
		? "Executing plan..."
		for i = 1 to len(@aActions)
			aAction = @aActions[i]
			? "Step " + i + ": " + aAction[:from] + " -> " + aAction[:to]
			# Actual execution logic would go here
		next
		? "Plan execution complete!"
