#============================================#
#  stzGraphPlanner - Enhanced Version
#============================================#

class stzGraphPlanner from stzObject
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

	def Profile(_cProfile_)
		_cProfile_ = StzLower(_cProfile_)
		if HasKey(@aProfiles, _cProfile_)
			return @aProfiles[_cProfile_]
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

		pcPlanName = StzLower(pcPlanName)
		@aPlans + [pcPlanName, ["", "", "", [], [], "", [], []]]  # Added slots for explored and alternatives

		This.SetCurrentPlan(pcPlanName)

	def Plan(pcPlanName)
		if CheckParams()
			if NOT isString(pcPlanName)
				StzRaise("Incorrect param type! pcPlanName must be a string.")
			ok
		ok

		pcName = StzLower(pcPlanName)
		return @aPlans[pcPlanName]

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

	def Walk(pcFrom, pcTo)
		This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

		def WalkFrom(pcFrom, pcTo)
			This.WalkXT(This.CurrentPlan(), pcFrom, pcTo)

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

		def WalkIn(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

		def WalkInPlan(pcPlanName, pcFrom, pcTo)
			This.WalkXT(pcPlanName, pcFrom, pcTo)

	def From(pcFrom)
		This.FromXT(This.CurrentPlan(), pcFrom)

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

	def To(pcTo)
		This.ToXT(This.CurrentPlan(), pcTo)

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
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[2]

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
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[3]

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


	def Actions()
		return This.ActionsXT(This.CurrentPlan())

		def ActionsOfCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

		def ActionsInCurrentPlan()
			return This.ActionsXT(This.CurrentPlan())

	def ActionsXT(pcPlanName)
		_aResult_ = This._GetResult(pcPlanName)
		return _aResult_[1]
	
		def ActionsIn(pcPlanName)
			return This.ActionsXT(pcPlanName)

		def ActionsOf(pcPlanName)
			if CheckParams()
				if isList(pcPlanName) and IsOfOrOfPlanOrInOrInPlanNamedParamList(pcPlanName)
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

	def WhichIsCheaper(pcOtherPlan)
		return This.WhichIsCheaperXT(This.CurrentPlan(), pcOtherPlan)

	def WhichIsCheaperXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.WhichIsCheaper()

	def CostSaving(pcOtherPlan)
		return This.CostSavingXT(This.CurrentPlan(), pcOtherPlan)

	def CostSavingXT(pcPlan1, pcPlan2)
		_oComp_ = This.CompareToXTQ(pcPlan1, pcPlan2)
		return _oComp_.CostSaving()

	#---------------------------------#
	#  MULTI-PLAN COMPARISON          #
	#---------------------------------#

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
			_aCurrentResult_ = This._GetResult(pcPlanName)
			
			if len(@aHistory) = 0
				return "No historical data available for comparison."
			ok
	
			return new stzHistoricalComparison(This, pcPlanName, _aCurrentResult_, @aHistory)
	
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

	def ClearHistory()
		@aHistory = []

	#---------------------------------#
	#  CONSTRAINT-BASED FILTERING     #
	#---------------------------------#

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
					
					_bInOpen_ = FALSE
					_nLen2_ = len(_aOpen_)
					for j = 1 to _nLen2_
						_aNode_ = _aOpen_[j]
						if _aNode_[1] = _cNeighbor_
							_bInOpen_ = TRUE
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
	    
	    while TRUE
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
			_cExplanation_ += NL
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
			return FALSE
		done
? @@NL(paConstraints)	
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
					return FALSE
				ok
	
			but _cKey_ = "mincost"
				if _aResult_[2] < pValue
					return FALSE
				ok
	
			but _cKey_ = "avoid"
				_acStates_ = _aResult_[3]
				_cNodeToAvoid_ = StzLower(pValue)
				_nLen3_ = len(_acStates_)
				for k = 1 to _nLen3_
					if StzLower(_acStates_[k]) = _cNodeToAvoid_
						return FALSE
					ok
				next
	
			but _cKey_ = "requires"
				_acStates_ = _aResult_[3]
				_cRequiredNode_ = StzLower(pValue)
				if StzFindFirst(_cRequiredNode_, _acStates_) = 0
					return FALSE
				ok
	
			but _cKey_ = "maxsteps"
				if len(_aResult_[3]) > pValue
					return FALSE
				ok
			ok
		next
	
		return TRUE

#======================================#
#  stzPlanComparison Helper Class      #
#======================================#

class stzPlanComparison from stzObject
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
		_nDiff_ = abs(@aResult1[2] - @aResult2[2])
		return _nDiff_
		
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

class stzMultiPlanComparison from stzObject
	@oPlanner
	@acPlanNames
	@aResults

	def init(poPlanner, pacPlanNames, paResults)
		@oPlanner = poPlanner
		@acPlanNames = pacPlanNames
		@aResults = paResults

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

	def RankingTable()
	
		_aTable_ = []
		
		# Optional header
		add(_aTable_, ["Rank", "Plan", "Cost", "Steps"])
		
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
			add(_aTable_, [i, _cPlan_, _nCost_, _nSteps_])
			
		next
		
		return _aTable_

	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
	
	def BestBy(_cCriterion_)
		_aRanking_ = This.RankBy(_cCriterion_)
		if len(_aRanking_) > 0
			return _aRanking_[1][1]
		ok
		stzraise("No ranks returned by this criterion : " + _cCriterion_ + "!")
	
	def WorstBy(_cCriterion_)
		_aRanking_ = This.RankBy(_cCriterion_)
		_nLen_ = len(_aRanking_)
		if _nLen_ > 0
			return _aRanking_[_nLen_][1]
		ok
		stzraise("No ranks returned by this criterion : " + _cCriterion_ + "!")

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

class stzHistoricalComparison from stzObject
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

	def IsImprovement()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		return @aCurrentResult[2] < _nAvgCost_

	def Improvement()
		_nAvgCost_ = @oPlanner.HistoricalAverage("cost")
		if _nAvgCost_ = 0
			return 0
		ok
		return ((_nAvgCost_ - @aCurrentResult[2]) / _nAvgCost_)

		def ImprovementRatio()
			return This.Improvement()

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

class stzPlanFilter from stzObject
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

	def Show()
		? @@NL( This.PlansXT() )


	def BestBy(_cCriterion_)
		if len(@acFilteredPlans) = 0
			return ""
		ok

		_oMultiComp_ = @oPlanner.CompareMultipleQ(@acFilteredPlans)
		return _oMultiComp_.BestBy(_cCriterion_)

	def RankingTable()
		if len(@acFilteredPlans) = 0
			? "No plans match the filters."
			return
		ok

		_oMultiComp_ = @oPlanner.CompareManyQ(@acFilteredPlans)
		return _oMultiComp_.RankingTable()

	def ShowRankingTable()
		StzTableQ(This.RankingTable()).Show()
