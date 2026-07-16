#============================================#
#  stzWorkflow - Business Process Modeling   #
#  Sequential & State Machine workflows      #
#============================================#

$acWorkflowTypes = ["sequential", "statemachine"]
$acWorkflowDefaultValidators = ["deadlock", "reachability", "completeness", "sla", "bottleneck"]

class stzWorkflow from stzDiagram
	@cWorkflowType = "sequential"  # or "statemachine"
	
	# Workflow-specific structures
	@aSteps = []
	@aStates = []
	@aTransitions = []
	@aActors = []
	@aSLAs = []
	
	# Performance tracking
	@aMetrics = []
	@aDurations = []
	@aBottlenecks = []
	
	# Org chart linking
	@oLinkedOrgChart = NULL
	@aRoleAssignments = []

	def init(pcId)
		super.init(pcId)
		super.SetGraphType("flow")

		@acValidators = $acWorkflowDefaultValidators
	
	#-----------------------#
	#  WORKFLOW TYPE        #
	#-----------------------#
	
	def SetWorkflowType(pcType)
		_cType_ = StzLower(pcType)
		if StzFindFirst($acWorkflowTypes, _cType_) > 0
			@cWorkflowType = _cType_
		ok
	
	def WorkflowType()
		return @cWorkflowType
	
	def IsSequential()
		return @cWorkflowType = "sequential"
	
	def IsStateMachine()
		return @cWorkflowType = "statemachine"
	
	#-----------------------#
	#  SEQUENTIAL WORKFLOW  #
	#-----------------------#
	
	def AddStep_(pcId)
		This.AddStepXT(pcId, pcId)
	
	def AddStepXT(pcId, pcLabel)
	    This.AddStepXTT(pcId, pcLabel, [ ["_dummy", ""] ])  # Minimal hashlist
	
	def AddStepXTT(pcId, pcLabel, paProps)
	    # Convert empty list to valid hashlist
	    if isList(paProps) and len(paProps) = 0
	        paProps = [ ["_empty", ""] ]
	    ok
	    
	    _aStep_ = [
	        :id = pcId,
	        :label = pcLabel,
	        :type = "process",
	        :assignedTo = "",
	        :duration = 0,
	        :sla = 0,
	        :properties = paProps
	    ]
	    @aSteps + _aStep_
	    
	    # Filter out dummy key before passing to AddNodeXTT
	    _aNodeProps_ = []
	    _nProps1Len_ = len(paProps)
	    for _iLoopProps1_ = 1 to _nProps1Len_
	    	_aPair_ = paProps[_iLoopProps1_]
	        if _aPair_[1] != "_empty"
	            _aNodeProps_ + _aPair_
	        ok
	    end
	    
	    _aNodeProps_ + ["nodeType", "step"]
	    This.AddNodeXTT(pcId, pcLabel, _aNodeProps_)
	
	def Step_(pcId)
		_nSteps9Len_ = len(@aSteps)
		for _iLoopSteps9_ = 1 to _nSteps9Len_
			_aStep_ = @aSteps[_iLoopSteps9_]
			if _aStep_[:id] = pcId
				return _aStep_
			ok
		end
		return []
	
	def Steps()
		return @aSteps
	
	def ConnectSteps(pcFrom, pcTo)
		This.Connect(pcFrom, pcTo)
	
		def Then(pcFrom, pcTo)
			This.ConnectSteps(pcFrom, pcTo)
	
	#-----------------------#
	#  STATE MACHINE        #
	#-----------------------#
	
	def AddState(pcId)
		This.AddStateXT(pcId, pcId)
	
	def AddStateXT(pcId, pcLabel)
		This.AddStateXTT(pcId, pcLabel, [])
	
	def AddStateXTT(pcId, pcLabel, paProps)

		_aState_ = [
			:id = pcId,
			:label = pcLabel,
			:isInitial = FALSE,
			:isFinal = FALSE,
			:properties = paProps
		]
		@aStates + _aState_
		
		# Add as diagram node
		_cType_ = "state"
		if HasKey(paProps, :isInitial) and paProps[:isInitial]
			_cType_ = "start"
		but HasKey(paProps, :isFinal) and paProps[:isFinal]
			_cType_ = "endpoint"
		ok
		
		paProps + [ "nodetype", "state" ]
		paProps + [ "type", _cType_ ]

		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddTransition(pcFrom, pcTo, pcEvent)
		This.AddTransitionXT(pcFrom, pcTo, pcEvent, "")
	
	def AddTransitionXT(pcFrom, pcTo, pcEvent, pcCondition)
		_aTransition_ = [
			:from = pcFrom,
			:to = pcTo,
			:event = pcEvent,
			:condition = pcCondition
		]
		@aTransitions + _aTransition_
		
		This.AddEdgeXT(pcFrom, pcTo, pcEvent)
	
	def State(pcId)
		_nStates1Len_ = len(@aStates)
		for _iLoopStates1_ = 1 to _nStates1Len_
			_aState_ = @aStates[_iLoopStates1_]
			if _aState_[:id] = pcId
				return _aState_
			ok
		end
		return []
	
	def States()
		return @aStates
	
	def Transitions()
		return @aTransitions
	
	#-----------------------#
	#  ACTORS & ROLES       #
	#-----------------------#
	
	def AddActor(pcId, pcName, pcRole)
		_aActor_ = [
			:id = pcId,
			:name = pcName,
			:role = pcRole
		]
		@aActors + _aActor_
	
	def AssignStepTo(pcStepId, pcActorId)
		_nStepsLen_3 = len(@aSteps)
		for i = 1 to _nStepsLen_3
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:assignedTo] = pcActorId
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "assignedTo", pcActorId)
	
	def Actor(pcId)
		_nActors2Len_ = len(@aActors)
		for _iLoopActors2_ = 1 to _nActors2Len_
			_aActor_ = @aActors[_iLoopActors2_]
			if _aActor_[:id] = pcId
				return _aActor_
			ok
		end
		return []
	
	def Actors()
		return @aActors
	
	#-----------------------#
	#  SLA MANAGEMENT       #
	#-----------------------#
	
	def SetStepSLA(pcStepId, nHours)
		_nStepsLen_2 = len(@aSteps)
		for i = 1 to _nStepsLen_2
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:sla] = nHours
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "sla", nHours)
	
	def SetStepDuration(pcStepId, nHours)
		_nStepsLen_ = len(@aSteps)
		for i = 1 to _nStepsLen_
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:duration] = nHours
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "duration", nHours)
	
	def SLAViolations()
		_acViolations_ = []
		
		_nSteps8Len_ = len(@aSteps)
		for _iLoopSteps8_ = 1 to _nSteps8Len_
			_aStep_ = @aSteps[_iLoopSteps8_]
			if _aStep_[:sla] > 0 and _aStep_[:duration] > _aStep_[:sla]
				_acViolations_ + [
					:step = _aStep_[:id],
					:sla = _aStep_[:sla],
					:actual = _aStep_[:duration],
					:overrun = _aStep_[:duration] - _aStep_[:sla]
				]
			ok
		end
		
		return _acViolations_
	
	#-----------------------#
	#  ORG CHART LINKING    #
	#-----------------------#
	
	def SetOrgChart(poOrgChart)
		@oLinkedOrgChart = poOrgChart
	
	def MapRoleToPosition(pcRole, pcPositionId)
		@aRoleAssignments + [
			:role = pcRole,
			:position = pcPositionId
		]
	
	def GetPositionForStep(pcStepId)
		_aStep_ = This.Step_(pcStepId)
		if len(_aStep_) = 0
			return ""
		ok
		
		_cActorId_ = _aStep_[:assignedTo]
		if _cActorId_ = ""
			return ""
		ok
		
		_aActor_ = This.Actor(_cActorId_)
		if len(_aActor_) = 0
			return ""
		ok
		
		_cRole_ = _aActor_[:role]
		
		_nRoleAssignments1Len_ = len(@aRoleAssignments)
		for _iLoopRoleAssignments1_ = 1 to _nRoleAssignments1Len_
			_aMapping_ = @aRoleAssignments[_iLoopRoleAssignments1_]
			if _aMapping_[:role] = _cRole_
				return _aMapping_[:position]
			ok
		end
		
		return ""
	
	def WorkloadByPosition()
		_aWorkload_ = []
		
		if @oLinkedOrgChart = NULL
			return _aWorkload_
		ok
		
		# Count steps per position
		_nSteps7Len_ = len(@aSteps)
		for _iLoopSteps7_ = 1 to _nSteps7Len_
			_aStep_ = @aSteps[_iLoopSteps7_]
			_cPosition_ = This.GetPositionForStep(_aStep_[:id])
			if _cPosition_ != ""
				_bFound_ = FALSE
				_nWorkloadLen_ = len(_aWorkload_)
				for i = 1 to _nWorkloadLen_
					if _aWorkload_[i][:position] = _cPosition_
						_aWorkload_[i][:stepCount]++
						_aWorkload_[i][:totalDuration] += _aStep_[:duration]
						_bFound_ = TRUE
						exit
					ok
				end
				
				if NOT _bFound_
					_aWorkload_ + [
						:position = _cPosition_,
						:stepCount = 1,
						:totalDuration = _aStep_[:duration]
					]
				ok
			ok
		end
		
		return _aWorkload_
	
	#-----------------------#
	#  PERFORMANCE METRICS  #
	#-----------------------#
	
	def TotalDuration()
		_nTotal_ = 0
		_nSteps6Len_ = len(@aSteps)
		for _iLoopSteps6_ = 1 to _nSteps6Len_
			_aStep_ = @aSteps[_iLoopSteps6_]
			_nTotal_ += _aStep_[:duration]
		end
		return _nTotal_
	
	def CriticalPath()
		# For sequential: longest path from start to end
		# For state machine: longest path to final state
		_acPath_ = []
		_nLongest_ = 0
		
		if This.IsSequential()
			_acAllPaths_ = This.AllPathsFromStartToEnd()
			
			_nAcAllPaths1Len_ = len(_acAllPaths_)
			for _iLoopAcAllPaths1_ = 1 to _nAcAllPaths1Len_
				_acPath_ = _acAllPaths_[_iLoopAcAllPaths1_]
				_nDuration_ = 0
				_nAcPath1Len_ = len(_acPath_)
				for _iLoopAcPath1_ = 1 to _nAcPath1Len_
					_cStepId_ = _acPath_[_iLoopAcPath1_]
					_aStep_ = This.Step_(_cStepId_)
					if len(_aStep_) > 0
						_nDuration_ += _aStep_[:duration]
					ok
				end
				
				if _nDuration_ > _nLongest_
					_nLongest_ = _nDuration_
					_acCriticalPath_ = _acPath_
				ok
			end
		ok
		
		return [
			:path = _acCriticalPath_,
			:duration = _nLongest_
		]
	
	def AllPathsFromStartToEnd()
		_acStarts_ = []
		_acEnds_ = []
		
		# Find start/end nodes
		_nSteps5Len_ = len(@aSteps)
		for _iLoopSteps5_ = 1 to _nSteps5Len_
			_aStep_ = @aSteps[_iLoopSteps5_]
			_cId_ = _aStep_[:id]
			if len(This.Incoming(_cId_)) = 0
				_acStarts_ + _cId_
			ok
			if len(This.Neighbors(_cId_)) = 0
				_acEnds_ + _cId_
			ok
		end
		
		_acAllPaths_ = []
		_nAcStarts1Len_ = len(_acStarts_)
		for _iLoopAcStarts1_ = 1 to _nAcStarts1Len_
			_cStart_ = _acStarts_[_iLoopAcStarts1_]
			_nAcEnds1Len_ = len(_acEnds_)
			for _iLoopAcEnds1_ = 1 to _nAcEnds1Len_
				_cEnd_ = _acEnds_[_iLoopAcEnds1_]
				_acPaths_ = This.PathsXT(_cStart_, _cEnd_)
				_nAcPaths1Len_ = len(_acPaths_)
				for _iLoopAcPaths1_ = 1 to _nAcPaths1Len_
					_acPath_ = _acPaths_[_iLoopAcPaths1_]
					_acAllPaths_ + _acPath_
				end
			end
		end
		
		return _acAllPaths_
	
	def Bottlenecks()
		_acBottlenecks_ = []
		
		_nSteps4Len_ = len(@aSteps)
		for _iLoopSteps4_ = 1 to _nSteps4Len_
			_aStep_ = @aSteps[_iLoopSteps4_]
			_cId_ = _aStep_[:id]
			_nIncoming_ = len(This.Incoming(_cId_))
			_nOutgoing_ = len(This.Neighbors(_cId_))
			
			# High fan-in = bottleneck
			if _nIncoming_ > 2
				_acBottlenecks_ + [
					:step = _cId_,
					:reason = "high fan-in",
					:count = _nIncoming_
				]
			ok
			
			# SLA violation = bottleneck
			if _aStep_[:sla] > 0 and _aStep_[:duration] > _aStep_[:sla]
				_acBottlenecks_ + [
					:step = _cId_,
					:reason = "sla violation",
					:overrun = _aStep_[:duration] - _aStep_[:sla]
				]
			ok
		end
		
		return _acBottlenecks_
	
	#-----------------------#
	#  VALIDATION           #
	#-----------------------#
	
	def ValidateDeadlock()
		# Check for cycles in sequential workflow
		if This.IsSequential()
			if This.CyclicDependencies()
				return [
					:status = "fail",
					:domain = "deadlock",
					:issues = ["Workflow contains cycles"]
				]
			ok
		ok
		
		return [
			:status = "pass",
			:domain = "deadlock",
			:issues = []
		]
	
	def ValidateSLA()
		_acViolations_ = This.SLAViolations()
		
		_aIssues_ = []
		_nAcViolations1Len_ = len(_acViolations_)
		for _iLoopAcViolations1_ = 1 to _nAcViolations1Len_
			_aViolation_ = _acViolations_[_iLoopAcViolations1_]
			_aIssues_ + ("Step " + _aViolation_[:step] + " exceeds SLA by " + _aViolation_[:overrun] + "h")
		end
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "sla",
			:issueCount = len(_aIssues_),
			:issues = _aIssues_,
			:affectedNodes = This._ExtractStepIds(_acViolations_)
		]
	
	def ValidateBottleneck()
		_acBottlenecks_ = This.Bottlenecks()
		
		_aIssues_ = []
		_nAcBottlenecks1Len_ = len(_acBottlenecks_)
		for _iLoopAcBottlenecks1_ = 1 to _nAcBottlenecks1Len_
			_aBottleneck_ = _acBottlenecks_[_iLoopAcBottlenecks1_]
			_aIssues_ + ("Bottleneck at " + _aBottleneck_[:step] + ": " + _aBottleneck_[:reason])
		end
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "bottleneck",
			:issueCount = len(_aIssues_),
			:issues = _aIssues_,
			:affectedNodes = This._ExtractStepIds(_acBottlenecks_)
		]
	
	def _ExtractStepIds(paList)
		_acIds_ = []
		_nList1Len_ = len(paList)
		for _iLoopList1_ = 1 to _nList1Len_
			_aItem_ = paList[_iLoopList1_]
			if HasKey(_aItem_, :step)
				_acIds_ + _aItem_[:step]
			ok
		end
		return _acIds_
	
	def _ValidateSingle(pcValidator)
		switch StzLower(pcValidator)
		on "deadlock"
			return This.ValidateDeadlock()
		on "sla"
			return This.ValidateSLA()
		on "bottleneck"
			return This.ValidateBottleneck()
		other
			return super._ValidateSingle(pcValidator)
		off
	
	#-----------------------#
	#  VISUALIZATION        #
	#-----------------------#
	
	def ViewCriticalPath()
		_aCritical_ = This.CriticalPath()
		This.ApplyFocusTo(_aCritical_[:path])
		This.SetSubtitle("Critical Path (" + _aCritical_[:duration] + "h)")
		This.View()
	
	def ViewBottlenecks()
		_acBottlenecks_ = This.Bottlenecks()
		_acIds_ = This._ExtractStepIds(_acBottlenecks_)
		This.ApplyFocusTo(_acIds_)
		This.SetSubtitle("Bottlenecks (" + len(_acBottlenecks_) + ")")
		This.View()
	
	def ViewSLAViolations()
		_acViolations_ = This.SLAViolations()
		_acIds_ = This._ExtractStepIds(_acViolations_)
		This.ApplyFocusTo(_acIds_)
		This.SetSubtitle("SLA Violations (" + len(_acViolations_) + ")")
		This.View()
	
	def ViewByActor(pcActorId)
		_acSteps_ = []
		_nSteps3Len_ = len(@aSteps)
		for _iLoopSteps3_ = 1 to _nSteps3Len_
			_aStep_ = @aSteps[_iLoopSteps3_]
			if _aStep_[:assignedTo] = pcActorId
				_acSteps_ + _aStep_[:id]
			ok
		end
		
		_aActor_ = This.Actor(pcActorId)
		_cName_ = iif(len(_aActor_) > 0, _aActor_[:name], pcActorId)
		
		This.ApplyFocusTo(_acSteps_)
		This.SetSubtitle("Steps by " + _cName_)
		This.View()
	
	def ViewByRole(pcRole)
		_acSteps_ = []
		_nSteps2Len_ = len(@aSteps)
		for _iLoopSteps2_ = 1 to _nSteps2Len_
			_aStep_ = @aSteps[_iLoopSteps2_]
			if _aStep_[:assignedTo] != ""
				_aActor_ = This.Actor(_aStep_[:assignedTo])
				if len(_aActor_) > 0 and _aActor_[:role] = pcRole
					_acSteps_ + _aStep_[:id]
				ok
			ok
		end
		
		This.ApplyFocusTo(_acSteps_)
		This.SetSubtitle("Steps by role: " + pcRole)
		This.View()
	
	#-----------------------#
	#  EXPORT               #
	#-----------------------#
	
	def ToWorkflow()
		_cResult_ = 'workflow "' + @cId + '"' + NL
		_cResult_ += '    type: ' + @cWorkflowType + NL + NL
		
		if This.IsSequential()
			_cResult_ += 'steps' + NL
			_nSteps1Len_ = len(@aSteps)
			for _iLoopSteps1_ = 1 to _nSteps1Len_
				_aStep_ = @aSteps[_iLoopSteps1_]
				_cResult_ += '    ' + _aStep_[:id] + NL
				_cResult_ += '        label: "' + _aStep_[:label] + '"' + NL
				if _aStep_[:assignedTo] != ""
					_cResult_ += '        assignedTo: ' + _aStep_[:assignedTo] + NL
				ok
				if _aStep_[:duration] > 0
					_cResult_ += '        duration: ' + _aStep_[:duration] + NL
				ok
				if _aStep_[:sla] > 0
					_cResult_ += '        sla: ' + _aStep_[:sla] + NL
				ok
				_cResult_ += NL
			end
			
			_cResult_ += 'flow' + NL
			_aThisEdges1_ = This.Edges()
			_nThisEdges1Len_ = len(_aThisEdges1_)
			for _iLoopThisEdges1_ = 1 to _nThisEdges1Len_
				_aEdge_ = _aThisEdges1_[_iLoopThisEdges1_]
				_cResult_ += '    ' + _aEdge_[:from] + ' -> ' + _aEdge_[:to] + NL
			end
		ok
		
		if len(@aActors) > 0
			_cResult_ += NL + 'actors' + NL
			_nActors1Len_ = len(@aActors)
			for _iLoopActors1_ = 1 to _nActors1Len_
				_aActor_ = @aActors[_iLoopActors1_]
				_cResult_ += '    ' + _aActor_[:id] + NL
				_cResult_ += '        name: "' + _aActor_[:name] + '"' + NL
				_cResult_ += '        role: ' + _aActor_[:role] + NL
				_cResult_ += NL
			end
		ok
		
		return _cResult_


#============================================#
#  Workflow-Specific Rule Bases              #
#============================================#

class stzBPMRuleBase from stzObject
	def init()
		super.init("BPM Best Practices")
		@cDomain = "bpm"
		@cLevel = "workflow"
		This._LoadBPMRules()
	
	def _LoadBPMRules()
		# No orphan steps
		_oRule1_ = new stzGraphRule("bpm_no_orphans")
		_oRule1_ {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Step has no incoming or outgoing connections")
			When("nodeType", "equals", "step")
			ThenViolation("Orphan step detected")
		}
		This.AddRule(_oRule1_)
		
		# Single start point
		_oRule2_ = new stzGraphRule("bpm_single_start")
		_oRule2_ {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Workflow must have exactly one start")
		}
		This.AddRule(_oRule2_)
		
		# Decision nodes need 2+ paths
		_oRule3_ = new stzGraphRule("bpm_decision_branches")
		_oRule3_ {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Decision must have at least 2 outgoing paths")
			When("type", "equals", "decision")
			ThenViolation("Decision has insufficient branches")
		}
		This.AddRule(_oRule3_)
		
		# Steps must be assigned
		_oRule4_ = new stzGraphRule("bpm_assignment_required")
		_oRule4_ {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Step must be assigned to an actor")
			When("assignedTo", "equals", "")
			ThenViolation("Unassigned step")
		}
		This.AddRule(_oRule4_)


class stzSLARuleBase from stzObject
	def init()
		super.init("SLA Compliance")
		@cDomain = "sla"
		@cLevel = "workflow"
		This._LoadSLARules()
	
	def _LoadSLARules()
		# SLA definition required
		_oRule1_ = new stzGraphRule("sla_defined")
		_oRule1_ {
			SetRuleType("validation")
			SetDomain("sla")
			SetMessage("Critical steps must have SLA defined")
			When("critical", "equals", TRUE)
			Then("sla", "greaterthan", 0)
		}
		This.AddRule(_oRule1_)
		
		# Duration within SLA
		_oRule2_ = new stzGraphRule("sla_compliance")
		_oRule2_ {
			SetRuleType("validation")
			SetDomain("sla")
			SetMessage("Step duration exceeds SLA")
		}
		This.AddRule(_oRule2_)


#============================================#
#  Workflow Simulations                      #
#============================================#

class stzWorkflowSimulation from stzObject
	
	def OptimizeStep(pcStepId, nNewDuration)
		@aChanges + [
			:type = "optimize_step",
			:step = pcStepId,
			:newDuration = nNewDuration
		]
	
	def ReassignStep(pcStepId, pcFromActor, pcToActor)
		@aChanges + [
			:type = "reassign_step",
			:step = pcStepId,
			:from = pcFromActor,
			:to = pcToActor
		]
	
	def ParallelizeSteps(pacStepIds)
		@aChanges + [
			:type = "parallelize",
			:steps = pacStepIds
		]
	
	def _ApplyChanges()
		_nChanges1Len_ = len(@aChanges)
		for _iLoopChanges1_ = 1 to _nChanges1Len_
			_aChange_ = @aChanges[_iLoopChanges1_]
			switch _aChange_[:type]
			on "optimize_step"
				@oGraph.SetStepDuration(_aChange_[:step], _aChange_[:newDuration])
				
			on "reassign_step"
				@oGraph.AssignStepTo(_aChange_[:step], _aChange_[:to])
				
			on "parallelize"
				# Complex restructuring logic
				This._ParallelizeSteps(_aChange_[:steps])
			off
		end
	
	def _ParallelizeSteps(pacSteps)
		# Create fork/join pattern
		# Implementation for parallel execution

	#------------------------#
	#  WORKFLOW FILE FORMAT  #
	#------------------------#

	def ImportFlow(pSource)
		if isString(pSource) and StzRight(pSource, 8) = ".stzflow"
			_oParser_ = new stzFlowParser()
			_oLoaded_ = _oParser_.ParseFile(pSource)
		else
			_oParser_ = new stzFlowParser()
			_oLoaded_ = _oParser_.Parse(pSource)
		ok
		
		# Merge loaded workflow
		This._MergeWorkflow(_oLoaded_)
	
		def LoadFlow(pSource)
			This.ImportFlow(pSource)

	def _MergeWorkflow(oOther)
		# Copy steps
		_aOtherSteps1_ = oOther.Steps()
		_nOtherSteps1Len_ = len(_aOtherSteps1_)
		for _iLoopOtherSteps1_ = 1 to _nOtherSteps1Len_
			_aStep_ = _aOtherSteps1_[_iLoopOtherSteps1_]
			This.AddStepXTT(_aStep_[:id], _aStep_[:label], _aStep_[:properties])
			if _aStep_[:duration] > 0
				This.SetStepDuration(_aStep_[:id], _aStep_[:duration])
			ok
			if _aStep_[:sla] > 0
				This.SetStepSLA(_aStep_[:id], _aStep_[:sla])
			ok
		end
		
		# Copy edges
		_aOtherEdges1_ = oOther.Edges()
		_nOtherEdges1Len_ = len(_aOtherEdges1_)
		for _iLoopOtherEdges1_ = 1 to _nOtherEdges1Len_
			_aEdge_ = _aOtherEdges1_[_iLoopOtherEdges1_]
			This.ConnectSteps(_aEdge_[:from], _aEdge_[:to])
		end
		
		# Copy actors
		_aOtherActors1_ = oOther.Actors()
		_nOtherActors1Len_ = len(_aOtherActors1_)
		for _iLoopOtherActors1_ = 1 to _nOtherActors1Len_
			_aActor_ = _aOtherActors1_[_iLoopOtherActors1_]
			This.AddActor(_aActor_[:id], _aActor_[:name], _aActor_[:role])
		end


#============================================#
#  stzFlowParser - *.stzflow Parser          #
#============================================#

class stzFlowParser from stzObject
	def ParseFile(pcFilename)
		_cContent_ = read(pcFilename)
		return This.Parse(_cContent_)
	
	def Parse(pcContent)
		_oWorkflow_ = NULL
		_acLines_ = split(pcContent, NL)
		_cSection_ = ""
		_cCurrentItem_ = ""
		_aCurrentProps_ = []
		
		_nAcLines1Len_ = len(_acLines_)
		for _iLoopAcLines1_ = 1 to _nAcLines1Len_
			_cLine_ = _acLines_[_iLoopAcLines1_]
			_cLine_ = trim(_cLine_)
			
			if _cLine_ = '' or StzLeft(_cLine_, 1) = "#"
				loop
			ok
			
			if StzFindFirst(_cLine_, "workflow ")
				_cId_ = This._ExtractQuoted(_cLine_)
				_oWorkflow_ = new stzWorkflow(_cId_)
			
			but StzFindFirst(_cLine_, "type:")
				_cType_ = This._ExtractValue(_cLine_)
				_oWorkflow_.SetWorkflowType(_cType_)
			
			but _cLine_ = "steps"
				_cSection_ = "steps"
			
			but _cLine_ = "flow"
				_cSection_ = "flow"
			
			but _cLine_ = "actors"
				_cSection_ = "actors"
			
			but _cLine_ = "roles"
				_cSection_ = "roles"
			
			but _cSection_ = "steps"
				if NOT StzFindFirst(_cLine_, ":")
					if _cCurrentItem_ != ""
						This._AddStep(_oWorkflow_, _cCurrentItem_, _aCurrentProps_)
					ok
					_cCurrentItem_ = _cLine_
					_aCurrentProps_ = []
				else
					_aParts_ = split(_cLine_, ":")
					_cKey_ = trim(_aParts_[1])
					_cValue_ = trim(_aParts_[2])
					_aCurrentProps_ + [_cKey_, This._ParseValue(_cValue_)]
				ok
			
			but _cSection_ = "flow" and StzFindFirst(_cLine_, "->")
				_aParts_ = split(_cLine_, "->")
				_oWorkflow_.ConnectSteps(trim(_aParts_[1]), trim(_aParts_[2]))
			
			but _cSection_ = "actors"
				if NOT StzFindFirst(_cLine_, ":")
					if _cCurrentItem_ != ""
						This._AddActor(_oWorkflow_, _cCurrentItem_, _aCurrentProps_)
					ok
					_cCurrentItem_ = _cLine_
					_aCurrentProps_ = []
				else
					_aParts_ = split(_cLine_, ":")
					_aCurrentProps_ + [trim(_aParts_[1]), This._ParseValue(trim(_aParts_[2]))]
				ok
			
			but _cSection_ = "roles" and StzFindFirst(_cLine_, "->")
				_aParts_ = split(_cLine_, "->")
				_oWorkflow_.MapRoleToPosition(trim(_aParts_[1]), trim(_aParts_[2]))
			ok
		end
		
		# Add last items
		if _cSection_ = "steps" and _cCurrentItem_ != ""
			This._AddStep(_oWorkflow_, _cCurrentItem_, _aCurrentProps_)
		ok
		if _cSection_ = "actors" and _cCurrentItem_ != ""
			This._AddActor(_oWorkflow_, _cCurrentItem_, _aCurrentProps_)
		ok
		
		return _oWorkflow_
	
	def _AddStep(_oWorkflow_, pcId, paProps)
		_cLabel_ = pcId
		_nDuration_ = 0
		_nSLA_ = 0
		_cAssigned_ = ""
		
		_nLen_ = len(paProps)
		for i = 1 to _nLen_ step 2
			_cKey_ = paProps[i]
			pValue = paProps[i + 1]
			
			if _cKey_ = "label"
				_cLabel_ = pValue
			but _cKey_ = "duration"
				_nDuration_ = pValue
			but _cKey_ = "sla"
				_nSLA_ = pValue
			but _cKey_ = "assignedto"
				_cAssigned_ = pValue
			ok
		end
		
		_oWorkflow_.AddStepXT(pcId, _cLabel_)
		if _nDuration_ > 0
			_oWorkflow_.SetStepDuration(pcId, _nDuration_)
		ok
		if _nSLA_ > 0
			_oWorkflow_.SetStepSLA(pcId, _nSLA_)
		ok
		if _cAssigned_ != ""
			_oWorkflow_.AssignStepTo(pcId, _cAssigned_)
		ok
	
	def _AddActor(_oWorkflow_, pcId, paProps)
		_cName_ = pcId
		_cRole_ = ""
		
		_nLen_ = len(paProps)
		for i = 1 to _nLen_ step 2
			if paProps[i] = "name"
				_cName_ = paProps[i + 1]
			but paProps[i] = "role"
				_cRole_ = paProps[i + 1]
			ok
		end
		
		_oWorkflow_.AddActor(pcId, _cName_, _cRole_)
	
	def _ParseValue(_cValue_)
		if isdigit(_cValue_)
			return 0 + _cValue_
		ok
		if StzLeft(_cValue_, 1) = '"' and StzRight(_cValue_, 1) = '"'
			return StzMid(_cValue_, 2, StzLen(_cValue_) - 2)
		ok
		return _cValue_
	
	def _ExtractQuoted(_cLine_)
		_nStart_ = StzFindFirst(_cLine_, '"')
		if _nStart_ = 0 return "" ok
		_nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
		_nEnd_ = StzFindFirst(_nEnd_, '"')
		return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)

	def _ExtractValue(_cLine_)
		_nPos_ = StzFindFirst(_cLine_, ":")
		if _nPos_ = 0 return "" ok
		return trim(StzMid(_cLine_, _nPos_ + 1, StzLen(_cLine_) - _nPos_))
