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
		@acValidators = $acWorkflowDefaultValidators
	
	#-----------------------#
	#  WORKFLOW TYPE        #
	#-----------------------#
	
	def SetWorkflowType(pcType)
		cType = lower(pcType)
		if ring_find($acWorkflowTypes, cType) > 0
			@cWorkflowType = cType
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
	    
	    aStep = [
	        :id = pcId,
	        :label = pcLabel,
	        :type = "process",
	        :assignedTo = "",
	        :duration = 0,
	        :sla = 0,
	        :properties = paProps
	    ]
	    @aSteps + aStep
	    
	    # Filter out dummy key before passing to AddNodeXTT
	    aNodeProps = []
	    for aPair in paProps
	        if aPair[1] != "_empty"
	            aNodeProps + aPair
	        ok
	    end
	    
	    aNodeProps + ["nodeType", "step"]
	    This.AddNodeXTT(pcId, pcLabel, aNodeProps)
	
	def Step_(pcId)
		for aStep in @aSteps
			if aStep[:id] = pcId
				return aStep
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

		aState = [
			:id = pcId,
			:label = pcLabel,
			:isInitial = FALSE,
			:isFinal = FALSE,
			:properties = paProps
		]
		@aStates + aState
		
		# Add as diagram node
		cType = "state"
		if HasKey(paProps, :isInitial) and paProps[:isInitial]
			cType = "start"
		but HasKey(paProps, :isFinal) and paProps[:isFinal]
			cType = "endpoint"
		ok
		
		paProps + [ "nodetype", "state" ]
		paProps + [ "type", cType ]

		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddTransition(pcFrom, pcTo, pcEvent)
		This.AddTransitionXT(pcFrom, pcTo, pcEvent, "")
	
	def AddTransitionXT(pcFrom, pcTo, pcEvent, pcCondition)
		aTransition = [
			:from = pcFrom,
			:to = pcTo,
			:event = pcEvent,
			:condition = pcCondition
		]
		@aTransitions + aTransition
		
		This.AddEdgeXT(pcFrom, pcTo, pcEvent)
	
	def State(pcId)
		for aState in @aStates
			if aState[:id] = pcId
				return aState
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
		aActor = [
			:id = pcId,
			:name = pcName,
			:role = pcRole
		]
		@aActors + aActor
	
	def AssignStepTo(pcStepId, pcActorId)
		for i = 1 to len(@aSteps)
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:assignedTo] = pcActorId
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "assignedTo", pcActorId)
	
	def Actor(pcId)
		for aActor in @aActors
			if aActor[:id] = pcId
				return aActor
			ok
		end
		return []
	
	def Actors()
		return @aActors
	
	#-----------------------#
	#  SLA MANAGEMENT       #
	#-----------------------#
	
	def SetStepSLA(pcStepId, nHours)
		for i = 1 to len(@aSteps)
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:sla] = nHours
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "sla", nHours)
	
	def SetStepDuration(pcStepId, nHours)
		for i = 1 to len(@aSteps)
			if @aSteps[i][:id] = pcStepId
				@aSteps[i][:duration] = nHours
				exit
			ok
		end
		
		This.SetNodeProperty(pcStepId, "duration", nHours)
	
	def SLAViolations()
		acViolations = []
		
		for aStep in @aSteps
			if aStep[:sla] > 0 and aStep[:duration] > aStep[:sla]
				acViolations + [
					:step = aStep[:id],
					:sla = aStep[:sla],
					:actual = aStep[:duration],
					:overrun = aStep[:duration] - aStep[:sla]
				]
			ok
		end
		
		return acViolations
	
	#-----------------------#
	#  ORG CHART LINKING    #
	#-----------------------#
	
	def LinkOrgChart(poOrgChart)
		@oLinkedOrgChart = poOrgChart
	
	def MapRoleToPosition(pcRole, pcPositionId)
		@aRoleAssignments + [
			:role = pcRole,
			:position = pcPositionId
		]
	
	def GetPositionForStep(pcStepId)
		aStep = This.Step_(pcStepId)
		if len(aStep) = 0
			return ""
		ok
		
		cActorId = aStep[:assignedTo]
		if cActorId = ""
			return ""
		ok
		
		aActor = This.Actor(cActorId)
		if len(aActor) = 0
			return ""
		ok
		
		cRole = aActor[:role]
		
		for aMapping in @aRoleAssignments
			if aMapping[:role] = cRole
				return aMapping[:position]
			ok
		end
		
		return ""
	
	def WorkloadByPosition()
		aWorkload = []
		
		if @oLinkedOrgChart = NULL
			return aWorkload
		ok
		
		# Count steps per position
		for aStep in @aSteps
			cPosition = This.GetPositionForStep(aStep[:id])
			if cPosition != ""
				bFound = FALSE
				for i = 1 to len(aWorkload)
					if aWorkload[i][:position] = cPosition
						aWorkload[i][:stepCount]++
						aWorkload[i][:totalDuration] += aStep[:duration]
						bFound = TRUE
						exit
					ok
				end
				
				if NOT bFound
					aWorkload + [
						:position = cPosition,
						:stepCount = 1,
						:totalDuration = aStep[:duration]
					]
				ok
			ok
		end
		
		return aWorkload
	
	#-----------------------#
	#  PERFORMANCE METRICS  #
	#-----------------------#
	
	def TotalDuration()
		nTotal = 0
		for aStep in @aSteps
			nTotal += aStep[:duration]
		end
		return nTotal
	
	def CriticalPath()
		# For sequential: longest path from start to end
		# For state machine: longest path to final state
		acPath = []
		nLongest = 0
		
		if This.IsSequential()
			acAllPaths = This.AllPathsFromStartToEnd()
			
			for acPath in acAllPaths
				nDuration = 0
				for cStepId in acPath
					aStep = This.Step_(cStepId)
					if len(aStep) > 0
						nDuration += aStep[:duration]
					ok
				end
				
				if nDuration > nLongest
					nLongest = nDuration
					acCriticalPath = acPath
				ok
			end
		ok
		
		return [
			:path = acCriticalPath,
			:duration = nLongest
		]
	
	def AllPathsFromStartToEnd()
		acStarts = []
		acEnds = []
		
		# Find start/end nodes
		for aStep in @aSteps
			cId = aStep[:id]
			if len(This.Incoming(cId)) = 0
				acStarts + cId
			ok
			if len(This.Neighbors(cId)) = 0
				acEnds + cId
			ok
		end
		
		acAllPaths = []
		for cStart in acStarts
			for cEnd in acEnds
				acPaths = This.FindAllPaths(cStart, cEnd)
				for acPath in acPaths
					acAllPaths + acPath
				end
			end
		end
		
		return acAllPaths
	
	def Bottlenecks()
		acBottlenecks = []
		
		for aStep in @aSteps
			cId = aStep[:id]
			nIncoming = len(This.Incoming(cId))
			nOutgoing = len(This.Neighbors(cId))
			
			# High fan-in = bottleneck
			if nIncoming > 2
				acBottlenecks + [
					:step = cId,
					:reason = "high fan-in",
					:count = nIncoming
				]
			ok
			
			# SLA violation = bottleneck
			if aStep[:sla] > 0 and aStep[:duration] > aStep[:sla]
				acBottlenecks + [
					:step = cId,
					:reason = "sla violation",
					:overrun = aStep[:duration] - aStep[:sla]
				]
			ok
		end
		
		return acBottlenecks
	
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
		acViolations = This.SLAViolations()
		
		aIssues = []
		for aViolation in acViolations
			aIssues + ("Step " + aViolation[:step] + " exceeds SLA by " + aViolation[:overrun] + "h")
		end
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "sla",
			:issueCount = len(aIssues),
			:issues = aIssues,
			:affectedNodes = This._ExtractStepIds(acViolations)
		]
	
	def ValidateBottleneck()
		acBottlenecks = This.Bottlenecks()
		
		aIssues = []
		for aBottleneck in acBottlenecks
			aIssues + ("Bottleneck at " + aBottleneck[:step] + ": " + aBottleneck[:reason])
		end
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "bottleneck",
			:issueCount = len(aIssues),
			:issues = aIssues,
			:affectedNodes = This._ExtractStepIds(acBottlenecks)
		]
	
	def _ExtractStepIds(paList)
		acIds = []
		for aItem in paList
			if HasKey(aItem, :step)
				acIds + aItem[:step]
			ok
		end
		return acIds
	
	def _ValidateSingle(pcValidator)
		switch lower(pcValidator)
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
		aCritical = This.CriticalPath()
		This.ApplyFocusTo(aCritical[:path])
		This.SetSubtitle("Critical Path (" + aCritical[:duration] + "h)")
		This.View()
	
	def ViewBottlenecks()
		acBottlenecks = This.Bottlenecks()
		acIds = This._ExtractStepIds(acBottlenecks)
		This.ApplyFocusTo(acIds)
		This.SetSubtitle("Bottlenecks (" + len(acBottlenecks) + ")")
		This.View()
	
	def ViewSLAViolations()
		acViolations = This.SLAViolations()
		acIds = This._ExtractStepIds(acViolations)
		This.ApplyFocusTo(acIds)
		This.SetSubtitle("SLA Violations (" + len(acViolations) + ")")
		This.View()
	
	def ViewByActor(pcActorId)
		acSteps = []
		for aStep in @aSteps
			if aStep[:assignedTo] = pcActorId
				acSteps + aStep[:id]
			ok
		end
		
		aActor = This.Actor(pcActorId)
		cName = iif(len(aActor) > 0, aActor[:name], pcActorId)
		
		This.ApplyFocusTo(acSteps)
		This.SetSubtitle("Steps by " + cName)
		This.View()
	
	def ViewByRole(pcRole)
		acSteps = []
		for aStep in @aSteps
			if aStep[:assignedTo] != ""
				aActor = This.Actor(aStep[:assignedTo])
				if len(aActor) > 0 and aActor[:role] = pcRole
					acSteps + aStep[:id]
				ok
			ok
		end
		
		This.ApplyFocusTo(acSteps)
		This.SetSubtitle("Steps by role: " + pcRole)
		This.View()
	
	#-----------------------#
	#  EXPORT               #
	#-----------------------#
	
	def ToWorkflow()
		cResult = 'workflow "' + @cId + '"' + NL
		cResult += '    type: ' + @cWorkflowType + NL + NL
		
		if This.IsSequential()
			cResult += 'steps' + NL
			for aStep in @aSteps
				cResult += '    ' + aStep[:id] + NL
				cResult += '        label: "' + aStep[:label] + '"' + NL
				if aStep[:assignedTo] != ""
					cResult += '        assignedTo: ' + aStep[:assignedTo] + NL
				ok
				if aStep[:duration] > 0
					cResult += '        duration: ' + aStep[:duration] + NL
				ok
				if aStep[:sla] > 0
					cResult += '        sla: ' + aStep[:sla] + NL
				ok
				cResult += NL
			end
			
			cResult += 'flow' + NL
			for aEdge in This.Edges()
				cResult += '    ' + aEdge[:from] + ' -> ' + aEdge[:to] + NL
			end
		ok
		
		if len(@aActors) > 0
			cResult += NL + 'actors' + NL
			for aActor in @aActors
				cResult += '    ' + aActor[:id] + NL
				cResult += '        name: "' + aActor[:name] + '"' + NL
				cResult += '        role: ' + aActor[:role] + NL
				cResult += NL
			end
		ok
		
		return cResult


#============================================#
#  Workflow-Specific Rule Bases              #
#============================================#

class stzBPMRuleBase from stzGraphRuleBase
	def init()
		super.init("BPM Best Practices")
		@cDomain = "bpm"
		@cLevel = "workflow"
		This._LoadBPMRules()
	
	def _LoadBPMRules()
		# No orphan steps
		oRule1 = new stzGraphRule("bpm_no_orphans")
		oRule1 {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Step has no incoming or outgoing connections")
			When("nodeType", "equals", "step")
			ThenViolation("Orphan step detected")
		}
		This.AddRule(oRule1)
		
		# Single start point
		oRule2 = new stzGraphRule("bpm_single_start")
		oRule2 {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Workflow must have exactly one start")
		}
		This.AddRule(oRule2)
		
		# Decision nodes need 2+ paths
		oRule3 = new stzGraphRule("bpm_decision_branches")
		oRule3 {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Decision must have at least 2 outgoing paths")
			When("type", "equals", "decision")
			ThenViolation("Decision has insufficient branches")
		}
		This.AddRule(oRule3)
		
		# Steps must be assigned
		oRule4 = new stzGraphRule("bpm_assignment_required")
		oRule4 {
			SetRuleType("validation")
			SetDomain("bpm")
			SetMessage("Step must be assigned to an actor")
			When("assignedTo", "equals", "")
			ThenViolation("Unassigned step")
		}
		This.AddRule(oRule4)


class stzSLARuleBase from stzGraphRuleBase
	def init()
		super.init("SLA Compliance")
		@cDomain = "sla"
		@cLevel = "workflow"
		This._LoadSLARules()
	
	def _LoadSLARules()
		# SLA definition required
		oRule1 = new stzGraphRule("sla_defined")
		oRule1 {
			SetRuleType("validation")
			SetDomain("sla")
			SetMessage("Critical steps must have SLA defined")
			When("critical", "equals", TRUE)
			Then("sla", "greaterthan", 0)
		}
		This.AddRule(oRule1)
		
		# Duration within SLA
		oRule2 = new stzGraphRule("sla_compliance")
		oRule2 {
			SetRuleType("validation")
			SetDomain("sla")
			SetMessage("Step duration exceeds SLA")
		}
		This.AddRule(oRule2)


#============================================#
#  Workflow Simulations                      #
#============================================#

class stzWorkflowSimulation from stzGraphSimulation
	
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
		for aChange in @aChanges
			switch aChange[:type]
			on "optimize_step"
				@oGraph.SetStepDuration(aChange[:step], aChange[:newDuration])
				
			on "reassign_step"
				@oGraph.AssignStepTo(aChange[:step], aChange[:to])
				
			on "parallelize"
				# Complex restructuring logic
				This._ParallelizeSteps(aChange[:steps])
			off
		end
	
	def _ParallelizeSteps(pacSteps)
		# Create fork/join pattern
		# Implementation for parallel execution

	#------------------------#
	#  WORKFLOW FILE FORMAT  #
	#------------------------#

	def ImportFlow(pSource)
		if isString(pSource) and right(pSource, 8) = ".stzflow"
			oParser = new stzFlowParser()
			oLoaded = oParser.ParseFile(pSource)
		else
			oParser = new stzFlowParser()
			oLoaded = oParser.Parse(pSource)
		ok
		
		# Merge loaded workflow
		This._MergeWorkflow(oLoaded)
	
		def LoadFlow(pSource)
			This.ImportFlow(pSource)

	def _MergeWorkflow(oOther)
		# Copy steps
		for aStep in oOther.Steps()
			This.AddStepXTT(aStep[:id], aStep[:label], aStep[:properties])
			if aStep[:duration] > 0
				This.SetStepDuration(aStep[:id], aStep[:duration])
			ok
			if aStep[:sla] > 0
				This.SetStepSLA(aStep[:id], aStep[:sla])
			ok
		end
		
		# Copy edges
		for aEdge in oOther.Edges()
			This.ConnectSteps(aEdge[:from], aEdge[:to])
		end
		
		# Copy actors
		for aActor in oOther.Actors()
			This.AddActor(aActor[:id], aActor[:name], aActor[:role])
		end


#============================================#
#  stzFlowParser - *.stzflow Parser          #
#============================================#

class stzFlowParser
	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		oWorkflow = NULL
		acLines = split(pcContent, NL)
		cSection = ""
		cCurrentItem = ""
		aCurrentProps = []
		
		for cLine in acLines
			cLine = trim(cLine)
			
			if cLine = '' or left(cLine, 1) = "#"
				loop
			ok
			
			if substr(cLine, "workflow ")
				cId = This._ExtractQuoted(cLine)
				oWorkflow = new stzWorkflow(cId)
			
			but substr(cLine, "type:")
				cType = This._ExtractValue(cLine)
				oWorkflow.SetWorkflowType(cType)
			
			but cLine = "steps"
				cSection = "steps"
			
			but cLine = "flow"
				cSection = "flow"
			
			but cLine = "actors"
				cSection = "actors"
			
			but cLine = "roles"
				cSection = "roles"
			
			but cSection = "steps"
				if NOT substr(cLine, ":")
					if cCurrentItem != ""
						This._AddStep(oWorkflow, cCurrentItem, aCurrentProps)
					ok
					cCurrentItem = cLine
					aCurrentProps = []
				else
					aParts = split(cLine, ":")
					cKey = trim(aParts[1])
					cValue = trim(aParts[2])
					aCurrentProps + [cKey, This._ParseValue(cValue)]
				ok
			
			but cSection = "flow" and substr(cLine, "->")
				aParts = split(cLine, "->")
				oWorkflow.ConnectSteps(trim(aParts[1]), trim(aParts[2]))
			
			but cSection = "actors"
				if NOT substr(cLine, ":")
					if cCurrentItem != ""
						This._AddActor(oWorkflow, cCurrentItem, aCurrentProps)
					ok
					cCurrentItem = cLine
					aCurrentProps = []
				else
					aParts = split(cLine, ":")
					aCurrentProps + [trim(aParts[1]), This._ParseValue(trim(aParts[2]))]
				ok
			
			but cSection = "roles" and substr(cLine, "->")
				aParts = split(cLine, "->")
				oWorkflow.MapRoleToPosition(trim(aParts[1]), trim(aParts[2]))
			ok
		end
		
		# Add last items
		if cSection = "steps" and cCurrentItem != ""
			This._AddStep(oWorkflow, cCurrentItem, aCurrentProps)
		ok
		if cSection = "actors" and cCurrentItem != ""
			This._AddActor(oWorkflow, cCurrentItem, aCurrentProps)
		ok
		
		return oWorkflow
	
	def _AddStep(oWorkflow, pcId, paProps)
		cLabel = pcId
		nDuration = 0
		nSLA = 0
		cAssigned = ""
		
		nLen = len(paProps)
		for i = 1 to nLen step 2
			cKey = paProps[i]
			pValue = paProps[i + 1]
			
			if cKey = "label"
				cLabel = pValue
			but cKey = "duration"
				nDuration = pValue
			but cKey = "sla"
				nSLA = pValue
			but cKey = "assignedto"
				cAssigned = pValue
			ok
		end
		
		oWorkflow.AddStepXT(pcId, cLabel)
		if nDuration > 0
			oWorkflow.SetStepDuration(pcId, nDuration)
		ok
		if nSLA > 0
			oWorkflow.SetStepSLA(pcId, nSLA)
		ok
		if cAssigned != ""
			oWorkflow.AssignStepTo(pcId, cAssigned)
		ok
	
	def _AddActor(oWorkflow, pcId, paProps)
		cName = pcId
		cRole = ""
		
		nLen = len(paProps)
		for i = 1 to nLen step 2
			if paProps[i] = "name"
				cName = paProps[i + 1]
			but paProps[i] = "role"
				cRole = paProps[i + 1]
			ok
		end
		
		oWorkflow.AddActor(pcId, cName, cRole)
	
	def _ParseValue(cValue)
		if isdigit(cValue)
			return 0 + cValue
		ok
		if left(cValue, 1) = '"' and right(cValue, 1) = '"'
			return @substr(cValue, 2, len(cValue) - 1)
		ok
		return cValue
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0 return "" ok
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
	
	def _ExtractValue(cLine)
		nPos = substr(cLine, ":")
		if nPos = 0 return "" ok
		return trim(@substr(cLine, nPos + 1, len(cLine)))
