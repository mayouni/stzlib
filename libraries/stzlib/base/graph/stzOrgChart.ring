#=====================================================
#  stzOrgChart - COMPLETE FIXED ARCHITECTURE
#  All loop variables uniquely named to avoid collisions
#=====================================================

func IsStzOrgChart(pObj)
	if isObject(pObj) and classname(pObj) = "stzorgchart"
		return TRUE
	ok
	return FALSE

class stzOrgChart from stzDiagram

	@aPositions = []
	@aPeople = []
	@aDepartments = []
	@aAnalysisLayers = []

	def init(pcTitle)
		super.init(pcTitle)

	#==========================#
	#  POSITION MANAGEMENT     #
	#==========================#

	def AddPositionXT(pcId, pcTitle)
		This.AddPositionXTT(pcId, pcTitle, [])

	def AddPositionXTT(pcId, pcTitle, paAttributes)
		aPosition = [
			:id = pcId,
			:title = pcTitle,
			:level = 0,
			:department = "",
			:reportsTo = "",
			:incumbent = "",
			:isVacant = TRUE,
			:attributes = paAttributes
		]
		@aPositions + aPosition
		
		This.AddNodeXTT(pcId, pcTitle, [
			:type = :box,
			:color = :white,
			:positionType = "position"
		])

	def AddExecutivePositionXT(pcId, pcTitle)
		This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])
		This.SetNodeProperty(pcId, "color", "gold")

	def AddManagementPosition(pcId)
		This.AddManagementPositionXT(pcId, pcId)

	def AddManagementPositionXT(pcId, pcTitle)
		This.AddPositionXTT(pcId, pcTitle, [:level = "management"])
		This.SetNodeProperty(pcId, "color", "lightblue")

	def AddStaffPositionXT(pcId, pcTitle)
		This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])
		This.SetNodeProperty(pcId, "color", "lightgreen")

	def ReportsTo(pcSubordinate, pcSupervisor)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcSubordinate
				@aPositions[i][:reportsTo] = pcSupervisor
				exit
			ok
		end
		This.Connect(pcSupervisor, pcSubordinate)
	
	def SetPositionDepartment(pcPositionId, pcDepartment)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcPositionId
				@aPositions[i][:department] = pcDepartment
				exit
			ok
		end
		This.SetNodeProperty(pcPositionId, "department", pcDepartment)

	def Position(pcId)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcId
				return @aPositions[i]
			ok
		end
		return []

	def Positions()
		return @aPositions

	def VacantPositions()
		acVacant = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			aPos = @aPositions[i]
			bIsVacant = TRUE
			if HasKey(aPos, :isVacant)
				bIsVacant = aPos[:isVacant]
			ok
			
			if bIsVacant = TRUE
				if HasKey(aPos, :id)
					acVacant + aPos[:id]
				ok
			ok
		end
		return acVacant

	#==========================#
	#  PEOPLE MANAGEMENT       #
	#==========================#

	def AddPersonXT(pcId, pcName)
		This.AddPersonXTT(pcId, pcName, [])

	def AddPersonXTT(pcId, pcName, paData)
		aPerson = [
			:id = pcId,
			:name = pcName,
			:position = "",
			:data = paData
		]
		@aPeople + aPerson

	def AssignPerson(pcPersonId, pcPositionId)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcPositionId
				@aPositions[i][:incumbent] = pcPersonId
				@aPositions[i][:isVacant] = FALSE
				exit
			ok
		end
		
		nPplCount = len(@aPeople)
		for i = 1 to nPplCount
			if @aPeople[i][:id] = pcPersonId
				@aPeople[i][:position] = pcPositionId
				exit
			ok
		end
		
		aPerson = This.PersonData(pcPersonId)
		aPosition = This.Position(pcPositionId)
		cLabel = aPosition[:title] + "\n" + aPerson[:name]
		This.SetNodeProperty(pcPositionId, "label", cLabel)

	def PersonData(pcPersonId)
		nPplCount = len(@aPeople)
		for i = 1 to nPplCount
			if @aPeople[i][:id] = pcPersonId
				return @aPeople[i]
			ok
		end
		return []

	def People()
		return @aPeople

	#==========================#
	#  DEPARTMENT MANAGEMENT   #
	#==========================#

	def AddDepartmentXTT(pcId, pcName, paPositions)
		aDept = [
			:id = pcId,
			:name = pcName,
			:positions = paPositions,
			:head = ""
		]
		@aDepartments + aDept
		
		if len(paPositions) > 0
			This.AddCluster(pcId, pcName, paPositions, "lightgray")
		ok

	def Department(pcId)
		nDeptCount = len(@aDepartments)
		for i = 1 to nDeptCount
			if @aDepartments[i][:id] = pcId
				return @aDepartments[i]
			ok
		end
		return []

	def Departments()
		return @aDepartments

	#==========================#
	#  ANALYSIS LAYERS         #
	#==========================#

	def AddAnalysisLayer(pcName, pcType)
		oLayer = new stzOrgChartAnalysisLayer(This, pcName, pcType)
		@aAnalysisLayers + oLayer
		return oLayer

	def ApplyLayer(pcLayerName)
		nLayerCount = len(@aAnalysisLayers)
		for i = 1 to nLayerCount
			if @aAnalysisLayers[i].Name() = pcLayerName
				@aAnalysisLayers[i].Apply()
				return
			ok
		end

	def ApplyAllLayers()
		nLayerCount = len(@aAnalysisLayers)
		for i = 1 to nLayerCount
			@aAnalysisLayers[i].Apply()
		end

	#==========================#
	#  COMPLIANCE & GOVERNANCE #
	#==========================#

	def ValidateBCEAOGovernance()
		oValidator = new stzOrgChartBCEAOValidator(This)
		return oValidator.Validate()

	def ValidateSpanOfControl()
		aIssues = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cPosId = @aPositions[i][:id]
			nDirectReports = This.DirectReportsCount(cPosId)
			
			if nDirectReports > 9
				aIssues + "Excessive span: " + cPosId + " (" + nDirectReports + " reports)"
			ok
		end
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "span_of_control",
			:issues = aIssues
		]

	def ValidateSegregationOfDuties()
		oValidator = new stzOrgChartSODValidator(This)
		return oValidator.Validate()

	def DirectReportsCount(pcPositionId)
		nCount = 0
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:reportsTo] = pcPositionId
				nCount++
			ok
		end
		return nCount

	def DirectReports(pcPositionId)
		acReports = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:reportsTo] = pcPositionId
				acReports + @aPositions[i][:id]
			ok
		end
		return acReports

	#==========================#
	#  ORGANIZATIONAL METRICS  #
	#==========================#

	def AverageSpanOfControl()
		nTotal = 0
		nManagers = 0
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cPosId = @aPositions[i][:id]
			nReports = This.DirectReportsCount(cPosId)
			if nReports > 0
				nTotal += nReports
				nManagers++
			ok
		end
		if nManagers = 0
			return 0
		ok
		return nTotal / nManagers

	def VacancyRate()
		nTotal = len(@aPositions)
		if nTotal = 0
			return 0
		ok
		
		nVacant = 0
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			aPos = @aPositions[i]
			if HasKey(aPos, :isVacant)
				if aPos[:isVacant] = TRUE
					nVacant++
				ok
			ok
		end
		
		return (nVacant / nTotal) * 100

	def PositionsByLevel()
		aLevels = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cLevel = "staff"
			if HasKey(@aPositions[i], :attributes)
				aAttribs = @aPositions[i][:attributes]
				if isList(aAttribs) and HasKey(aAttribs, :level)
					cLevel = aAttribs[:level]
				ok
			ok
			
			bFound = FALSE
			nLvlCount = len(aLevels)
			for j = 1 to nLvlCount
				if aLevels[j][1] = cLevel
					aLevels[j][2]++
					bFound = TRUE
					exit
				ok
			end
			
			if NOT bFound
				aLevels + [cLevel, 1]
			ok
		end
		return aLevels

	def SuccessionRisk()
		acRisk = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			aPos = @aPositions[i]
			bVacant = TRUE
			if HasKey(aPos, :isVacant)
				bVacant = aPos[:isVacant]
			ok
			
			if NOT bVacant
				bHasSuccessor = FALSE
				if HasKey(aPos, :attributes)
					aAttribs = aPos[:attributes]
					if isList(aAttribs) and HasKey(aAttribs, :successor)
						bHasSuccessor = TRUE
					ok
				ok
				
				if NOT bHasSuccessor
					if HasKey(aPos, :id)
						acRisk + aPos[:id]
					ok
				ok
			ok
		end
		return acRisk

	#==========================#
	#  REPORTING & ANALYTICS   #
	#==========================#

	def GenerateReport(pcType)
		oReporter = new stzOrgChartReporter(This)
		return oReporter.Generate(pcType)

	#==========================#
	#  ORGANIZATIONAL CHANGES  #
	#==========================#

	def ReassignPerson(pcPersonId, pcNewPositionId)
		aPerson = This.PersonData(pcPersonId)
		cOldPosition = aPerson[:position]
		
		if cOldPosition != ""
			nPosCount = len(@aPositions)
			for i = 1 to nPosCount
				if @aPositions[i][:id] = cOldPosition
					@aPositions[i][:incumbent] = ""
					@aPositions[i][:isVacant] = TRUE
					exit
				ok
			end
		ok
		
		This.AssignPerson(pcPersonId, pcNewPositionId)

	def RemovePosition(pcPositionId)
		nPosCount = len(@aPositions)
		nIndex = 0
		
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcPositionId
				nIndex = i
				exit
			ok
		end
		
		if nIndex > 0
			if NOT @aPositions[nIndex][:isVacant]
				cPersonId = @aPositions[nIndex][:incumbent]
				nPplCount = len(@aPeople)
				for j = 1 to nPplCount
					if @aPeople[j][:id] = cPersonId
						@aPeople[j][:position] = ""
						exit
					ok
				end
			ok
			del(@aPositions, nIndex)
			This.RemoveNode(pcPositionId)
		ok

	def ChangeReportingLine(pcSubordinate, pcNewSupervisor)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcSubordinate
				cOldSupervisor = @aPositions[i][:reportsTo]
				@aPositions[i][:reportsTo] = pcNewSupervisor
				
				if cOldSupervisor != ""
					This.Disconnect(cOldSupervisor, pcSubordinate)
				ok
				This.Connect(pcNewSupervisor, pcSubordinate)
				exit
			ok
		end

	#==========================#
	#  SCENARIOS & SIMULATIONS #
	#==========================#

	def SimulateReorganization(paChanges)
		oSimulation = new stzOrgChartSimulation(This)
		oSimulation.ApplyChanges(paChanges)
		return oSimulation.Results()

	def CreateSnapshot(pcSnapshotId)
		aSnapshot = [
			:id = pcSnapshotId,
			:date = Date(),
			:positions = @aPositions,
			:people = @aPeople,
			:departments = @aDepartments
		]
		return aSnapshot

	#==========================#
	#  VISUALIZATION           #
	#==========================#

	def ViewWithPeople()
		# Include person names in visualization
		oRule = new stzVisualRule("show_people")
		oRule.WhenPropertyEquals("ispeople", TRUE)
		oRule.ApplyColor("blue--")
		This.SetVisualRule(oRule)
		This.ApplyVisualRules()

		
		This.View()

	def ViewVacancies()
		# Highlight vacant positions
		oRule = new stzVisualRule("highlight_vacant")
		oRule.WhenPropertyEquals("isVacant", TRUE)
		oRule.ApplyColor("red")
		oRule.ApplyStyle("dashed")
		This.SetVisualRule(oRule)
		This.ApplyVisualRules()
		This.View()

	def ViewByDepartment()
		This.ColorByDepartment()
		This.View()

	def ColorByDepartment()
		aColorMap = [
			:board = "gold",
			:executive = "lightcoral",
			:operations = "lightblue",
			:treasury = "lightgreen",
			:risk = "orange",
			:audit = "purple",
			:hr = "pink",
			:it = "cyan"
		]
		
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cDept = @aPositions[i][:department]
			if cDept != "" and HasKey(aColorMap, cDept)
				This.SetNodeProperty(@aPositions[i][:id], "color", aColorMap[cDept])
			ok
		end

	def HighlightPath(pcFromId, pcToId)
		acPath = This.PathBetween(pcFromId, pcToId)
		nPathCount = len(acPath)
		for i = 1 to nPathCount
			This.SetNodeProperty(acPath[i], "color", "yellow")
		end


#=====================================================
#  stzOrgChartAnalysisLayer
#=====================================================

class stzOrgChartAnalysisLayer

	@oOrgChart
	@cName = ""
	@cType = ""
	@aMetrics = []

	def init(poOrgChart, pcName, pcType)
		@oOrgChart = poOrgChart
		@cName = pcName
		@cType = pcType

	def Name()
		return @cName

	def Type()
		return @cType

	def Apply()
		switch @cType
		on "performance"
			This._ApplyPerformanceMetrics()
		on "risk"
			This._ApplyRiskAnalysis()
		on "compliance"
			This._ApplyComplianceChecks()
		on "succession"
			This._ApplySuccessionPlanning()
		off

	def _ApplyPerformanceMetrics()
		# Color-code by performance

	def _ApplyRiskAnalysis()
		# Highlight high-risk positions

	def _ApplyComplianceChecks()
		# Show compliance status

	def _ApplySuccessionPlanning()
		# Visualize succession readiness


#=====================================================
#  stzOrgChartBCEAOValidator
#=====================================================

class stzOrgChartBCEAOValidator

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Validate()
		aIssues = []
		
		# Rule 1: Board required
		bHasBoard = FALSE
		nPosCount = len(@oOrgChart.@aPositions)
		for i = 1 to nPosCount
			aPos = @oOrgChart.@aPositions[i]
			if HasKey(aPos, :title)
				cTitle = lower(aPos[:title])
				if substr(cTitle, "board")
					bHasBoard = TRUE
					exit
				ok
			ok
		end
		
		if NOT bHasBoard
			aIssues + "BCEAO-001: No Board of Directors found"
		ok
		
		# Rule 2: Audit independence
		for i = 1 to nPosCount
			aPos = @oOrgChart.@aPositions[i]
			cDept = ""
			if HasKey(aPos, :department)
				cDept = aPos[:department]
			ok
			
			if cDept = "audit"
				cReportsTo = ""
				if HasKey(aPos, :reportsTo)
					cReportsTo = aPos[:reportsTo]
				ok
				
				if cReportsTo != ""
					aSuperPos = @oOrgChart.Position(cReportsTo)
					if len(aSuperPos) > 0 and HasKey(aSuperPos, :department)
						if aSuperPos[:department] != "board"
							aIssues + "BCEAO-002: Audit reports to non-board position"
						ok
					ok
				ok
			ok
		end
		
		# Rule 3: Risk function
		bHasRisk = FALSE
		for i = 1 to nPosCount
			aPos = @oOrgChart.@aPositions[i]
			if HasKey(aPos, :department)
				if aPos[:department] = "risk"
					bHasRisk = TRUE
					exit
				ok
			ok
		end
		
		if NOT bHasRisk
			aIssues + "BCEAO-003: No dedicated Risk Management function"
		ok
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "BCEAO_governance",
			:issueCount = len(aIssues),
			:issues = aIssues
		]


#=====================================================
#  stzOrgChartSODValidator
#=====================================================

class stzOrgChartSODValidator

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Validate()
		aIssues = []
		
		# SOD: Operations cannot report to Treasury
		nPosCount = len(@oOrgChart.@aPositions)
		for i = 1 to nPosCount
			aPos = @oOrgChart.@aPositions[i]
			cDept = ""
			if HasKey(aPos, :department)
				cDept = aPos[:department]
			ok
			
			if cDept = "operations"
				cReportsTo = ""
				if HasKey(aPos, :reportsTo)
					cReportsTo = aPos[:reportsTo]
				ok
				
				if cReportsTo != ""
					aSuperPos = @oOrgChart.Position(cReportsTo)
					if len(aSuperPos) > 0 and HasKey(aSuperPos, :department)
						if aSuperPos[:department] = "treasury"
							aIssues + "SOD-001: Operations reports through Treasury"
						ok
					ok
				ok
			ok
		end
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "segregation_of_duties",
			:issueCount = len(aIssues),
			:issues = aIssues
		]


#=====================================================
#  stzOrgChartReporter
#=====================================================

class stzOrgChartReporter

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Generate(pcType)
		switch lower(pcType)
		on "summary"
			return This.SummaryReport()
		on "vacancies"
			return This.VacancyReport()
		on "succession"
			return This.SuccessionReport()
		on "compliance"
			return This.ComplianceReport()
		on "span"
			return This.SpanOfControlReport()
		other
			return []
		off

	def SummaryReport()
		return [
			:title = "Organizational Summary",
			:date = Date(),
			:metrics = [
				:totalPositions = len(@oOrgChart.@aPositions),
				:filledPositions = len(@oOrgChart.@aPositions) - len(@oOrgChart.VacantPositions()),
				:vacancyRate = @oOrgChart.VacancyRate(),
				:avgSpan = @oOrgChart.AverageSpanOfControl(),
				:levels = @oOrgChart.PositionsByLevel()
			]
		]

	def VacancyReport()
		acVacant = @oOrgChart.VacantPositions()
		aDetails = []
		
		nVacCount = len(acVacant)
		
		for iVac = 1 to nVacCount
			aPos = @oOrgChart.Position(acVacant[iVac])
			if len(aPos) = 0 loop ok
			
			cLevel = "staff"
			cDept = ""
			cTitle = ""
			
			if HasKey(aPos, :title)
				cTitle = aPos[:title]
			ok
			
			if HasKey(aPos, :department)
				cDept = aPos[:department]
			ok
			
			if HasKey(aPos, :attributes)
				aAttribs = aPos[:attributes]
				if isList(aAttribs) and HasKey(aAttribs, :level)
					cLevel = aAttribs[:level]
				ok
			ok
			
			aDetails + [
				:position = acVacant[iVac],
				:title = cTitle,
				:department = cDept,
				:level = cLevel
			]
		end
		
		nVacRate = @oOrgChart.VacancyRate()
		
		aReport = [
			:title = "Vacancy Report",
			:vacancyCount = nVacCount,
			:vacancyRate = nVacRate,
			:details = aDetails
		]
		
		return aReport

	def SuccessionReport()
		acRisk = @oOrgChart.SuccessionRisk()
		aDetails = []
		
		nRiskCount = len(acRisk)
		for iRisk = 1 to nRiskCount
			aPos = @oOrgChart.Position(acRisk[iRisk])
			if len(aPos) = 0 loop ok
			
			cPersonId = ""
			cPersonName = ""
			cTitle = ""
			cDept = ""
			
			if HasKey(aPos, :incumbent)
				cPersonId = aPos[:incumbent]
			ok
			
			if cPersonId != ""
				aPerson = @oOrgChart.PersonData(cPersonId)
				if len(aPerson) > 0 and HasKey(aPerson, :name)
					cPersonName = aPerson[:name]
				ok
			ok
			
			if HasKey(aPos, :title)
				cTitle = aPos[:title]
			ok
			
			if HasKey(aPos, :department)
				cDept = aPos[:department]
			ok
			
			aDetails + [
				:position = acRisk[iRisk],
				:title = cTitle,
				:incumbent = cPersonName,
				:department = cDept,
				:riskLevel = "high"
			]
		end
		
		return [
			:title = "Succession Risk Report",
			:date = Date(),
			:highRiskCount = nRiskCount,
			:details = aDetails
		]

	def ComplianceReport()
		aReport = [
			:title = "Compliance Status Report",
			:date = Date(),
			:checks = []
		]
		
		aReport[:checks] + @oOrgChart.ValidateBCEAOGovernance()
		aReport[:checks] + @oOrgChart.ValidateSpanOfControl()
		aReport[:checks] + @oOrgChart.ValidateSegregationOfDuties()
		
		nFail = 0
		nCheckCount = len(aReport[:checks])
		for iCheck = 1 to nCheckCount
			if aReport[:checks][iCheck][:status] = "fail"
				nFail++
			ok
		end
		
		aReport[:overallStatus] = iif(nFail = 0, "compliant", "non-compliant")
		aReport[:failedChecks] = nFail
		
		return aReport

	def SpanOfControlReport()
		aReport = [
			:title = "Span of Control Analysis",
			:date = Date(),
			:details = []
		]
		
		nPosCount = len(@oOrgChart.@aPositions)
		for iPos = 1 to nPosCount
			aPos = @oOrgChart.@aPositions[iPos]
			cPosId = ""
			cTitle = ""
			
			if HasKey(aPos, :id)
				cPosId = aPos[:id]
			ok
			
			if HasKey(aPos, :title)
				cTitle = aPos[:title]
			ok
			
			if cPosId != ""
				nReports = len(@oOrgChart.DirectReports(cPosId))
				
				if nReports > 0
					cStatus = "optimal"
					if nReports > 9 cStatus = "excessive" ok
					if nReports < 3 cStatus = "underutilized" ok
					
					aReport[:details] + [
						:position = cPosId,
						:title = cTitle,
						:directReports = nReports,
						:status = cStatus
					]
				ok
			ok
		end
		
		return aReport


#=====================================================
#  stzOrgChartSimulation
#=====================================================

class stzOrgChartSimulation

	@oOriginalChart
	@oSimulatedChart
	@aChanges = []
	@aResults = []

	def init(poOrgChart)
		@oOriginalChart = poOrgChart
		@oSimulatedChart = This._CloneChart(poOrgChart)

	def _CloneChart(poChart)
		oClone = new stzOrgChart(poChart.Id() + "_sim")
		oClone.@aPositions = poChart.@aPositions
		oClone.@aPeople = poChart.@aPeople
		oClone.@aDepartments = poChart.@aDepartments
		return oClone

	def ApplyChanges(paChanges)
		@aChanges = paChanges
		
		nChangeCount = len(paChanges)
		for iChange = 1 to nChangeCount
			aChange = paChanges[iChange]
			
			switch aChange[:type]
			on "reassign"
				@oSimulatedChart.ReassignPerson(aChange[:person], aChange[:newPosition])
			on "remove_position"
				@oSimulatedChart.RemovePosition(aChange[:position])
			on "add_position"
				@oSimulatedChart.AddPositionXT(aChange[:id], aChange[:title])
			on "change_reporting"
				@oSimulatedChart.ChangeReportingLine(aChange[:subordinate], aChange[:supervisor])
			off
		end
		
		This._AnalyzeResults()

	def _AnalyzeResults()
		@aResults = [
			:before = [
				:spanOfControl = @oOriginalChart.AverageSpanOfControl(),
				:vacancyRate = @oOriginalChart.VacancyRate()
			],
			:after = [
				:spanOfControl = @oSimulatedChart.AverageSpanOfControl(),
				:vacancyRate = @oSimulatedChart.VacancyRate()
			],
			:changes = @aChanges
		]

	def Results()
		return @aResults

	def SimulatedChart()
		return @oSimulatedChart
