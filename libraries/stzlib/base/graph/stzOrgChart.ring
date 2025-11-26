
#=====================================================
#  stzOrgChart - COMPLETE FIXED ARCHITECTURE
#  All loop variables uniquely named to avoid collisions
#=====================================================

$aOrgColors = [

    :board = "gold",
    :executive = "gold-",      # Lighter gold
    :management = "blue+",      # Mid-blue
    :staff = "green-",          # Green
    :operations = "blue",
    :treasury = "green",
    :risk = "orange",
    :audit = "purple",
    :hr = "pink",
    :it = "cyan",
    :sales = "blue",
    :engineering = "green-",
    :focus = "magenta+"
]


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
	@bUseInvisibleHelpers = TRUE

	@cEdgeStyle = $cDefaultOrgChartEdgeStyle   # Defined in stzDiagram.ring
	@cEdgeSpline = $cDefaultOrgChartEdgeSpline # Idem
	@cEdgeColor = $cDefaultOrgChartEdgeColor  # Idem
	@cClusterColor = $cDefaultClusterColor	   

	#TODO// Add other options

	def init(pcTitle)
		super.init(pcTitle)

	        # Auto-apply orgchart preset
	        This.SetLayoutPreset("orgchart")

	#==========================#
	#  POSITION MANAGEMENT     #
	#==========================#

	def AddPosition(pcId)
		This.AddPositionXTT(pcId, pcId, [])

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

	#---

	def AddExecutivePosition(pcId)
		This.AddExecutivePositionXT(pcId, pcId)

	def AddExecutivePositionXT(pcId, pcTitle)
	This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])
	This.SetNodeProperty(pcId, "color", $aOrgColors[:executive])  # Use global palette
	
	#---

	def AddManagementPosition(pcId)
		This.AddManagementPositionXT(pcId, pcId)

	def AddManagementPositionXT(pcId, pcTitle)
	    This.AddPositionXTT(pcId, pcTitle, [:level = "management"])
	    This.SetNodeProperty(pcId, "color", $aOrgColors[:management])  # Use global palette

	#---

	def AddStaffPosition(pcId)
		This.AddStaffPositionXT(pcIde, pcId)

	def AddStaffPositionXT(pcId, pcTitle)
	    This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])
	    This.SetNodeProperty(pcId, "color", $aOrgColors[:staff])  # Use global palette

	def AddStaffPositionXTT(pcId, pcTitle, paProp)
	    if NOT IsHashList(paprop)
	        stzraise("Incorrect param type! paProp must be a hashlist.")
	    ok
	
	    bLevel = HasKey(paProp, "level")
	
	    if NOT bLevel
	        paProp + [ "level", "staff" ]
	    else
	        if NOT (isString(paProp[:level]) and paProp[:level] = "staff")
	            stzraise("Incorrect param value! the value of the key 'level' should be 'staff'.")
	        ok
	    ok
	
	    This.AddPositionXTT(pcId, pcTitle, paProp)
	    This.SetNodeProperty(pcId, "color", $aOrgColors[:engineering])  # Use global palette

	#---

	def ReportsTo(pcSubordinate, pcSupervisor)
	    nPosCount = len(@aPositions)
	    for i = 1 to nPosCount
	        if @aPositions[i][:id] = pcSubordinate
	            @aPositions[i][:reportsTo] = pcSupervisor
	            exit
	        ok
	    end
	    
	    # Use standard connection - let Graphviz handle layout
	    This.Connect(pcSupervisor, pcSubordinate)

	#---

	def SetPositionDepartment(pcPositionId, pcDepartment)
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			if @aPositions[i][:id] = pcPositionId
				@aPositions[i][:department] = pcDepartment
				exit
			ok
		end
		This.SetNodeProperty(pcPositionId, "department", pcDepartment)

	#---

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

	def AddPerson(pcId)
		This.AddPersonXTT(pcId, pcId, [])

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

	#---

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

		def Persons()
			return @aPeople

	#==========================#
	#  DEPARTMENT MANAGEMENT   #
	#==========================#

	def AddDepartment(pcId)
		This.AddDepratmentXTT(pcId, pcId, [])

	def AddDepartmentXT(pcId, pcName)
		This.AddDepartmentXTT(pcId, pcName, [])

	def AddDepartmentXTT(pcId, pcName, paPositions)
		aDept = [
			:id = pcId,
			:name = pcName,
			:positions = paPositions,
			:head = ""
		]
		@aDepartments + aDept
		
		if len(paPositions) > 0
			This.AddClusterXTT(pcId, pcName, paPositions, @cClusterColor)
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

	#===========================#
	#  COMPLIANCE & GOVERNANCE  #
	#===========================#

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
		return len(This.DirectReports(pcPositionId))

		def DirectReportsN(pcPositionId)
			return This.DirectReportsCount(pcPositionId)

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

	#===========================#
	#  SCENARIOS & SIMULATIONS  #
	#===========================#

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

	#=================#
	#  VISUALIZATION  #
	#=================#

	def SetEdgeStyle(pcStyle)
		@cEdgeStyle = pcStyle

	def SetEdgeSpline(pcSpline)
		@cEdgeSpline = pcSpline

	def SetEdgeColor(pcColor)
		@cEdgeColor = pcColor

	def SetClusterColor(pcColor)
		@cClusterColor = pcColor

	#--

	def ViewPopulated()
	    nPosCount = len(@aPositions)
	    for i = 1 to nPosCount
	        if NOT @aPositions[i][:isVacant]
	            This.SetNodeProperty(@aPositions[i][:id], "color", $aOrgColors[:focus])
	        ok
	    end
	    This.View()

	    def ViewPeople()
		This.ViewPopulated()

	    def ViewWithPeople()
		This.ViewPopulated()

	def ViewVacant()
	    nPosCount = len(@aPositions)
	    for i = 1 to nPosCount
	        if @aPositions[i][:isVacant]
	            This.SetNodeProperty(@aPositions[i][:id], "color", $aOrgColors[:focus])
	        ok
	    end
	    This.View()

	    def ViewVacancies()
		This.ViewVacant()

	def ViewByDepartment()
		This.ColorByDepartment()
		This.View()

	def ColorByDepartment()

	    nPosCount = len(@aPositions)
	    for i = 1 to nPosCount
	        cDept = @aPositions[i][:department]
	        if cDept != "" and HasKey($aOrgColors, cDept)
	            # Use parent's color resolution (respects themes)
	            This.SetNodeProperty(@aPositions[i][:id], "color", $aOrgColors[cDept])
	        ok
	    end

	def HighlightPath(pcFromId, pcToId)
	    acPath = This.PathBetween(pcFromId, pcToId)
	    
	    if len(acPath) = 0
	        return
	    ok
	    
	    # Dim all nodes first
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    for i = 1 to nLen
	        cNodeId = aNodes[i]["id"]
	        This.SetNodeProperty(cNodeId, "color", "gray++")
	    end
	    
	    # Brighten path nodes
	    nPathLen = len(acPath)
	    for i = 1 to nPathLen
	        This.SetNodeProperty(acPath[i], "color", "yellow")
	    end
	    
	    # Thicken path edges
	    for i = 1 to nPathLen - 1
	        This.SetEdgeProperty(acPath[i], acPath[i+1], "color", "red")
	        This.SetEdgeProperty(acPath[i], acPath[i+1], "penwidth", 3)
	    end

	#=====================================================
	#  NEW FEATURE: EXPORT TO .STZORG FORMAT
	#=====================================================

	def ToStzOrg()
		cResult = 'orgchart "' +
			  This.Id() + '"' + NL + NL
		
		# Positions
		cResult += "positions" + NL
		aPositions = This.Positions()
		nPosLen = len(aPositions)
		for i = 1 to nPosLen
			aPos = aPositions[i]
			cResult += "    " + aPos[:id] + NL
			cResult += "        title: " + aPos[:title] + NL
			cResult += "        level: " + aPos[:level] + NL
			cResult += "        department: " + aPos[:department] + NL
			cResult += "        reportsTo: " + aPos[:reportsTo] + NL
			cResult += NL
		end
		
		# People
		cResult += "people" + NL
		aPeople = This.People()
		nPplLen = len(aPeople)
		for i = 1 to nPplLen
			aPerson = aPeople[i]
			cResult += "    " + aPerson[:id] + NL
			cResult += "        name: " + aPerson[:name] + NL
			cResult += NL
		end
		
		# Assignments
		cResult += "assignments" + NL
		for i = 1 to nPosLen
			aPos = aPositions[i]
			if aPos[:incumbent] != ""
				cResult += "    " + aPos[:incumbent] + " -> " + aPos[:id] + NL
			ok
		end
		cResult += NL
		
		# Departments
		cResult += "departments" + NL
		aDepts = This.Departments()
		nDeptLen = len(aDepts)
		for i = 1 to nDeptLen
			aDept = aDepts[i]
			cResult += "    " + aDept[:id] + NL
			cResult += "        name: " + aDept[:name] + NL
			cResult += "        positions: " + Q(aDept[:positions]).ToCode() + NL
			cResult += NL
		end
		
		return cResult
	
	def WriteToStzOrgFile(pcFileName)
		write(pcfileName, This.ToStzOrg())
		return TRUE
	
	#=====================================================
	#  NEW FEATURE: IMPORT FROM .STZORG FORMAT
	#=====================================================
	
	def ImportStzOrg(cString)
		acLines = split(cString, NL)
		cCurrentSection = ""
		cCurrentId = ""
		aCurrent = []
		cTile = ""

		nLen = len(acLines)
		for i = 1 to nLen
			cLine = trim(acLines[i])
			if cLine = "" or left(cLine, 1) = "#" loop ok
			
			if substr(cLine, "orgchart ")
				cTitle = substr(cLine, 10, len(cLine)-1)
				
			but cLine = "positions"
				cCurrentSection = "positions"
				
			but cLine = "people"
				cCurrentSection = "people"
				
			but cLine = "assignments"
				cCurrentSection = "assignments"
				
			but cLine = "departments"
				cCurrentSection = "departments"
				
			but cCurrentSection = "positions"
				if NOT substr(cLine, ":")
					if cCurrentId != ""
						This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
						if aCurrent[:department] != ""
							This.SetPositionDepartment(cCurrentId, aCurrent[:department])
						ok
						if aCurrent[:reportsTo] != ""
							This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
						ok
					ok
					cCurrentId = cLine
					aCurrent = [ :title = "", :level = "", :department = "", :reportsTo = "" ]
					
				but substr(cLine, "title:")
					aCurrent[:title] = trim(substr(cLine, 7, len(cLine)))
					
				but substr(cLine, "level:")
					aCurrent[:level] = trim(substr(cLine, 7, len(cLine)))
					
				but substr(cLine, "department:")
					aCurrent[:department] = trim(substr(cLine, 12, len(cLine)))
					
				but substr(cLine, "reportsTo:")
					aCurrent[:reportsTo] = trim(substr(cLine, 11, len(cLine)))
				ok
				
			but cCurrentSection = "people"
				if NOT substr(cLine, ":")
					if cCurrentId != ""
						This.AddPersonXT(cCurrentId, aCurrent[:name])
					ok
					cCurrentId = cLine
					aCurrent = [ :name = "" ]
					
				but substr(cLine, "name:")
					aCurrent[:name] = trim(substr(cLine, 6, len(cLine)))
				ok
				
			but cCurrentSection = "assignments"
				if substr(cLine, " -> ")
					aParts = split(cLine, " -> ")
					This.AssignPerson(trim(aParts[1]), trim(aParts[2]))
				ok
				
			but cCurrentSection = "departments"
				if NOT substr(cLine, ":")
					if cCurrentId != ""
						This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
					ok
					cCurrentId = cLine
					aCurrent = [ :name = "", :positions = [] ]
					
				but substr(cLine, "name:")
					aCurrent[:name] = trim(substr(cLine, 6, len(cLine)))
					
				but substr(cLine, "positions:")
					cPosStr = trim(substr(cLine, 11, len(cLine)))
					cPosStr = replace(cPosStr, "[", "")
					cPosStr = replace(cPosStr, "]", "")
					aCurrent[:positions] = split(cPosStr, ",")
					for i = 1 to len(aCurrent[:positions])
						aCurrent[:positions][i] = trim(aCurrent[:positions][i])
					end
				ok
			ok
		end
		
		# Add last item if needed
		if cCurrentSection = "positions" and cCurrentId != ""
			This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
			if aCurrent[:department] != ""
				This.SetPositionDepartment(cCurrentId, aCurrent[:department])
			ok
			if aCurrent[:reportsTo] != ""
				This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
			ok

		but cCurrentSection = "people" and cCurrentId != ""
			This.AddPersonXT(cCurrentId, aCurrent[:name])

		but cCurrentSection = "departments" and cCurrentId != ""
			This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
		ok
	
	def ImportFromStzOrgFile(pcFileName)
		cContent = read(pcFileName)
		This.ImportStzOrg(cContent)

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
	    nPosCount = len(@oOrgChart.@aPositions)
	    for i = 1 to nPosCount
	        aPos = @oOrgChart.@aPositions[i]
	        if HasKey(aPos[:attributes], "performance")
	            nScore = aPos[:attributes]["performance"]
	            cColor = "red"
	            if nScore > 75 cColor = "green" ok
	            if nScore >= 50 and nScore <= 75 cColor = "yellow" ok
	            @oOrgChart.SetNodeProperty(aPos[:id], "color", cColor)
	        ok
	    end

	def _ApplyRiskAnalysis()
	    acRisk = @oOrgChart.SuccessionRisk()  # Already implemented
	    nLen = len(acRisk)
	    for i = 1 to nLen
	        @oOrgChart.SetNodeProperty(acRisk[i], "color", "orange")
	        @oOrgChart.SetNodeProperty(acRisk[i], "penwidth", 3)
	    end

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
