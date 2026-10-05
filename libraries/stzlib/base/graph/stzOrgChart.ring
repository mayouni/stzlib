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
		return 1
	ok
	return 0

# THE ORG CHART'S NOTATION -- DN1, the first real domain profile.
#
# The profile lives HERE, beside the model it speaks for, and registers
# itself the first time an org chart is born (file-top code after a class
# region never runs, so registration cannot be a load-time side effect).
#
# What the domain declares:
#   VOCABULARY  the levels the Add* constructors already write, every
#               one a box -- an org chart's differences are colour and
#               rank, never shape. OPEN, because positions carry :level
#               rather than :type and a chart may hold plain nodes too.
#   RULES       the tree grammar as refusals that teach. One supervisor
#               per position (:SecondParent), reporting lines flow one
#               way (:Cycle), and nobody reports to themselves
#               (:SelfLink). These are the STRUCTURAL floor; the
#               governance rule bases (separation-of-duties, vacancy,
#               succession) stay where they are -- they judge content,
#               not shape, and CheckCompliance already owns them.
#   GRAMMAR     none: top-down rank-is-hierarchy is already the
#               diagram's default reading.
#
# The editor inherits the floor at the gesture: dragging a reporting
# line onto a position that has a supervisor is refused before the
# model hears about it, with no editor code knowing what an org is.
func StzOrgChartNotation()
	_o_ = StzNotation("orgchart")
	if _o_.Name_() = "orgchart"  return _o_  ok
	_o_ = new stzNotation("orgchart")
	_o_.AddKind("position", "box")
	_o_.AddKind("executive", "box")
	_o_.AddKind("management", "box")
	_o_.AddKind("staff", "box")
	_o_.Forbid(:SelfLink,
		"a position cannot report to itself. If the intent is that it " +
		"reports to nobody, leave it unconnected: roots are how boards " +
		"are drawn.")
	_o_.Forbid(:SecondParent,
		"a position reports to ONE supervisor. For dotted-line or " +
		"matrix reporting, model the second relation as its own edge " +
		"kind when DN grows one -- a second solid line states a second " +
		"boss, and the chart would be asserting it.")
	_o_.Forbid(:Cycle,
		"reporting lines flow one way. This link would make a position " +
		"an indirect supervisor of its own supervisor, and the chart " +
		"would have no top.")
	StzRegisterNotation(_o_)
	return _o_

	func OrgChartNotation()
		return StzOrgChartNotation()

# Models an organisation as positions, people and departments, draws its reporting lines, and checks them against governance rules.
#
# An org chart is a diagram whose nodes are positions and whose edges run from supervisor to
# subordinate. Positions have a level (executive, management, staff), people are assigned to them,
# and the chart answers vacancy, span-of-control and succession questions, validates itself (BCEAO,
# segregation of duties, span, vacancy, succession), writes reports, highlights subsets with the
# View calls and saves to the .stzorg text format. Records are hash lists with lowercase keys.
# Several calls hold known defects, listed in their warnings: the succession check and the level
# colours read a key that is never written, and a few View calls raise.
#
#   receiver   o1 = new stzOrgChart("TechCo"); o1.AddExecutiveXT("ceo", "CEO");
#              o1.AddManagerXT("vp", "VP Sales"); o1.ReportsTo("vp", "ceo")
#   example    ? @@( o1.DirectReports("ceo") )
#              #--> [ "vp" ]
#   see        stzDiagram, stzGraph, stzOrgChartReporter, stzOrgChartSimulation
class stzOrgChart from stzDiagram

	@aPositions = []
	@aPeople = []
	@aDepartments = []

	@acValidators = $acOrgChartDefaultValidators

	# Rule-base sources loaded via LoadRuleBase (file path, profile
	# name, or rule-base object). Consumed by the future rule-eval
	# engine; for now this is just a recorded list.
	@aRuleBases = []

	# Builds an empty org chart named by its title, kept in lowercase as the id, under the org chart layout preset and notation.
	#
	#   pcTitle    The chart name, as text without spaces or line breaks
	#   returns    nothing; the chart is built
	#   note       the notation forbids a self-report, a second supervisor and a reporting cycle
	#              when the chart is validated
	#   warning    a title with a space or a line break raises an error
	#   see        AddPosition, SetValidators
	def init(pcTitle)
		super.init(pcTitle)
		super.SetGraphType("structural")

	        # Auto-apply orgchart preset
	        This.SetLayoutPreset("orgchart")

		# born under its own notation (DN1): the tree grammar's rules
		# reach Validate() and the editor's gestures from the first
		# moment, not after somebody remembers to ask
		This.SetNotation(StzOrgChartNotation())

	#==========================#
	#  POSITION MANAGEMENT     #
	#==========================#

	# Adds a position whose title is its id, with no level, as a record and as a white box node; a repeated id is not refused.
	#
	#   returns    nothing; the chart changes
	#   warning    adding an id twice leaves two records and two nodes under it
	#   see        AddExecutivePosition, AddManagementPosition, AddStaffPosition
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


	# Adds a position of level executive whose title is its id; its node stays white until someone is assigned.
	#
	#   returns    nothing; the chart changes
	#   see        AddPosition, AddManagementPosition
	#---
	def AddExecutivePosition(pcId)
		This.AddExecutivePositionXT(pcId, pcId)

		# Adds a position of level executive whose title is its id; another spelling of the executive-position call.
		#
		#   returns    nothing; the chart changes
		#   see        AddExecutivePosition
		def AddExecutive(pcId)
			This.AddExecutivePositionXT(pcId, pcId)

	def AddExecutivePositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])
	    	# Don't set color here - leave as white until person assigned	

		def AddExecutiveXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "executive"])

	# Adds a position of level management whose title is its id.
	#
	#   returns    nothing; the chart changes
	#   see        AddPosition, AddStaffPosition
	def AddManagementPosition(pcId)
		This.AddManagementPositionXT(pcId, pcId)

		# Adds a position of level management whose title is its id; another spelling of the management-position call.
		#
		#   returns    nothing; the chart changes
		#   see        AddManagementPosition
		def AddManager(pcId)
			This.AddManagementPositionXT(pcId, pcId)

	def AddManagementPositionXT(pcId, pcTitle)
	    	This.AddPositionXTT(pcId, pcTitle, [:level = "management"])
	    	# Don't set color here

		def AddManagerXT(pcId, pcTitle)
			This.AddPositionXTT(pcId, pcTitle, [:level = "management"])

	# Adds a position of level staff whose title is its id.
	#
	#   returns    nothing; the chart changes
	#   see        AddPosition, AddManagementPosition
	def AddStaffPosition(pcId)
		# Typo: pcIde -> pcId. Method was unreachable -- R24 every call.
		This.AddStaffPositionXT(pcId, pcId)

		# Adds a position of level staff whose title is its id; another spelling of the staff-position call.
		#
		#   returns    nothing; the chart changes
		#   see        AddStaffPosition
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

	# Makes one position report to another: records the supervisor and draws an edge from supervisor to subordinate.
	#
	#   pcSubordinate   The id of the position that reports
	#   pcSupervisor    The id of the position reported to
	#   returns         nothing; the chart changes
	#   warning         a missing id raises "Cannot add edge: one or both nodes do not exist!"; a
	#                   second supervisor adds a second edge and the record keeps the last one, and
	#                   reporting to itself is accepted; the same pair twice raises, since the graph
	#                   is simple
	#   see             ChangeReportingLine, DirectReports
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

	    # Makes one position report to another; another spelling of the reporting call.
	    #
	    #   pcSubordinate   The id of the position that reports
	    #   pcSupervisor    The id of the position reported to
	    #   returns         nothing; the chart changes
	    #   see             ReportsTo
	    def RelatesTo(pcSubordinate, pcSupervisor)
		This.ReportsTo(pcSubordinate, pcSupervisor)

	    # Makes one position report to another; another spelling of the reporting call.
	    #
	    #   pcSubordinate   The id of the position that reports
	    #   pcSupervisor    The id of the position reported to
	    #   returns         nothing; the chart changes
	    #   see             ReportsTo
	    def SubordinateOf(pcSubordinate, pcSupervisor)
		This.ReportsTo(pcSubordinate, pcSupervisor)

	# Sets the department of a position, in its record and as a node property; an unknown position id is ignored.
	#
	#   pcPositionId   The id of the position
	#   pcDepartment   The department name, as text such as risk or audit
	#   returns        nothing; the chart changes
	#   warning        the department name is what the BCEAO and segregation validators and
	#                  ColorByDepartment read
	#   see            ColorByDepartment, ValidateBCEAOGovernance
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

	# Returns the record of a position as a hash list with id, title, level and any assignment, supervisor or department; [ ] when unknown.
	#
	#   returns    a hash list, or [ ]
	#   warning    the keys are lowercase, such as reportsto and isvacant, and a position never
	#              assigned has no incumbent key
	#   see        Positions, Person
	#---
	def Position(pcId)
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			if @aPositions[i][:id] = pcId
				return @aPositions[i]
			ok
		end
		return []

	# Returns the records of every position, in the order they were added.
	#
	#   returns    a list of hash lists
	#   see        Position, VacantPositions
	#@ aka  THERE IS NO Node() ALIAS HERE, AND THAT IS THE FIX.
	def Positions()
		# Found 2026-08-29 by the scope governance on its first run over this
		# domain, and not by any of the 22 assertions the org suite already
		# passed: every one of them checks what the rules SAY, and a rule that
		# governs nothing says nothing. The count of governed subjects is what
		# made it visible -- no-self-report governs 0 positions in a chart of
		# four, which no verdict-shaped test can express.
		return @aPositions

	# Returns every position as an [ id, title, supervisor id ] triple, the supervisor being empty text for a root.
	#
	#   returns    a list of triples
	#   warning    this is the input the SVG and PNG pictures are drawn from
	#   see        ToSVG, ToPNG
	#@ aka  -- the PIXEL tiers (GR6b, SOFTANZA_GRAPHICS_PLAN.md) -----------------
	def ToTreeNodes()
		_a_ = []
		_nL_ = len(@aPositions)
		for _i_ = 1 to _nL_
			_cId_ = "" + @aPositions[_i_][:id]
			_cTitle_ = _cId_
			if HasKey(@aPositions[_i_], :title)
				if ("" + @aPositions[_i_][:title]) != ""
					_cTitle_ = "" + @aPositions[_i_][:title]
				ok
			ok
			_cUp_ = ""
			if HasKey(@aPositions[_i_], :reportsTo)
				_cUp_ = "" + @aPositions[_i_][:reportsTo]
			ok
			_a_ + [ _cId_, _cTitle_, _cUp_ ]
		next
		return _a_

	def ToCanvasQ(paOptions)
		return StzTreeCanvasQ(This.ToTreeNodes(), paOptions)

	# Returns the chart drawn as an SVG tree, with no graphviz or display device needed.
	#
	#   paOptions   Drawing options as a hash list, such as :Title, :Font, :NodeWidth, :NodeHeight,
	#               :HGap, :VGap or :Background
	#   returns     text, an svg document
	#   warning     a :Title adds a title band above the tree
	#   see         ToPNG, ToTreeNodes
	def ToSVG(paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToSVG()
		_oCv_.Free()
		return _cOut_

	# Draws the chart as a tree to a PNG file and returns the PNG bytes as text.
	#
	#   pcPath      The file to write, as text
	#   paOptions   Drawing options as for ToSVG
	#   returns     the PNG content, as a string of bytes
	#   warning     the file is written where the path says; a relative path means the current
	#               folder
	#   see         ToSVG
	def ToPNG(pcPath, paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToPNG(pcPath)
		_oCv_.Free()
		return _cOut_

	# Returns a fresh stzGraph projecting the chart: one node per position and one supervises edge from supervisor to subordinate.
	#
	#   returns    a new stzGraph
	#   warning    each node carries kind, title and, when set, level, department, roles and
	#              reportsTo as properties; the chart itself is not touched
	#   see        CheckCompliance, GovernanceFindings
	#@ aka  -- the RULE-GRAPH projection (graph-rules plan, phase 2b) ------------
	def AsRuleGraph()
		_oG_ = new stzGraph("orgchart-rules")
		_nP_ = len(@aPositions)
		for _i_ = 1 to _nP_
			_p_ = @aPositions[_i_]
			_id_ = "" + _p_[:id]
			if NOT _oG_.NodeExists(_id_)
				_oG_.AddNode(_id_)
			ok
			_oG_.SetNodeProperty(_id_, "kind", "position")
			_oG_.SetNodeProperty(_id_, "title", "" + _p_[:title])
			if HasKey(_p_, :level)       _oG_.SetNodeProperty(_id_, "level", _p_[:level])            ok
			if HasKey(_p_, :department)  _oG_.SetNodeProperty(_id_, "department", _p_[:department])   ok
			if HasKey(_p_, :roles)       _oG_.SetNodeProperty(_id_, "roles", _p_[:roles])            ok
			if HasKey(_p_, :reportsTo)   _oG_.SetNodeProperty(_id_, "reportsTo", "" + _p_[:reportsTo]) ok
		next
		# edges: supervisor -> subordinate (outgoing = direct reports)
		for _i_ = 1 to _nP_
			_p_ = @aPositions[_i_]
			if HasKey(_p_, :reportsTo) and ("" + _p_[:reportsTo]) != ""
				_sup_ = "" + _p_[:reportsTo]
				if _oG_.NodeExists(_sup_) and NOT _oG_.EdgeExists(_sup_, "" + _p_[:id])
					_oG_.AddEdgeXTT(_sup_, "" + _p_[:id], "supervises", [ :type = "org" ])
				ok
			ok
		next
		return _oG_

	# Runs a compliance rule base over the chart's graph projection and returns its findings.
	#
	#   poRuleBase   A rule base object such as stzSOXRuleBase
	#   returns      a list of hash lists [ :rule, :subject, :where, :severity, :message ]; [ ] when
	#                none
	#   warning      only stzSOXRuleBase adds a rule beyond the four every base carries: a position
	#                holding both approver and executor in its roles
	#   see          AsRuleGraph, GovernanceFindings
	#@ aka  Run a compliance rule base over this org chart's projection. Returns unified findings [ :rule, :subject, :where, :severity, :message ].
	def CheckCompliance(poRuleBase)
		return poRuleBase.Check(This.AsRuleGraph())

	# Returns the findings of the four universal rules: self-report, reporting cycle, orphan position and excessive span of control.
	#
	#   returns    a list of hash lists [ :rule, :subject, :where, :severity, :message ]; [ ] when
	#              sound
	#   warning    a position without a supervisor is a warning unless it is an executive; a self-
	#              report is an error; the span limit is 8 direct reports
	#   see        GovernanceIsSound, CheckCompliance
	#@ aka  The universal org-integrity rules (no-self-report / no-cyclic-reporting / no-orphan-position / span-of-control), regime-agnostic.
	def GovernanceFindings()
		return StzOrgRuleSetQ().Check(This.AsRuleGraph())

	# TRUE if the universal org rules find nothing of error severity; warnings do not count.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        GovernanceFindings
	def GovernanceIsSound()
		return StzOrgRuleSetQ().IsSound(This.AsRuleGraph())

	# The uniform graph-owned verb (so an stzRuleReport can Collect an org chart
	# like any other graph): the chart checks ITSELF over its projection.
	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

	# Returns the ids of the positions that have no incumbent, which includes every position never assigned.
	#
	#   returns    a list of ids
	#   see        NonVacantPositions, VacancyRate
	def VacantPositions()
		_acVacant_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @aPositions[i]
			_bIsVacant_ = 1
			if HasKey(_aPos_, :isVacant)
				_bIsVacant_ = _aPos_[:isVacant]
			ok
			
			if _bIsVacant_ = 1
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

	# Returns the ids of the positions that have an incumbent.
	#
	#   returns    a list of ids
	#   see        VacantPositions
	def NonVacantPositions()
		_acNonVacant_ = []
		_nPosCount_ = len(@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @aPositions[i]
			_bIsVacant_ = 1
			if HasKey(_aPos_, :isVacant)
				_bIsVacant_ = _aPos_[:isVacant]
			ok
			
			if _bIsVacant_ = 0
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

	# Adds a person whose name is the id, not yet in any position; a repeated id is not refused.
	#
	#   returns    nothing; the chart changes
	#   warning    adding an id twice leaves two records
	#   see        AssignPerson, Person
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

	# Puts a person in a position: the position takes the person as incumbent and stops being vacant, and the person records the position.
	#
	#   pcPersonId     The id of the person
	#   pcPositionId   The id of the position, or a pair such as :ToPosition = "ceo"
	#   returns        nothing; the chart changes
	#   warning        an unknown position or person id is not refused, it leaves the other record
	#                  pointing at nothing; the node colour is set to white, since the level colour
	#                  is never found
	#   see            ReassignPerson, VacantPositions
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
				@aPositions[i][:isVacant] = 0
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

		# Puts a person in a position; another spelling of the assignment call.
		#
		#   pcPersonId     The id of the person
		#   pcPositionId   The id of the position, or a pair such as :ToNode = "ceo"
		#   returns        nothing; the chart changes
		#   see            AssignPerson
		def Assign(pcPersonId, pcPositionId)
			This.AssignPerson(pcPersonId, pcPositionId)

	# Returns the record of a person as a hash list of id, name, position and data; [ ] when unknown.
	#
	#   pcPersonId   The id of the person
	#   returns      a hash list, or [ ]
	#   warning      PersonData is the same call
	#   see          People, AssignPerson
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

	# Returns the records of every person, in the order they were added.
	#
	#   returns    a list of hash lists
	#   see        Person
	def People()
		return @aPeople

		# Returns the records of every person, in the order they were added; another spelling of the people call.
		#
		#   returns    a list of hash lists
		#   see        People
		def Persons()
			return @aPeople

	#==========================#
	#  DEPARTMENT MANAGEMENT   #
	#==========================#

	# Adds a department record whose name is its id and which holds no position; no cluster is drawn for it.
	#
	#   returns    nothing; the chart changes
	#   warning    to draw a cluster of positions give the positions when adding it, through
	#              AddDepartmentXTT
	#   see        Departments, SetPositionDepartment
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

	# Returns the record of a department as a hash list of id, name, positions and head; [ ] when unknown.
	#
	#   returns    a hash list, or [ ]
	#   see        Departments
	def Department(pcId)
		_nDeptCount_ = len(@aDepartments)
		for i = 1 to _nDeptCount_
			if @aDepartments[i][:id] = pcId
				return @aDepartments[i]
			ok
		end
		return []

	# Returns the records of every department, in the order they were added.
	#
	#   returns    a list of hash lists
	#   see        Department
	def Departments()
		return @aDepartments

	#===========================#
	#  COMPLIANCE & GOVERNANCE  #
	#===========================#

	# Returns the names of the validators Validate runs.
	#
	#   returns    a list of texts
	#   see        SetValidators, DefaultValidators
	def Validators()
		return @acValidators

	# Returns the validator names a new chart starts with: bceao, sod, soc, vacancy and succession.
	#
	#   returns    a list of texts
	#   see        Validators, SetValidators
	def DefaultValidators()
		return $acOrgChartDefaultValidators

	# Chooses which validators Validate runs; the list is kept as given.
	#
	#   pacValidators   The validator names, as a list of text such as bceao, sod, soc, vacancy,
	#                   succession, nonvacancy or banking
	#   returns         nothing; the chart changes
	#   warning         a single text instead of a list makes Validate answer with that validator's
	#                   own verdict instead of the combined one
	#   see             Validators, Validate
	def SetValidators(pacValidators)
		@acValidators = pacValidators

	# Runs every chosen validator and returns a combined verdict with each validator's own result and the positions concerned.
	#
	#   returns    a hash list [ :status, :validatorsRun, :validatorsFailed, :totalIssues, :results,
	#              :affectedNodes ]
	#   warning    status is pass or fail; a validator name that is not known gives a result of
	#              status error that does not count as a failure, so a list of unknown names passes
	#   see        IsValid, SetValidators
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

	# TRUE if Validate finds every chosen validator passing.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        Validate
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

	# Checks three BCEAO rules: a board position, audit reporting to a board department and a risk department; returns the verdict.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues ]
	#   warning    the board is found by the word board in a title, and audit and risk by the
	#              department names audit, board and risk
	#   see        Validate, ValidateSegregationOfDuties
	def ValidateBCEAOGovernance()
		_oValidator_ = new stzOrgChartBCEAOValidator(This)
		return _oValidator_.Validate()

	# Fails when a position has more than 9 direct reports; returns the verdict and one issue per such position.
	#
	#   returns    a hash list [ :status, :domain, :issues ]
	#   warning    this verdict has no issueCount and no affectedNodes keys
	#   see        AverageSpanOfControl, DirectReportsCount
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

	# Fails when a position of the operations department reports directly to a position of the treasury department.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues ]
	#   warning    only a direct supervisor is checked, though the message says through
	#   see        Validate, ValidateBCEAOGovernance
	def ValidateSegregationOfDuties()
		_oValidator_ = new stzOrgChartSODValidator(This)
		return _oValidator_.Validate()

	# Fails when any position is vacant; returns the verdict with the vacant ids as the affected nodes.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues, :affectedNodes ]
	#   warning    the issue text is a count such as Vacant positions: 3
	#   see        VacantPositions, ValidateNonVacancy
	def ValidateVacancy()
		_acVacant_ = This.VacantPositions()
		
		return [
			:status = iif(len(_acVacant_) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(_acVacant_),
			:issues = iif(len(_acVacant_) > 0, ["Vacant positions: " + len(_acVacant_)], []),
			:affectedNodes = _acVacant_
		]
	
	# Fails when any position is filled, the reverse of the vacancy check; the filled ids are the affected nodes.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues, :affectedNodes ]
	#   warning    the issue text still says Vacant positions
	#   see        ValidateVacancy, NonVacantPositions
	def ValidateNonVacancy()
		_acVacant_ = This.NonVacantPositions()
		
		return [
			:status = iif(len(_acVacant_) = 0, "pass", "fail"),
			:domain = "vacancy",
			:issueCount = len(_acVacant_),
			:issues = iif(len(_acVacant_) > 0, ["Vacant positions: " + len(_acVacant_)], []),
			:affectedNodes = _acVacant_
		]

	# Fails for every filled position without a successor, one issue each; the positions are the affected nodes.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues, :affectedNodes ]
	#   warning    known defect: a successor is looked for under a key that is never written, so
	#              every filled position fails
	#   see        SuccessionRisk
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
	
	# Passes every time with no issue: a placeholder for banking rules not written yet.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues, :affectedNodes ]
	#   see        Validate
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

	# Returns how many positions report straight to a position.
	#
	#   pcPositionId   The id of the supervisor position
	#   returns        a number
	#   warning        DirectReportsN is the same call
	#   see            DirectReports
	def DirectReportsCount(pcPositionId)
		return len(This.DirectReports(pcPositionId))

		def DirectReportsN(pcPositionId)
			return This.DirectReportsCount(pcPositionId)

	# Returns the ids of the positions that report straight to a position; [ ] when there are none or the id is unknown.
	#
	#   pcPositionId   The id of the supervisor position
	#   returns        a list of ids
	#   warning        a root position record gains an empty reportsto key as a side effect of the
	#                  lookup
	#   see            DirectReportsCount, ReportsTo
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

	# Returns the mean number of direct reports over the positions that have at least one; 0 when nobody reports.
	#
	#   returns    a number
	#   see        ValidateSpanOfControl, DirectReportsCount
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

	# Returns the vacant positions as a percentage of all positions.
	#
	#   returns    a number from 0 to 100
	#   warning    raises error R1 on a chart with no position, a division by zero
	#   see        VacantPositions, Explain
	def VacancyRate()	
		_nResult_ = ( len(This.Vacant()) / len(This.Positions()) ) * 100
		return _nResult_

	# Returns the position ids grouped by level, under the keys executive, management and staff.
	#
	#   returns    a hash list of three lists of ids
	#   warning    a position of any other level, or with none, is left out
	#   see        NumberOfPositionsByLevel
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

	# Returns how many positions each level holds, under the keys executive, management and staff.
	#
	#   returns    a hash list of three numbers
	#   warning    PositionsCountByLevel and PositionsByLevelN are the same call; a position of
	#              another level is not counted
	#   see        PositionsByLevel
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

	# Returns the ids of the filled positions that have no successor; today that is every filled position.
	#
	#   returns    a list of ids
	#   warning    known defect: the successor is looked for under an attributes key that is never
	#              written, so a successor set with SetNodeProperty is not seen
	#   see        ValidateSuccession, ViewAtRisk
	def SuccessionRisk()
	    _acRisk_ = []
	    _nPosCount_ = len(@aPositions)
	    for i = 1 to _nPosCount_
	        _aPos_ = @aPositions[i]
	        _bVacant_ = 1
	        if HasKey(_aPos_, :isVacant)
	            _bVacant_ = _aPos_[:isVacant]
	        ok
	        
	        if NOT _bVacant_
	            _bHasSuccessor_ = 0
	            # Fix: Check attributes as list
	            if isList(_aPos_[:attributes]) and HasKey(_aPos_[:attributes], :successor)
	                _bHasSuccessor_ = 1
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

	# Returns the five standard reports in a list: summary, vacancy, succession, compliance and span of control.
	#
	#   returns    a list of five hash lists
	#   warning    Report is the same call; the other reports are each one call below
	#   see        GenerateReportXT, GenerateSummaryReport
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

	# Returns the summary report: totals, vacancy rate, average span and the position ids by level.
	#
	#   returns    a hash list [ :title, :date, :metrics ]
	#   warning    metrics holds totalPositions, filledPositions, vacancyRate, avgSpan and levels
	#   see        GenerateReport, VacancyRate
	def GenerateSummaryReport()
		return This.GenerateReportXT("summary")

		# Returns the summary report; another spelling of the summary-report call.
		#
		#   returns    a hash list [ :title, :date, :metrics ]
		#   see        GenerateSummaryReport
		def GenerateSummary()
			return This.GenerateReportXT("summary")

		# Returns the summary report; another spelling of the summary-report call.
		#
		#   returns    a hash list [ :title, :date, :metrics ]
		#   see        GenerateSummaryReport
		def Summary()
			return This.GenerateReportXT("summary")

		# Returns the summary report; another spelling of the summary-report call.
		#
		#   returns    a hash list [ :title, :date, :metrics ]
		#   see        GenerateSummaryReport
		def SummaryReport()
			return This.GenerateReportXT("summary")

	# Returns the vacancy report: how many positions are vacant, the rate, and the title and department of each.
	#
	#   returns    a hash list [ :title, :vacancyCount, :vacancyRate, :details ]
	#   warning    known defect: the level of each detail is always staff, since it is read from a
	#              key that is never written
	#   see        GenerateReport, VacantPositions
	def GenerateVacancyReport()
		return This.GenerateReportXT("Vacancy")

		# Returns the vacancy report; another spelling of the vacancy-report call.
		#
		#   returns    a hash list [ :title, :vacancyCount, :vacancyRate, :details ]
		#   see        GenerateVacancyReport
		def GenerateVacancy()
			return This.GenerateReportXT("vacancy")

		# Returns the vacancy report; another spelling of the vacancy-report call.
		#
		#   returns    a hash list [ :title, :vacancyCount, :vacancyRate, :details ]
		#   see        GenerateVacancyReport
		def Vacancy()
			return This.GenerateReportXT("vacancy")

		# Returns the vacancy report; another spelling of the vacancy-report call.
		#
		#   returns    a hash list [ :title, :vacancyCount, :vacancyRate, :details ]
		#   see        GenerateVacancyReport
		def VacancyReport()
			return This.GenerateReportXT("vacancy")

	# Returns the succession report: each filled position without a successor, with its title, incumbent's name and a high risk level.
	#
	#   returns    a hash list [ :title, :date, :highRiskCount, :details ]
	#   warning    every filled position is listed today, because no successor is ever found
	#   see        GenerateReport, SuccessionRisk
	def GenerateSuccessionReport()
		return This.GenerateReportXT("succession")

		# Returns the succession report; another spelling of the succession-report call.
		#
		#   returns    a hash list [ :title, :date, :highRiskCount, :details ]
		#   see        GenerateSuccessionReport
		def GenerateSuccession()
			return This.GenerateReportXT("succession")

		# Returns the succession report; another spelling of the succession-report call.
		#
		#   returns    a hash list [ :title, :date, :highRiskCount, :details ]
		#   see        GenerateSuccessionReport
		def Succession()
			return This.GenerateReportXT("succession")

		# Returns the succession report; another spelling of the succession-report call.
		#
		#   returns    a hash list [ :title, :date, :highRiskCount, :details ]
		#   see        GenerateSuccessionReport
		def SuccessionReport()
			return This.GenerateReportXT("succession")

	# Returns the compliance report: the BCEAO, span-of-control and segregation verdicts and whether the chart is compliant overall.
	#
	#   returns    a hash list [ :title, :date, :checks, :overallStatus, :failedChecks ]
	#   warning    overallStatus is compliant or non-compliant
	#   see        GenerateReport, Validate
	def GenerateComplianceReport()
		return This.GenerateReportXT("compliance")

		# Returns the compliance report; another spelling of the compliance-report call.
		#
		#   returns    a hash list [ :title, :date, :checks, :overallStatus, :failedChecks ]
		#   see        GenerateComplianceReport
		def GenerateCompliance()
			return This.GenerateReportXT("compliance")

		# Returns the compliance report; another spelling of the compliance-report call.
		#
		#   returns    a hash list [ :title, :date, :checks, :overallStatus, :failedChecks ]
		#   see        GenerateComplianceReport
		def Compliance()
			return This.GenerateReportXT("compliance")

		# Returns the compliance report; another spelling of the compliance-report call.
		#
		#   returns    a hash list [ :title, :date, :checks, :overallStatus, :failedChecks ]
		#   see        GenerateComplianceReport
		def ComplianceReport()
			return This.GenerateReportXT("compliance")

	# Returns the span report: each supervisor with its direct report count and a status of underutilized, optimal or excessive.
	#
	#   returns    a hash list [ :title, :date, :details ]
	#   warning    fewer than 3 reports is underutilized and more than 9 excessive; a position with
	#              no report is not listed
	#   see        GenerateReport, AverageSpanOfControl
	def GenerateSpanOfControlReport()
		return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def GenerateSpanOfControl()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def SpanOfControl()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def GenerateSOCReport()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def GenerateSOC()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def SOC()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def SpanOfControlReport()
			return This.GenerateReportXT("spanofcontrol")

		# Returns the span-of-control report; another spelling of the span-report call.
		#
		#   returns    a hash list [ :title, :date, :details ]
		#   see        GenerateSpanOfControlReport
		def SOCReport()
			return This.GenerateReportXT("spanofcontrol")

	#==========================#
	#  ORGANIZATIONAL CHANGES  #
	#==========================#

	# Moves a person to another position: the old position becomes vacant and the new one takes the person as incumbent.
	#
	#   pcPersonId        The id of the person
	#   pcNewPositionId   The id of the new position, or a pair such as :ToPosition = "vp2"
	#   returns           nothing; the chart changes
	#   warning           an unknown new position still vacates the old one and leaves the person
	#                     pointing at nothing
	#   see               AssignPerson, VacantPositions
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
					@aPositions[i][:isVacant] = 1
					exit
				ok
			end
		ok
		
		This.AssignPerson(pcPersonId, pcNewPositionId)

		# Moves a person to another position; another spelling of the reassignment call.
		#
		#   pcPersonId        The id of the person
		#   pcNewPositionId   The id of the new position, or a pair such as :ToPosition = "vp2"
		#   returns           nothing; the chart changes
		#   see               ReassignPerson
		def Reassign(pcPersonId, pcNewPositionId)
			This.ReassignPerson(pcPersonId, pcNewPositionId)

	# Removes a position and its node with the edges at it; its incumbent is left without a position; an unknown id is ignored.
	#
	#   pcPositionId   The id of the position to remove
	#   returns        nothing; the chart changes
	#   warning        positions that reported to it keep its id as their supervisor and are not
	#                  reconnected
	#   see            ChangeReportingLine, ReassignPerson
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

	# Moves a position under a new supervisor: removes the edge from its old supervisor, if any, and adds one from the new.
	#
	#   pcSubordinate     The id of the position that reports
	#   pcNewSupervisor   The id of the new supervisor
	#   returns           nothing; the chart changes
	#   warning           no check is made for a cycle: making the top position report to its own
	#                     subordinate is accepted
	#   see               ReportsTo
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
	
	# Sets the colour that the View calls give to the positions they highlight, resolved to a #rrggbb code.
	#
	#   pColor     A colour, such as :red, "red" or "#C94DC9"
	#   returns    nothing; the chart changes
	#   warning    #C94DC9 is the default
	#   see        FocusColor, ApplyFocusTo
	def SetFocusColor(pColor)
	    @cFocusColor = ResolveColor(pColor)
	
	# Returns the highlight colour as a #rrggbb code; #C94DC9 until set.
	#
	#   returns    text
	#   see        SetFocusColor, ApplyFocusTo
	def FocusColor()
	    return @cFocusColor
	
	# Paints every position node white, which is meant to restore the level colours.
	#
	#   returns    nothing; the chart changes
	#   warning    known defect: the level colour is read from a key that is never written, so every
	#              node ends white
	#   see        ApplyFocusTo, ColorByDepartment
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
	
	# Paints every node white, then paints the listed positions with the focus colour.
	#
	#   acNodeIds   The ids of the positions to highlight, as a list
	#   returns     nothing; the chart changes
	#   warning     an id that is not a node is ignored
	#   see         SetFocusColor, ResetAllNodeColors
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

	# Sets the fill colour of department clusters added from now on, resolved to a #rrggbb code; existing clusters keep theirs.
	#
	#   pcColor    A colour, such as :red or "#FF0000"
	#   returns    nothing; the chart changes
	#   warning    call it before adding departments with their positions
	#   see        AddDepartment, ColorByDepartment
	def SetDepartmentColor(pcColor)
		super.SetClusterColor(ResolveColor(pcColor))

	# Highlights the positions named in the affectedNodes of a validation result and displays the chart.
	#
	#   aValidationResult   A verdict hash list, such as Validate or ValidateVacancy returns
	#   returns             nothing; the chart is displayed
	#   warning             a result without affectedNodes highlights nothing; the display needs
	#                       graphviz and a viewer, so it was not run here
	#   see                 ViewXT, Validate
	#@ aka  --
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

	# Highlights the vacant positions with the focus colour and displays the chart, under the subtitle Vacant Positions when a title is set.
	#
	#   returns    nothing; the chart is displayed
	#   warning    the display needs graphviz and a viewer, so it was not run here; the colouring
	#              was checked with the display call replaced
	#   see        ViewNonVacant, VacantPositions
	#@ aka  --
	def ViewVacant()

	    If This.Title() != ""
		This.SetSubtitle("Vacant Positions")
	    ok

	    _acVacant_ = This.VacantPositions()
	    This.ApplyFocusTo(_acVacant_)
	    This.View()
	
	    # Highlights the vacant positions and displays the chart; another spelling of the vacant view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewVacant
	    def ViewVacancies()
	        This.ViewVacant()

	# Highlights the filled positions with the focus colour and displays the chart, under the subtitle Non-Vacant Positions when a title is set.
	#
	#   returns    nothing; the chart is displayed
	#   warning    the display needs graphviz and a viewer, so it was not run here
	#   see        ViewVacant, NonVacantPositions
	def ViewNonVacant()

	    If This.Title() != ""
		This.SetSubtitle("Non-Vacant Positions")
	    ok

	    _acVacant_ = This.NonVacantPositions()
	    This.ApplyFocusTo(_acVacant_)
	    This.View()

	    # Highlights the filled positions and displays the chart; another spelling of the filled view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewNonVacant
	    def ViewPopulated()
		This.ViewNonVacant()

	    # Highlights the filled positions and displays the chart; another spelling of the filled view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewNonVacant
	    def ViewPeople()
	        This.ViewNonVacant()
	
	    # Highlights the filled positions and displays the chart; another spelling of the filled view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewNonVacant
	    def ViewWithPeople()
	        This.ViewNonVacant()

	# Highlights the positions whose node property performance is 75 or more, and displays the chart.
	#
	#   returns    nothing; the chart is displayed
	#   warning    performance is a number you set with SetNodeProperty; a node without it is not
	#              highlighted; the display needs graphviz and a viewer, so it was not run here
	#   see        ViewNonPerformant, ViewMediumPerformers
	#TODO// Add Performant() or PerformantPositions(),
	#@ aka  --
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
	
	    # Highlights the high performers and displays the chart; another spelling of the performant view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewPerformant
	    def ViewHighPerformers()
	        This.ViewPerformant()
	
	# Highlights the positions whose node property performance is below 50, and displays the chart.
	#
	#   returns    nothing; the chart is displayed
	#   warning    a node without a performance property is not highlighted
	#   see        ViewPerformant, ViewMediumPerformers
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
	
	    # Highlights the low performers and displays the chart; another spelling of the non-performant view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewNonPerformant
	    def ViewLowPerformers()
	        This.ViewNonPerformant()
	
	# Highlights the positions whose node property performance is from 50 up to 75, and displays the chart.
	#
	#   returns    nothing; the chart is displayed
	#   warning    a node without a performance property is not highlighted
	#   see        ViewPerformant, ViewNonPerformant
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

	# Validates by the named norm and highlights the positions not named in its issues, or all of them on a pass; then displays the chart.
	#
	#   pcNorm     The validator name, as text such as vacancy, bceao or sod
	#   returns    nothing; the chart is displayed
	#   warning    positions are recognised in the issue texts as words that are node ids; when no
	#              issue names one, nothing is highlighted
	#   see        ViewNonCompliant, ValidateXT
	#TODO // Add Compliant() or CompliantPositions() and
	#@ aka  --
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

	# Raises error R20 today instead of highlighting the positions named in a failing norm's issues and displaying the chart.
	#
	#   pcNorm     The validator name, as text such as vacancy, bceao or sod
	#   returns    nothing today
	#   warning    known defect: it calls Validate with an argument that Validate does not take, so
	#              every call raises R20
	#   see        ViewCompliant
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

	# Highlights the filled positions without a successor and displays the chart, under the subtitle At risk positions when a title is set.
	#
	#   returns    nothing; the chart is displayed
	#   warning    today that is every filled position; the display needs graphviz and a viewer, so
	#              it was not run here
	#   see        SuccessionRisk, ViewNotAtRisk
	#@ aka  --
	def ViewAtRisk()

	    If This.Title() != ""
		This.SetSubtitle("At risk posisitions")
	    ok

	    _acRisk_ = This.SuccessionRisk()
	    This.ApplyFocusTo(_acRisk_)
	    This.View()
	
	    # Highlights the positions at succession risk and displays the chart; another spelling of the at-risk view.
	    #
	    #   returns    nothing; the chart is displayed
	    #   see        ViewAtRisk
	    def ViewSuccessionRisk()
	        This.ViewAtRisk()
	
	# Raises error R24 today instead of highlighting the positions that have a successor and displaying the chart.
	#
	#   returns    nothing today
	#   warning    known defect: it reads an attribute @bShowTitle that no class defines, so every
	#              call raises R24
	#   see        ViewAtRisk, SuccessionRisk
	def ViewNotAtRisk()

	    If @bShowTitle = 1
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

	# Highlights the positions of one department and displays the chart; raises error R24 when the chart has a title.
	#
	#   pcDepartmentId   The department name of the positions, as set by SetPositionDepartment
	#   returns          nothing; the chart is displayed
	#   warning          known defect: the subtitle line, written when a title is set, reads an
	#                    undefined variable ppcdepartmentid; without a title it works
	#   see              ViewAllDepartments, SetPositionDepartment
	#@ aka  --
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
	
	# Paints positions by their department colour and displays the chart.
	#
	#   returns    nothing; the chart is displayed
	#   warning    only departments named in the colour table are painted
	#   see        ColorByDepartment, ViewDepartment
	def ViewAllDepartments()
	    This.ResetAllNodeColors()
	    This.ColorByDepartment()
	    This.View()

	# Highlights the positions on the path between two positions and displays the chart; with a title set it also adds a stray node.
	#
	#   pcFromId   The id of the position the path starts at
	#   pcToId     The id of the position the path ends at
	#   returns    nothing; the chart is displayed
	#   warning    known defect: with a title set, the subtitle line indexes the node list by id and
	#              adds a node with an empty id; without a title it works
	#   see        ViewReportingPath, HilightPath
	#@ aka  --
	def ViewPath(pcFromId, pcToId)

	    If This.Title() != ""
		This.SetSubtitle("Path from '" + @aNodes[pcFromId] + "' to '" + @aNodes[pcFromId] + "'" )
	    ok

	    _acPath_ = This.PathBetween(pcFromId, pcToId)
	    This.ApplyFocusTo(_acPath_)
	    This.View()
	
	    # Highlights the path between two positions and displays the chart; another spelling of the path view.
	    #
	    #   pcFromId   The id of the position the path starts at
	    #   pcToId     The id of the position the path ends at
	    #   returns    nothing; the chart is displayed
	    #   see        ViewPath
	    def ViewReportingPath(pcFromId, pcToId)
	        This.ViewPath(pcFromId, pcToId)

	    # Highlights the path between two positions and displays the chart; another spelling of the path view.
	    #
	    #   pcFromId   The id of the position the path starts at
	    #   pcToId     The id of the position the path ends at
	    #   returns    nothing; the chart is displayed
	    #   see        ViewPath
	    def HilightPath(pcFromId, pcToId)
		This.ViewPath(pcFromId, pcToId)

	    # Highlights the path between two positions and displays the chart; another spelling of the path view.
	    #
	    #   pcFromId   The id of the position the path starts at
	    #   pcToId     The id of the position the path ends at
	    #   returns    nothing; the chart is displayed
	    #   see        ViewPath
	    def FocusOnPath(pcFromId, pcToId)
		This.ViewPath(pcFromId, pcToId)

	# Highlights the nodes whose property has a given value, any value when the value is empty text, and displays the chart.
	#
	#   pcKey      The property name to look for, as text
	#   pValue     The value to match, or "" to match any node that has the property
	#   returns    nothing; the chart is displayed
	#   warning    the property is read from the node, so level, department and any property set
	#              with SetNodeProperty can be used
	#   see        ViewNodesWithTag, SetNodeProperty
	#@ aka  --
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
	            if pValue = "" or _aNode_["properties"][pcKey] = pValue
	                _acMatching_ + _aNode_["id"]
	            ok
	        ok
	    end
	    
	    This.ApplyFocusTo(_acMatching_)
	    This.View()
	
	# Does nothing today instead of highlighting the nodes that hold several properties: the body is a TODO.
	#
	#   pacProps   The property names to look for, as a list
	#   returns    nothing today
	#   warning    known defect: the method is an empty stub
	#   see        ViewNodesWithProperty
	def ViewNodeWithProperties(pacProps)
	# Highlights the nodes whose tags property holds a tag and displays the chart.
	#
	#   pcTag      The tag to look for, as text
	#   returns    nothing; the chart is displayed
	#   warning    tags is a list set with SetNodeProperty(id, "tags", [ ... ]); a node without tags
	#              is not highlighted
	#   see        ViewNodesWithTags, SetNodeProperty
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

	# Does nothing today instead of highlighting the nodes that hold several tags: the body is a TODO.
	#
	#   pacTags    The tags to look for, as a list
	#   returns    nothing today
	#   warning    known defect: the method is an empty stub
	#   see        ViewNodesWithTag
	def ViewNodesWithTags(pacTags)
	# Paints each position with the colour of its department when the department is in the colour table, such as risk or audit.
	#
	#   returns    nothing; the chart changes
	#   warning    the table names board, executive, management, staff, operations, treasury, risk,
	#              audit, hr, it, sales and engineering; a position with no department gains an
	#              empty department key
	#   see        ViewAllDepartments, SetPositionDepartment
		#TODO
	#@ aka  --
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

	# Returns a hash list explaining the chart: structure, hierarchy, staffing, compliance findings, risks and efficiency remarks.
	#
	#   returns    a hash list of texts and lists of texts
	#   warning    raises error R1 on a chart with no position, a division by zero
	#   see        GenerateReport, Validate
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

	# Returns the chart in the .stzorg text format: positions, people, assignments and departments.
	#
	#   returns    text, several lines
	#   warning    the chart's id, in lowercase, is written as the name
	#   see        WriteToStzOrgFile, ImportStzOrg
	def ToStzOrg()
		_cResult_ = 'orgchart "' +
			  This.Id() + '"' + char(10) + char(10)
		
		# Positions
		_cResult_ += "positions" + char(10)
		_aPositions_ = This.Positions()
		_nPosLen_ = len(_aPositions_)
		for i = 1 to _nPosLen_
			_aPos_ = _aPositions_[i]
			_cResult_ += "    " + _aPos_[:id] + char(10)
			_cResult_ += "        title: " + _aPos_[:title] + char(10)
			_cResult_ += "        level: " + _aPos_[:level] + char(10)
			_cResult_ += "        department: " + _aPos_[:department] + char(10)
			_cResult_ += "        reportsTo: " + _aPos_[:reportsTo] + char(10)
			_cResult_ += char(10)
		end
		
		# People
		_cResult_ += "people" + char(10)
		_aPeople_ = This.People()
		_nPplLen_ = len(_aPeople_)
		for i = 1 to _nPplLen_
			_aPerson_ = _aPeople_[i]
			_cResult_ += "    " + _aPerson_[:id] + char(10)
			_cResult_ += "        name: " + _aPerson_[:name] + char(10)
			_cResult_ += char(10)
		end
		
		# Assignments
		_cResult_ += "assignments" + char(10)
		for i = 1 to _nPosLen_
			_aPos_ = _aPositions_[i]
			if _aPos_[:incumbent] != ""
				_cResult_ += "    " + _aPos_[:incumbent] + " -> " + _aPos_[:id] + char(10)
			ok
		end
		_cResult_ += char(10)
		
		# Departments
		_cResult_ += "departments" + char(10)
		_aDepts_ = This.Departments()
		_nDeptLen_ = len(_aDepts_)
		for i = 1 to _nDeptLen_
			_aDept_ = _aDepts_[i]
			_cResult_ += "    " + _aDept_[:id] + char(10)
			_cResult_ += "        name: " + _aDept_[:name] + char(10)
			_cResult_ += "        positions: " + Q(_aDept_[:positions]).ToCode() + char(10)
			_cResult_ += char(10)
		end
		
		return _cResult_
	

	# Writes the chart to a file in the .stzorg format, adding .stzorg to the name when it is missing.
	#
	#   pcFileName   The file to write, as text, with or without the .stzorg ending
	#   returns      1
	#   warning      an existing file is overwritten
	#   see          ToStzOrg, WriteStzOrg
	def WriteToStzOrgFile(pcFileName)
		if StzRight(pcFileName, 7) != ".stzorg"
			pcFileName += ".stzorg"
		ok

		write(pcfileName, This.ToStzOrg())
		return 1
	
	# Writes the chart to a file in the .stzorg format, using the file name exactly as given.
	#
	#   pcFileName   The file to write, as text
	#   returns      1
	#   warning      an existing file is overwritten and no ending is added
	#   see          ToStzOrg, WriteToStzOrgFile
	def WriteStzOrg(pcFileName)
		write(pcfileName, This.ToStzOrg())
			return 1

	# Reads .stzorg text and adds its positions, people, assignments and departments to the chart; the name line is ignored.
	#
	#   cString    The .stzorg text, as ToStzOrg writes it
	#   returns    nothing; the chart changes
	#   warning    the content is added to what the chart already holds; the positions listed for a
	#              department come back wrapped in double quotes
	#   see        ImportFromStzOrgFile, ToStzOrg
	#@ aka  ===================================================== IMPORT FROM .STZORG FORMAT =====================================================
	def ImportStzOrg(cString)
		_acLines_ = @split(cString, char(10))
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

	# Reads a .stzorg file and adds its content to the chart; a missing file raises error R35.
	#
	#   pcFileName   The path of the .stzorg file, as text
	#   returns      nothing; the chart changes
	#   see          ImportStzOrg, WriteToStzOrgFile
	def ImportFromStzOrgFile(pcFileName)
		_cContent_ = read(pcFileName)
		This.ImportStzOrg(_cContent_)
	
		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadStzOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def ImportOrg(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadOrgChart(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadStzOrgFile(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def Load_(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadFile(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Reads a .stzorg file into the chart; another spelling of the file import.
		#
		#   pcFileName   The path of the .stzorg file, as text
		#   returns      nothing; the chart changes
		#   see          ImportFromStzOrgFile
		def LoadFrom(pcFileName)
			This.ImportFromStzOrgFile(pcFileName)

		# Records a rule-base source in the chart's list; nothing evaluates it yet, as the rule-base system is a stub.
		#
		#   pSource    A rule-base file path, profile name or rule-base object
		#   returns    nothing; the chart changes
		#   warning    to run a rule base use CheckCompliance
		#   see        RuleBases, CheckCompliance
		#@ aka  LoadRuleBase: stub for the future rule-base validation system. Accepts a file path, a class instance, or a pre-built profile name (string). For now it just records the source -- the actual rule-evaluation engine will land with the dedicated stzRuleBase class.
		def LoadRuleBase(pSource)
			@aRuleBases + pSource

		# Returns the rule-base sources recorded by LoadRuleBase, in order.
		#
		#   returns    a list
		#   see        LoadRuleBase
		def RuleBases()
			return @aRuleBases

# Stub rule-base classes that the narrative tests instantiate via
# LoadRuleBase(new stzXxxRuleBase()). They land here as minimal
# placeholders -- a real rule-evaluation engine will replace them
# without changing the public Load + Validate surface.

# Holds a named set of org-chart compliance rules, starting with the four universal ones, ready to check a chart.
#
# It is a stzGraphRuleSet in the orgchart domain: self-report, reporting cycle, orphan position and
# span of control. The regime classes below it (SOX, GDPR, PCI-DSS, HIPAA, ISO 27001, Basel III,
# BCEAO) differ by name today, and only SOX adds a rule of its own. Pass one to
# stzOrgChart.CheckCompliance.
#
#   receiver   o1 = new stzRuleBase("Mine")
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzOrgChart, stzGraphRuleSet
class stzRuleBase from stzGraphRuleSet
	# Builds a compliance rule base named for a regime, in the orgchart domain, with the four universal org rules; a non-text name gives "".
	#
	#   pcName     The rule base name, as text
	#   returns    nothing; the rule base is built
	#   warning    the rules are self-report, reporting cycle, orphan position and span of control
	#   see        CheckCompliance, AddRule
	def init(pcName)
		if isString(pcName)
			super.init(pcName)
		else
			super.init("")
		ok
		This.SetDomainQ("orgchart")
		# every compliance base carries the universal org-integrity tier (phase
		# 2b) -- broken reporting is a problem under any regime. Regime-specific
		# rules are added by the subclasses (see stzSOXRuleBase).
		_StzAddUniversalOrgRules(This)

# Holds the SOX compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules plus a separation-of-duties rule that flags a position holding
# both approver and executor roles.
#
#   receiver   o1 = new stzSOXRuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 5
#   see        stzRuleBase, stzOrgChart
class stzSOXRuleBase from stzRuleBase
	# Builds the SOX rule base: the four universal org rules under the name SOX; it adds the separation-of-duties rule, so it holds five rules.
	#
	#   returns    nothing; the rule base is built
	#   see        CheckCompliance, AddRule
	def init()
		super.init("SOX")
		# SOX exemplar: separation-of-duties (illustrative -- see stzOrgRule.ring)
		StzAddSODRule(This)

# Holds the GDPR compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzGDPRRuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzGDPRRuleBase from stzRuleBase
	# Builds the GDPR rule base: the four universal org rules under the name GDPR; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("GDPR")

# Holds the PCI-DSS compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzPCIDSSRuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzPCIDSSRuleBase from stzRuleBase
	# Builds the PCI-DSS rule base: the four universal org rules under the name PCI-DSS; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("PCI-DSS")

# Holds the HIPAA compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzHIPAARuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzHIPAARuleBase from stzRuleBase
	# Builds the HIPAA rule base: the four universal org rules under the name HIPAA; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("HIPAA")

# Holds the ISO 27001 compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzISO27001RuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzISO27001RuleBase from stzRuleBase
	# Builds the ISO 27001 rule base: the four universal org rules under the name ISO 27001; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("ISO 27001")

# Holds the Basel III compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzBaselIIIRuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzBaselIIIRuleBase from stzRuleBase
	# Builds the Basel III rule base: the four universal org rules under the name Basel III; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("Basel III")

# Holds the BCEAO compliance rules for an org chart, ready to pass to CheckCompliance.
#
# Holds the four universal org rules and no rule of its own yet: only the name tells it from the
# other regimes.
#
#   receiver   o1 = new stzBCEAORuleBase()
#   example    ? o1.NumberOfRules()
#              #--> 4
#   see        stzRuleBase, stzOrgChart
class stzBCEAORuleBase from stzRuleBase
	# Builds the BCEAO rule base: the four universal org rules under the name BCEAO; it adds no rule of its own.
	#
	#   returns    nothing; the rule base is built
	#   warning    only the name tells the regimes apart today
	#   see        CheckCompliance, AddRule
	def init()
		super.init("BCEAO")

		# IsValid / Validate already exist on stzOrgChart above --
		# the rule-base layer hooks into them when implemented.

#=====================================================
#  stzOrgChartBCEAOValidator
#=====================================================

# Checks an org chart against three BCEAO governance rules: a board, audit under the board, and a risk function.
#
# It takes a snapshot of the chart when it is built. stzOrgChart.ValidateBCEAOGovernance builds one
# for you.
#
#   receiver   oc = new stzOrgChart("TechCo"); oc.AddExecutiveXT("ceo", "CEO");
#              oc.AddManagerXT("vp", "VP Sales"); oc.ReportsTo("vp", "ceo"); oc.AddPersonXT("p1",
#              "Alice"); oc.AssignPerson("p1", "ceo"); o1 = new stzOrgChartBCEAOValidator(oc)
#   example    ? o1.Validate()[:status]
#              #--> fail
#   see        stzOrgChart, stzOrgChartSODValidator
class stzOrgChartBCEAOValidator from stzObject

	@oOrgChart

	# Builds a BCEAO governance validator over an org chart, taking a snapshot of it at that moment.
	#
	#   poOrgChart   The stzOrgChart to validate
	#   returns      nothing; the validator is built
	#   warning      a position added to the chart afterwards is not seen: build the validator last
	#   see          Validate
	def init(poOrgChart)
		@oOrgChart = poOrgChart

	# Checks three BCEAO rules: a board position, audit under a board department and a risk department; returns the verdict.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues ]
	#   warning    codes BCEAO-001 to BCEAO-003; the board is found by the word board in a position
	#              title, and audit and risk by the department names audit, board and risk
	#   see        init
	def Validate()
		_aIssues_ = []
		
		# Rule 1: Board required
		_bHasBoard_ = 0
		_nPosCount_ = len(@oOrgChart.@aPositions)
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			if HasKey(_aPos_, :title)
				_cTitle_ = StzLower(_aPos_[:title])
				if StzFindFirst("board", _cTitle_)
					_bHasBoard_ = 1
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
		_bHasRisk_ = 0
		for i = 1 to _nPosCount_
			_aPos_ = @oOrgChart.@aPositions[i]
			if HasKey(_aPos_, :department)
				if _aPos_[:department] = "risk"
					_bHasRisk_ = 1
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

# Checks an org chart for one segregation-of-duties rule: operations must not report directly to treasury.
#
# It takes a snapshot of the chart when it is built. stzOrgChart.ValidateSegregationOfDuties builds
# one for you.
#
#   receiver   oc = new stzOrgChart("TechCo"); oc.AddExecutiveXT("ceo", "CEO");
#              oc.AddManagerXT("vp", "VP Sales"); oc.ReportsTo("vp", "ceo"); oc.AddPersonXT("p1",
#              "Alice"); oc.AssignPerson("p1", "ceo"); o1 = new stzOrgChartSODValidator(oc)
#   example    ? o1.Validate()[:status]
#              #--> pass
#   see        stzOrgChart, stzOrgChartBCEAOValidator
class stzOrgChartSODValidator from stzObject

	@oOrgChart

	# Builds a segregation-of-duties validator over an org chart, taking a snapshot of it at that moment.
	#
	#   poOrgChart   The stzOrgChart to validate
	#   returns      nothing; the validator is built
	#   warning      a position added to the chart afterwards is not seen: build the validator last
	#   see          Validate
	def init(poOrgChart)
		@oOrgChart = poOrgChart

	# Fails when a position of the operations department reports directly to a position of the treasury department.
	#
	#   returns    a hash list [ :status, :domain, :issueCount, :issues ]
	#   warning    one rule, code SOD-001; only a direct supervisor is checked, though the message
	#              says through
	#   see        init
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

# Builds the five standard reports of an org chart: summary, vacancy, succession, compliance and span of control.
#
# It takes a snapshot of the chart when it is built, so a position added later is not reported. Each
# report is a hash list with a title and its figures; stzOrgChart.GenerateReport and its aliases
# build a fresh reporter on every call, which is the usual way to reach it.
#
#   receiver   oc = new stzOrgChart("TechCo"); oc.AddExecutiveXT("ceo", "CEO");
#              oc.AddManagerXT("vp", "VP Sales"); oc.ReportsTo("vp", "ceo"); oc.AddPersonXT("p1",
#              "Alice"); oc.AssignPerson("p1", "ceo"); o1 = new stzOrgChartReporter(oc)
#   example    ? o1.VacancyReport()[:vacancycount]
#              #--> 1
#   see        stzOrgChart
class stzOrgChartReporter from stzObject

	@oOrgChart

	# Builds a reporter over an org chart, taking a snapshot of it at that moment for every later report.
	#
	#   poOrgChart   The stzOrgChart to report on
	#   returns      nothing; the reporter is built
	#   warning      a position added to the chart afterwards is not in the reports: build the
	#                reporter last
	#   see          Generate, SummaryReport
	def init(poOrgChart)
		@oOrgChart = poOrgChart

	# Returns the five standard reports in a list: summary, vacancy, succession, compliance and span of control.
	#
	#   returns    a list of five hash lists
	#   see        SummaryReport, VacancyReport, SuccessionReport, ComplianceReport,
	#              SpanOfControlReport
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


	# Returns the summary report: totals, vacancy rate, average span and the position ids by level.
	#
	#   returns    a hash list [ :title, :date, :metrics ]
	#   warning    metrics holds totalPositions, filledPositions, vacancyRate, avgSpan and levels
	#   see        Generate, VacancyReport
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

	# Returns the vacancy report: how many positions are vacant, the rate, and the title and department of each.
	#
	#   returns    a hash list [ :title, :vacancyCount, :vacancyRate, :details ]
	#   warning    known defect: the level of each detail is always staff, since it is read from a
	#              key that is never written
	#   see        Generate, SummaryReport
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

	# Returns the succession report: each filled position without a successor, with its title and the incumbent's name.
	#
	#   returns    a hash list [ :title, :date, :highRiskCount, :details ]
	#   warning    every filled position is listed today, because no successor is ever found; each
	#              is marked with risk level high
	#   see        Generate, ComplianceReport
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

	# Returns the compliance report: the BCEAO, span-of-control and segregation verdicts and the overall status.
	#
	#   returns    a hash list [ :title, :date, :checks, :overallStatus, :failedChecks ]
	#   warning    overallStatus is compliant or non-compliant
	#   see        Generate, SpanOfControlReport
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

	# Returns the span report: each supervisor with its direct report count and a status of underutilized, optimal or excessive.
	#
	#   returns    a hash list [ :title, :date, :details ]
	#   warning    fewer than 3 reports is underutilized and more than 9 excessive; a position with
	#              no report is not listed
	#   see        Generate, ComplianceReport
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

# Tries changes on a copy of an org chart and reports the average span and vacancy rate before and after.
#
# The copy holds the records of the original (positions, people, departments) but no graph nodes, so
# a change_reporting change raises today. The original chart is never touched.
#
#   receiver   oc = new stzOrgChart("TechCo"); oc.AddExecutiveXT("ceo", "CEO");
#              oc.AddManagerXT("vp", "VP Sales"); oc.ReportsTo("vp", "ceo"); oc.AddPersonXT("p1",
#              "Alice"); oc.AssignPerson("p1", "ceo"); o1 = new stzOrgChartSimulation(oc)
#   example    o1.ApplyChanges([ [ :type = "add_position", :id = "n1", :title = "New" ] ])
#              ? o1.Results()[:after][:vacancyrate]
#              #--> 66.67
#   see        stzOrgChart
class stzOrgChartSimulation from stzObject

	@oOriginalChart
	@oSimulatedChart
	@aChanges = []
	@aResults = []

	# Builds a what-if simulation over an org chart by copying its positions, people and departments into a second chart.
	#
	#   poOrgChart   The stzOrgChart to simulate changes on
	#   returns      nothing; the simulation is built
	#   warning      the copy is named after the original with _sim added and holds no graph nodes,
	#                so only the records are copied
	#   see          ApplyChanges, SimulatedChartQ
	def init(poOrgChart)
		@oOriginalChart = poOrgChart
		@oSimulatedChart = This._CloneChart(poOrgChart)

	def _CloneChart(poChart)
		_oClone_ = new stzOrgChart(poChart.Id() + "_sim")
		_oClone_.@aPositions = poChart.@aPositions
		_oClone_.@aPeople = poChart.@aPeople
		_oClone_.@aDepartments = poChart.@aDepartments
		return _oClone_

	# Applies a list of changes to the copy, never to the original, then records the before and after spans and vacancy rates.
	#
	#   paChanges   A list of hash lists, each with :type, one of reassign (:person, :newPosition),
	#               remove_position (:position), add_position (:id, :title) or change_reporting
	#               (:subordinate, :supervisor)
	#   returns     nothing; the results are stored
	#   warning     known defect: a change_reporting change raises "Cannot add edge: one or both
	#               nodes do not exist!", since the copy has no nodes; an unknown :type is skipped
	#               without a word
	#   see         Results, SimulatedChartQ
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

	# Returns the before and after average span of control and vacancy rate, and the changes applied; [ ] before ApplyChanges.
	#
	#   returns    a hash list [ :before, :after, :changes ], or [ ]
	#   see        ApplyChanges
	def Results()
		return @aResults

	# Returns the what-if chart the changes were applied to; the original chart is not touched.
	#
	#   returns    a stzOrgChart
	#   warning    the copy has records but no graph nodes
	#   see        ApplyChanges, Results
	#@ aka  The what-if chart produced by the simulation -- an OBJECT, hence Q.
	def SimulatedChartQ()
		return @oSimulatedChart
