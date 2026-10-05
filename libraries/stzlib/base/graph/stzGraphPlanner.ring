#============================================#
#  stzGraphPlanner - Enhanced Version
#============================================#

# Plans the cheapest route through a graph under named plans, criteria and profiles, then explains, compares and filters the plans.
#
# A planner takes a copy of a stzGraph when it is built. Each plan has a start and a goal (a node,
# or a function that tests nodes), criteria to minimise or maximise over the edge properties (or a
# profile: fastest, safest, cheapest, shortest, balanced, efficient) and, once executed, a result:
# the actions, their total cost and the route. The search runs in the engine as a uniform-cost
# search, so the route is the cheapest for non-negative costs. Every execution is also kept in a
# history. The comparison, ranking, filtering and history calls work on the executed plans, and
# stzGraphPlanner has a very large set of alternative spellings for the same calls.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "A", [ :x = 0 ]); g1.AddNodeXTT("b", "B",
#              [ :x = 1 ]); g1.AddNodeXTT("c", "C", [ :x = 2 ]); g1.AddEdgeXTT("a", "b", "r", [
#              :distance = 5, :cost = 1 ]); g1.AddEdgeXTT("b", "c", "r", [ :distance = 5, :cost = 9
#              ]); g1.AddEdgeXTT("a", "c", "r", [ :distance = 20, :cost = 2 ]); o1 = new
#              stzGraphPlanner(g1); o1.AddPlan("short"); o1.Walk("a", "c"); o1.Minimize("distance");
#              o1.Execute(); o1.AddPlan("cheap"); o1.Walk("a", "c"); o1.Minimize("cost");
#              o1.Execute()
#   example    ? @@( o1.Route() )
#              #--> [ "a", "c" ]
#   see        stzGraph, stzPlanComparison, stzMultiPlanComparison, stzPlanFilter,
#              stzHistoricalComparison
class stzGraphPlanner from stzObject
	@oGraph
	@aPlans  
	@cCurrentPlan
	@aProfiles  # Predefined optimization profiles

	@aHistory  # Historical plan executions

	# Builds a planner over a graph, taking a copy of it at that moment, with no plan yet and the six named profiles ready.
	#
	#   poGraph    The stzGraph to plan over
	#   returns    nothing; the planner is built
	#   note       anything but a stzGraph raises an error
	#   warning    a node or an edge added to the graph afterwards is not seen by the planner:
	#              Execute then raises, for example, Node 'c' does not exist
	#   see        AddPlan, Profile
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

	# Returns the criteria of a named profile: fastest, safest, cheapest, shortest, balanced or efficient; [ ] for any other name.
	#
	#   _cProfile_   The profile name, as text without a leading colon
	#   returns      a list of hash lists [ :property, :direction, :weight ]; [ ] when unknown
	#   note         the criteria are fastest: time .7 and distance .3; safest: danger .8 and risk
	#                .2; cheapest: cost .8 and distance .2; shortest: distance 1; balanced: time .4,
	#                cost .3, distance .3; efficient: energy .6 and time .4
	#   warning      a name written with a colon such as :fastest finds nothing here, though Using
	#                accepts it
	#   see          Using, AddPlan
	def Profile(_cProfile_)
		_cProfile_ = StzLower(_cProfile_)
		if HasKey(@aProfiles, _cProfile_)
			return @aProfiles[_cProfile_]
		ok
		return []

	#-----------------------#
	#  PLAN MANAGEMENT      #
	#-----------------------#
	
	# Creates an empty plan under a lowercase name and makes it the current plan.
	#
	#   pcPlanName   The plan name, as text
	#   returns      nothing; the planner changes
	#   note         a plan holds a start, a goal, criteria, constraints and, after Execute, a
	#                result; a non-text name raises an error
	#   warning      a name already used is added a second time, and the first plan of that name is
	#                the one every later call finds
	#   see          SetCurrentPlan, Walk, Using
	def AddPlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		pcPlanName = StzLower(pcPlanName)
		@aPlans + [pcPlanName, ["", "", "", [], [], "", [], []]]  # Added slots for explored and alternatives

		This.SetCurrentPlan(pcPlanName)

	# Returns the raw data of a plan: start, goal, goal function, criteria, constraints, result, explored nodes and decision points.
	#
	#   pcPlanName   The plan name, as text
	#   returns      a list of 8 slots
	#   note         the slots are in that order; the result slot is empty text until Execute
	#   warning      an unknown name raises error R2, an index out of range
	#   see          AddPlan, Explain
	def Plan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		pcName = StzLower(pcPlanName)
		return @aPlans[pcPlanName]

	# Makes a plan the current one, the one every call without a plan name works on.
	#
	#   pcPlanName   The plan name, as text
	#   returns      nothing; the planner changes
	#   note         WorkOnPlan is the same call
	#   warning      an unknown name raises Inexistant plan
	#   see          CurrentPlan, AddPlan
	def SetCurrentPlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				stzraise("Incorrect param type! pcPlanName must be a string!")
			ok
		ok

		pcPlanName = StzLower(pcPlanName)

		if NOT HasKey(@aPlans, pcPlanName)
			stzraise("Inexistant plan (" + pcPlanName + ")!")
		ok

		@cCurrentPlan = pcPlanName

		# Makes a plan the current one; another spelling of the current-plan call.
		#
		#   pcPlanName   The plan name, as text
		#   returns      nothing; the planner changes
		#   see          SetCurrentPlan
		def WorkOnPlan(pcPlanName)
			This.SetCurrentPlan(pcPlanName)

	# Returns the name of the current plan, in lowercase; the last plan added or chosen.
	#
	#   returns    text
	#   see        SetCurrentPlan, AddPlan
	def CurrentPlan()
		return @cCurrentPlan

	# Deletes a plan; refused for the only plan, for the current plan and for an unknown name.
	#
	#   pcPlanName   The plan name, as text
	#   returns      nothing; the planner changes
	#   warning      each refusal raises an error, so make another plan current first
	#   see          SetCurrentPlan, AddPlan
	def RemovePlan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				stzraise("Incorrect param type! pcPlanName must be a string!")
			ok
		ok

		pcPlanName = StzLower(pcPlanName)

		if NOT HasKey(@aPlans, pcPlanName)
			stzraise("Inexistant plan (" + pcPlanName + ")!")
		ok

		_nLen_ = len(@aPlans)
		if _nLen_ = 1
			stzraise("Can't remove the only plan we have!")
		ok

		if pcPlanName = This.CurrentPlan()
			stzraise("Can't remove the current plan we are working on! Set another plan as current first.")
		ok

		_n_ = 0
		for i = 1 to _nLen_
			if @aPlans[i][1] = pcPlanName
				_n_ = i
				exit
			ok
		next

		if _n_ > 0
			del(@aPlans, _n_)
		ok

	#----------------------#
	#  CONFIGURING A PLAN  #
	#----------------------#

	# Sets the start and the goal of the current plan; the goal may be a node id or a function that tests a node.
	#
	#   pcFrom     The id of the node to start from
	#   pcTo       The id of the node to reach, or a function that takes a node and says TRUE at a
	#              goal
	#   returns    nothing; the planner changes
	#   note       a goal function goes to ToReachF
	#   warning    the ids are not checked until Execute; with the pairs :From = and :To = the
	#              values are taken from the pairs
	#   see        WalkIn, From, To, Execute
	def Walk(pcFrom, pcTo)
		This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

		# Sets the start and the goal of the current plan; another spelling of the walk call.
		#
		#   pcFrom     The id of the node to start from
		#   pcTo       The id of the node to reach, or a function that takes a node and says TRUE at
		#              a goal
		#   returns    nothing; the planner changes
		#   see        Walk
		def WalkFrom(pcFrom, pcTo)
			This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

		# Sets the start and the goal of the current plan; another spelling of the walk call.
		#
		#   pcFrom     The id of the node to start from
		#   pcTo       The id of the node to reach, or a function that takes a node and says TRUE at
		#              a goal
		#   returns    nothing; the planner changes
		#   see        Walk
		def WalkFromNode(pcFrom, pcTo)
			This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

	def WalkXT(pcPlanName, pcFrom, pcTo)
		if CheckParams()
			if isList(pcFrom) and IsFromOrFromNodeNamedParamList(pcFrom)
				pcFrom = pcFrom[2]
			ok
			if isList(pcTo) and IsToOrToNodeOrUntilReachFNamedParamList(pcTo)
				pcTo = pcTo[2]
			ok
	
			if @IsFunction(pcTo)
				This.FromXT(pcPlanName, pcFrom)
				This.ToReachXTF(pcPlanName, pcTo)
				return
			ok
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][1] = pcFrom
		@aPlans[_nPos_][2][2] = pcTo

		# Sets the start and the goal of a named plan; an unknown plan name raises an error.
		#
		#   pcPlanName   The plan name, as text
		#   pcFrom       The id of the node to start from
		#   pcTo         The id of the node to reach, or a function that takes a node and says TRUE
		#                at a goal
		#   returns      nothing; the planner changes
		#   warning      the ids are not checked until Execute
		#   see          Walk, From, To
		def WalkIn(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

		# Sets the start and the goal of a named plan; another spelling of the walk-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcFrom       The id of the node to start from
		#   pcTo         The id of the node to reach, or a function that takes a node and says TRUE
		#                at a goal
		#   returns      nothing; the planner changes
		#   see          WalkIn
		def WalkInPlan(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

	# Sets the start node of the current plan.
	#
	#   pcFrom     The id of the node to start from
	#   returns    nothing; the planner changes
	#   warning    the id is not checked until Execute, which raises Invalid start node for an
	#              unknown one
	#   see        To, Walk
	def From(pcFrom)
		This.FromXT(This.CurrentPlan(), pcFrom)

		# Sets the start node of the current plan; another spelling of the start call.
		#
		#   pcFrom     The id of the node to start from
		#   returns    nothing; the planner changes
		#   see        From
		def FromNode(pcFrom)
			This.From(pcFrom)

	def FromXT(pcPlanName, pcFrom)
		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][1] = pcFrom

		def FromNodeXT(pcPlanName, pcFrom)
			This.FromXT(pcPlanName, pcFrom)

	# Sets the goal of the current plan: a node id, or a function that tests nodes.
	#
	#   pcTo       The id of the node to reach, or a function that takes a node and says TRUE at a
	#              goal
	#   returns    nothing; the planner changes
	#   warning    a goal node wins over a goal function when both are set
	#   see        From, Walk, ToReachF
	def To(pcTo)
		This.ToXT(This.CurrentPlan(), pcTo)

		# Sets the goal of the current plan; another spelling of the goal call.
		#
		#   pcTo       The id of the node to reach, or a function that takes a node and says TRUE at
		#              a goal
		#   returns    nothing; the planner changes
		#   see        To
		def ToNode(pcTo)
			This.To(pcTo)

	def ToXT(pcPlanName, pcTo)
		if @IsFunction(pcTo)
			This.ToReachFXT(pcPlanName, pcTo)
			return
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][2] = pcTo

		def ToNodeXT(pcPlanName, pcTo)
			This.ToXT(pcPlanName, pcTo)
	
	def ToF(pGoalFunc)
		This.ToFXT(This.CurrentPlan(), pGoalFunc)

		# Sets a goal function on the current plan: the search stops at the first node it accepts, cheapest first.
		#
		#   pGoalFunc   A function that takes a node record and answers TRUE when the goal is
		#               reached
		#   returns     nothing; the planner changes
		#   note        the goal function receives the node as a hash list [ :id, :label,
		#               :properties ]
		#   warning     anything but a function raises an error; if no node is accepted the plan
		#               ends with an empty route and a cost of 0
		#   see         To, ReachF, Execute
		def ToReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		# Sets a goal function on the current plan; another spelling of the goal-function call.
		#
		#   pGoalFunc   A function that takes a node record and answers TRUE when the goal is
		#               reached
		#   returns     nothing; the planner changes
		#   see         ToReachF
		def ReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		# Sets a goal function on the current plan; another spelling of the goal-function call.
		#
		#   pGoalFunc   A function that takes a node record and answers TRUE when the goal is
		#               reached
		#   returns     nothing; the planner changes
		#   see         ToReachF
		def UntilReachF(pGoalFunc)
			This.ToF(pGoalFunc)

		# Sets a goal function on the current plan; another spelling of the goal-function call.
		#
		#   pGoalFunc   A function that takes a node record and answers TRUE when the goal is
		#               reached
		#   returns     nothing; the planner changes
		#   see         ToReachF
		def UntilYouReachF(pGoalFunc)
			This.ToF(pGoalFunc)

	def ToFXT(pcPlanName, pGoalFunc)
		if CheckParams()
			if NOT @IsFunction(pGoalFunc)
				StzRaise("Incorrect param type! pGoalFunc must be a function.")
			ok
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][3] = pGoalFunc

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

		# Sets a goal function on a named plan, so the search for it stops at the first node the function accepts.
		#
		#   pcPlanName   The plan name, as text
		#   pGoalFunc    A function that takes a node record and answers TRUE when the goal is
		#                reached
		#   returns      nothing; the planner changes
		#   warning      an unknown plan name raises Plan not found
		#   see          ToReachF, Execute
		def ToReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		# Sets a goal function on a named plan, so the search for it stops at the first node the function accepts.
		#
		#   pcPlanName   The plan name, as text
		#   pGoalFunc    A function that takes a node record and answers TRUE when the goal is
		#                reached
		#   returns      nothing; the planner changes
		#   warning      an unknown plan name raises Plan not found
		#   see          ToReachF, Execute
		def ReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		# Sets a goal function on a named plan, so the search for it stops at the first node the function accepts.
		#
		#   pcPlanName   The plan name, as text
		#   pGoalFunc    A function that takes a node record and answers TRUE when the goal is
		#                reached
		#   returns      nothing; the planner changes
		#   warning      an unknown plan name raises Plan not found
		#   see          ToReachF, Execute
		def UntilReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

		# Sets a goal function on a named plan, so the search for it stops at the first node the function accepts.
		#
		#   pcPlanName   The plan name, as text
		#   pGoalFunc    A function that takes a node record and answers TRUE when the goal is
		#                reached
		#   returns      nothing; the planner changes
		#   warning      an unknown plan name raises Plan not found
		#   see          ToReachF, Execute
		def UntilYouReachXTF(pcPlanName, pGoalFunc)
			This.ToFXT(pcPlanName, pGoalFunc)

	# Gives the current plan the criteria of a named profile, or a criteria list of your own, replacing the earlier ones.
	#
	#   pProfile   A profile name such as :fastest, :safest, :cheapest, :shortest, :balanced or
	#              :efficient, or a list of criteria hash lists
	#   returns    nothing; the planner changes
	#   note       a profile's criteria use edge properties: every edge must carry them or Execute
	#              raises
	#   warning    an unknown profile name raises Unknown profile; a criterion written by hand
	#              without :weight is searched with weight 1 but shown with an empty weight by
	#              CostBreakdown
	#   see        Profile, Minimize, Execute
	#@ aka  --
	def Using(pProfile)
		This.UsingXT(pProfile, This.CurrentPlan())

		# Gives the current plan the criteria of a named profile; another spelling of the profile call.
		#
		#   pProfile   A profile name such as :fastest, :safest, :cheapest, :shortest, :balanced or
		#              :efficient, or a list of criteria hash lists
		#   returns    nothing; the planner changes
		#   see        Using
		def UsingProfile(pProfile)
			This.UsingXT(pProfile, This.CurrentPlan())

	def UsingXT(pProfile, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and IsInPlanNamedParamList(pcPlanName)
				pcPlanName = pcPlanName[2]
			ok
		ok

		_aProfileCriteria_ = []
		
		if isString(pProfile)
			_cProfile_ = StzLower(pProfile)
			if StzLeft(_cProfile_, 1) = ":"
				_cProfile_ = StzRight(_cProfile_, StzLen(_cProfile_) - 1)
			ok
			_aProfileCriteria_ = This.Profile(_cProfile_)
			if len(_aProfileCriteria_) = 0
				stzraise("Unknown profile: " + pProfile)
			ok
		but isList(pProfile)
			_aProfileCriteria_ = pProfile
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		
		@aPlans[_nPos_][2][4] = _aProfileCriteria_

		def UsingProfileXT(pProfile, pcPlanName)
			This.UsingXT(pProfile, pcPlanName)

	# Adds a criterion that minimises an edge property to the current plan, with weight 1, after the criteria it already has.
	#
	#   pcProperty   The edge property to optimise, as text such as distance, time or cost
	#   returns      nothing; the planner changes
	#   warning      criteria add up: a plan given Using(:fastest) and Minimize("cost") weighs time,
	#                distance and cost; every edge must carry the property or Execute raises
	#   see          Maximize, Using, Execute
	#@ aka  --
	def Minimize(pcProperty)
		This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def Minimise(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def Minimising(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def Minimizing(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def MinimizeFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def MinimiseFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def MinimisingFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

		# Adds a minimising criterion to the current plan; another spelling of the minimise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Minimize
		def MinimizingFor(pcProperty)
			This.MinimizeXT(pcProperty, This.CurrentPlan())

	def MinimizeXT(pcProperty, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and IsInPlanNamedParamList(pcPlanName)
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

	# Adds a criterion that minimises an edge property to a named plan, with weight 1, after its existing criteria.
	#
	#   pcPlanName   The plan name, as text
	#   pcProperty   The edge property to optimise, as text such as distance, time or cost
	#   returns      nothing; the planner changes
	#   warning      an unknown plan name raises Plan not found; every edge must carry the property
	#                or Execute raises
	#   see          Minimize, MaximizeIn
	def MinimizeIn(pcPlanName, pcProperty)
		if CheckParams()
			if isList(pcPlanName) and IsPlanOrInPlanNamedParamList(pcPlanName)
				pcPlanName = pcPlanName[2]
			ok
			if isList(pcProperty) and IsForNamedParamList(pcProperty)
				pcProperty = pcProperty[2]
			ok
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][4] + [:property = pcProperty, :direction = "minimize", :weight = 1]

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimiseIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimizingIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimisingIn(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimizeInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimiseInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimizingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

		# Adds a minimising criterion to a named plan; another spelling of the minimise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MinimizeIn
		def MinimisingInPlan(pcPlanName, pcProperty)
			This.MinimizeIn(pcPlanName, pcProperty)

	# Adds a criterion that maximises an edge property to the current plan, with weight 1, after the criteria it already has.
	#
	#   pcProperty   The edge property to optimise, as text such as distance, time or cost
	#   returns      nothing; the planner changes
	#   warning      a maximised property counts as a negative cost, so the route cost may be
	#                negative and the search, which assumes non-negative costs, is not sure to find
	#                the best route; every edge must carry the property or Execute raises
	#   see          Minimize, MaximizeIn, Execute
	def Maximize(pcProperty)
		This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def Maximise(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def Maximizing(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def Maximising(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def MaximizeFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def MaximiseFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def MaximizingFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

		# Adds a maximising criterion to the current plan; another spelling of the maximise call.
		#
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          Maximize
		def MaximisingFor(pcProperty)
			This.MaximizeXT(pcProperty, This.CurrentPlan())

	def MaximizeXT(pcProperty, pcPlanName)
		if CheckParams()
			if isList(pcPlanName) and IsInPlanNamedParamList(pcPlanName)
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

	# Adds a criterion that maximises an edge property to a named plan, with weight 1, after its existing criteria.
	#
	#   pcPlanName   The plan name, as text
	#   pcProperty   The edge property to optimise, as text such as distance, time or cost
	#   returns      nothing; the planner changes
	#   warning      an unknown plan name raises Plan not found; the cost may be negative
	#   see          Maximize, MinimizeIn
	def MaximizeIn(pcPlanName, pcProperty)
		if CheckParams()
			if isList(pcPlanName) and IsPlanOrInPlanNamedParamList(pcPlanName)
				pcPlanName = pcPlanName[2]
			ok
			if isList(pcProperty) and IsForNamedParamList(pcProperty)
				pcProperty = pcProperty[2]
			ok
		ok

		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		@aPlans[_nPos_][2][4] + [:property = pcProperty, :direction = "maximize", :weight = 1]

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximiseIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximizingIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximisingIn(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximizeInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximiseInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximizingInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

		# Adds a maximising criterion to a named plan; another spelling of the maximise-in call.
		#
		#   pcPlanName   The plan name, as text
		#   pcProperty   The edge property to optimise, as text such as distance, time or cost
		#   returns      nothing; the planner changes
		#   see          MaximizeIn
		def MaximisingInPlan(pcPlanName, pcProperty)
			This.MaximizeIn(pcPlanName, pcProperty)

	# Searches the graph for the cheapest route of the current plan, stores the result and adds the run to the history.
	#
	#   returns    nothing; the planner changes
	#   note       running a plan again repeats the search and adds another history entry; Run,
	#              ExecuteCurrentPlan and RunCurrentPlan are the same call
	#   warning    a node id the graph lacks, or an edge without a property the criteria name,
	#              raises an error whose text shows the unfilled words ' + cProperty + '; a goal
	#              that cannot be reached ends the plan with an empty route and a cost of 0, and
	#              still counts as executed
	#   see        ExecutePlan, Route, Cost, History
	#@ aka  --
	def Execute()
		This.ExecuteXT(This.CurrentPlan())

		# Searches the cheapest route of the current plan; another spelling of the execute call.
		#
		#   returns    nothing; the planner changes
		#   see        Execute
		def Run()
			This.Execute()

		# Searches the cheapest route of the current plan; another spelling of the execute call.
		#
		#   returns    nothing; the planner changes
		#   see        Execute
		def ExecuteCurrentPlan()
			This.Execute()

		# Searches the cheapest route of the current plan; another spelling of the execute call.
		#
		#   returns    nothing; the planner changes
		#   see        Execute
		def RunCurrentPlan()
			This.Execute()

	def ExecuteXT(pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		
		_aPlanData_ = @aPlans[_nPos_][2]
		_cStartNode_ = _aPlanData_[1]
		_cGoalNode_ = _aPlanData_[2]
		pGoalFunc = _aPlanData_[3]
		_aOptimize_ = _aPlanData_[4]
		_aConstraints_ = _aPlanData_[5]
		
		if _cStartNode_ != ""
			_cStartNode_ = StzLower(_cStartNode_)
		ok
		if _cGoalNode_ != ""
			_cGoalNode_ = StzLower(_cGoalNode_)
		ok
		
		if _cStartNode_ = "" or NOT @oGraph.NodeExists(_cStartNode_)
			stzraise("Invalid start node!")
		ok
		
		_aResult_ = ""
		if _cGoalNode_ != ""
			pHeuristic = This._SelectHeuristic(_cStartNode_, _cGoalNode_)
			_aResult_ = This._AStar(_cStartNode_, _cGoalNode_, pHeuristic, _aOptimize_, _aConstraints_)
		but pGoalFunc != ""
			_aResult_ = This._GoalSearch(_cStartNode_, pGoalFunc, _aOptimize_, _aConstraints_)
		else
			stzraise("Either goal node or goal function must be specified!")
		ok
		
		@aPlans[_nPos_][2][6] = _aResult_
		
		# Store in history
		This._AddToHistory(pcPlanName, _aResult_, _aOptimize_)
		
		# Searches the graph for the cheapest route of a named plan, stores the result and adds the run to the history.
		#
		#   pcPlanName   The plan name, as text
		#   returns      nothing; the planner changes
		#   note         an unknown plan name raises Plan not found
		#   warning      a node id the graph lacks, or an edge without a property the criteria name,
		#                raises an error whose text shows the unfilled words ' + cProperty + '; a
		#                goal that cannot be reached ends the plan with an empty route and a cost of
		#                0, and still counts as executed
		#   see          Execute, Route, Cost
		def ExecutePlan(pcPlanName)
			This.ExecuteXT(pcPlanName)

		def RunXT(pcPlanName)
			This.ExecuteXT(pcPlanName)

		# Searches the cheapest route of a named plan; another spelling of the execute-plan call.
		#
		#   pcPlanName   The plan name, as text
		#   returns      nothing; the planner changes
		#   see          ExecutePlan
		def RunPlan(pcPlanName)
			This.ExecuteXT(pcPlanName)

	#-----------------------#
	#  PLAN ACCESSORS       #
	#-----------------------#
	
	# Returns the total cost of the current plan's route, the sum of its weighted step costs.
	#
	#   returns    a number
	#   warning    raises Plan has not been executed before Execute; the cost is 0 when no route was
	#              found
	#   see        CostOf, Route, CostBreakdown
	def Cost()
		return This.CostXT(This.CurrentPlan())

		# Returns the total cost of the current plan's route; another spelling of the cost call.
		#
		#   returns    a number
		#   see        Cost
		def CostOfCurrentPlan()
			return This.CostXT(This.CurrentPlan())

		# Returns the total cost of the current plan's route; another spelling of the cost call.
		#
		#   returns    a number
		#   see        Cost
		def CostInCurrentPlan()
			return This.CostXT(This.CurrentPlan())

	def CostXT(pcPlanName)
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[2]

		# Returns the total cost of a named plan's route.
		#
		#   pcPlanName   The plan name, as text
		#   returns      a number
		#   warning      raises Plan has not been executed before Execute; the pair form accepts :Of
		#                and :OfPlan only, another key such as :Plan raises R21
		#   see          Cost, Route
		def CostOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and IsOfOrOfPlanNamedParamList(pcPlanName)
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

	# Returns the route of the current plan: the node ids from the start to the goal, in order.
	#
	#   returns    a list of node ids, in lowercase; [ ] when no route
	#   warning    raises Plan has not been executed before Execute
	#   see        RouteOf, Actions
	def Route()
		return This.RouteXT(This.CurrentPlan())

		# Returns the route of the current plan as node ids; another spelling of the route call.
		#
		#   returns    a list of node ids
		#   see        Route
		def RouteOfCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		# Returns the route of the current plan as node ids; another spelling of the route call.
		#
		#   returns    a list of node ids
		#   see        Route
		def RouteInCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		# Returns the route of the current plan as node ids; another spelling of the route call.
		#
		#   returns    a list of node ids
		#   see        Route
		#@ aka  --
		def States()
			return This.RouteXT(This.CurrentPlan())

		# Returns the route of the current plan as node ids; another spelling of the route call.
		#
		#   returns    a list of node ids
		#   see        Route
		def StatesOfCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

		# Returns the route of the current plan as node ids; another spelling of the route call.
		#
		#   returns    a list of node ids
		#   see        Route
		def StatesInCurrentPlan()
			return This.RouteXT(This.CurrentPlan())

	def RouteXT(pcPlanName)
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[3]

		# Returns the route of a named plan: the node ids from the start to the goal, in order.
		#
		#   pcPlanName   The plan name, as text
		#   returns      a list of node ids, in lowercase; [ ] when no route
		#   warning      raises Plan has not been executed before Execute
		#   see          Route, ActionsOf
		def RouteOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and IsOfOrOfPlanOrInOrInPlanNamedParamList(pcPlanName)
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


	# Returns the steps of the current plan's route, each with its start, end and weighted cost.
	#
	#   returns    a list of hash lists [ :from, :to, :cost ]
	#   warning    raises Plan has not been executed before Execute
	#   see        ActionsOf, Route, CostBreakdown
	def Actions()
		return This.ActionsXT(This.CurrentPlan())

		# Returns the steps of the current plan's route; another spelling of the actions call.
		#
		#   returns    a list of hash lists [ :from, :to, :cost ]
		#   see        Actions
		def ActionsOfCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

		# Returns the steps of the current plan's route; another spelling of the actions call.
		#
		#   returns    a list of hash lists [ :from, :to, :cost ]
		#   see        Actions
		def ActionsInCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

	def ActionsXT(pcPlanName)
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[1]
	
		def ActionsIn(pcPlanName)
			return This.ActionsXT(pcPlanName)

		# Returns the steps of a named plan's route, each with its start, end and weighted cost.
		#
		#   pcPlanName   The plan name, as text
		#   returns      a list of hash lists [ :from, :to, :cost ]
		#   warning      raises Plan has not been executed before Execute
		#   see          Actions, RouteOf
		def ActionsOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and IsOfOrOfPlanOrInOrInPlanNamedParamList(pcPlanName)
					pcPlanName = pcPlanName[2]
				ok
			ok
			return This.ActionsXT(pcPlanName)

		def ActionsOfPlan(pcPlanName)
			return This.ActionsXT(pcPlanName)

	# Returns a summary of the current plan: its name, steps, total cost, route and the number of steps.
	#
	#   returns    a hash list [ :plan, :actions, :total_cost, :route, :steps ]
	#   warning    raises Plan has not been executed before Execute; steps counts edges, where the
	#              comparison reports count route nodes
	#   see        Why, CostBreakdown, Show
	def Explain()
		return This.ExplainXT(This.CurrentPlan())

		# Returns a summary of the current plan; another spelling of the explain call.
		#
		#   returns    a hash list [ :plan, :actions, :total_cost, :route, :steps ]
		#   see        Explain
		def ExplainCurrentPlan()
			return This.ExplainXT(This.CurrentPlan())

	def ExplainXT(pcPlanName)
		_aResult_ = This._GetResult(pcPlanName)
		return [
			:plan = pcPlanName,
			:actions = _aResult_[1],
			:total_cost = _aResult_[2],
			:route = _aResult_[3],
			:steps = len(_aResult_[1])
		]
	
		def ExplainPlan(pcPlanName)
			return This.ExplainXT(pcPlanName)

	#-----------------------#
	#  EXPLANATION METHODS  #
	#-----------------------#

	# Returns, for each step of the current plan, how each criterion's value and weight add to the step's cost.
	#
	#   returns    a list of hash lists [ :step, :from, :to, :criteria, :total ]
	#   note       each criteria entry holds property, value, weight, direction and contribution;
	#              ExplainCostBreakdown is the same call
	#   warning    raises Plan has not been executed before Execute; a criterion without a weight
	#              shows an empty weight and a contribution of 0
	#   see        Explain, Cost
	def CostBreakdown()
		return This.CostBreakdownXT(This.CurrentPlan())

		def ExplainCostBreakdown()
			return This.CostBreakdown()

	def CostBreakdownXT(pcPlanName)
		_aActions_ = This.ActionsXT(pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		_aOptimize_ = @aPlans[_nPos_][2][4]
		
		_aBreakdown_ = []
		_nLen_ = len(_aActions_)
		for i = 1 to _nLen_
			_aAction_ = _aActions_[i]
			_aStep_ = [
				:step = i,
				:from = _aAction_[:from],
				:to = _aAction_[:to],
				:criteria = []
			]
			
			_nStepTotal_ = 0
			if len(_aOptimize_) > 0
				_nLen2_ = len(_aOptimize_)
				for j = 1 to _nLen2_
					_aCriterion_ = _aOptimize_[j]
					_cProp_ = _aCriterion_[:property]
					_nWeight_ = _aCriterion_[:weight]
					_cDir_ = _aCriterion_[:direction]
					
					pValue = @oGraph.EdgeProperty(_aAction_[:from], _aAction_[:to], _cProp_)
					if pValue = ""
						pValue = 1
					ok
					
					_nContribution_ = 0
					if _cDir_ = "minimize"
						_nContribution_ = _nWeight_ * pValue
					else
						_nContribution_ = -_nWeight_ * pValue
					ok
					
					_nStepTotal_ += _nContribution_
					
					_aStep_[:criteria] + [
						:property = _cProp_,
						:value = pValue,
						:weight = _nWeight_,
						:direction = _cDir_,
						:contribution = _nContribution_
					]
				next
			ok
			
			_aStep_ + [:total = _nStepTotal_]
			_aBreakdown_ + _aStep_
		next
		
		return _aBreakdown_

		def ExplainCostBreakdownXT(pcPlanName)
			return This.CostBreakdownXT(pcPlanName)

	# Returns why the current plan went as it did: its cost, how many nodes the search explored and what it optimised.
	#
	#   cAspect    Any value
	#   returns    a hash list [ :plan, :total_cost, :nodes_explored, :optimized_for, :route ]
	#   note       ExplainWhy is the same call
	#   warning    raises error R2 before Execute; the aspect argument has no effect
	#   see        Explain, Efficiency
	def Why(cAspect)
		return This.WhyXT(cAspect, This.CurrentPlan())

		def ExplainWhy(cAspect)
			return This.Why(cAspect)

	def WhyXT(cAspect, pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		_aPlanData_ = @aPlans[_nPos_][2]
		_aResult_ = _aPlanData_[6]
		_aExplored_ = _aPlanData_[7]
		_aOptimize_ = _aPlanData_[4]
		
		_aCriteria_ = []
		_nLen_ = len(_aOptimize_)
		for i = 1 to _nLen_
			_aCrit_ = _aOptimize_[i]
			_aCriteria_ + [
				:direction = _aCrit_[:direction],
				:property = _aCrit_[:property]
			]
		next
		
		return [
			:plan = pcPlanName,
			:total_cost = _aResult_[2],
			:nodes_explored = len(_aExplored_),
			:optimized_for = _aCriteria_,
			:route = _aResult_[3]
		]

		def ExplainWhyXT(cAspect, pcPlanName)
			return This.WhyXT(cAspect, pcPlanName)

	# Returns the decision points met while searching: each node with several neighbours, with its first neighbour and the option count.
	#
	#   returns    a hash list [ :plan, :decision_points ]
	#   note       ExplainAlternatives is the same call
	#   warning    chosen is the first neighbour listed, not the one the route took; [ ] decision
	#              points before Execute
	#   see        Why, Efficiency
	def Alternatives()
		return This.AlternativesXT(This.CurrentPlan())

		def ExplainAlternatives()
			return This.Alternatives()

	def AlternativesXT(pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		_aPlanData_ = @aPlans[_nPos_][2]
		_aAlternatives_ = _aPlanData_[8]
		
		return [
			:plan = pcPlanName,
			:decision_points = _aAlternatives_
		]

		def ExplainAlternativesXT(pcPlanName)
			return This.ExplainAlternativesXT(pcPlanName)

	# Returns how hard the search worked: nodes explored against route length, with an assessment of the effort.
	#
	#   returns    a hash list [ :plan, :nodes_explored, :path_length, :ratio, :assessment ]
	#   note       the ratio is below 1.5 very efficient, below 2.5 efficient, below 4 moderate;
	#              ExplainEfficiency is the same call
	#   warning    raises error R2 before Execute and R1 divide by zero when the route is empty, for
	#              example when the goal was not reached
	#   see        Why, Alternatives
	def Efficiency()
		return This.ExplainEfficiencyXT(This.CurrentPlan())

		def ExplainEfficiency()
			return This.Efficiency()

	def EfficiencyXT(pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		_aPlanData_ = @aPlans[_nPos_][2]
		_aResult_ = _aPlanData_[6]
		_aExplored_ = _aPlanData_[7]
		
		_nPathLength_ = len(_aResult_[3])
		_nExplored_ = len(_aExplored_)
		_nRatio_ = _nExplored_ / _nPathLength_
		
		_cAssessment_ = ""
		if _nRatio_ < 1.5
			_cAssessment_ = "very efficient"
		but _nRatio_ < 2.5
			_cAssessment_ = "efficient"
		but _nRatio_ < 4
			_cAssessment_ = "moderate"
		else
			_cAssessment_ = "explored many alternatives"
		ok
		
		return [
			:plan = pcPlanName,
			:nodes_explored = _nExplored_,
			:path_length = _nPathLength_,
			:ratio = _nRatio_,
			:assessment = _cAssessment_
		]

		def ExplainEfficiencyXT(pcPlanName)
			return This.EfficiencyXT(pcPlanName)

	#-----------------------#
	#  COMPARISON METHODS   #
	#-----------------------#

	# Compares the current plan with another: routes, where they diverge, both costs and which is cheaper.
	#
	#   pcOtherPlan   The name of the plan to compare with the current one
	#   returns       a hash list [ :plan1, :plan2, :same_path, :route1, :route2, :diverge_at_step,
	#                 :cost1, :cost2, :cheaper ]
	#   note          CompareWith is the same call; CompareToQ gives the comparison object instead
	#   warning       both plans must have been executed or the call raises; a plan that found no
	#                 route has cost 0 and wins as the cheaper
	#   see           Difference, Tradeoffs, WhichIsCheaper
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
			_aResult1_ = This._GetResult(pcPlan1)
			_aResult2_ = This._GetResult(pcPlan2)
		
			return new stzPlanComparison(This, pcPlan1, pcPlan2, _aResult1_, _aResult2_)

			def CompareWithXTQ(pcPlan1, pcPlan2)
				return This.CompareToXTQ(pcPlan1, pcPlan2)

	# Compares the current plan with another; the same answer as the comparison call.
	#
	#   pcOtherPlan   The name of the plan to compare with the current one
	#   returns       a hash list [ :plan1, :plan2, :same_path, :route1, :route2, :diverge_at_step,
	#                 :cost1, :cost2, :cheaper ]
	#   see           CompareTo
	def Difference(pcOtherPlan)
		return This.DifferenceXT(This.CurrentPlan(), pcOtherPlan)

		def DifferenceWith(pcOtherPlan)
			return This.Difference(pcOtherPlan)

		def ExplainDifference(pcOtherPlan)
			return This.Difference(pcOtherPlan)

		def ExplainDifferenceWith(pcOtherPlan)
			return This.Difference(pcOtherPlan)

	def DifferenceXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.Explain()

		def DifferenceWithXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

		def ExplainDifferenceXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

		def ExplainDifferenceWithXT(pcPlan1, pcPlan2)
			return This.DifferenceXT(pcPlan1, pcPlan2)

	# Compares the current plan with another by cost and by route length, with a recommendation.
	#
	#   pcOtherPlan   The name of the plan to compare with the current one
	#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
	#                 :length_difference, :recommendation ]
	#   warning       both plans must have been executed; ties give the winner tie; the length is
	#                 counted in route nodes
	#   see           CompareTo, WhichIsCheaper
	def Tradeoffs(pcOtherPlan)
		return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def TradeoffsOf(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def TradeoffsAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainTradeoffs(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainTradeoffsOf(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainTradeoffsAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		#@ aka  --
		def Compromises(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def CompromisesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def CompromisesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def Compromizes(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def CompromizesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def CompromizesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromises(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromisesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromisesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromizes(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromizesWith(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)

		# Compares the current plan with another by cost and route length; another spelling of the trade-off call.
		#
		#   pcOtherPlan   The name of the plan to compare with the current one
		#   returns       a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
		#                 :length_difference, :recommendation ]
		#   see           Tradeoffs
		def ExplainCompromizesAgainst(pcOtherPlan)
			return This.TradeoffsXT(This.CurrentPlan(), pcOtherPlan)


	def TradeoffsXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.Tradeoffs()

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

	# Returns the cheaper of the current plan and another: a plan name, or both names in a list on a tie.
	#
	#   pcOtherPlan   The name of the plan to compare with the current one
	#   returns       a plan name, or a list of two names
	#   warning       both plans must have been executed
	#   see           CostSaving, CompareTo
	def WhichIsCheaper(pcOtherPlan)
		return This.WhichIsCheaperXT(This.CurrentPlan(), pcOtherPlan)

	def WhichIsCheaperXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.WhichIsCheaper()

	# Returns how much cheaper the cheaper of the current plan and another is, as a positive number.
	#
	#   pcOtherPlan   The name of the plan to compare with the current one
	#   returns       a number, 0 on a tie
	#   warning       both plans must have been executed
	#   see           WhichIsCheaper, Tradeoffs
	def CostSaving(pcOtherPlan)
		return This.CostSavingXT(This.CurrentPlan(), pcOtherPlan)

	def CostSavingXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.CostSaving()

	#---------------------------------#
	#  MULTI-PLAN COMPARISON          #
	#---------------------------------#

	# Compares several executed plans: their costs, route lengths and routes, and the best plan by cost and by route length.
	#
	#   _acPlanNames_   The plan names, as a list of text
	#   returns         a hash list [ :total_plans, :plans, :best_by_cost, :best_by_steps ]
	#   note            CompareAll and CompareMultiple are the same call; the Q forms give the
	#                   comparison object
	#   warning         a plan that does not exist or was not executed is left out without a word,
	#                   while total_plans still counts it; raises when no plan is left; a list of
	#                   lists or a non-list raises
	#   see             RankPlansBy, CompareTo
	def CompareMany(_acPlanNames_)
		return This.CompareManyQ(_acPlanNames_).CompareAll()

		def CompareAll(_acPlanNames_)
			return This.CompareMany(_acPlanNames_)

		def CompareMultiple(_acPlanNames_)
			return This.CompareMany(_acPlanNames_)

		def CompareManyQ(_acPlanNames_)
			if CheckParams()
				if isList(_acPlanNames_) and NOT isList(_acPlanNames_[1])
					# Good - list of plan names
				else
					stzraise("Parameter must be a list of plan names!")
				ok
			ok
		
			_aAllResults_ = []
			_nLen_ = len(_acPlanNames_)
			for i = 1 to _nLen_
				_cPlan_ = _acPlanNames_[i]
				# Check if plan was executed
				_nPos_ = This._FindPlan(_cPlan_)
				if _nPos_ > 0 and @aPlans[_nPos_][2][6] != ""
					_aResult_ = This._GetResult(_cPlan_)
					_aAllResults_ + [_cPlan_, _aResult_]
				ok
			next
		
			return new stzMultiPlanComparison(This, _acPlanNames_, _aAllResults_)
		
			def CompareAllQ(_acPlanNames_)
				return This.CompareManyQ(_acPlanNames_)
	
			def CompareMultipleQ(_acPlanNames_)
				return This.CompareManyQ(_acPlanNames_)

	# Ranks every executed plan by cost or by route length, cheapest first.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        a list of [ plan name, value ] pairs, smallest first
	#   warning        any other word gives every plan the value 0, in the order the plans were
	#                  made; [ ] when no plan was executed
	#   see            CompareMany, BestHistoricalPlan
	def RankPlansBy(_cCriterion_)
		return This.RankPlansByXT(_cCriterion_, :all)

	def RankPlansByXT(_cCriterion_, pPlans)
		_acPlanNames_ = []
		
		if isString(pPlans) and StzLower(pPlans) = "all"
			_nLen_ = len(@aPlans)
			for i = 1 to _nLen_
				_cPlanName_ = @aPlans[i][1]
				# Only include executed plans
				if @aPlans[i][2][6] != ""
					_acPlanNames_ + _cPlanName_
				ok
			next

		but isList(pPlans)
			_acPlanNames_ = pPlans
		ok
	
		if len(_acPlanNames_) = 0
			return []
		ok
	
		_oMultiComp_ = This.CompareMultipleQ(_acPlanNames_)
		return _oMultiComp_.RankBy(_cCriterion_)

	#---------------------------------#
	#  HISTORICAL COMPARISON          #
	#---------------------------------#

	# Returns every execution recorded so far: the plan name, its result, its criteria and a date and time stamp.
	#
	#   returns    a list of [ name, result, criteria, stamp ]
	#   warning    every Execute adds an entry, including a repeat run of the same plan
	#   see        HistoryCount, ClearHistory
	def History()
		return @aHistory

	# Returns how many executions are recorded in the history.
	#
	#   returns    a number
	#   see        History, ClearHistory
	def HistoryCount()
		return len(@aHistory)

		# Returns how many executions are recorded; another spelling of the history-count call.
		#
		#   returns    a number
		#   see        HistoryCount
		def HistorySize()
			return len(@aHistory)

	# Compares the current plan's cost and route length with the history's average and best plan, in one summary.
	#
	#   returns    a hash list [ :current_plan, :cost, :steps, :historical_average_cost,
	#              :historical_average_steps, :observation, :best_historical_plan ]
	#   note       the observation reads better, worse or equal, with the percentage
	#   warning    raises error R13 when the history is empty, since the comparison object it needs
	#              is replaced by a message text; the average includes the current plan's own run
	#   see        HistoricalAverage, BestHistoricalPlan
	def CompareWithHistory()
		return This.CompareWithHistoryXT(This.CurrentPlan())

		def CompareWithHistoryQ()
			return This.CompareWithHistoryXTQ(This.CurrentPlan())
	
	def CompareWithHistoryXT(pcPlanName)
		return This.CompareWithHistoryXTQ(pcPlanName).Explain()

		def CompareWithHistoryXTQ(pcPlanName)
			_aCurrentResult_ = This._GetResult(pcPlanName)
			
			if len(@aHistory) = 0
				return "No historical data available for comparison."
			ok
	
			return new stzHistoricalComparison(This, pcPlanName, _aCurrentResult_, @aHistory)
	
	# Returns the mean cost, or the mean route length in nodes, over every recorded execution; 0 for an empty history.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        a number
	#   warning        any other word gives 0
	#   see            BestHistoricalPlan, History
	def HistoricalAverage(_cCriterion_)
		if len(@aHistory) = 0
			return 0
		ok

		_cCriterion_ = StzLower(_cCriterion_)
		_nSum_ = 0
		_nCount_ = 0

		_nLen_ = len(@aHistory)
		for i = 1 to _nLen_
			_aHistItem_ = @aHistory[i]
			_aResult_ = _aHistItem_[2]
			
			if _cCriterion_ = "cost"
				_nSum_ += _aResult_[2]
				_nCount_++
			but _cCriterion_ = "steps" or _cCriterion_ = "length"
				_nSum_ += len(_aResult_[3])
				_nCount_++
			ok
		next

		if _nCount_ = 0
			return 0
		ok

		return _nSum_ / _nCount_

		def HistoAverage()
			return This.HistoricalAverage()

	# Returns the name of the recorded execution with the smallest cost or route length; empty text for an empty history.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        text
	#   warning        any other word counts every run as 0 and answers the first recorded plan
	#   see            WorstHistoricalPlan, HistoricalAverage
	def BestHistoricalPlan(_cCriterion_)
		if len(@aHistory) = 0
			return ""
		ok

		_cCriterion_ = StzLower(_cCriterion_)
		_cBestPlan_ = ""
		_nBestValue_ = 999999

		_nLen_ = len(@aHistory)
		for i = 1 to _nLen_
			_aHistItem_ = @aHistory[i]
			_cPlanName_ = _aHistItem_[1]
			_aResult_ = _aHistItem_[2]
			
			_nValue_ = 0
			if _cCriterion_ = "cost"
				_nValue_ = _aResult_[2]
			but _cCriterion_ = "steps" or _cCriterion_ = "length"
				_nValue_ = len(_aResult_[3])
			ok

			if _nValue_ < _nBestValue_
				_nBestValue_ = _nValue_
				_cBestPlan_ = _cPlanName_
			ok
		next

		return _cBestPlan_

		def BestHistoPlan(_cCriterion_)
			return This.BestHistoricalPlan(_cCriterion_)

	# Returns the name of the recorded execution with the largest cost or route length; empty text for an empty history.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        text
	#   warning        any other word counts every run as 0 and answers the first recorded plan
	#   see            BestHistoricalPlan, HistoricalAverage
	def WorstHistoricalPlan(_cCriterion_)
		if len(@aHistory) = 0
			return ""
		ok
	
		_cCriterion_ = StzLower(_cCriterion_)
		_cWorstPlan_ = ""
		_nWorstValue_ = -999999
	
		_nLen_ = len(@aHistory)
		for i = 1 to _nLen_
			_aHistItem_ = @aHistory[i]
			_cPlanName_ = _aHistItem_[1]
			_aResult_ = _aHistItem_[2]
			
			_nValue_ = 0
			if _cCriterion_ = "cost"
				_nValue_ = _aResult_[2]
			but _cCriterion_ = "steps" or _cCriterion_ = "length"
				_nValue_ = len(_aResult_[3])
			ok
	
			if _nValue_ > _nWorstValue_
				_nWorstValue_ = _nValue_
				_cWorstPlan_ = _cPlanName_
			ok
		next
	
		return _cWorstPlan_

		def WortsHistoPlan(_cCriterion_)
			return This.WorstHistoricalPlan(_cCriterion_)

	# Empties the history of executions, leaving the plans and their results as they are.
	#
	#   returns    nothing; the planner changes
	#   see        History, HistoryCount
	def ClearHistory()
		@aHistory = []

	#---------------------------------#
	#  CONSTRAINT-BASED FILTERING     #
	#---------------------------------#

	# Returns the names of the plans that meet every constraint: maxcost, mincost, avoid, requires or maxsteps.
	#
	#   paConstraints   A list of pairs such as [ :maxCost = 30, :avoid = "c" ]
	#   returns         a list of plan names
	#   warning         a plan that was not executed never matches; a key it does not know is
	#                   ignored; maxsteps counts route nodes; FilterPlansQ gives the filter object
	#   see             PlansWithin, PlansRequiring, FilterPlansQ
	def FilterPlans(paConstraints)
		return This.FilterPlansQ(paConstraints).Plans()

		def FilterPlansQ(paConstraints)
			_acAllPlans_ = []
			_nLen_ = len(@aPlans)
			for i = 1 to _nLen_
				_acAllPlans_ + @aPlans[i][1]
			next
			
			return This.FilterPlansXTQ(_acAllPlans_, paConstraints)
	
	def FilterPlansXT(_acPlanNames_, paConstraints)
		return This.FilterPlansXTQ(_acPlanNames_, paConstraints).Plans()

		def FilterPlansXTQ(_acPlanNames_, paConstraints)
			_acFiltered_ = []
	
			_nLen_ = len(_acPlanNames_)
			for i = 1 to _nLen_
				_cPlan_ = _acPlanNames_[i]
				
				if This._PlanMeetsConstraints(_cPlan_, paConstraints)
					_acFiltered_ + _cPlan_
				ok
			next
	
			return new stzPlanFilter(This, _acFiltered_, paConstraints)
	
	# Returns the plans whose cost is within a percentage above the cost of a base plan, the base included.
	#
	#   nPercentage   The allowed excess over the base cost, as a number such as 10 for 10 percent
	#   _cBasePlan_   The name of the base plan, or a pair such as :Of = "cheap"
	#   returns       a list of plan names
	#   warning       the base plan must have been executed; PlansWithinQ gives the filter object
	#   see           FilterPlans
	def PlansWithin(nPercentage, _cBasePlan_)
		return This.PlansWithinQ(nPercentage, _cBasePlan_).Plans()

		def PlansWithinQ(nPercentage, _cBasePlan_)
			if CheckParams()
				if isList(_cBasePlan_) and IsOfOrOfPlanNamedParamList(_cBasePlan_)
					_cBasePlan_ = _cBasePlan_[2]
				ok
			ok
	
			_aBaseResult_ = This._GetResult(_cBasePlan_)
			_nBaseCost_ = _aBaseResult_[2]
			_nMaxCost_ = _nBaseCost_ * (1 + nPercentage/100)
	
			return This.FilterPlansQ([ :maxCost = _nMaxCost_ ])

	# Returns the plans whose route does not pass through a node, case ignored.
	#
	#   cNode      The id of the node to avoid
	#   returns    a list of plan names
	#   warning    the name is misspelled and kept as is; PlansThatAvoid raises R14 because it calls
	#              the correctly spelled name, which does not exist
	#   see        PlansRequiring, FilterPlans
	def PlansAvoinding(cNode)
		return This.PlansAvoidingQ(cNode).Plans()

		def PlansThatAvoid(cNode)
			return This.PlansAvoiding(cNode)

		# Returns the filter object holding the plans whose route does not pass through a node.
		#
		#   cNode      The id of the node to avoid
		#   returns    a stzPlanFilter
		#   warning    PlansThatAvoidQ is the same call
		#   see        PlansAvoinding, FilterPlansQ
		def PlansAvoidingQ(cNode)
			return This.FilterPlansQ([ :avoid = cNode ])
	
			def PlansThatAvoidQ(cNode)
				return This.PlansAvoidingQ(cNode)

	# Returns the plans whose route passes through a node, case ignored.
	#
	#   cNode      The id of the node the route must pass through
	#   returns    a list of plan names
	#   warning    PlansThatRequire is the same call; PlansRequiringQ gives the filter object
	#   see        PlansAvoinding, FilterPlans
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

	# Prints the current plan: its cost, step count, each step with its cost and the explanation text.
	#
	#   returns    nothing; text is printed
	#   warning    an unexecuted or unknown plan prints a not found or not executed line instead of
	#              raising
	#              seen in the gallery: Steps counts edges in the summary (2 for a to c to d) while the ranking table counts route nodes (3)
	#   see        ShowPlan, Explain
	def Show()
		This.ShowXT(This.CurrentPlan())

		# Prints the current plan; another spelling of the show call.
		#
		#   returns    nothing; text is printed
		#   see        Show
		def ShowCurrentPlan()
			This.ShowXT(This.CurrentPlan())

	def ShowXT(pcPlanName)
		try
			_aResult_ = This._GetResult(pcPlanName)
			? "Plan: " + pcPlanName
			? "  Total Cost: " + _aResult_[2]
			? "  Steps: " + len(_aResult_[1])
			? ""
			? "Actions:"
			_nLen_ = len(_aResult_[1])
			for i = 1 to _nLen_
				_aAction_ = _aResult_[1][i]
				? "  " + _aAction_[:from] + " -> " + _aAction_[:to]
				if HasKey(_aAction_, :cost)
					? "    Cost: " + _aAction_[:cost]
				ok
			next
			? ""
			? "Explanation:"
			? _aResult_[4]
		catch
			? "Plan '" + pcPlanName + "' not found or not executed."
		done
	
		# Prints a named plan: its cost, step count, each step with its cost and the explanation text.
		#
		#   pcPlanName   The plan name, as text
		#   returns      nothing; text is printed
		#   warning      an unexecuted or unknown plan prints a not found or not executed line
		#                instead of raising
		#   see          Show, Explain
		def ShowPlan(pcPlanName)
			This.ShowXT(pcPlanName)

	#-----------------------#
	#  HELPERS              #
	#-----------------------#
	
	def _FindPlan(pcPlanName)
		pcPlanName = StzLower(pcPlanName)
		_nLen_ = len(@aPlans)
		for i = 1 to _nLen_
			if StzLower(@aPlans[i][1]) = pcPlanName
				return i
			ok
		next
		return 0
	
	def _GetResult(pcPlanName)
		_nPos_ = This._FindPlan(pcPlanName)
		if _nPos_ = 0
			stzraise("Plan not found!")
		ok
		_aResult_ = @aPlans[_nPos_][2][6]
		if _aResult_ = ""
			stzraise("Plan has not been executed!")
		ok
		return _aResult_
	
	#-----------------------#
	#  A* ALGORITHM         #
	#-----------------------#
	
	# A* now runs IN THE ENGINE (stzGraph.AStarPlan -> Zig). The planner's cost
	# model is dynamic (per-optimisation transition costs over Ring-side edge
	# properties), so we first push each edge's effective cost into the engine
	# as its weight, then let the engine do the search. Heuristic mode 0
	# (Dijkstra/UCS) guarantees an optimal path for any non-negative cost --
	# the coordinate heuristic isn't admissible against arbitrary cost units.
	# The engine returns [ route, exploredOrder ] in one search, keeping the
	# explainability metrics (nodes_explored / efficiency) honest. pHeuristic
	# and aConstraints are kept for signature compatibility.
	def _AStar(cStart, cGoal, pHeuristic, _aOptimize_, _aConstraints_)
		# 1) push per-optimisation transition costs as engine edge weights
		_aEdges_ = @oGraph.Edges()
		_nE_ = len(_aEdges_)
		for i = 1 to _nE_
			_cF_ = _aEdges_[i][:from]
			_cT_ = _aEdges_[i][:to]
			@oGraph.SetEdgeWeight(_cF_, _cT_, This._CalculateTransitionCost(_cF_, _cT_, _aOptimize_))
		next

		# 2) engine A* search (mode 0 = Dijkstra/UCS, optimal)
		_aPlan_ = @oGraph.AStarPlan(cStart, cGoal, 0)
		_acRoute_ = _aPlan_[1]
		_aExplored_ = _aPlan_[2]

		# 3) decision points along the explored order (explainability metadata)
		_aAlternatives_ = []
		_nX_ = len(_aExplored_)
		for i = 1 to _nX_
			_aNb_ = @oGraph.Neighbors(_aExplored_[i])
			_nNb_ = len(_aNb_)
			if _nNb_ > 1
				_aAlternatives_ + [:node = _aExplored_[i], :chosen = _aNb_[1], :total_options = _nNb_]
			ok
		next

		if len(_acRoute_) = 0
			This._StoreExplorationData(cStart, cGoal, _aExplored_, _aAlternatives_)
			return [[], 0, [], "No path found"]
		ok

		# 4) reconstruct the planner's action list + total cost from the route
		_aActions_ = []
		_nTotalCost_ = 0
		_nR_ = len(_acRoute_)
		for i = 1 to _nR_ - 1
			_cFrom_ = _acRoute_[i]
			_cTo_ = _acRoute_[i + 1]
			_nTransitionCost_ = This._CalculateTransitionCost(_cFrom_, _cTo_, _aOptimize_)
			_nTotalCost_ += _nTransitionCost_
			_aActions_ + [:from = _cFrom_, :to = _cTo_, :cost = _nTransitionCost_]
		next

		_cExplanation_ = This._GenerateExplanation(_aActions_)

		This._StoreExplorationData(cStart, cGoal, _aExplored_, _aAlternatives_)
		return [_aActions_, _nTotalCost_, _acRoute_, _cExplanation_]
	
	def _GoalSearch(cStart, pGoalFunc, _aOptimize_, _aConstraints_)
		_aOpen_ = [[cStart, 0]]
		_aClosedSet_ = []
		_aCostSoFar_ = [[cStart, 0]]
		_aParent_ = []
		_aExplored_ = []
		_aAlternatives_ = []
		
		while len(_aOpen_) > 0
			_nMinIdx_ = 1
			_nMinCost_ = _aOpen_[1][2]
			_nLen_ = len(_aOpen_)
			for i = 2 to _nLen_
				if _aOpen_[i][2] < _nMinCost_
					_nMinCost_ = _aOpen_[i][2]
					_nMinIdx_ = i
				ok
			next
			
			_cCurrent_ = _aOpen_[_nMinIdx_][1]
			del(_aOpen_, _nMinIdx_)
			
			_aExplored_ + _cCurrent_
			
			_aNode_ = @oGraph.Node(_cCurrent_)
			if call pGoalFunc(_aNode_)
				_aResult_ = This._ReconstructPlan(_aParent_, _cCurrent_, _aCostSoFar_, _aOptimize_)
				This._StoreExplorationData(cStart, _cCurrent_, _aExplored_, _aAlternatives_)
				return _aResult_
			ok
			
			_aClosedSet_ + _cCurrent_
			
			_aNeighbors_ = @oGraph.Neighbors(_cCurrent_)
			_nLen_ = len(_aNeighbors_)
			
			if _nLen_ > 1
				_aAlternatives_ + [:node = _cCurrent_, :chosen = _aNeighbors_[1], :total_options = _nLen_]
			ok
			
			for i = 1 to _nLen_
				_cNeighbor_ = _aNeighbors_[i]
				if StzFindFirst(_cNeighbor_, _aClosedSet_) > 0
					loop
				ok
				
				_nCurrentCost_ = This._GetScore(_aCostSoFar_, _cCurrent_)
				_nTransitionCost_ = This._CalculateTransitionCost(_cCurrent_, _cNeighbor_, _aOptimize_)
				_nNewCost_ = _nCurrentCost_ + _nTransitionCost_
				
				_nNeighborCost_ = This._GetScore(_aCostSoFar_, _cNeighbor_)
				if _nNeighborCost_ = -1 or _nNewCost_ < _nNeighborCost_
					This._SetScore(_aCostSoFar_, _cNeighbor_, _nNewCost_)
					This._SetParent(_aParent_, _cNeighbor_, _cCurrent_)
					
					_bInOpen_ = 0
					_nLen2_ = len(_aOpen_)
					for j = 1 to _nLen2_
						_aNode_ = _aOpen_[j]
						if _aNode_[1] = _cNeighbor_
							_bInOpen_ = 1
							_aNode_[2] = _nNewCost_
							exit
						ok
					next
					
					if NOT _bInOpen_
						_aOpen_ + [_cNeighbor_, _nNewCost_]
					ok
				ok
			next
		end
		
		This._StoreExplorationData(cStart, "", _aExplored_, _aAlternatives_)
		return [[], 0, [], "No goal state found"]

	def _StoreExplorationData(cStart, cGoal, _aExplored_, _aAlternatives_)
		_nPos_ = This._FindPlan(This.CurrentPlan())
		if _nPos_ > 0
			@aPlans[_nPos_][2][7] = _aExplored_
			@aPlans[_nPos_][2][8] = _aAlternatives_
		ok

	def _ReconstructPlan(_aParent_, cGoal, aGScore, _aOptimize_)
	    _acPath_ = [cGoal]
	    _cCurrent_ = cGoal
	    
	    while 1
	        _cParent_ = This._GetParent(_aParent_, _cCurrent_)
	        if _cParent_ = ""
	            exit
	        ok
	        _acPath_ + _cParent_
	        _cCurrent_ = _cParent_
	    end
	    
	    _acReversed_ = []
	    _nLen_ = len(_acPath_)
	    for i = _nLen_ to 1 step -1
	        _acReversed_ + _acPath_[i]
	    next
	    
	    # Get total cost from accumulated g-score (weighted cost from A*)
	    _nTotalCost_ = This._GetScore(aGScore, cGoal)
	    
	    # Build action list with individual transition costs
	    _aActions_ = []
	    _nLen_ = len(_acReversed_)
	    for i = 1 to _nLen_ - 1
	        _cFrom_ = _acReversed_[i]
	        _cTo_ = _acReversed_[i + 1]
	        
	        # Calculate this transition's weighted cost
	        _nTransitionCost_ = This._CalculateTransitionCost(_cFrom_, _cTo_, _aOptimize_)
	        
	        _aActions_ + [:from = _cFrom_, :to = _cTo_, :cost = _nTransitionCost_]
	    next
	    
	    _cExplanation_ = This._GenerateExplanation(_aActions_)
	    
	    return [_aActions_, _nTotalCost_, _acReversed_, _cExplanation_]

	def _CalculateTransitionCost(_cFrom_, _cTo_, _aOptimize_)
		if len(_aOptimize_) = 0
			return 1
		ok
		
		_nCost_ = 0
		_nLen_ = len(_aOptimize_)
		for i = 1 to _nLen_
			_aCriterion_ = _aOptimize_[i]
			_cProperty_ = _aCriterion_[:property]
			_nWeight_ = iif(HasKey(_aCriterion_, :weight), _aCriterion_[:weight], 1)
			_cDirection_ = _aCriterion_[:direction]
			
			pValue = @oGraph.EdgeProperty(_cFrom_, _cTo_, _cProperty_)
			if pValue = ""
				pValue = 1
			ok
			
			if _cDirection_ = "minimize"
				_nCost_ += _nWeight_ * pValue
			else
				_nCost_ -= _nWeight_ * pValue
			ok
		next
		
		return _nCost_
	
	def _SelectHeuristic(cStart, cGoal)
		#WARNING // TODO
		# This method checks for :x property but many examples in 
		# stzGraphPlannerTest.ring file don't define coordinates,
		# falling back to constant heuristic (returns 1).
		# This affects A* efficiency claims.

		_aStartNode_ = @oGraph.Node(cStart)
		_aGoalNode_ = @oGraph.Node(cGoal)
		
		if HasKey(_aStartNode_[:properties], :x) and HasKey(_aGoalNode_[:properties], :x)
			return func(poGraph, _cFrom_, _cTo_) {
				_aFrom_ = poGraph.Node(_cFrom_)
				_aTo_ = poGraph.Node(_cTo_)
				_nX1_ = _aFrom_[:properties][:x]
				_nY1_ = _aFrom_[:properties][:y]
				_nX2_ = _aTo_[:properties][:x]
				_nY2_ = _aTo_[:properties][:y]
				return sqrt(pow(_nX2_-_nX1_, 2) + pow(_nY2_-_nY1_, 2))
			}
		ok
		
		return func(poGraph, _cFrom_, _cTo_) {
			if _cFrom_ = _cTo_
				return 0
			ok
			return 1
		}
	
	def _GenerateExplanation(_aActions_)
		if len(_aActions_) = 0
			return "No actions required"
		ok
		
		_cExplanation_ = ""
		_nLen_ = len(_aActions_)
		for i = 1 to _nLen_
			_aAction_ = _aActions_[i]
			_cExplanation_ += "Step " + i + ": " + _aAction_[:from] + " -> " + _aAction_[:to]
			if HasKey(_aAction_, :cost)
				_cExplanation_ += " (cost: " + _aAction_[:cost] + ")"
			ok
			_cExplanation_ += char(10)
		next
		
		return trim(_cExplanation_)
	
	def _GetScore(aScores, cNode)
		_nLen_ = len(aScores)
		for i = 1 to _nLen_
			_aScore_ = aScores[i]
			if _aScore_[1] = cNode
				return _aScore_[2]
			ok
		next
		return -1
	
	def _SetScore(aScores, cNode, _nValue_)
		_nLen_ = len(aScores)
		for i = 1 to _nLen_
			if aScores[i][1] = cNode
				aScores[i][2] = _nValue_
				return
			ok
		next
		aScores + [cNode, _nValue_]
	
	def _GetParent(_aParent_, cNode)
		_nLen_ = len(_aParent_)
		for i = 1 to _nLen_
			_aEntry_ = _aParent_[i]
			if _aEntry_[1] = cNode
				return _aEntry_[2]
			ok
		next
		return ""
	
	def _SetParent(_aParent_, cNode, cParentNode)
		_nLen_ = len(_aParent_)
		for i = 1 to _nLen_
			if _aParent_[i][1] = cNode
				_aParent_[i][2] = cParentNode
				return
			ok
		next
		_aParent_ + [cNode, cParentNode]

	def _AddToHistory(_cPlanName_, _aResult_, _aOptimize_)
		_cTimestamp_ = date() + " " + time()
		@aHistory + [_cPlanName_, _aResult_, _aOptimize_, _cTimestamp_]

	def _PlanMeetsConstraints(_cPlanName_, paConstraints)
		_aResult_ = []
		try
			_aResult_ = This._GetResult(_cPlanName_)
		catch
			return 0
		done

		_nLen_ = len(paConstraints)
		for i = 1 to _nLen_
			_aConstraint_ = paConstraints[i]
			
			if NOT isList(_aConstraint_)
				loop
			ok
			
			_cKey_ = StzLower(_aConstraint_[1])
			pValue = _aConstraint_[2]
	
			if _cKey_ = "maxcost"
				if _aResult_[2] > pValue
					return 0
				ok
	
			but _cKey_ = "mincost"
				if _aResult_[2] < pValue
					return 0
				ok
	
			but _cKey_ = "avoid"
				_acStates_ = _aResult_[3]
				_cNodeToAvoid_ = StzLower(pValue)
				_nLen3_ = len(_acStates_)
				for k = 1 to _nLen3_
					if StzLower(_acStates_[k]) = _cNodeToAvoid_
						return 0
					ok
				next
	
			but _cKey_ = "requires"
				_acStates_ = _aResult_[3]
				_cRequiredNode_ = StzLower(pValue)
				if StzFindFirst(_cRequiredNode_, _acStates_) = 0
					return 0
				ok
	
			but _cKey_ = "maxsteps"
				if len(_aResult_[3]) > pValue
					return 0
				ok
			ok
		next
	
		return 1

#======================================#
#  stzPlanComparison Helper Class      #
#======================================#

# Compares two executed plans: their routes, costs and lengths, which is cheaper and what each gains.
#
# It is built by stzGraphPlanner.CompareToQ and is the object behind CompareTo, Tradeoffs,
# WhichIsCheaper and CostSaving. The route length is counted in nodes.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "A", [ :x = 0 ]); g1.AddNodeXTT("b", "B",
#              [ :x = 1 ]); g1.AddNodeXTT("c", "C", [ :x = 2 ]); g1.AddEdgeXTT("a", "b", "r", [
#              :distance = 5, :cost = 1 ]); g1.AddEdgeXTT("b", "c", "r", [ :distance = 5, :cost = 9
#              ]); g1.AddEdgeXTT("a", "c", "r", [ :distance = 20, :cost = 2 ]); o1 = new
#              stzGraphPlanner(g1); o1.AddPlan("short"); o1.Walk("a", "c"); o1.Minimize("distance");
#              o1.Execute(); o1.AddPlan("cheap"); o1.Walk("a", "c"); o1.Minimize("cost");
#              o1.Execute(); o2 = o1.CompareToQ("short")
#   example    ? o2.WhichIsCheaper()
#              #--> cheap
#   see        stzGraphPlanner, stzMultiPlanComparison
class stzPlanComparison from stzObject
	@oPlanner
	@cPlan1
	@cPlan2
	@aResult1
	@aResult2

	# Builds a comparison of two executed plans from their names and their results, which the planner supplies.
	#
	#   poPlanner   The stzGraphPlanner the plans belong to
	#   pcPlan1     The name of the first plan
	#   pcPlan2     The name of the second plan
	#   paResult1   The result list of the first plan
	#   paResult2   The result list of the second plan
	#   returns     nothing; the comparison is built
	#   warning     usually reached through stzGraphPlanner.CompareToQ, which fills these in
	#   see         Explain, Tradeoffs
	def init(poPlanner, pcPlan1, pcPlan2, paResult1, paResult2)
		@oPlanner = poPlanner
		@cPlan1 = pcPlan1
		@cPlan2 = pcPlan2
		@aResult1 = paResult1
		@aResult2 = paResult2

	# Returns both routes, where they first differ, both costs and which plan is cheaper.
	#
	#   returns    a hash list [ :plan1, :plan2, :same_path, :route1, :route2, :diverge_at_step,
	#              :cost1, :cost2, :cheaper ]
	#   warning    diverge_at_step is 0 when the routes are the same; cheaper is equal on a tie
	#   see        Tradeoffs, WhichIsCheaper
	def Explain()
		_aStates1_ = @aResult1[3]
		_aStates2_ = @aResult2[3]
		
		_bSamePath_ = (@@(_aStates1_) = @@(_aStates2_))
		_nDivergeStep_ = 0
		
		if NOT _bSamePath_
			_nLen_ = @Min([ len(_aStates1_), len(_aStates2_) ])
			for i = 1 to _nLen_
				if _aStates1_[i] != _aStates2_[i]
					_nDivergeStep_ = i
					exit
				ok
			next
		ok
		
		_cCheaper_ = ""
		if @aResult1[2] < @aResult2[2]
			_cCheaper_ = @cPlan1
		but @aResult1[2] > @aResult2[2]
			_cCheaper_ = @cPlan2
		else
			_cCheaper_ = "equal"
		ok
		
		return [
			:plan1 = @cPlan1,
			:plan2 = @cPlan2,
			:same_path = _bSamePath_,
			:route1 = _aStates1_,
			:route2 = _aStates2_,
			:diverge_at_step = _nDivergeStep_,
			:cost1 = @aResult1[2],
			:cost2 = @aResult2[2],
			:cheaper = _cCheaper_
		]
	
	# Compares the two plans by cost and by route length, and recommends one for cost.
	#
	#   returns    a hash list [ :plan1, :plan2, :cost_winner, :cost_savings, :length_winner,
	#              :length_difference, :recommendation ]
	#   warning    a tie gives the winner tie; the length is counted in route nodes; Compromises and
	#              Compromizes are the same call
	#   see        Explain, WhichIsCheaper
	def Tradeoffs()
		_nCost1_ = @aResult1[2]
		_nCost2_ = @aResult2[2]
		_nLen1_ = len(@aResult1[3])
		_nLen2_ = len(@aResult2[3])
		
		_cCostWinner_ = ""
		_nCostSaving_ = 0
		if _nCost1_ < _nCost2_
			_cCostWinner_ = @cPlan1
			_nCostSaving_ = _nCost2_ - _nCost1_
		but _nCost1_ > _nCost2_
			_cCostWinner_ = @cPlan2
			_nCostSaving_ = _nCost1_ - _nCost2_
		else
			_cCostWinner_ = "tie"
		ok
		
		_cLengthWinner_ = ""
		_nLengthDiff_ = 0
		if _nLen1_ < _nLen2_
			_cLengthWinner_ = @cPlan1
			_nLengthDiff_ = _nLen2_ - _nLen1_
		but _nLen1_ > _nLen2_
			_cLengthWinner_ = @cPlan2
			_nLengthDiff_ = _nLen1_ - _nLen2_
		else
			_cLengthWinner_ = "tie"
		ok
		
		_cRecommendation_ = ""
		if _cCostWinner_ != "tie"
			_cRecommendation_ = "Choose " + _cCostWinner_ + " for cost optimization"
		else
			_cRecommendation_ = "Plans are equivalent in cost"
		ok
		
		return [
			:plan1 = @cPlan1,
			:plan2 = @cPlan2,
			:cost_winner = _cCostWinner_,
			:cost_savings = _nCostSaving_,
			:length_winner = _cLengthWinner_,
			:length_difference = _nLengthDiff_,
			:recommendation = _cRecommendation_
		]

		def Compromises()
			return This.Tradeoffs()

		def Compromizes()
			return This.Tradeoffs()

	# Returns the name of the cheaper plan, or both names in a list when the costs are equal.
	#
	#   returns    a plan name, or a list of two names
	#   warning    Cheaper, WhichIsCheaperPlan and CheaperPlan are the same call
	#   see        CostSaving, Explain
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

	# Returns how much cheaper the cheaper plan is: the absolute difference of the two costs.
	#
	#   returns    a number, 0 on a tie
	#   warning    HowMutchCheaper is the same call
	#   see        WhichIsCheaper, Tradeoffs
	def CostSaving()
		_nDiff_ = abs(@aResult1[2] - @aResult2[2])
		return _nDiff_
		
		def HowMutchCheaper()
			return This.CostSaving()

	# Returns the absolute difference between the two routes' lengths, counted in nodes.
	#
	#   returns    a number
	#   warning    PathLenDiff and PathLengthDiff are the same call
	#   see        Tradeoffs
	def PathLengthDifference()
		return abs(len(@aResult1[3]) - len(@aResult2[3]))

		# Returns the absolute difference between the two routes' lengths; another spelling of the length-difference call.
		#
		#   returns    a number
		#   see        PathLengthDifference
		def PathLenDiff()
			return abs(len(@aResult1[3]) - len(@aResult2[3]))

		# Returns the absolute difference between the two routes' lengths; another spelling of the length-difference call.
		#
		#   returns    a number
		#   see        PathLengthDifference
		def PathLengthDiff()
			return abs(len(@aResult1[3]) - len(@aResult2[3]))

#======================================#
#  stzMultiPlanComparison Class        #
#======================================#

# Compares several executed plans: ranks them by cost or route length and names the best and the worst.
#
# It is built by stzGraphPlanner.CompareManyQ. A plan that was not found or not executed is left out
# of the ranking.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "A", [ :x = 0 ]); g1.AddNodeXTT("b", "B",
#              [ :x = 1 ]); g1.AddNodeXTT("c", "C", [ :x = 2 ]); g1.AddEdgeXTT("a", "b", "r", [
#              :distance = 5, :cost = 1 ]); g1.AddEdgeXTT("b", "c", "r", [ :distance = 5, :cost = 9
#              ]); g1.AddEdgeXTT("a", "c", "r", [ :distance = 20, :cost = 2 ]); o1 = new
#              stzGraphPlanner(g1); o1.AddPlan("short"); o1.Walk("a", "c"); o1.Minimize("distance");
#              o1.Execute(); o1.AddPlan("cheap"); o1.Walk("a", "c"); o1.Minimize("cost");
#              o1.Execute(); o2 = o1.CompareManyQ([ "short", "cheap" ])
#   example    ? o2.BestBy("cost")
#              #--> cheap
#   see        stzGraphPlanner, stzPlanComparison
class stzMultiPlanComparison from stzObject
	@oPlanner
	@acPlanNames
	@aResults

	# Builds a comparison of several executed plans from their names and their [ name, result ] pairs, which the planner supplies.
	#
	#   poPlanner      The stzGraphPlanner the plans belong to
	#   pacPlanNames   The names of the plans asked for, as a list
	#   paResults      The [ plan name, result ] pairs of the plans that were found and executed
	#   returns        nothing; the comparison is built
	#   warning        usually reached through stzGraphPlanner.CompareManyQ
	#   see            RankBy, CompareAll
	def init(poPlanner, pacPlanNames, paResults)
		@oPlanner = poPlanner
		@acPlanNames = pacPlanNames
		@aResults = paResults

	# Ranks the plans by cost or by route length, smallest first.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        a list of [ plan name, value ] pairs
	#   warning        any other word gives every plan the value 0
	#   see            BestBy, RankingTable
	def RankBy(_cCriterion_)
		_cCriterion_ = StzLower(_cCriterion_)
		_aRanking_ = []
		
		_nLen_ = len(@aResults)
		for i = 1 to _nLen_
			_cPlan_ = @aResults[i][1]      # First element of pair
			_aResult_ = @aResults[i][2]    # Second element of pair
			
			_nValue_ = 0
			if _cCriterion_ = "cost"
				_nValue_ = _aResult_[2]
			but _cCriterion_ = "steps" or _cCriterion_ = "length"
				_nValue_ = len(_aResult_[3])
			ok
	
			_aRanking_ + [_cPlan_, _nValue_]
		next
	
		# Sort ascending
		_nLen_ = len(_aRanking_)
		for i = 1 to _nLen_-1
			for j = i+1 to _nLen_
				if _aRanking_[j][2] < _aRanking_[i][2]
					_aTemp_ = _aRanking_[i]
					_aRanking_[i] = _aRanking_[j]
					_aRanking_[j] = _aTemp_
				ok
			next
		next
	
		return _aRanking_

	# Returns a table of the plans ranked by cost, with a header row and the rank, plan, cost and steps of each.
	#
	#   returns    a list of rows, the first being the header
	#   warning    steps counts route nodes
	#   see        ShowRankingTable, RankBy
	def RankingTable()
	
		_aTable_ = []
		
		# Optional header
		_aTable_ + ["Rank", "Plan", "Cost", "Steps"]
		
		_aRankedByCost_ = This.RankBy("cost")
		_nLen_ = len(_aRankedByCost_)
		
		for i = 1 to _nLen_
			
			_cPlan_ = _aRankedByCost_[i][1]
			_nCost_ = _aRankedByCost_[i][2]
			
			# Find steps
			_nSteps_ = 0
			_nLen2_ = len(@aResults)
			for j = 1 to _nLen2_
				if @aResults[j][1] = _cPlan_
					_nSteps_ = len(@aResults[j][2][3])
					exit
				ok
			next
			
			# Add row as pure data
			_aTable_ + [i, _cPlan_, _nCost_, _nSteps_]
			
		next
		
		return _aTable_

	# Prints the ranking table as a boxed table.
	#
	#   returns    nothing; a table is printed
	#   see        RankingTable
	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
	
	# Returns the name of the plan with the smallest value of a criterion; raises an error when no plan was compared.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        text
	#   warning        with a tie the plan listed first wins
	#   see            WorstBy, RankBy
	def BestBy(_cCriterion_)
		_aRanking_ = This.RankBy(_cCriterion_)
		if len(_aRanking_) > 0
			return _aRanking_[1][1]
		ok
		stzraise("No ranks returned by this criterion : " + _cCriterion_ + "!")
	
	# Returns the name of the plan with the largest value of a criterion; raises an error when no plan was compared.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        text
	#   warning        with a tie the plan listed last is the worst
	#   see            BestBy, RankBy
	def WorstBy(_cCriterion_)
		_aRanking_ = This.RankBy(_cCriterion_)
		_nLen_ = len(_aRanking_)
		if _nLen_ > 0
			return _aRanking_[_nLen_][1]
		ok
		stzraise("No ranks returned by this criterion : " + _cCriterion_ + "!")

	# Returns every plan's cost, route length and route, with the best plan by cost and by length.
	#
	#   returns    a hash list [ :total_plans, :plans, :best_by_cost, :best_by_steps ]
	#   warning    total_plans counts the names asked for, even those left out for not being
	#              executed; raises when no plan was compared
	#   see        RankBy, BestBy
	def CompareAll()
		_aAllPlans_ = []
		
		_nLen_ = len(@aResults)
		for i = 1 to _nLen_
			_cPlan_ = @aResults[i][1]
			_aResult_ = @aResults[i][2]
			
			_aAllPlans_ + [
				:plan = _cPlan_,
				:cost = _aResult_[2],
				:steps = len(_aResult_[3]),
				:route = _aResult_[3]
			]
		next
		
		return [
			:total_plans = len(@acPlanNames),
			:plans = _aAllPlans_,
			:best_by_cost = This.BestBy("cost"),
			:best_by_steps = This.BestBy("steps")
		]

#======================================#
#  stzHistoricalComparison Class       #
#======================================#

# Compares an executed plan with the planner's history of executions: its gain over the average cost and the best past plan.
#
# It is built by stzGraphPlanner.CompareWithHistoryQ. The history includes the compared plan's own
# run.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "A", [ :x = 0 ]); g1.AddNodeXTT("b", "B",
#              [ :x = 1 ]); g1.AddNodeXTT("c", "C", [ :x = 2 ]); g1.AddEdgeXTT("a", "b", "r", [
#              :distance = 5, :cost = 1 ]); g1.AddEdgeXTT("b", "c", "r", [ :distance = 5, :cost = 9
#              ]); g1.AddEdgeXTT("a", "c", "r", [ :distance = 20, :cost = 2 ]); o1 = new
#              stzGraphPlanner(g1); o1.AddPlan("short"); o1.Walk("a", "c"); o1.Minimize("distance");
#              o1.Execute(); o1.AddPlan("cheap"); o1.Walk("a", "c"); o1.Minimize("cost");
#              o1.Execute(); o2 = o1.CompareWithHistoryXTQ("short")
#   example    ? o2.IsImprovement()
#              #--> 0
#   see        stzGraphPlanner
class stzHistoricalComparison from stzObject
	@oPlanner
	@cCurrentPlan
	@aCurrentResult
	@aHistory

	# Builds a comparison of a plan's result with the planner's history of executions, which the planner supplies.
	#
	#   poPlanner         The stzGraphPlanner whose history is used
	#   pcCurrentPlan     The name of the plan compared
	#   paCurrentResult   The result list of that plan
	#   paHistory         The history entries of the planner
	#   returns           nothing; the comparison is built
	#   warning           usually reached through stzGraphPlanner.CompareWithHistoryQ
	#   see               Explain, IsImprovement
	def init(poPlanner, pcCurrentPlan, paCurrentResult, paHistory)
		@oPlanner = poPlanner
		@cCurrentPlan = pcCurrentPlan
		@aCurrentResult = paCurrentResult
		@aHistory = paHistory

	# Returns the plan's cost and steps next to the history's averages, an observation in percent and the best past plan.
	#
	#   returns    a hash list [ :current_plan, :cost, :steps, :historical_average_cost,
	#              :historical_average_steps, :observation, :best_historical_plan ]
	#   warning    the history includes the plan's own run, so the average is never fully
	#              independent of it
	#   see        IsImprovement, ImprovementPercentage
	def Explain()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		_nAvgSteps_ = @oPlanner.HistoricalAverage("steps")
		_nCurrentCost_ = @aCurrentResult[2]
		_nCurrentSteps_ = len(@aCurrentResult[3])
		
		_cObservation_ = ""
		_nPercentDiff_ = 0
		
		if _nCurrentCost_ < _nAvgCost_
			_nPercentDiff_ = ((_nAvgCost_ - _nCurrentCost_) / _nAvgCost_) * 100
			_cObservation_ = "✓ Current plan is " + _nPercentDiff_ + "% better than average"
		but _nCurrentCost_ > _nAvgCost_
			_nPercentDiff_ = ((_nCurrentCost_ - _nAvgCost_) / _nAvgCost_) * 100
			_cObservation_ = "✗ Current plan is " + _nPercentDiff_ + "% worse than average"
		else
			_cObservation_ = "= Current plan matches historical average"
		ok
		
		return [
			:current_plan = @cCurrentPlan,
			:cost = _nCurrentCost_,
			:steps = _nCurrentSteps_,
			:historical_average_cost = _nAvgCost_,
			:historical_average_steps = _nAvgSteps_,
			:observation = _cObservation_,
			:best_historical_plan = @oPlanner.BestHistoricalPlan("cost")
		]

	# TRUE if the plan's cost is below the historical average cost.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        Improvement, Explain
	def IsImprovement()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		return @aCurrentResult[2] < _nAvgCost_

	# Returns the plan's gain over the historical average cost as a ratio: positive when cheaper, negative when dearer.
	#
	#   returns    a number
	#   warning    0 when the average is 0; ImprovementRatio is the same call
	#   see        ImprovementPercentage, IsImprovement
	def Improvement()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		if _nAvgCost_ = 0
			return 0
		ok
		return ((_nAvgCost_ - @aCurrentResult[2]) / _nAvgCost_)

		def ImprovementRatio()
			return This.Improvement()

	# Returns the plan's gain over the historical average cost in percent: positive when cheaper, negative when dearer.
	#
	#   returns    a number
	#   warning    0 when the average is 0; Improvement100 is the same call
	#   see        Improvement
	def ImprovementPercentage()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		if _nAvgCost_ = 0
			return 0
		ok
		return ((_nAvgCost_ - @aCurrentResult[2]) / _nAvgCost_) * 100

		def Improvement100()
			return This.ImprovementPercentage()

#======================================#
#  stzPlanFilter Class                 #
#======================================#

# Holds the plans that met a set of constraints, and lists, counts, ranks and prints them.
#
# It is built by stzGraphPlanner.FilterPlansQ, PlansWithinQ, PlansAvoidingQ and PlansRequiringQ. The
# constraints are maxcost, mincost, avoid, requires and maxsteps.
#
#   receiver   g1 = new stzGraph("g1"); g1.AddNodeXTT("a", "A", [ :x = 0 ]); g1.AddNodeXTT("b", "B",
#              [ :x = 1 ]); g1.AddNodeXTT("c", "C", [ :x = 2 ]); g1.AddEdgeXTT("a", "b", "r", [
#              :distance = 5, :cost = 1 ]); g1.AddEdgeXTT("b", "c", "r", [ :distance = 5, :cost = 9
#              ]); g1.AddEdgeXTT("a", "c", "r", [ :distance = 20, :cost = 2 ]); o1 = new
#              stzGraphPlanner(g1); o1.AddPlan("short"); o1.Walk("a", "c"); o1.Minimize("distance");
#              o1.Execute(); o1.AddPlan("cheap"); o1.Walk("a", "c"); o1.Minimize("cost");
#              o1.Execute(); o2 = o1.FilterPlansQ([ :maxCost = 6 ])
#   example    ? @@( o2.Plans() )
#              #--> [ "cheap" ]
#   see        stzGraphPlanner, stzMultiPlanComparison
class stzPlanFilter from stzObject
	@oPlanner
	@acFilteredPlans
	@aConstraints

	# Builds a filter result from the names of the plans that met the constraints and the constraints themselves.
	#
	#   poPlanner       The stzGraphPlanner the plans belong to
	#   pacFiltered     The names of the plans that matched, as a list
	#   paConstraints   The constraints that were applied
	#   returns         nothing; the filter is built
	#   warning         usually reached through stzGraphPlanner.FilterPlansQ
	#   see             Plans, Count
	def init(poPlanner, pacFiltered, paConstraints)
		@oPlanner = poPlanner
		@acFilteredPlans = pacFiltered
		@aConstraints = paConstraints

	# Returns the names of the plans that met the constraints.
	#
	#   returns    a list of plan names
	#   warning    FilteredPlans is the same call
	#   see        Count
	def Plans()
		return @acFilteredPlans

		# Returns the names of the plans that met the constraints; another spelling of the plans call.
		#
		#   returns    a list of plan names
		#   see        Plans
		def FilteredPlans()
			return @acFilteredPlans

	# Returns how many plans met the constraints.
	#
	#   returns    a number
	#   warning    NumberOfPlans, NumberOfFilteredPlans, HowManyPlans and HowManyFilteredPlans are
	#              the same call
	#   see        Plans
	def Count()
		return len(@acFilteredPlans)

		# Returns how many plans met the constraints; another spelling of the count call.
		#
		#   returns    a number
		#   see        Count
		def NumberOfPlans()
			return len(@acFilteredPlans)

		# Returns how many plans met the constraints; another spelling of the count call.
		#
		#   returns    a number
		#   see        Count
		def NumberOfFilteredPlans()
			return len(@acFilteredPlans)

		# Returns how many plans met the constraints; another spelling of the count call.
		#
		#   returns    a number
		#   see        Count
		def HowManyPlans()
			return len(@acFilteredPlans)

		# Returns how many plans met the constraints; another spelling of the count call.
		#
		#   returns    a number
		#   see        Count
		def HowManyFilteredPlans()
			return len(@acFilteredPlans)

	def PlansXT()

		_aDetails_ = []

		_nLen_ = len(@acFilteredPlans)
		for i = 1 to _nLen_
			_cPlan_ = @acFilteredPlans[i]
			_aPlanResult_ = @oPlanner._GetResult(_cPlan_)
			
			_aPlanInfo_ = []
			_aPlanInfo_ + [ "plan", _cPlan_ ]
			_aPlanInfo_ + [ "cost", _aPlanResult_[2] ]
			_aPlanInfo_ + [ "steps", len(_aPlanResult_[3]) ]
			_aPlanInfo_ + [ "route", _aPlanResult_[3] ]

			_aDetails_ + _aPlanInfo_

		next

		_aResult_ = [
			:constrains_applied = @aConstraints,
			:plans_matching_count = len(@acFilteredPlans),
			:plans_matching_details = _aDetails_
		]

		return _aResult_

		def FilteredPlansXT()
			return This.PlansXT()

	# Prints the constraints applied and, for each matching plan, its cost, steps and route, as a nested listing.
	#
	#   returns    nothing; text is printed
	#   warning    the constraints key is spelled constrains_applied in the data
	#   see        Plans
	def Show()
		? @@NL( This.PlansXT() )


	# Returns the matching plan with the smallest value of a criterion; empty text when none matched.
	#
	#   _cCriterion_   cost, or steps or length for the number of route nodes
	#   returns        text
	#   warning        any other word counts every plan as 0
	#   see            RankingTable
	def BestBy(_cCriterion_)
		if len(@acFilteredPlans) = 0
			return ""
		ok

		_oMultiComp_ = @oPlanner.CompareMultipleQ(@acFilteredPlans)
		return _oMultiComp_.BestBy(_cCriterion_)

	# Returns the matching plans as a ranking table with a header; prints a message and returns nothing when none matched.
	#
	#   returns    a list of rows, or nothing
	#   warning    with no match it prints No plans match the filters
	#   see        ShowRankingTable, BestBy
	def RankingTable()
		if len(@acFilteredPlans) = 0
			? "No plans match the filters."
			return
		ok

		_oMultiComp_ = @oPlanner.CompareManyQ(@acFilteredPlans)
		return _oMultiComp_.RankingTable()

	# Prints the ranking table of the matching plans as a boxed table.
	#
	#   returns    nothing; a table is printed
	#   warning    with no matching plan it prints the no-match message, then raises "paTable must
	#              be a list"
	#   see        RankingTable
	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
