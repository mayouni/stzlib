#=====================================================
#  stzOrgChart - COMPLETE FIXED ARCHITECTURE
#  All loop variables uniquely named to avoid collisions
#=====================================================

$aOrgColors = [

    :board = "gold",
    :executive = "gold",      # Lighter gold
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

$acOrgChartDefaultValidators = ["bceao", "sod", "soc", "vacancy", "succession"]

func OrgChartDefaultValidators()
	return $acOrgChartDefaultValidators

	func DefaultOrgChartValidators()
		return $acOrgChartDefaultValidators

func IsStzOrgChart(pObj)
	if isObject(pObj) and classname(pObj) = "stzorgchart"
		return TRUE
	ok
	return FALSE

class stzOrgChart from stzDiagram

	@aPositions = []
	@aPeople = []
	@aDepartments = []

	@acValidators = $acOrgChartDefaultValidators

	def init(pcTitle)
		super.init(pcTitle)
		super.SetGraphType("structural")

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
		if not (islist(paAttributes) and IsHashList(paAttributes))
			stzraise("Incorrect param type! paAttributes must be a hashlist.")
		ok

		aPosition = [
			:id = pcId,
			:title = pcTitle
		]
		nLen = len(paAttributes)
		for i = 1 to nLen
			aPosition + paAttributes[i]
		next

		@aPositions + aPosition
		
		This.AddNodeXTT(pcId, pcTitle, [
			:type = "box",
			:color = "white",
			:positionType = "position"
		])

	    # Ensure attributes flow to node properties
	    if isList(paAttributes) and len(paAttributes) > 0
	        acKeys = keys(paAttributes)
	        nKeyLen = len(acKeys)
	        for i = 1 to nKeyLen
	            This.SetNodeProperty(pcId, acKeys[i], paAttributes[acKeys[i]])
	        end
	    ok


	#---

	def AddExecutivePosition(pcId)
		This.AddExecutivePositionXT(pcId, pcId)

		def AddExecutive(pcId)
			This.AddExecutivePositionXT(pcId, pcId)

	def AddExecutivePositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])
	    	# Don't set color here - leave as white until person assigned	

		def AddExecutiveXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])

	def AddManagementPosition(pcId)
		This.AddManagementPositionXT(pcId, pcId)

		def AddManager(pcId)
			This.AddManagementPositionXT(pcId, pcId)

	def AddManagementPositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "management"])
	    	# Don't set color here

		def AddManagerXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "management"])

	def AddStaffPosition(pcId)
		This.AddStaffPositionXT(pcIde, pcId)

		def AddStaff(pcId)
			This.AddStaffPositionXT(pcIde, pcId)

	def AddStaffPositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])
	    	# Don't set color here

		def AddStaffXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])

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

	    def AddStaffXTT(pcId, pcTitle, paProp)
		This.AddStaffPositionXTT(pcId, pcTitle, paProp)

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

	    def RelatesTo(pcSubordinate, pcSupervisor)
		This.ReportsTo(pcSubordinate, pcSupervisor)

	    def SubordinateOf(pcSubordinate, pcSupervisor)
		This.ReportsTo(pcSubordinate, pcSupervisor)

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

		def Node(pcId)
			return This.Position(pcId)

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

		def Vacant()
			return This.VacantPositions()

		def VacantNodes()
			return This.VacantPositions()

	def NonVacantPositions()
		acNonVacant = []
		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			aPos = @aPositions[i]
			bIsVacant = TRUE
			if HasKey(aPos, :isVacant)
				bIsVacant = aPos[:isVacant]
			ok
			
			if bIsVacant = FALSE
				if HasKey(aPos, :id)
					acNonVacant + aPos[:id]
				ok
			ok
		end
		return acNonVacant

		def NonVacant()
			return This.NonVacantPositions()

		def NonVacantNodes()
			return This.NonVacantPositions()

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

		if CheckParams()
			if isList(pcPositionId) and StzListQ(pcPositionId).IsToOrToPositionOrToNodeNamedParam()
				pcPositionId = pcPositionId[2]
			ok
			if NOT isString(pcPositionId)
				stzraise("Incorrect param type! pcPositionId must be a string.")
			ok
		ok

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

		# Restore level color when filled
		aPosition = This.Position(pcPositionId)
		cLevelColor = "white"
		    
		if isList(aPosition[:attributes]) and HasKey(aPosition[:attributes], :level)
		        cLevel = aPosition[:attributes][:level]
		        if cLevel = "executive"
		            cLevelColor = $aOrgColors[:executive]
		        but cLevel = "management"
		            cLevelColor = $aOrgColors[:management]
		        but cLevel = "staff"
		            cLevelColor = $aOrgColors[:staff]
		        ok
		ok

		This.SetNodeProperty(pcPositionId, "color", cLevelColor)

		def Assign(pcPersonId, pcPositionId)
			This.AssignPerson(pcPersonId, pcPositionId)

	def Person(pcPersonId)
		nPplCount = len(@aPeople)
		for i = 1 to nPplCount
			if @aPeople[i][:id] = pcPersonId
				return @aPeople[i]
			ok
		end
		return []

		def PersonData(pcPersonId)
			return This.Person(pcPersonId)

	def People()
		return @aPeople

		def Persons()
			return @aPeople

	#==========================#
	#  DEPARTMENT MANAGEMENT   #
	#==========================#

	def AddDepartment(pcId)
		This.AddDepartmentXTT(pcId, pcId, [])

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

	#===========================#
	#  COMPLIANCE & GOVERNANCE  #
	#===========================#

	def Validators()
		return @acValidators

	def DefaultValidators()
		return $acOrgChartDefaultValidators

	def SetValidators(pacValidators)
		@acValidators = pacValidators

	def Validate()
		return This.ValidateXT(@acValidators)

	def ValidateXT(pValidator)
		if isString(pValidator)
			return This._ValidateSingle(pValidator)
		but isList(pValidator)
			aResults = []
			nFailed = 0
			nTotalIssues = 0
			acAllAffected = []
			
			nLen = len(pValidator)
			for i = 1 to nLen
				aResult = This._ValidateSingle(pValidator[i])
				aResults + aResult
				if aResult[:status] = "fail"
					nFailed++
					nTotalIssues += aResult[:issueCount]
					nAffLen = len(aResult[:affectedNodes])
					for j = 1 to nAffLen
						if ring_find(acAllAffected, aResult[:affectedNodes][j]) = 0
							acAllAffected + aResult[:affectedNodes][j]
						ok
					end
				ok
			end
			
			return [
				:status = iif(nFailed = 0, "pass", "fail"),
				:validatorsRun = len(pValidator),
				:validatorsFailed = nFailed,
				:totalIssues = nTotalIssues,
				:results = aResults,
				:affectedNodes = acAllAffected
			]
		ok

	def IsValid()
		aResult = This.Validate()
		return aResult[:status] = "pass"

	def IsValidXT(pValidator)
		aResult = This.ValidateXT(pValidator)
		return aResult[:status] = "pass"

	def _ValidateSingle(pcValidator)
		switch lower(pcValidator)

		on "bceao"
			return This.ValidateBCEAOGovernance()

		on "spanofcontrol"
			return This.ValidateSpanOfControl()
		on "soc"
			return This.ValidateSpanOfControl()

		on "separationofduties"
			return This.ValidateSegregationOfDuties()
		on "segregationofduties"
			return This.ValidateSegregationOfDuties()
		on "sod"
			return This.ValidateSegregationOfDuties()

		on "vacancy"
			return This.ValidateVacancy()
		on "nonvacancy"
			return This.ValidateNonVacancy()

		on "succession"
			return This.ValidateSuccession()

		on "banking"
			return This.ValidateBanking()

		on "compliance"
			return This.ValidateCompliance()
		on "noncompliance"
			return This.ValidateNonCompliance()

		on "summary"
			return This.ValidationSummary()

		other
		        return [
		            :status = "error",
		            :domain = pcValidator,
		            :issues = ["Unknown validator for OrgChart: " + pcValidator]
		        ]
		off

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
				aIssues + ("Excessive span: " + cPosId + " (" + nDirectReports + " reports)" )
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

	def ValidateVacancy()
		acVacant = This.VacantPositions()
		
		return [
			:status = iif(len(acVacant) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(acVacant),
			:issues = iif(len(acVacant) > 0, ["Vacant positions: " + len(acVacant)], []),
			:affectedNodes = acVacant
		]
	
	def ValidateNonVacancy()
		acVacant = This.NonVacantPositions()
		
		return [
			:status = iif(len(acVacant) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(acVacant),
			:issues = iif(len(acVacant) > 0, ["Vacant positions: " + len(acVacant)], []),
			:affectedNodes = acVacant
		]

	def ValidateSuccession()
		acRisk = This.SuccessionRisk()
		aIssues = []
		nLen = len(acRisk)
		for i = 1 to nLen
			aIssues + ("No successor: " + acRisk[i])
		end
		
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "succession",
			:issueCount = len(aIssues),
			:issues = aIssues,
			:affectedNodes = acRisk
		]
	
	def ValidateBanking()
		return [
			:status = "pass",
			:domain = "banking",
			:issueCount = 0,
			:issues = [],
			:affectedNodes = []
		]
	
	def ValidateCompliance()
		return This.ValidateBCEAOGovernance()

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
		nResult = ( len(This.Vacant()) / len(This.Positions()) ) * 100
		return nResult

	def PositionsByLevel()
		aResult = [
			:executive = [],
			:management = [],
			:staff = []
		]

		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cLevel = "staff"
			if HasKey(@aPositions[i], "level")
				if haskey(aResult, @aPositions[i][:level])
					aResult[@aPositions[i][:level]] + @aPositions[i][:id]
				ok
			ok
			
		end
		return aResult

	def NumberOfPositionsByLevel()
		aResult = [
			:executive = 0,
			:management = 0,
			:staff = 0
		]

		nPosCount = len(@aPositions)
		for i = 1 to nPosCount
			cLevel = "staff"
			if HasKey(@aPositions[i], "level")
				if haskey(aResult, @aPositions[i][:level])
					aResult[@aPositions[i][:level]]++
				ok
			ok
			
		end
		return aResult

		def PositionsCountByLevel()
			return This.NumberOfPositionsByLevel()

		def PositionsByLevelN()
			return This.NumberOfPositionsByLevel()

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
	            # Fix: Check attributes as list
	            if isList(aPos[:attributes]) and HasKey(aPos[:attributes], :successor)
	                bHasSuccessor = TRUE
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

	def GenerateReport()
		# Reports generated --> [ "summary", "vacancy", "succession", "compliance", "spanofcontrol" ]

		oReporter = new stzOrgChartReporter(This)
		return oReporter.Generate()

		def Report()
			return This.GenerateReport()

	def GenerateReportXT(pcType)
		# pcType --> [ "summary", "vacancy", "succession", "compliance", "spanofcontrol" ]

		oReporter = new stzOrgChartReporter(This)
		return oReporter.GenerateXT(pcType)

		def ReportXT(pcType)
			return This.GenerateReportXT(pcType)

	def GenerateSummaryReport()
		return This.GenerateReportXT("summary")

		def GenerateSummary()
			return This.GenerateReportXT("summary")

		def Summary()
			return This.GenerateReportXT("summary")

		def SummaryReport()
			return This.GenerateReportXT("summary")

	def GenerateVacancyReport()
		return This.GenerateReportXT("Vacancy")

		def GenerateVacancy()
			return This.GenerateReportXT("vacancy")

		def Vacancy()
			return This.GenerateReportXT("vacancy")

		def VacancyReport()
			return This.GenerateReportXT("vacancy")

	def GenerateSuccessionReport()
		return This.GenerateReportXT("succession")

		def GenerateSuccession()
			return This.GenerateReportXT("succession")

		def Succession()
			return This.GenerateReportXT("succession")

		def SuccessionReport()
			return This.GenerateReportXT("succession")

	def GenerateComplianceReport()
		return This.GenerateReportXT("compliance")

		def GenerateCompliance()
			return This.GenerateReportXT("compliance")

		def Compliance()
			return This.GenerateReportXT("compliance")

		def ComplianceReport()
			return This.GenerateReportXT("compliance")

	def GenerateSpanOfControlReport()
		return This.GenerateReportXT("spanofcontrol")

		def GenerateSpanOfControl()
			return This.GenerateReportXT("spanofcontrol")

		def SpanOfControl()
			return This.GenerateReportXT("spanofcontrol")

		def GenerateSOCReport()
			return This.GenerateReportXT("spanofcontrol")

		def GenerateSOC()
			return This.GenerateReportXT("spanofcontrol")

		def SOC()
			return This.GenerateReportXT("spanofcontrol")

		def SpanOfControlReport()
			return This.GenerateReportXT("spanofcontrol")

		def SOCReport()
			return This.GenerateReportXT("spanofcontrol")

	#==========================#
	#  ORGANIZATIONAL CHANGES  #
	#==========================#

	def ReassignPerson(pcPersonId, pcNewPositionId)

		if CheckParams()
			if isList(pcNewPositionId) and StzListQ(pcNewPositionId).IsToOrToPositionNamedParam()
				pcNewPositionId = pcNewPositionId[2]
			ok
			if NOT isString(pcNewPositionId)
				stzraise("Incorrect param type! pcNewPositionId must be a string.")
			ok
		ok

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

		def Reassign(pcPersonId, pcNewPositionId)
			This.ReassignPerson(pcPersonId, pcNewPositionId)

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

	#-------------------------#
	#  MANAGING VISUAL FOCUS  #
	#-------------------------#
	
	def SetFocusColor(pColor)
	    @cFocusColor = ResolveColor(pColor)
	
	def FocusColor()
	    return @cFocusColor
	
	def ResetAllNodeColors()
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    for i = 1 to nLen
	        cNodeId = aNodes[i]["id"]
	        aPos = This.Position(cNodeId)
	        
	        # Restore original level color
	        cOriginalColor = "white"
	        if HasKey(aPos, :attributes) and HasKey(aPos[:attributes], :level)
	            cLevel = aPos[:attributes][:level]
	            if cLevel = "executive"
	                cOriginalColor = $aOrgColors[:executive]
	            but cLevel = "management"
	                cOriginalColor = $aOrgColors[:management]
	            but cLevel = "staff"
	                cOriginalColor = $aOrgColors[:staff]
	            ok
	        ok
	        
	        This.SetNodeProperty(cNodeId, "color", cOriginalColor)
	    end
	
	def ApplyFocusTo(acNodeIds)
	    # Reset all first
	    This.ResetAllNodeColors()
	    
	    # Apply focus to specified nodes
	    nLen = len(acNodeIds)
	    for i = 1 to nLen
	        This.SetNodeProperty(acNodeIds[i], "color", @cFocusColor)
	    end
	
	#=================#
	#  VISUALIZATION  #
	#=================#

	def SetDepartmentColor(pcColor)
		super.SetClusterColor(ResolveColor(pcColor))

	#--
	
	def ViewValidation(aValidationResult)
	    # Extract affected nodes and apply focus
	    if HasKey(aValidationResult, :affectedNodes)
	        This.ApplyFocusTo(aValidationResult[:affectedNodes])
	    ok
	    This.View()
	
	def ViewXT(pcValidator)
	    # Validate and view in one action
	    aResult = This.ValidateXT(pcValidator)
	    This.ViewValidation(aResult)

	#--


	def ViewVacant()

	    If This.Title() != ""
		This.SetSubtitle("Vacant Positions")
	    ok

	    acVacant = This.VacantPositions()
	    This.ApplyFocusTo(acVacant)
	    This.View()
	
	    def ViewVacancies()
	        This.ViewVacant()

	def ViewNonVacant()

	    If This.Title() != ""
		This.SetSubtitle("Non-Vacant Positions")
	    ok

	    acVacant = This.NonVacantPositions()
	    This.ApplyFocusTo(acVacant)
	    This.View()

	    def ViewPopulated()
		This.ViewNonVacant()

	    def ViewPeople()
	        This.ViewNonVacant()
	
	    def ViewWithPeople()
	        This.ViewNonVacant()

	#--

	#TODO// Add Performant() or PerformantPositions(),
	# and NonPerformant() or NonPerformantPositions()

	def ViewPerformant()

	    If This.Title() != ""
		This.SetSubtitle("Performant Positions")
	    ok

	    acHigh = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode["properties"], "performance")
	            nScore = aNode["properties"]["performance"]
	            if nScore >= 75
	                acHigh + aNode["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(acHigh)
	    This.View()
	
	    def ViewHighPerformers()
	        This.ViewPerformant()
	
	def ViewNonPerformant()

	    If This.Title() != ""
		This.SetSubtitle("Non-performant Positions")
	    ok

	    acLow = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode["properties"], "performance")
	            nScore = aNode["properties"]["performance"]
	            if nScore < 50
	                acLow + aNode["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(acLow)
	    This.View()
	
	    def ViewLowPerformers()
	        This.ViewNonPerformant()
	
	#TODO // Add MediumPerformers()

	def ViewMediumPerformers()

	    If This.Title() != ""
		This.SetSubtitle("Medium-performer Positions")
	    ok

	    acMedium = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode["properties"], "performance")
	            nScore = aNode["properties"]["performance"]
	            if nScore >= 50 and nScore < 75
	                acMedium + aNode["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(acMedium)
	    This.View()

	#--

	#TODO // Add Compliant() or CompliantPositions() and
	# NonCompliant() or NonCompliantPositions()

	def ViewCompliant(pcNorm)

	    If This.Title() != ""
		This.SetSubtitle("Compliant posisitions")
	    ok

	    aResult = This.ValidateXT(pcNorm)
	    
	    if isNumber(aResult)
	        if aResult = 1
	            acAll = []
	            aNodes = This.Nodes()
	            nLen = len(aNodes)
	            for i = 1 to nLen
	                acAll + aNodes[i]["id"]
	            end
	            This.ApplyFocusTo(acAll)
	        else
	            This.ApplyFocusTo([])
	        ok
	        This.View()
	        return
	    ok
	    
	    if aResult[:status] = "pass"
	        acAll = []
	        aNodes = This.Nodes()
	        nLen = len(aNodes)
	        for i = 1 to nLen
	            acAll + aNodes[i]["id"]
	        end
	        This.ApplyFocusTo(acAll)
	    else
	        # For failures, only show focused nodes if issues mention specific nodes
	        acIssueNodes = This._ExtractNodesFromIssues(aResult[:issues])
	        if len(acIssueNodes) > 0
	            # Show compliant nodes (not in issues)
	            acAll = []
	            aNodes = This.Nodes()
	            nLen = len(aNodes)
	            for i = 1 to nLen
	                cNodeId = aNodes[i]["id"]
	                if ring_find(acIssueNodes, cNodeId) = 0
	                    acAll + cNodeId
	                ok
	            end
	            This.ApplyFocusTo(acAll)
	        else
	            # Org-level failure - show nothing focused
	            This.ApplyFocusTo([])
	        ok
	    ok
	    
	    This.View()
	
	    def ViewCompliantXT(pcNorm)
		This.ViewCompliant(pcNorm)

	def ViewNonCompliant(pcNorm)

	    If This.Title() != ""
		This.SetSubtitle("Non Compliant posisitions")
	    ok

	    aResult = This.Validate(pcNorm)
	    
	    # Handle boolean results
	    if isNumber(aResult)
	        if aResult = 0  # FALSE = all non-compliant
	            acAll = []
	            aNodes = This.Nodes()
	            nLen = len(aNodes)
	            for i = 1 to nLen
	                acAll + aNodes[i]["id"]
	            end
	            This.ApplyFocusTo(acAll)
	        else  # TRUE = none non-compliant
	            This.ApplyFocusTo([])
	        ok
	        This.View()
	        return
	    ok
	    
	    # Handle hashlist results
	    if aResult[:status] = "fail"
	        acIssueNodes = This._ExtractNodesFromIssues(aResult[:issues])
	        This.ApplyFocusTo(acIssueNodes)
	    else
	        This.ApplyFocusTo([])
	    ok
	    
	    This.View()
	
	    def ViewNonCompliantXT(pcNorm)
		This.ViewNonCompliant(pcNorm)

	def _ExtractNodesFromIssues(acIssues)
	    acNodes = []
	    nLen = len(acIssues)
	    
	    for i = 1 to nLen
	        cIssue = acIssues[i]
	        # Parse issue string to extract node IDs
	        # Format: "BCEAO-002: Audit reports to non-board position"
	        # or: "SOC-001: Position X has excessive span"
	        
	        aWords = @split(cIssue, " ")
	        nWordLen = len(aWords)
	        for j = 1 to nWordLen
	            cWord = aWords[j]
	            # Check if this word is a node ID
	            if This.NodeExists(cWord)
	                if ring_find(acNodes, cWord) = 0
	                    acNodes + cWord
	                ok
	            ok
	        end
	    end
	    
	    return acNodes

	#--
	
	def ViewAtRisk()

	    If This.Title() != ""
		This.SetSubtitle("At risk posisitions")
	    ok

	    acRisk = This.SuccessionRisk()
	    This.ApplyFocusTo(acRisk)
	    This.View()
	
	    def ViewSuccessionRisk()
	        This.ViewAtRisk()
	
	def ViewNotAtRisk()

	    If @bShowTitle = TRUE
		This.SetSubtitle("Not-at risk posisitions")
	    ok

	    acRisk = This.SuccessionRisk()
	    acAll = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        cNodeId = aNodes[i]["id"]
	        if ring_find(acRisk, cNodeId) = 0
	            acAll + cNodeId
	        ok
	    end
	    
	    This.ApplyFocusTo(acAll)
	    This.View()

	#--

	def ViewDepartment(pcDepartmentId)

	    If This.Title() != ""
		This.SetSubtitle("Department '" + @aDepartments[PpcDepartmentId]  + "'")
	    ok

	    acDeptNodes = []
	    nPosCount = len(@aPositions)
	    
	    for i = 1 to nPosCount
	        if @aPositions[i][:department] = pcDepartmentId
	            acDeptNodes + @aPositions[i][:id]
	        ok
	    end
	    
	    This.ApplyFocusTo(acDeptNodes)
	    This.View()
	
	def ViewAllDepartments()
	    This.ResetAllNodeColors()
	    This.ColorByDepartment()
	    This.View()

	#--

	def ViewPath(pcFromId, pcToId)

	    If This.Title() != ""
		This.SetSubtitle("Path from '" + @aNodes[pcFromId] + "' to '" + @aNodes[pcFromId] + "'" )
	    ok

	    acPath = This.PathBetween(pcFromId, pcToId)
	    This.ApplyFocusTo(acPath)
	    This.View()
	
	    def ViewReportingPath(pcFromId, pcToId)
	        This.ViewPath(pcFromId, pcToId)

	    def HilightPath(pcFromId, pcToId)
		This.ViewPath(pcFromId, pcToId)

	    def FocusOnPath(pcFromId, pcToId)
		This.ViewPath(pcFromId, pcToId)

	#--

	def ViewNodesWithProperty(pcKey, pValue)

	    If This.Title() != ""
		This.SetSubtitle("Nodes with property " + @@([ pcKey, pValue ]) )
	    ok

	    acMatching = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode["properties"], pcKey)
	            if pValue = NULL or aNode["properties"][pcKey] = pValue
	                acMatching + aNode["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(acMatching)
	    This.View()
	
	def ViewNodeWithProperties(pacProps)
		#TODO

	def ViewNodesWithTag(pcTag)

	    If This.Title() != ""
		This.SetSubtitle("Nodes with tag '" + pcTag + "'")
	    ok

	    acMatching = []
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        if HasKey(aNode["properties"], "tags")
	            if ring_find(aNode["properties"]["tags"], pcTag) > 0
	                acMatching + aNode["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(acMatching)
	    This.View()

	def ViewNodesWithTags(pacTags)
		#TODO

	#--

	def ColorByDepartment()

	    nPosCount = len(@aPositions)
	    for i = 1 to nPosCount
	        cDept = @aPositions[i][:department]
	        if cDept != "" and HasKey($aOrgColors, cDept)
	            # Use parent's color resolution (respects themes)
	            This.SetNodeProperty(@aPositions[i][:id], "color", $aOrgColors[cDept])
	        ok
	    end

	#==========================#
	#  ORGANIZATIONAL EXPLAIN  #
	#==========================#

	def Explain()
		aExplanation = [
			:type = "Organization Chart",
			:structure = "",
			:hierarchy = [],
			:staffing = [],
			:compliance = [],
			:risks = [],
			:efficiency = []
		]
		
		# Structure overview
		nPos = len(@aPositions)
		nPeople = len(@aPeople)
		nDepts = len(@aDepartments)
		aExplanation[:structure] = "Organization '" + @cId + "' has " + nPos + 
		                           " positions, " + nPeople + " people, and " + 
		                           nDepts + " departments."
		
		# Hierarchy analysis
		aLevels = This.PositionsByLevel()
		nLvlLen = len(aLevels)
		for i = 1 to nLvlLen
			aExplanation[:hierarchy] + ( aLevels[i][1] + ": " + len(aLevels[i][2]) + " positions")
		end
		
		nAvgSpan = This.AverageSpanOfControl()
		aExplanation[:hierarchy] + ("Average span of control: " + nAvgSpan)
		
		# Staffing status
		nVacRate = This.VacancyRate()
		aExplanation[:staffing] + ("Vacancy rate: " + nVacRate + "%")
		
		acVacant = This.VacantPositions()
		if len(acVacant) > 0
			aExplanation[:staffing] + ("Vacant positions: " + JoinXT(acVacant, ", "))
		else
			aExplanation[:staffing] + "All positions filled"
		ok
		
		# Succession risk
		acRisk = This.SuccessionRisk()
		if len(acRisk) > 0
			aExplanation[:risks] + ("Succession risk: " + len(acRisk) + " positions without successor")
			aExplanation[:risks] + ("At-risk positions: " + JoinXT(acRisk, ", "))
		else
			aExplanation[:risks] + "No succession risks identified"
		ok
		
		# Compliance checks
		aBCEAO = This.ValidateBCEAOGovernance()
		aSOC = This.ValidateSpanOfControl()
		aSOD = This.ValidateSegregationOfDuties()
		
		nIssues = 0
		if aBCEAO[:status] = "fail"
			nIssues += len(aBCEAO[:issues])
		ok
		if aSOC[:status] = "fail"
			nIssues += len(aSOC[:issues])
		ok
		if aSOD[:status] = "fail"
			nIssues += len(aSOD[:issues])
		ok
		
		if nIssues = 0
			aExplanation[:compliance] + "All compliance checks passed"
		else
			aExplanation[:compliance] + ("Found " + nIssues + " compliance issues")
			if aBCEAO[:status] = "fail"
				aExplanation[:compliance] + ("BCEAO: " + joinXT(aBCEAO[:issues], "; "))
			ok
			if aSOC[:status] = "fail"
				aExplanation[:compliance] + ("Span of Control: " + joinXT(aSOC[:issues], "; "))
			ok
			if aSOD[:status] = "fail"
				aExplanation[:compliance] + ("Segregation of Duties: " + joinXT(aSOD[:issues], "; "))
			ok
		ok
		
		# Efficiency metrics
		if nAvgSpan < 3
			aExplanation[:efficiency] + "Span of control may be underutilized (< 3 reports average)"
		but nAvgSpan > 9
			aExplanation[:efficiency] + "WARNING: Span of control exceeds recommended limit (> 9 reports average)"
		else
			aExplanation[:efficiency] + "Span of control within optimal range (3-9 reports)"
		ok
		
		if nVacRate > 20
			aExplanation[:efficiency] + "HIGH vacancy rate - may impact operations"
		but nVacRate > 10
			aExplanation[:efficiency] + "Moderate vacancy rate - monitor staffing"
		else
			aExplanation[:efficiency] + "Healthy staffing levels"
		ok
		
		return aExplanation

	#============================#
	#  EXPORT TO .STZORG FORMAT  #
	#============================#

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
		if right(pcFileName, 7) != ".stzorg"
			pcFileName += ".stzorg"
		ok

		write(pcfileName, This.ToStzOrg())
		return TRUE
	
	def WriteStzOrg(pcFileName)
		write(pcfileName, This.ToStzOrg())
			return TRUE

	#=====================================================
	#  IMPORT FROM .STZORG FORMAT
	#=====================================================
	
	def ImportStzOrg(cString)
		acLines = @split(cString, NL)
		cCurrentSection = ""
		cCurrentId = ""
		aCurrent = []
		cTitle = ""
	
		nLen = len(acLines)
		for i = 1 to nLen
			cLine = trim(acLines[i])
			if cLine = '' or left(cLine, 1) = "#"
				loop
			ok
			
			if substr(cLine, "orgchart ")
				cTitle = @substr(cLine, 10, len(cLine)-1)
				
			but cLine = "positions"
				# Flush previous section
				if cCurrentSection = "positions" and cCurrentId != ""
					This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
					if aCurrent[:department] != "" and
					   trim(aCurrent[:department]) != ""
						This.SetPositionDepartment(cCurrentId, aCurrent[:department])
					ok
					if aCurrent[:reportsTo] != "" and
					   trim(aCurrent[:reportsTo]) != ""
						This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
					ok

				but cCurrentSection = "people" and cCurrentId != ""
					This.AddPersonXT(cCurrentId, aCurrent[:name])

				but cCurrentSection = "departments" and cCurrentId != ""
					This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
				ok
				
				cCurrentSection = "positions"
				cCurrentId = ""
				
			but cLine = "people"
				# Flush previous section
				if cCurrentSection = "positions" and cCurrentId != ""
					This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
					if aCurrent[:department] != "" and
					   trim(aCurrent[:department]) != ""
						This.SetPositionDepartment(cCurrentId, aCurrent[:department])
					ok
					if aCurrent[:reportsTo] != "" and
					   trim(aCurrent[:reportsTo]) != ""
						This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
					ok

				but cCurrentSection = "people" and cCurrentId != ""
					This.AddPersonXT(cCurrentId, aCurrent[:name])

				but cCurrentSection = "departments" and cCurrentId != ""
					This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
				ok
				
				cCurrentSection = "people"
				cCurrentId = ""
				
			but cLine = "assignments"
				# Flush previous section
				if cCurrentSection = "positions" and cCurrentId != ""
					This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
					if aCurrent[:department] != "" and
					   trim(aCurrent[:department]) != ""
						This.SetPositionDepartment(cCurrentId, aCurrent[:department])
					ok
					if aCurrent[:reportsTo] != "" and
					   trim(aCurrent[:reportsTo]) != ""
						This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
					ok

				but cCurrentSection = "people" and cCurrentId != ""
					This.AddPersonXT(cCurrentId, aCurrent[:name])

				but cCurrentSection = "departments" and cCurrentId != ""
					This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
				ok
				
				cCurrentSection = "assignments"
				cCurrentId = ""
				
			but cLine = "departments"
				# Flush previous section
				if cCurrentSection = "positions" and cCurrentId != ""
					This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
					if aCurrent[:department] != "" and
					   trim(aCurrent[:department]) != ""
						This.SetPositionDepartment(cCurrentId, aCurrent[:department])
					ok
					if aCurrent[:reportsTo] != "" and
					   trim(aCurrent[:reportsTo]) != ""
						This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
					ok

				but cCurrentSection = "people" and cCurrentId != ""
					This.AddPersonXT(cCurrentId, aCurrent[:name])

				but cCurrentSection = "departments" and cCurrentId != ""
					This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
				ok
				
				cCurrentSection = "departments"
				cCurrentId = ""
				
			but cCurrentSection = "positions"
				if NOT substr(cLine, ":")

					# Flush previous position
					if cCurrentId != ""
						This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
						if aCurrent[:department] != "" and
						   trim(aCurrent[:department]) != ""
							This.SetPositionDepartment(cCurrentId, aCurrent[:department])
						ok
						if aCurrent[:reportsTo] != "" and
						   trim(aCurrent[:reportsTo]) != ""
							This.ReportsTo(cCurrentId, aCurrent[:reportsTo])
						ok
					ok
					
					cCurrentId = cLine
					aCurrent = [
						:title = "",
						:level = "",
						:department = "",
						:reportsTo = ""
					]
					
				but substr(cLine, "title:")
					aCurrent[:title] = trim(@substr(cLine, 7, len(cLine)))
					# Remove quotes if present
					if left(aCurrent[:title], 1) = '"' and
					   right(aCurrent[:title], 1) = '"'
						aCurrent[:title] = @substr(aCurrent[:title], 2, len(aCurrent[:title]) - 1)
					ok
					
				but substr(cLine, "level:")
					aCurrent[:level] = trim(@substr(cLine, 7, len(cLine)))
					
				but substr(cLine, "department:")
					aCurrent[:department] = trim(@substr(cLine, 12, len(cLine)))
					
				but substr(cLine, "reportsTo:")
					aCurrent[:reportsTo] = trim(@substr(cLine, 11, len(cLine)))
				ok
				
			but cCurrentSection = "people"
				if NOT substr(cLine, ":")
					# Flush previous person
					if cCurrentId != ""
						This.AddPersonXT(cCurrentId, aCurrent[:name])
					ok
					
					cCurrentId = cLine
					aCurrent = [ :name = "" ]
					
				but substr(cLine, "name:")
					aCurrent[:name] = trim(@substr(cLine, 6, len(cLine)))
				ok
				
			but cCurrentSection = "assignments"
				if substr(cLine, " -> ")
					aParts = @split(cLine, " -> ")
					This.AssignPerson(trim(aParts[1]), trim(aParts[2]))
				ok
				
			but cCurrentSection = "departments"
				if NOT substr(cLine, ":")
					# Flush previous department
					if cCurrentId != ""
						This.AddDepartmentXTT(cCurrentId, aCurrent[:name], aCurrent[:positions])
					ok
					
					cCurrentId = cLine
					aCurrent = [ :name = "", :positions = [] ]
					
				but substr(cLine, "name:")
					aCurrent[:name] = trim(@substr(cLine, 6, len(cLine)))
					
				but substr(cLine, "positions:")
					cPosStr = trim(@substr(cLine, 11, len(cLine)))
					cPosStr = replace(cPosStr, "[", "")
					cPosStr = replace(cPosStr, "]", "")
					aCurrent[:positions] = @split(cPosStr, ",")
					nPosLen = len(aCurrent[:positions])
					for j = 1 to nPosLen
						aCurrent[:positions][j] = trim(aCurrent[:positions][j])
					end
				ok
			ok
		end
		
		# Flush last item
		if cCurrentSection = "positions" and cCurrentId != ""
			This.AddPositionXTT(cCurrentId, aCurrent[:title], [ :level = aCurrent[:level] ])
			if aCurrent[:department] != "" and
			   trim(aCurrent[:department]) != ""
				This.SetPositionDepartment(cCurrentId, aCurrent[:department])
			ok
			if aCurrent[:reportsTo] != "" and
			   trim(aCurrent[:reportsTo]) != ""
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
	
		def LoadStzOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def LoadOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def ImportOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def LoadOrgChart(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def LoadStzOrgFile(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def Load_(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def LoadFile(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		def LoadFrom(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

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

	def Generate()
		aResult = []

		aResult + This.SummaryReport()
		aResult + This.VacancyReport()
		aResult + This.SuccessionReport()
		aResult + This.ComplianceReport()
		aResult + This.SpanOfControlReport()

		return aResult

	def GenerateXT(pcType)
		switch lower(pcType)
		on "summary"
			return This.SummaryReport()

		on "vacancies"
			return This.VacancyReport()
		on "vacancy"
			return This.VacancyReport()
		on "vacant"
			return This.VacancyReport()

		on "succession"
			return This.SuccessionReport()

		on "compliance"
			return This.ComplianceReport()

		on "span"
			return This.SpanOfControlReport()
		on "spanofcontrol"
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

		def Summary()
			return This.SummaryReport()

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

		def Vacancy()
			return This.VacancyReport()

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


		def Succession()
			return This.SuccessionReport()

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

		def Compliance()
			return This.ComplianceReport()

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

		def SpanOfControl()
			return This.SpanOfControlReport()

		def SOC()
			return This.SpanOfControlReport()

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
