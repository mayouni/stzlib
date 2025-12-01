#============================================#
#  stzGraphSimulation - Scenario Engine      #
#============================================#

class stzGraphSimulation
	@cSimId
	@cDescription = ""
	@cAuthor = ""
	@cDate = ""
	
	@oGraph = NULL
	@aSnapshot = []
	
	@aChanges = []
	@aMetrics = []
	@aResults = []

	def init(pcSimId)
		@cSimId = pcSimId
	
	#-----------------#
	#  CONFIGURATION  #
	#-----------------#
	
	def SetGraph(poGraph)
		@oGraph = poGraph
		This._CaptureSnapshot()
	
	def SetDescription(pcDesc)
		@cDescription = pcDesc
	
	def SetAuthor(pcAuthor)
		@cAuthor = pcAuthor
	
	def SetDate(pcDate)
		@cDate = pcDate
	
	#-----------------#
	#  CHANGE OPS     #
	#-----------------#
	
	def MovePosition(pcPosId, pcFromSuper, pcToSuper)
		@aChanges + [
			:type = "move",
			:position = pcPosId,
			:from = pcFromSuper,
			:to = pcToSuper
		]
	
	def AddPosition(pcId, pcTitle, pcLevel, pcReportsTo)
		@aChanges + [
			:type = "add_position",
			:id = pcId,
			:title = pcTitle,
			:level = pcLevel,
			:reportsTo = pcReportsTo
		]
	
	def RemovePosition(pcId)
		@aChanges + [
			:type = "remove_position",
			:id = pcId
		]
	
	def AssignPerson(pcPersonId, pcName, pcPosition)
		@aChanges + [
			:type = "assign",
			:personId = pcPersonId,
			:name = pcName,
			:position = pcPosition
		]
	
	def ReassignPerson(pcPersonId, pcFromPos, pcToPos)
		@aChanges + [
			:type = "reassign",
			:personId = pcPersonId,
			:from = pcFromPos,
			:to = pcToPos
		]
	
	def SetProperty(pcNodeId, pcKey, pValue)
		@aChanges + [
			:type = "set_property",
			:nodeId = pcNodeId,
			:key = pcKey,
			:value = pValue
		]
	
	#-----------------#
	#  METRICS        #
	#-----------------#
	
	def TrackMetric(pcMetric, paParams)
		@aMetrics + [
			:name = pcMetric,
			:params = paParams
		]
	
	def TrackSpanOfControl(pcPositionId)
		This.TrackMetric("span_of_control", [:position = pcPositionId])
	
	def TrackVacancyRate()
		This.TrackMetric("vacancy_rate", [])
	
	def TrackCompliance(paValidators)
		This.TrackMetric("compliance", [:validators = paValidators])
	
	#-----------------#
	#  EXECUTION      #
	#-----------------#
	
	def Run()
		# Capture before state
		aBefore = This._CaptureMetrics()
		
		# Apply changes
		This._ApplyChanges()
		
		# Capture after state
		aAfter = This._CaptureMetrics()
		
		# Restore original
		This._RestoreSnapshot()
		
		# Build result
		@aResults = This._BuildResult(aBefore, aAfter)
		
		return @aResults
	
	def _ApplyChanges()
		for aChange in @aChanges
			switch aChange[:type]
			on "move"
				@oGraph.ChangeReportingLine(aChange[:position], aChange[:to])
				
			on "add_position"
				@oGraph.AddPositionXTT(aChange[:id], aChange[:title], [:level = aChange[:level]])
				@oGraph.ReportsTo(aChange[:id], aChange[:reportsTo])
				
			on "remove_position"
				@oGraph.RemovePosition(aChange[:id])
				
			on "assign"
				@oGraph.AddPersonXT(aChange[:personId], aChange[:name])
				@oGraph.AssignPerson(aChange[:personId], aChange[:position])
				
			on "reassign"
				@oGraph.ReassignPerson(aChange[:personId], aChange[:to])
				
			on "set_property"
				@oGraph.SetNodeProperty(aChange[:nodeId], aChange[:key], aChange[:value])
			off
		end
	
	def _CaptureSnapshot()
		@aSnapshot = [
			:nodes = @oGraph.Nodes(),
			:edges = @oGraph.Edges(),
			:positions = @oGraph.Positions(),
			:people = @oGraph.People()
		]
	
	def _RestoreSnapshot()
		@oGraph.SetNodes(@aSnapshot[:nodes])
		@oGraph.SetEdges(@aSnapshot[:edges])
		# Full restoration logic here
	
	def _CaptureMetrics()
		aMetrics = []
		
		for aMetric in @aMetrics
			cName = aMetric[:name]
			aParams = aMetric[:params]
			
			switch cName
			on "span_of_control"
				if HasKey(aParams, :position)
					nSpan = @oGraph.DirectReportsCount(aParams[:position])
					aMetrics + [:metric = cName, :position = aParams[:position], :value = nSpan]
				else
					nAvg = @oGraph.AverageSpanOfControl()
					aMetrics + [:metric = cName, :value = nAvg]
				ok
				
			on "vacancy_rate"
				nRate = @oGraph.VacancyRate()
				aMetrics + [:metric = cName, :value = nRate]
				
			on "compliance"
				aValidators = aParams[:validators]
				aResult = @oGraph.ValidateXT(aValidators)
				aMetrics + [:metric = cName, :value = aResult]
			off
		end
		
		return aMetrics
	
	def _BuildResult(paBefore, paAfter)
		aDeltas = []
		
		# Compare metrics
		for i = 1 to len(paBefore)
			aBefore = paBefore[i]
			aAfter = paAfter[i]
			
			if aBefore[:metric] = aAfter[:metric]
				if HasKey(aBefore, :value) and HasKey(aAfter, :value)
					if isNumber(aBefore[:value]) and isNumber(aAfter[:value])
						nDelta = aAfter[:value] - aBefore[:value]
						aDeltas + [
							:metric = aBefore[:metric],
							:before = aBefore[:value],
							:after = aAfter[:value],
							:delta = nDelta
						]
					ok
				ok
			ok
		end
		
		return [
			:simulationId = @cSimId,
			:description = @cDescription,
			:changeCount = len(@aChanges),
			:before = paBefore,
			:after = paAfter,
			:deltas = aDeltas
		]
	
	#-----------------#
	#  RESULTS        #
	#-----------------#
	
	def Results()
		return @aResults
	
	def ShowResults()
		? "Simulation: " + @cSimId
		? "Description: " + @cDescription
		? "Changes applied: " + @aResults[:changeCount]
		? ""
		? "Metric Deltas:"
		
		for aDelta in @aResults[:deltas]
			? "  " + aDelta[:metric] + ":"
			? "    Before: " + aDelta[:before]
			? "    After: " + aDelta[:after]
			? "    Delta: " + aDelta[:delta]
		end


#============================================#
#  stzSimulationBase - Scenario Collection   #
#============================================#

class stzSimulationBase
	@cName
	@aoSimulations = []

	def init(pcName)
		@cName = pcName
	
	def AddSimulation(oSim)
		@aoSimulations + oSim
	
	def Simulation(pcId)
		for oSim in @aoSimulations
			if oSim.@cSimId = pcId
				return oSim
			ok
		end
		return NULL
	
	def Simulations()
		return @aoSimulations
	
	def RunAll(poGraph)
		aResults = []
		
		for oSim in @aoSimulations
			oSim.SetGraph(poGraph)
			aResult = oSim.Run()
			aResults + aResult
		end
		
		return aResults
	
	def LoadFromFile(pcFilename)
		oParser = new stzSimulationParser()
		oSim = oParser.ParseFile(pcFilename)
		This.AddSimulation(oSim)


#============================================#
#  stzSimulationParser - *.stzsim Parser     #
#============================================#

class stzSimulationParser
	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		acLines = split(pcContent, NL)
		oSim = NULL
		cSection = ""
		
		for cLine in acLines
			cLine = trim(cLine)
			
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			if substr(cLine, "simulation ")
				cId = This._ExtractQuoted(cLine)
				oSim = new stzGraphSimulation(cId)
				
			but substr(cLine, "description:")
				oSim.SetDescription(This._ExtractValue(cLine))
				
			but substr(cLine, "author:")
				oSim.SetAuthor(This._ExtractValue(cLine))
				
			but substr(cLine, "date:")
				oSim.SetDate(This._ExtractValue(cLine))
				
			but cLine = "changes"
				cSection = "changes"
				
			but cLine = "metrics"
				cSection = "metrics"
				
			but cSection = "changes"
				This._ParseChange(cLine, oSim)
				
			but cSection = "metrics"
				This._ParseMetric(cLine, oSim)
			ok
		end
		
		return oSim
	
	def _ParseChange(cLine, oSim)
		if substr(cLine, "move ")
			# Parse move command
		but substr(cLine, "add position ")
			# Parse add
		but substr(cLine, "assign person ")
			# Parse assign
		ok
	
	def _ParseMetric(cLine, oSim)
		if substr(cLine, "track ")
			# Parse metric tracking
		ok
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0 return "" ok
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
	
	def _ExtractValue(cLine)
		nPos = substr(cLine, ":")
		return trim(@substr(cLine, nPos + 1, len(cLine)))
