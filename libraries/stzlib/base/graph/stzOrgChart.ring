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

func StzOrgChartDefaultValidators()
	return $acOrgChartDefaultValidators

	func OrgChartDefaultValidators()
		return StzOrgChartDefaultValidators()

	func DefaultOrgChartValidators()
		return StzOrgChartDefaultValidators()

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

	# Rule-base sources loaded via LoadRuleBase (file path, profile
	# name, or rule-base object). Consumed by the future rule-eval
	# engine; for now this is just a recorded list.
	@aRuleBases = []

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

		_aPosition_ = [
			:id = pcId,
			:title = pcTitle
		]
		_nLen_ = len(paAttributes)
		for i = 1 to _nLen_
			_aPosition_ + paAttributes[i]
		next

		@aPositions + _aPosition_
		
		This.AddNodeXTT(pcId, pcTitle, [
			:type = "box",
			:color = "white",
			:positionType = "position"
		])

	    # Ensure attributes flow to node properties
	    if isList(paAttributes) and len(paAttributes) > 0
	        _acKeys_ = keys(paAttributes)
	        _nKeyLen_ = len(_acKeys_)
	        for i = 1 to _nKeyLen_
	            This.SetNodeProperty(pcId, _acKeys_[i], paAttributes[_acKeys_[i]])
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
		# Typo: pcIde -> pcId. Method was unreachable -- R24 every call.
		This.AddStaffPositionXT(pcId, pcId)

		def AddStaff(pcId)
			# Same typo as parent. R24 every call.
			This.AddStaffPositionXT(pcId, pcId)

	def AddStaffPositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])
	    	# Don't set color here

		def AddStaffXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "staff"])

	def AddStaffPositionXTT(pcId, pcTitle, paProp)
	    # Typo: paprop -> paProp. Method was unreachable -- R24 every call.
	    if NOT IsHashList(paProp)
	        stzraise("Incorrect param type! paProp must be a hashlist.")
	    ok
	
	    _bLevel_ = HasKey(paProp, "level")
	
	    if NOT _bLevel_
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
	    _nPosCount_ = len(@aPositions)
	    for i = 1 to _nPosCount_
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
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			if @aPositions[i][:id] = pcPositionId
				@aPositions[i][:department] = pcDepartment
				exit
			ok
		end
		This.SetNodeProperty(pcPositionId, "department", pcDepartment)

	#---

	def Position(pcId)
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
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
		_acVacant_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @aPositions[i]
			_bIsVacant_ = TRUE
			if HasKey(_aPos_, :isVacant)
				_bIsVacant_ = _aPos_[:isVacant]
			ok
			
			if _bIsVacant_ = TRUE
				if HasKey(_aPos_, :id)
					_acVacant_ + _aPos_[:id]
				ok
			ok
		end
		return _acVacant_

		def Vacant()
			return This.VacantPositions()

		def VacantNodes()
			return This.VacantPositions()

	def NonVacantPositions()
		_acNonVacant_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @aPositions[i]
			_bIsVacant_ = TRUE
			if HasKey(_aPos_, :isVacant)
				_bIsVacant_ = _aPos_[:isVacant]
			ok
			
			if _bIsVacant_ = FALSE
				if HasKey(_aPos_, :id)
					_acNonVacant_ + _aPos_[:id]
				ok
			ok
		end
		return _acNonVacant_

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
		_aPerson_ = [
			:id = pcId,
			:name = pcName,
			:position = "",
			:data = paData
		]
		@aPeople + _aPerson_

	#---

	def AssignPerson(pcPersonId, pcPositionId)

		if CheckParams()
			if isList(pcPositionId) and IsToOrToPositionOrToNodeNamedParamList(pcPositionId)
				pcPositionId = pcPositionId[2]
			ok
			if NOT isString(pcPositionId)
				stzraise("Incorrect param type! pcPositionId must be a string.")
			ok
		ok

		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			if @aPositions[i][:id] = pcPositionId
				@aPositions[i][:incumbent] = pcPersonId
				@aPositions[i][:isVacant] = FALSE
				exit
			ok
		end
		
		_nPplCount_ = len(@aPeople)
		for i = 1 to _nPplCount_
			if @aPeople[i][:id] = pcPersonId
				@aPeople[i][:position] = pcPositionId
				exit
			ok
		end
		
		_aPerson_ = This.PersonData(pcPersonId)
		_aPosition_ = This.Position(pcPositionId)
		_cLabel_ = _aPosition_[:title] + "\n" + _aPerson_[:name]

		# Restore level color when filled
		_aPosition_ = This.Position(pcPositionId)
		_cLevelColor_ = "white"
		    
		if isList(_aPosition_[:attributes]) and HasKey(_aPosition_[:attributes], :level)
		        _cLevel_ = _aPosition_[:attributes][:level]
		        if _cLevel_ = "executive"
		            _cLevelColor_ = $aOrgColors[:executive]
		        but _cLevel_ = "management"
		            _cLevelColor_ = $aOrgColors[:management]
		        but _cLevel_ = "staff"
		            _cLevelColor_ = $aOrgColors[:staff]
		        ok
		ok

		This.SetNodeProperty(pcPositionId, "color", _cLevelColor_)

		def Assign(pcPersonId, pcPositionId)
			This.AssignPerson(pcPersonId, pcPositionId)

	def Person(pcPersonId)
		_nPplCount_ = len(@aPeople)
		for i = 1 to _nPplCount_
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
		_aDept_ = [
			:id = pcId,
			:name = pcName,
			:positions = paPositions,
			:head = ""
		]
		@aDepartments + _aDept_
		
		if len(paPositions) > 0
			This.AddClusterXTT(pcId, pcName, paPositions, @cClusterColor)
		ok

	def Department(pcId)
		_nDeptCount_ = len(@aDepartments)
		for i = 1 to _nDeptCount_
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
			_aResults_ = []
			_nFailed_ = 0
			_nTotalIssues_ = 0
			_acAllAffected_ = []
			
			_nLen_ = len(pValidator)
			for i = 1 to _nLen_
				_aResult_ = This._ValidateSingle(pValidator[i])
				_aResults_ + _aResult_
				if _aResult_[:status] = "fail"
					_nFailed_++
					_nTotalIssues_ += _aResult_[:issueCount]
					_nAffLen_ = len(_aResult_[:affectedNodes])
					for j = 1 to _nAffLen_
						if StzFindFirst(_acAllAffected_, _aResult_[:affectedNodes][j]) = 0
							_acAllAffected_ + _aResult_[:affectedNodes][j]
						ok
					end
				ok
			end
			
			return [
				:status = iif(_nFailed_ = 0, "pass", "fail"),
				:validatorsRun = len(pValidator),
				:validatorsFailed = _nFailed_,
				:totalIssues = _nTotalIssues_,
				:results = _aResults_,
				:affectedNodes = _acAllAffected_
			]
		ok

	def IsValid()
		_aResult_ = This.Validate()
		return _aResult_[:status] = "pass"

	def IsValidXT(pValidator)
		_aResult_ = This.ValidateXT(pValidator)
		return _aResult_[:status] = "pass"

	def _ValidateSingle(pcValidator)
		switch StzLower(pcValidator)

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
		_oValidator_ = new stzOrgChartBCEAOValidator(This)
		return _oValidator_.Validate()

	def ValidateSpanOfControl()
		_aIssues_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_cPosId_ = @aPositions[i][:id]
			_nDirectReports_ = This.DirectReportsCount(_cPosId_)
			
			if _nDirectReports_ > 9
				_aIssues_ + ("Excessive span: " + _cPosId_ + " (" + _nDirectReports_ + " reports)" )
			ok
		end
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "span_of_control",
			:issues = _aIssues_
		]

	def ValidateSegregationOfDuties()
		_oValidator_ = new stzOrgChartSODValidator(This)
		return _oValidator_.Validate()

	def ValidateVacancy()
		_acVacant_ = This.VacantPositions()
		
		return [
			:status = iif(len(_acVacant_) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(_acVacant_),
			:issues = iif(len(_acVacant_) > 0, ["Vacant positions: " + len(_acVacant_)], []),
			:affectedNodes = _acVacant_
		]
	
	def ValidateNonVacancy()
		_acVacant_ = This.NonVacantPositions()
		
		return [
			:status = iif(len(_acVacant_) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(_acVacant_),
			:issues = iif(len(_acVacant_) > 0, ["Vacant positions: " + len(_acVacant_)], []),
			:affectedNodes = _acVacant_
		]

	def ValidateSuccession()
		_acRisk_ = This.SuccessionRisk()
		_aIssues_ = []
		_nLen_ = len(_acRisk_)
		for i = 1 to _nLen_
			_aIssues_ + ("No successor: " + _acRisk_[i])
		end
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "succession",
			:issueCount = len(_aIssues_),
			:issues = _aIssues_,
			:affectedNodes = _acRisk_
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
		_acReports_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			if @aPositions[i][:reportsTo] = pcPositionId
				_acReports_ + @aPositions[i][:id]
			ok
		end
		return _acReports_

	#==========================#
	#  ORGANIZATIONAL METRICS  #
	#==========================#

	def AverageSpanOfControl()
		_nTotal_ = 0
		_nManagers_ = 0
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_cPosId_ = @aPositions[i][:id]
			_nReports_ = This.DirectReportsCount(_cPosId_)
			if _nReports_ > 0
				_nTotal_ += _nReports_
				_nManagers_++
			ok
		end
		if _nManagers_ = 0
			return 0
		ok
		return _nTotal_ / _nManagers_

	def VacancyRate()	
		_nResult_ = ( len(This.Vacant()) / len(This.Positions()) ) * 100
		return _nResult_

	def PositionsByLevel()
		_aResult_ = [
			:executive = [],
			:management = [],
			:staff = []
		]

		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_cLevel_ = "staff"
			if HasKey(@aPositions[i], "level")
				if haskey(_aResult_, @aPositions[i][:level])
					_aResult_[@aPositions[i][:level]] + @aPositions[i][:id]
				ok
			ok
			
		end
		return _aResult_

	def NumberOfPositionsByLevel()
		_aResult_ = [
			:executive = 0,
			:management = 0,
			:staff = 0
		]

		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_cLevel_ = "staff"
			if HasKey(@aPositions[i], "level")
				if haskey(_aResult_, @aPositions[i][:level])
					_aResult_[@aPositions[i][:level]]++
				ok
			ok
			
		end
		return _aResult_

		def PositionsCountByLevel()
			return This.NumberOfPositionsByLevel()

		def PositionsByLevelN()
			return This.NumberOfPositionsByLevel()

	def SuccessionRisk()
	    _acRisk_ = []
	    _nPosCount_ = len(@aPositions)
	    for i = 1 to _nPosCount_
	        _aPos_ = @aPositions[i]
	        _bVacant_ = TRUE
	        if HasKey(_aPos_, :isVacant)
	            _bVacant_ = _aPos_[:isVacant]
	        ok
	        
	        if NOT _bVacant_
	            _bHasSuccessor_ = FALSE
	            # Fix: Check attributes as list
	            if isList(_aPos_[:attributes]) and HasKey(_aPos_[:attributes], :successor)
	                _bHasSuccessor_ = TRUE
	            ok
	            
	            if NOT _bHasSuccessor_
	                if HasKey(_aPos_, :id)
	                    _acRisk_ + _aPos_[:id]
	                ok
	            ok
	        ok
	    end
	    return _acRisk_

	#==========================#
	#  REPORTING & ANALYTICS   #
	#==========================#

	def GenerateReport()
		# Reports generated --> [ "summary", "vacancy", "succession", "compliance", "spanofcontrol" ]

		_oReporter_ = new stzOrgChartReporter(This)
		return _oReporter_.Generate()

		def Report()
			return This.GenerateReport()

	def GenerateReportXT(pcType)
		# pcType --> [ "summary", "vacancy", "succession", "compliance", "spanofcontrol" ]

		_oReporter_ = new stzOrgChartReporter(This)
		return _oReporter_.GenerateXT(pcType)

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
			if isList(pcNewPositionId) and IsToOrToPositionNamedParamList(pcNewPositionId)
				pcNewPositionId = pcNewPositionId[2]
			ok
			if NOT isString(pcNewPositionId)
				stzraise("Incorrect param type! pcNewPositionId must be a string.")
			ok
		ok

		_aPerson_ = This.PersonData(pcPersonId)
		_cOldPosition_ = _aPerson_[:position]
		
		if _cOldPosition_ != ""
			_nPosCount_ = len(@aPositions)
			for i = 1 to _nPosCount_
				if @aPositions[i][:id] = _cOldPosition_
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
		_nPosCount_ = len(@aPositions)
		_nIndex_ = 0
		
		for i = 1 to _nPosCount_
			if @aPositions[i][:id] = pcPositionId
				_nIndex_ = i
				exit
			ok
		end
		
		if _nIndex_ > 0
			if NOT @aPositions[_nIndex_][:isVacant]
				_cPersonId_ = @aPositions[_nIndex_][:incumbent]
				_nPplCount_ = len(@aPeople)
				for j = 1 to _nPplCount_
					if @aPeople[j][:id] = _cPersonId_
						@aPeople[j][:position] = ""
						exit
					ok
				end
			ok
			del(@aPositions, _nIndex_)
			This.RemoveNode(pcPositionId)
		ok

	def ChangeReportingLine(pcSubordinate, pcNewSupervisor)
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			if @aPositions[i][:id] = pcSubordinate
				_cOldSupervisor_ = @aPositions[i][:reportsTo]
				@aPositions[i][:reportsTo] = pcNewSupervisor
				
				if _cOldSupervisor_ != ""
					This.Disconnect(_cOldSupervisor_, pcSubordinate)
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
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    for i = 1 to _nLen_
	        _cNodeId_ = _aNodes_[i]["id"]
	        _aPos_ = This.Position(_cNodeId_)
	        
	        # Restore original level color
	        _cOriginalColor_ = "white"
	        if HasKey(_aPos_, :attributes) and HasKey(_aPos_[:attributes], :level)
	            _cLevel_ = _aPos_[:attributes][:level]
	            if _cLevel_ = "executive"
	                _cOriginalColor_ = $aOrgColors[:executive]
	            but _cLevel_ = "management"
	                _cOriginalColor_ = $aOrgColors[:management]
	            but _cLevel_ = "staff"
	                _cOriginalColor_ = $aOrgColors[:staff]
	            ok
	        ok
	        
	        This.SetNodeProperty(_cNodeId_, "color", _cOriginalColor_)
	    end
	
	def ApplyFocusTo(acNodeIds)
	    # Reset all first
	    This.ResetAllNodeColors()
	    
	    # Apply focus to specified nodes
	    _nLen_ = len(acNodeIds)
	    for i = 1 to _nLen_
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
	    _aResult_ = This.ValidateXT(pcValidator)
	    This.ViewValidation(_aResult_)

	#--


	def ViewVacant()

	    If This.Title() != ""
		This.SetSubtitle("Vacant Positions")
	    ok

	    _acVacant_ = This.VacantPositions()
	    This.ApplyFocusTo(_acVacant_)
	    This.View()
	
	    def ViewVacancies()
	        This.ViewVacant()

	def ViewNonVacant()

	    If This.Title() != ""
		This.SetSubtitle("Non-Vacant Positions")
	    ok

	    _acVacant_ = This.NonVacantPositions()
	    This.ApplyFocusTo(_acVacant_)
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

	    _acHigh_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _aNode_ = _aNodes_[i]
	        if HasKey(_aNode_["properties"], "performance")
	            _nScore_ = _aNode_["properties"]["performance"]
	            if _nScore_ >= 75
	                _acHigh_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acHigh_)
	    This.View()
	
	    def ViewHighPerformers()
	        This.ViewPerformant()
	
	def ViewNonPerformant()

	    If This.Title() != ""
		This.SetSubtitle("Non-performant Positions")
	    ok

	    _acLow_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _aNode_ = _aNodes_[i]
	        if HasKey(_aNode_["properties"], "performance")
	            _nScore_ = _aNode_["properties"]["performance"]
	            if _nScore_ < 50
	                _acLow_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acLow_)
	    This.View()
	
	    def ViewLowPerformers()
	        This.ViewNonPerformant()
	
	#TODO // Add MediumPerformers()

	def ViewMediumPerformers()

	    If This.Title() != ""
		This.SetSubtitle("Medium-performer Positions")
	    ok

	    _acMedium_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _aNode_ = _aNodes_[i]
	        if HasKey(_aNode_["properties"], "performance")
	            _nScore_ = _aNode_["properties"]["performance"]
	            if _nScore_ >= 50 and _nScore_ < 75
	                _acMedium_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acMedium_)
	    This.View()

	#--

	#TODO // Add Compliant() or CompliantPositions() and
	# NonCompliant() or NonCompliantPositions()

	def ViewCompliant(pcNorm)

	    If This.Title() != ""
		This.SetSubtitle("Compliant posisitions")
	    ok

	    _aResult_ = This.ValidateXT(pcNorm)
	    
	    if isNumber(_aResult_)
	        if _aResult_ = 1
	            _acAll_ = []
	            _aNodes_ = This.Nodes()
	            _nLen_ = len(_aNodes_)
	            for i = 1 to _nLen_
	                _acAll_ + _aNodes_[i]["id"]
	            end
	            This.ApplyFocusTo(_acAll_)
	        else
	            This.ApplyFocusTo([])
	        ok
	        This.View()
	        return
	    ok
	    
	    if _aResult_[:status] = "pass"
	        _acAll_ = []
	        _aNodes_ = This.Nodes()
	        _nLen_ = len(_aNodes_)
	        for i = 1 to _nLen_
	            _acAll_ + _aNodes_[i]["id"]
	        end
	        This.ApplyFocusTo(_acAll_)
	    else
	        # For failures, only show focused nodes if issues mention specific nodes
	        _acIssueNodes_ = This._ExtractNodesFromIssues(_aResult_[:issues])
	        if len(_acIssueNodes_) > 0
	            # Show compliant nodes (not in issues)
	            _acAll_ = []
	            _aNodes_ = This.Nodes()
	            _nLen_ = len(_aNodes_)
	            for i = 1 to _nLen_
	                _cNodeId_ = _aNodes_[i]["id"]
	                if StzFindFirst(_cNodeId_, _acIssueNodes_) = 0
	                    _acAll_ + _cNodeId_
	                ok
	            end
	            This.ApplyFocusTo(_acAll_)
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

	    _aResult_ = This.Validate(pcNorm)
	    
	    # Handle boolean results
	    if isNumber(_aResult_)
	        if _aResult_ = 0  # FALSE = all non-compliant
	            _acAll_ = []
	            _aNodes_ = This.Nodes()
	            _nLen_ = len(_aNodes_)
	            for i = 1 to _nLen_
	                _acAll_ + _aNodes_[i]["id"]
	            end
	            This.ApplyFocusTo(_acAll_)
	        else  # TRUE = none non-compliant
	            This.ApplyFocusTo([])
	        ok
	        This.View()
	        return
	    ok
	    
	    # Handle hashlist results
	    if _aResult_[:status] = "fail"
	        _acIssueNodes_ = This._ExtractNodesFromIssues(_aResult_[:issues])
	        This.ApplyFocusTo(_acIssueNodes_)
	    else
	        This.ApplyFocusTo([])
	    ok
	    
	    This.View()
	
	    def ViewNonCompliantXT(pcNorm)
		This.ViewNonCompliant(pcNorm)

	def _ExtractNodesFromIssues(acIssues)
	    _acNodes_ = []
	    _nLen_ = len(acIssues)
	    
	    for i = 1 to _nLen_
	        _cIssue_ = acIssues[i]
	        # Parse issue string to extract node IDs
	        # Format: "BCEAO-002: Audit reports to non-board position"
	        # or: "SOC-001: Position X has excessive span"
	        
	        _aWords_ = @split(_cIssue_, " ")
	        _nWordLen_ = len(_aWords_)
	        for j = 1 to _nWordLen_
	            _cWord_ = _aWords_[j]
	            # Check if this word is a node ID
	            if This.NodeExists(_cWord_)
	                if StzFindFirst(_cWord_, _acNodes_) = 0
	                    _acNodes_ + _cWord_
	                ok
	            ok
	        end
	    end
	    
	    return _acNodes_

	#--
	
	def ViewAtRisk()

	    If This.Title() != ""
		This.SetSubtitle("At risk posisitions")
	    ok

	    _acRisk_ = This.SuccessionRisk()
	    This.ApplyFocusTo(_acRisk_)
	    This.View()
	
	    def ViewSuccessionRisk()
	        This.ViewAtRisk()
	
	def ViewNotAtRisk()

	    If @bShowTitle = TRUE
		This.SetSubtitle("Not-at risk posisitions")
	    ok

	    _acRisk_ = This.SuccessionRisk()
	    _acAll_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _cNodeId_ = _aNodes_[i]["id"]
	        if StzFindFirst(_cNodeId_, _acRisk_) = 0
	            _acAll_ + _cNodeId_
	        ok
	    end
	    
	    This.ApplyFocusTo(_acAll_)
	    This.View()

	#--

	def ViewDepartment(pcDepartmentId)

	    If This.Title() != ""
		This.SetSubtitle("Department '" + @aDepartments[PpcDepartmentId]  + "'")
	    ok

	    _acDeptNodes_ = []
	    _nPosCount_ = len(@aPositions)
	    
	    for i = 1 to _nPosCount_
	        if @aPositions[i][:department] = pcDepartmentId
	            _acDeptNodes_ + @aPositions[i][:id]
	        ok
	    end
	    
	    This.ApplyFocusTo(_acDeptNodes_)
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

	    _acPath_ = This.PathBetween(pcFromId, pcToId)
	    This.ApplyFocusTo(_acPath_)
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

	    _acMatching_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _aNode_ = _aNodes_[i]
	        if HasKey(_aNode_["properties"], pcKey)
	            if pValue = NULL or _aNode_["properties"][pcKey] = pValue
	                _acMatching_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acMatching_)
	    This.View()
	
	def ViewNodeWithProperties(pacProps)
		#TODO

	def ViewNodesWithTag(pcTag)

	    If This.Title() != ""
		This.SetSubtitle("Nodes with tag '" + pcTag + "'")
	    ok

	    _acMatching_ = []
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    
	    for i = 1 to _nLen_
	        _aNode_ = _aNodes_[i]
	        if HasKey(_aNode_["properties"], "tags")
	            if StzFindFirst(pcTag, _aNode_["properties"]["tags"]) > 0
	                _acMatching_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acMatching_)
	    This.View()

	def ViewNodesWithTags(pacTags)
		#TODO

	#--

	def ColorByDepartment()

	    _nPosCount_ = len(@aPositions)
	    for i = 1 to _nPosCount_
	        _cDept_ = @aPositions[i][:department]
	        if _cDept_ != "" and HasKey($aOrgColors, _cDept_)
	            # Use parent's color resolution (respects themes)
	            This.SetNodeProperty(@aPositions[i][:id], "color", $aOrgColors[_cDept_])
	        ok
	    end

	#==========================#
	#  ORGANIZATIONAL EXPLAIN  #
	#==========================#

	def Explain()
		_aExplanation_ = [
			:type = "Organization Chart",
			:structure = "",
			:hierarchy = [],
			:staffing = [],
			:compliance = [],
			:risks = [],
			:efficiency = []
		]
		
		# Structure overview
		_nPos_ = len(@aPositions)
		_nPeople_ = len(@aPeople)
		_nDepts_ = len(@aDepartments)
		_aExplanation_[:structure] = "Organization '" + @cId + "' has " + _nPos_ + 
		                           " positions, " + _nPeople_ + " people, and " + 
		                           _nDepts_ + " departments."
		
		# Hierarchy analysis
		_aLevels_ = This.PositionsByLevel()
		_nLvlLen_ = len(_aLevels_)
		for i = 1 to _nLvlLen_
			_aExplanation_[:hierarchy] + ( _aLevels_[i][1] + ": " + len(_aLevels_[i][2]) + " positions")
		end
		
		_nAvgSpan_ = This.AverageSpanOfControl()
		_aExplanation_[:hierarchy] + ("Average span of control: " + _nAvgSpan_)
		
		# Staffing status
		_nVacRate_ = This.VacancyRate()
		_aExplanation_[:staffing] + ("Vacancy rate: " + _nVacRate_ + "%")
		
		_acVacant_ = This.VacantPositions()
		if len(_acVacant_) > 0
			_aExplanation_[:staffing] + ("Vacant positions: " + JoinXT(_acVacant_, ", "))
		else
			_aExplanation_[:staffing] + "All positions filled"
		ok
		
		# Succession risk
		_acRisk_ = This.SuccessionRisk()
		if len(_acRisk_) > 0
			_aExplanation_[:risks] + ("Succession risk: " + len(_acRisk_) + " positions without successor")
			_aExplanation_[:risks] + ("At-risk positions: " + JoinXT(_acRisk_, ", "))
		else
			_aExplanation_[:risks] + "No succession risks identified"
		ok
		
		# Compliance checks
		_aBCEAO_ = This.ValidateBCEAOGovernance()
		_aSOC_ = This.ValidateSpanOfControl()
		_aSOD_ = This.ValidateSegregationOfDuties()
		
		_nIssues_ = 0
		if _aBCEAO_[:status] = "fail"
			_nIssues_ += len(_aBCEAO_[:issues])
		ok
		if _aSOC_[:status] = "fail"
			_nIssues_ += len(_aSOC_[:issues])
		ok
		if _aSOD_[:status] = "fail"
			_nIssues_ += len(_aSOD_[:issues])
		ok
		
		if _nIssues_ = 0
			_aExplanation_[:compliance] + "All compliance checks passed"
		else
			_aExplanation_[:compliance] + ("Found " + _nIssues_ + " compliance issues")
			if _aBCEAO_[:status] = "fail"
				_aExplanation_[:compliance] + ("BCEAO: " + joinXT(_aBCEAO_[:issues], "; "))
			ok
			if _aSOC_[:status] = "fail"
				_aExplanation_[:compliance] + ("Span of Control: " + joinXT(_aSOC_[:issues], "; "))
			ok
			if _aSOD_[:status] = "fail"
				_aExplanation_[:compliance] + ("Segregation of Duties: " + joinXT(_aSOD_[:issues], "; "))
			ok
		ok
		
		# Efficiency metrics
		if _nAvgSpan_ < 3
			_aExplanation_[:efficiency] + "Span of control may be underutilized (< 3 reports average)"
		but _nAvgSpan_ > 9
			_aExplanation_[:efficiency] + "WARNING: Span of control exceeds recommended limit (> 9 reports average)"
		else
			_aExplanation_[:efficiency] + "Span of control within optimal range (3-9 reports)"
		ok
		
		if _nVacRate_ > 20
			_aExplanation_[:efficiency] + "HIGH vacancy rate - may impact operations"
		but _nVacRate_ > 10
			_aExplanation_[:efficiency] + "Moderate vacancy rate - monitor staffing"
		else
			_aExplanation_[:efficiency] + "Healthy staffing levels"
		ok
		
		return _aExplanation_

	#============================#
	#  EXPORT TO .STZORG FORMAT  #
	#============================#

	def ToStzOrg()
		_cResult_ = 'orgchart "' +
			  This.Id() + '"' + NL + NL
		
		# Positions
		_cResult_ += "positions" + NL
		_aPositions_ = This.Positions()
		_nPosLen_ = len(_aPositions_)
		for i = 1 to _nPosLen_
			_aPos_ = _aPositions_[i]
			_cResult_ += "    " + _aPos_[:id] + NL
			_cResult_ += "        title: " + _aPos_[:title] + NL
			_cResult_ += "        level: " + _aPos_[:level] + NL
			_cResult_ += "        department: " + _aPos_[:department] + NL
			_cResult_ += "        reportsTo: " + _aPos_[:reportsTo] + NL
			_cResult_ += NL
		end
		
		# People
		_cResult_ += "people" + NL
		_aPeople_ = This.People()
		_nPplLen_ = len(_aPeople_)
		for i = 1 to _nPplLen_
			_aPerson_ = _aPeople_[i]
			_cResult_ += "    " + _aPerson_[:id] + NL
			_cResult_ += "        name: " + _aPerson_[:name] + NL
			_cResult_ += NL
		end
		
		# Assignments
		_cResult_ += "assignments" + NL
		for i = 1 to _nPosLen_
			_aPos_ = _aPositions_[i]
			if _aPos_[:incumbent] != ""
				_cResult_ += "    " + _aPos_[:incumbent] + " -> " + _aPos_[:id] + NL
			ok
		end
		_cResult_ += NL
		
		# Departments
		_cResult_ += "departments" + NL
		_aDepts_ = This.Departments()
		_nDeptLen_ = len(_aDepts_)
		for i = 1 to _nDeptLen_
			_aDept_ = _aDepts_[i]
			_cResult_ += "    " + _aDept_[:id] + NL
			_cResult_ += "        name: " + _aDept_[:name] + NL
			_cResult_ += "        positions: " + Q(_aDept_[:positions]).ToCode() + NL
			_cResult_ += NL
		end
		
		return _cResult_
	

	def WriteToStzOrgFile(pcFileName)
		if StzRight(pcFileName, 7) != ".stzorg"
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
		_acLines_ = @split(cString, NL)
		_cCurrentSection_ = ""
		_cCurrentId_ = ""
		_aCurrent_ = []
		_cTitle_ = ""
	
		_nLen_ = len(_acLines_)
		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = '' or StzLeft(_cLine_, 1) = "#"
				loop
			ok
			
			if StzFindFirst("orgchart ", _cLine_)
				_cTitle_ = StzMid(_cLine_, 10, StzLen(_cLine_) - 10)
				
			but _cLine_ = "positions"
				# Flush previous section
				if _cCurrentSection_ = "positions" and _cCurrentId_ != ""
					This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
					if _aCurrent_[:department] != "" and
					   trim(_aCurrent_[:department]) != ""
						This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
					ok
					if _aCurrent_[:reportsTo] != "" and
					   trim(_aCurrent_[:reportsTo]) != ""
						This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
					ok

				but _cCurrentSection_ = "people" and _cCurrentId_ != ""
					This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])

				but _cCurrentSection_ = "departments" and _cCurrentId_ != ""
					This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
				ok
				
				_cCurrentSection_ = "positions"
				_cCurrentId_ = ""
				
			but _cLine_ = "people"
				# Flush previous section
				if _cCurrentSection_ = "positions" and _cCurrentId_ != ""
					This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
					if _aCurrent_[:department] != "" and
					   trim(_aCurrent_[:department]) != ""
						This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
					ok
					if _aCurrent_[:reportsTo] != "" and
					   trim(_aCurrent_[:reportsTo]) != ""
						This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
					ok

				but _cCurrentSection_ = "people" and _cCurrentId_ != ""
					This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])

				but _cCurrentSection_ = "departments" and _cCurrentId_ != ""
					This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
				ok
				
				_cCurrentSection_ = "people"
				_cCurrentId_ = ""
				
			but _cLine_ = "assignments"
				# Flush previous section
				if _cCurrentSection_ = "positions" and _cCurrentId_ != ""
					This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
					if _aCurrent_[:department] != "" and
					   trim(_aCurrent_[:department]) != ""
						This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
					ok
					if _aCurrent_[:reportsTo] != "" and
					   trim(_aCurrent_[:reportsTo]) != ""
						This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
					ok

				but _cCurrentSection_ = "people" and _cCurrentId_ != ""
					This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])

				but _cCurrentSection_ = "departments" and _cCurrentId_ != ""
					This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
				ok
				
				_cCurrentSection_ = "assignments"
				_cCurrentId_ = ""
				
			but _cLine_ = "departments"
				# Flush previous section
				if _cCurrentSection_ = "positions" and _cCurrentId_ != ""
					This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
					if _aCurrent_[:department] != "" and
					   trim(_aCurrent_[:department]) != ""
						This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
					ok
					if _aCurrent_[:reportsTo] != "" and
					   trim(_aCurrent_[:reportsTo]) != ""
						This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
					ok

				but _cCurrentSection_ = "people" and _cCurrentId_ != ""
					This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])

				but _cCurrentSection_ = "departments" and _cCurrentId_ != ""
					This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
				ok
				
				_cCurrentSection_ = "departments"
				_cCurrentId_ = ""
				
			but _cCurrentSection_ = "positions"
				if NOT StzFindFirst(":", _cLine_)

					# Flush previous position
					if _cCurrentId_ != ""
						This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
						if _aCurrent_[:department] != "" and
						   trim(_aCurrent_[:department]) != ""
							This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
						ok
						if _aCurrent_[:reportsTo] != "" and
						   trim(_aCurrent_[:reportsTo]) != ""
							This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
						ok
					ok

					_cCurrentId_ = _cLine_
					_aCurrent_ = [
						:title = "",
						:level = "",
						:department = "",
						:reportsTo = ""
					]

				but StzFindFirst("title:", _cLine_)
					_aCurrent_[:title] = trim(StzMid(_cLine_, 7, StzLen(_cLine_) - 6))
					# Remove quotes if present
					if StzLeft(_aCurrent_[:title], 1) = '"' and
					   StzRight(_aCurrent_[:title], 1) = '"'
						_aCurrent_[:title] = StzMid(_aCurrent_[:title], 2, StzLen(_aCurrent_[:title]) - 2)
					ok

				but StzFindFirst("level:", _cLine_)
					_aCurrent_[:level] = trim(StzMid(_cLine_, 7, StzLen(_cLine_) - 6))

				but StzFindFirst("department:", _cLine_)
					_aCurrent_[:department] = trim(StzMid(_cLine_, 12, StzLen(_cLine_) - 11))

				but StzFindFirst("reportsTo:", _cLine_)
					_aCurrent_[:reportsTo] = trim(StzMid(_cLine_, 11, StzLen(_cLine_) - 10))
				ok
				
			but _cCurrentSection_ = "people"
				if NOT StzFindFirst(":", _cLine_)
					# Flush previous person
					if _cCurrentId_ != ""
						This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])
					ok

					_cCurrentId_ = _cLine_
					_aCurrent_ = [ :name = "" ]

				but StzFindFirst("name:", _cLine_)
					_aCurrent_[:name] = trim(StzMid(_cLine_, 6, StzLen(_cLine_) - 5))
				ok

			but _cCurrentSection_ = "assignments"
				if StzFindFirst(" -> ", _cLine_)
					_aParts_ = @split(_cLine_, " -> ")
					This.AssignPerson(trim(_aParts_[1]), trim(_aParts_[2]))
				ok
				
			but _cCurrentSection_ = "departments"
				if NOT StzFindFirst(":", _cLine_)
					# Flush previous department
					if _cCurrentId_ != ""
						This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
					ok

					_cCurrentId_ = _cLine_
					_aCurrent_ = [ :name = "", :positions = [] ]

				but StzFindFirst("name:", _cLine_)
					_aCurrent_[:name] = trim(StzMid(_cLine_, 6, StzLen(_cLine_) - 5))

				but StzFindFirst("positions:", _cLine_)
					_cPosStr_ = trim(StzMid(_cLine_, 11, StzLen(_cLine_) - 10))
					_cPosStr_ = replace(_cPosStr_, "[", "")
					_cPosStr_ = replace(_cPosStr_, "]", "")
					_aCurrent_[:positions] = @split(_cPosStr_, ",")
					_nPosLen_ = len(_aCurrent_[:positions])
					for j = 1 to _nPosLen_
						_aCurrent_[:positions][j] = trim(_aCurrent_[:positions][j])
					end
				ok
			ok
		end
		
		# Flush last item
		if _cCurrentSection_ = "positions" and _cCurrentId_ != ""
			This.AddPositionXTT(_cCurrentId_, _aCurrent_[:title], [ :level = _aCurrent_[:level] ])
			if _aCurrent_[:department] != "" and
			   trim(_aCurrent_[:department]) != ""
				This.SetPositionDepartment(_cCurrentId_, _aCurrent_[:department])
			ok
			if _aCurrent_[:reportsTo] != "" and
			   trim(_aCurrent_[:reportsTo]) != ""
				This.ReportsTo(_cCurrentId_, _aCurrent_[:reportsTo])
			ok

		but _cCurrentSection_ = "people" and _cCurrentId_ != ""
			This.AddPersonXT(_cCurrentId_, _aCurrent_[:name])

		but _cCurrentSection_ = "departments" and _cCurrentId_ != ""
			This.AddDepartmentXTT(_cCurrentId_, _aCurrent_[:name], _aCurrent_[:positions])
		ok

	def ImportFromStzOrgFile(pcFileName)
		_cContent_ = read(pcFileName)
		This.ImportStzOrg(_cContent_)
	
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

		# LoadRuleBase: stub for the future rule-base validation
		# system. Accepts a file path, a class instance, or a
		# pre-built profile name (string). For now it just records
		# the source -- the actual rule-evaluation engine will land
		# with the dedicated stzRuleBase class.
		def LoadRuleBase(pSource)
			@aRuleBases + pSource

		def RuleBases()
			return @aRuleBases

# Stub rule-base classes that the narrative tests instantiate via
# LoadRuleBase(new stzXxxRuleBase()). They land here as minimal
# placeholders -- a real rule-evaluation engine will replace them
# without changing the public Load + Validate surface.

class stzRuleBase from stzObject
	@cName = ""
	def init(pcName)
		if isString(pcName)
			@cName = pcName
		ok
	def Name()
		return @cName

class stzSOXRuleBase from stzRuleBase
	def init()
		super.init("SOX")

class stzGDPRRuleBase from stzRuleBase
	def init()
		super.init("GDPR")

class stzPCIDSSRuleBase from stzRuleBase
	def init()
		super.init("PCI-DSS")

class stzHIPAARuleBase from stzRuleBase
	def init()
		super.init("HIPAA")

class stzISO27001RuleBase from stzRuleBase
	def init()
		super.init("ISO 27001")

class stzBaselIIIRuleBase from stzRuleBase
	def init()
		super.init("Basel III")

class stzBCEAORuleBase from stzRuleBase
	def init()
		super.init("BCEAO")

		# IsValid / Validate already exist on stzOrgChart above --
		# the rule-base layer hooks into them when implemented.

#=====================================================
#  stzOrgChartBCEAOValidator
#=====================================================

class stzOrgChartBCEAOValidator from stzObject

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Validate()
		_aIssues_ = []
		
		# Rule 1: Board required
		_bHasBoard_ = FALSE
		_nPosCount_ = len(@oOrgChart.@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			if HasKey(_aPos_, :title)
				_cTitle_ = StzLower(_aPos_[:title])
				if StzFindFirst("board", _cTitle_)
					_bHasBoard_ = TRUE
					exit
				ok
			ok
		end
		
		if NOT _bHasBoard_
			_aIssues_ + "BCEAO-001: No Board of Directors found"
		ok
		
		# Rule 2: Audit independence
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			_cDept_ = ""
			if HasKey(_aPos_, :department)
				_cDept_ = _aPos_[:department]
			ok
			
			if _cDept_ = "audit"
				_cReportsTo_ = ""
				if HasKey(_aPos_, :reportsTo)
					_cReportsTo_ = _aPos_[:reportsTo]
				ok
				
				if _cReportsTo_ != ""
					_aSuperPos_ = @oOrgChart.Position(_cReportsTo_)
					if len(_aSuperPos_) > 0 and HasKey(_aSuperPos_, :department)
						if _aSuperPos_[:department] != "board"
							_aIssues_ + "BCEAO-002: Audit reports to non-board position"
						ok
					ok
				ok
			ok
		end
		
		# Rule 3: Risk function
		_bHasRisk_ = FALSE
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			if HasKey(_aPos_, :department)
				if _aPos_[:department] = "risk"
					_bHasRisk_ = TRUE
					exit
				ok
			ok
		end
		
		if NOT _bHasRisk_
			_aIssues_ + "BCEAO-003: No dedicated Risk Management function"
		ok
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "BCEAO_governance",
			:issueCount = len(_aIssues_),
			:issues = _aIssues_
		]


#=====================================================
#  stzOrgChartSODValidator
#=====================================================

class stzOrgChartSODValidator from stzObject

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Validate()
		_aIssues_ = []
		
		# SOD: Operations cannot report to Treasury
		_nPosCount_ = len(@oOrgChart.@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			_cDept_ = ""
			if HasKey(_aPos_, :department)
				_cDept_ = _aPos_[:department]
			ok
			
			if _cDept_ = "operations"
				_cReportsTo_ = ""
				if HasKey(_aPos_, :reportsTo)
					_cReportsTo_ = _aPos_[:reportsTo]
				ok
				
				if _cReportsTo_ != ""
					_aSuperPos_ = @oOrgChart.Position(_cReportsTo_)
					if len(_aSuperPos_) > 0 and HasKey(_aSuperPos_, :department)
						if _aSuperPos_[:department] = "treasury"
							_aIssues_ + "SOD-001: Operations reports through Treasury"
						ok
					ok
				ok
			ok
		end
		
		return [
			:status = iif(len(_aIssues_) = 0, "pass", "fail"),
			:domain = "segregation_of_duties",
			:issueCount = len(_aIssues_),
			:issues = _aIssues_
		]


#=====================================================
#  stzOrgChartReporter
#=====================================================

class stzOrgChartReporter from stzObject

	@oOrgChart

	def init(poOrgChart)
		@oOrgChart = poOrgChart

	def Generate()
		_aResult_ = []

		_aResult_ + This.SummaryReport()
		_aResult_ + This.VacancyReport()
		_aResult_ + This.SuccessionReport()
		_aResult_ + This.ComplianceReport()
		_aResult_ + This.SpanOfControlReport()

		return _aResult_

	def GenerateXT(pcType)
		switch StzLower(pcType)
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
		_acVacant_ = @oOrgChart.VacantPositions()
		_aDetails_ = []
		
		_nVacCount_ = len(_acVacant_)
		
		for iVac = 1 to _nVacCount_
			_aPos_ = @oOrgChart.Position(_acVacant_[iVac])
			if len(_aPos_) = 0 loop ok
			
			_cLevel_ = "staff"
			_cDept_ = ""
			_cTitle_ = ""
			
			if HasKey(_aPos_, :title)
				_cTitle_ = _aPos_[:title]
			ok
			
			if HasKey(_aPos_, :department)
				_cDept_ = _aPos_[:department]
			ok
			
			if HasKey(_aPos_, :attributes)
				_aAttribs_ = _aPos_[:attributes]
				if isList(_aAttribs_) and HasKey(_aAttribs_, :level)
					_cLevel_ = _aAttribs_[:level]
				ok
			ok
			
			_aDetails_ + [
				:position = _acVacant_[iVac],
				:title = _cTitle_,
				:department = _cDept_,
				:level = _cLevel_
			]
		end
		
		_nVacRate_ = @oOrgChart.VacancyRate()
		
		_aReport_ = [
			:title = "Vacancy Report",
			:vacancyCount = _nVacCount_,
			:vacancyRate = _nVacRate_,
			:details = _aDetails_
		]
		
		return _aReport_

		def Vacancy()
			return This.VacancyReport()

	def SuccessionReport()
		_acRisk_ = @oOrgChart.SuccessionRisk()
		_aDetails_ = []
		
		_nRiskCount_ = len(_acRisk_)
		for iRisk = 1 to _nRiskCount_
			_aPos_ = @oOrgChart.Position(_acRisk_[iRisk])
			if len(_aPos_) = 0 loop ok
			
			_cPersonId_ = ""
			_cPersonName_ = ""
			_cTitle_ = ""
			_cDept_ = ""
			
			if HasKey(_aPos_, :incumbent)
				_cPersonId_ = _aPos_[:incumbent]
			ok
			
			if _cPersonId_ != ""
				_aPerson_ = @oOrgChart.PersonData(_cPersonId_)
				if len(_aPerson_) > 0 and HasKey(_aPerson_, :name)
					_cPersonName_ = _aPerson_[:name]
				ok
			ok
			
			if HasKey(_aPos_, :title)
				_cTitle_ = _aPos_[:title]
			ok
			
			if HasKey(_aPos_, :department)
				_cDept_ = _aPos_[:department]
			ok
			
			_aDetails_ + [
				:position = _acRisk_[iRisk],
				:title = _cTitle_,
				:incumbent = _cPersonName_,
				:department = _cDept_,
				:riskLevel = "high"
			]
		end
		
		return [
			:title = "Succession Risk Report",
			:date = Date(),
			:highRiskCount = _nRiskCount_,
			:details = _aDetails_
		]


		def Succession()
			return This.SuccessionReport()

	def ComplianceReport()
		_aReport_ = [
			:title = "Compliance Status Report",
			:date = Date(),
			:checks = []
		]
		
		_aReport_[:checks] + @oOrgChart.ValidateBCEAOGovernance()
		_aReport_[:checks] + @oOrgChart.ValidateSpanOfControl()
		_aReport_[:checks] + @oOrgChart.ValidateSegregationOfDuties()
		
		_nFail_ = 0
		_nCheckCount_ = len(_aReport_[:checks])
		for iCheck = 1 to _nCheckCount_
			if _aReport_[:checks][iCheck][:status] = "fail"
				_nFail_++
			ok
		end
		
		_aReport_[:overallStatus] = iif(_nFail_ = 0, "compliant", "non-compliant")
		_aReport_[:failedChecks] = _nFail_
		
		return _aReport_

		def Compliance()
			return This.ComplianceReport()

	def SpanOfControlReport()
		_aReport_ = [
			:title = "Span of Control Analysis",
			:date = Date(),
			:details = []
		]
		
		_nPosCount_ = len(@oOrgChart.@aPositions)
		for iPos = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[iPos]
			_cPosId_ = ""
			_cTitle_ = ""
			
			if HasKey(_aPos_, :id)
				_cPosId_ = _aPos_[:id]
			ok
			
			if HasKey(_aPos_, :title)
				_cTitle_ = _aPos_[:title]
			ok
			
			if _cPosId_ != ""
				_nReports_ = len(@oOrgChart.DirectReports(_cPosId_))
				
				if _nReports_ > 0
					_cStatus_ = "optimal"
					if _nReports_ > 9 _cStatus_ = "excessive" ok
					if _nReports_ < 3 _cStatus_ = "underutilized" ok
					
					_aReport_[:details] + [
						:position = _cPosId_,
						:title = _cTitle_,
						:directReports = _nReports_,
						:status = _cStatus_
					]
				ok
			ok
		end
		
		return _aReport_

		def SpanOfControl()
			return This.SpanOfControlReport()

		def SOC()
			return This.SpanOfControlReport()

#=====================================================
#  stzOrgChartSimulation
#=====================================================

class stzOrgChartSimulation from stzObject

	@oOriginalChart
	@oSimulatedChart
	@aChanges = []
	@aResults = []

	def init(poOrgChart)
		@oOriginalChart = poOrgChart
		@oSimulatedChart = This._CloneChart(poOrgChart)

	def _CloneChart(poChart)
		_oClone_ = new stzOrgChart(poChart.Id() + "_sim")
		_oClone_.@aPositions = poChart.@aPositions
		_oClone_.@aPeople = poChart.@aPeople
		_oClone_.@aDepartments = poChart.@aDepartments
		return _oClone_

	def ApplyChanges(paChanges)
		@aChanges = paChanges
		
		_nChangeCount_ = len(paChanges)
		for iChange = 1 to _nChangeCount_
			_aChange_ = paChanges[iChange]
			
			switch _aChange_[:type]
			on "reassign"
				@oSimulatedChart.ReassignPerson(_aChange_[:person], _aChange_[:newPosition])
			on "remove_position"
				@oSimulatedChart.RemovePosition(_aChange_[:position])
			on "add_position"
				@oSimulatedChart.AddPositionXT(_aChange_[:id], _aChange_[:title])
			on "change_reporting"
				@oSimulatedChart.ChangeReportingLine(_aChange_[:subordinate], _aChange_[:supervisor])
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

	# The what-if chart produced by the simulation -- an OBJECT, hence Q.
	def SimulatedChartQ()
		return @oSimulatedChart
