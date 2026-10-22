#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZFLOW                        #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzFlow -- faculties wired as a DATA FLOW.   #
#                  A flow names faculties, never models, so any #
#                  stage can be pinned to a model, to a set, or #
#                  to its FLOOR without touching the solution.  #
#                  It composes an stzGraph (LAW 5) and is       #
#                  CHECKED BEFORE IT RUNS: ResolvePlan() and    #
#                  CheckRules() run nothing.                    #
#                  What passes between stages is an stzParcel;  #
#                  a stage that refuses stops its branch and the#
#                  flow returns that refusal, never a half-built#
#                  value. (SOFTANZA_MODEL_FLOW.md section 6.)   #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

func StzFlowQ(pcName)
	return new stzFlow(pcName)

# the stage rows are plain lists: [ :id, :faculty, :params, :impl, :floor, :set ]
func _StzFlowStageRow(paStages, pcId)
	for _i_ = 1 to len(paStages)
		if paStages[_i_][:id] = pcId return _i_ ok
	next
	return 0

# Wires faculties into a data flow whose stages are checked before they run and whose results are parcels.
#
# A flow names faculties and never models, so any stage can be pinned to one implementation, to a
# set of them, or to its floor without touching the rest. It composes an stzGraph, and CheckRules,
# ResolvePlan and Why run nothing. Run feeds the input to the stages that have no predecessor,
# passes each parcel to the stage after it, stops at the first stage that refuses, and returns the
# value of the last stage in order, or the findings when the flow was refused. This slice has no
# merge, so a stage with several predecessors is a finding. Nothing here has been run against a real
# model: the examples use plain functions as stand-ins.
#
#   receiver   f1 = StzFacultyQ("flowpos")  f1.SetInputType(:text)  f1.SetOutputType(:number)
#              f1.SetFloor("last", "StzFindLast")  o1 = StzFlowQ("positions")  o1.AddStage("find",
#              "flowpos", [ "a", "b", "c", "b" ])
#   example    ? @@( o1.StageIds() )
#              #--> [ "find" ]
#              ? o1.IsSound()
#              #--> 1
#              ? o1.Run("c")
#              #--> 3
#              ? o1.StageParcelQ("find").Why()
#              #--> flowpos -> last (floor) | certainty unknown
#   see        stzFaculty, stzParcel, stzModelRegistry, stzGraph
class stzFlow from stzObject

	@cName = ""
	@aStages = []
	@aEdges = []              # [ from, to ]
	@oGraph = ""
	@bFloorEverywhere = 0
	@aParcels = []            # [ id, parcel ] of the last run
	@aPlanCache = []

	# Builds an empty flow of that name, with an empty stzGraph of its own to hold the stages.
	#
	#   pcName     the flow's name, shown in findings and in the trace of its parcels
	#   returns    nothing; the object is built
	#   note       a flow is built stage by stage with AddStage and ConnectStages, and is checked
	#              before it runs
	#   see        StzFlowQ, AddStage
	def init(pcName)
		@cName = pcName
		@oGraph = new stzGraph(pcName)

	# Returns the name the flow was built with.
	#
	#   returns    a text
	#   see        StzFlowQ, Explain
	def Name()
		return @cName

	# Returns the stzGraph the flow composes, with one node per stage and one edge per connection.
	#
	#   returns    an stzGraph
	#   note       cycle detection and reachability of the graph apply to the flow unchanged
	#   see        AddStage, ConnectStages
	#@ aka  the stzGraph this flow composes: cycle detection, reachability and the rule gate apply to it unchanged
	def Graph()
		return @oGraph

	# Returns the stage rows in the order they were added.
	#
	#   returns    a list of rows, each a list of [ key, value ] pairs: id, faculty, params, impl,
	#              floor, set
	#   note       impl, floor and set hold the pins of the stage: the registry decides when all
	#              three are empty
	#   warning    after a run the params of a stage hold the faculty's defaults merged in, because
	#              the run writes the merge back into the stage's list
	#   see        StageIds, AddStage, PinStage
	def Stages()
		return @aStages

	# Returns the ids of the stages in the order they were added.
	#
	#   returns    a list of text
	#   note       the order added is not the order run: TopologicalOrder gives the order of the
	#              data flow
	#   see        Stages, TopologicalOrder
	def StageIds()
		_a_ = []
		for _i_ = 1 to len(@aStages)
			add(_a_, @aStages[_i_][:id])
		next
		return _a_

	# Returns the connections between stages, in the order they were made.
	#
	#   returns    a list of [ from, to ] pairs of stage ids
	#   see        ConnectStages, Predecessors
	def Edges()
		return @aEdges

	# Returns how many stages the flow holds.
	#
	#   returns    a number
	#   see        StageIds, AddStage
	def NumberOfStages()
		return len(@aStages)

	# Adds a stage that runs a declared faculty; the flow names faculties and never models.
	#
	#   pcId        the stage's id, unique in the flow
	#   pcFaculty   the name of a faculty already declared, folded to lower case
	#   paParams    call parameters of the stage, merged over the faculty's defaults, where any
	#               value that is not a list counts as an empty list
	#   returns     nothing; use AddStageQ to chain
	#   note        the stage also becomes a node of the flow's stzGraph
	#   warning     raises an error for an id the flow already has and for a faculty that is not
	#               declared, naming the declared ones
	#   see         ConnectStages, PinStage, StzFacultyQ
	#@ aka  -- building: active verbs, each with its Q twin ----------------------------------------------
	def AddStage(pcId, pcFaculty, paParams)
		if _StzFlowStageRow(@aStages, pcId) > 0
			stzraise("AddStage: the flow '" + @cName + "' already has a stage '" + pcId + "'.")
		ok
		if NOT StzHasFaculty(pcFaculty)
			stzraise("AddStage: no faculty named '" + pcFaculty + "' is declared (declared: " + @@(StzFacultyNames()) + ").")
		ok
		if NOT isList(paParams) paParams = [] ok
		add(@aStages, [ :id = pcId, :faculty = lower(pcFaculty), :params = paParams, :impl = "", :floor = 0, :set = [] ])
		@oGraph.AddNode(pcId)

		def AddStageQ(pcId, pcFaculty, paParams)
			This.AddStage(pcId, pcFaculty, paParams)
			return This

	# Connects the output of one stage to the input of another, in the order given.
	#
	#   pcFrom     the id of the producing stage
	#   pcTo       the id of the consuming stage
	#   returns    nothing; use ConnectStagesQ to chain
	#   note       the stage with no predecessor receives the input of Run
	#   warning    raises an error when either stage is not in the flow; nothing is checked about
	#              types, cycles or fan-in here, those are findings of CheckRules
	#   see        AddStage, Predecessors, CheckRules
	def ConnectStages(pcFrom, pcTo)
		if _StzFlowStageRow(@aStages, pcFrom) = 0
			stzraise("ConnectStages: no stage '" + pcFrom + "'.")
		ok
		if _StzFlowStageRow(@aStages, pcTo) = 0
			stzraise("ConnectStages: no stage '" + pcTo + "'.")
		ok
		add(@aEdges, [ pcFrom, pcTo ])
		@oGraph.AddEdge(pcFrom, pcTo)

		def ConnectStagesQ(pcFrom, pcTo)
			This.ConnectStages(pcFrom, pcTo)
			return This

	# Pins a stage to one implementation by id, or to its floor with floor; the registry never overrides a pin.
	#
	#   pcId       the id of the stage
	#   pImpl      the id of an implementation of the stage's faculty, or the word floor in any case
	#   returns    nothing; use PinStageQ to chain
	#   note       pinning an implementation clears a floor pin and the reverse; a service can only
	#              be reached by pinning it by name
	#   warning    the id is not checked when pinned: an unknown one is refused only when the flow
	#              runs, with an unknown-implementation finding naming the stage, and a pinned
	#              implementation that is not installed is refused too, never replaced
	#   see        PinStageToSet, UnpinStage, UseFloorEverywhere
	#@ aka  Pin a stage to ONE implementation (by id), or to the floor with :floor. The registry never overrides a pin.
	def PinStage(pcId, pImpl)
		_i_ = _StzFlowStageRow(@aStages, pcId)
		if _i_ = 0 stzraise("PinStage: no stage '" + pcId + "'.") ok
		if isString(pImpl) and lower(pImpl) = "floor"
			@aStages[_i_][:floor] = 1
			@aStages[_i_][:impl] = ""
		else
			@aStages[_i_][:floor] = 0
			@aStages[_i_][:impl] = "" + pImpl
		ok

		def PinStageQ(pcId, pImpl)
			This.PinStage(pcId, pImpl)
			return This

	# Restricts the registry's choice for a stage to the implementations listed, still by measured quality.
	#
	#   pcId       the id of the stage
	#   pacImpls   a list of implementation ids the registry may choose among
	#   returns    nothing; use PinStageToSetQ to chain
	#   note       the other implementations appear in the plan as rejected, not in the pinned set
	#   warning    an id outside the faculty is simply never chosen, and when no listed id qualifies
	#              the floor answers; listing a service without pinning it is an error finding of
	#              CheckRules
	#   see        PinStage, UnpinStage, ResolvePlan
	#@ aka  Let the registry choose within a set of implementations (still gated by measured quality)
	def PinStageToSet(pcId, pacImpls)
		_i_ = _StzFlowStageRow(@aStages, pcId)
		if _i_ = 0 stzraise("PinStageToSet: no stage '" + pcId + "'.") ok
		@aStages[_i_][:set] = pacImpls

		def PinStageToSetQ(pcId, pacImpls)
			This.PinStageToSet(pcId, pacImpls)
			return This

	# Removes every pin from a stage, so the registry chooses for it again.
	#
	#   pcId       the id of the stage
	#   returns    nothing; use UnpinStageQ to chain
	#   note       it clears the implementation pin, the floor pin and the set
	#   warning    raises an error when the stage is not in the flow
	#   see        PinStage, PinStageToSet
	def UnpinStage(pcId)
		_i_ = _StzFlowStageRow(@aStages, pcId)
		if _i_ = 0 stzraise("UnpinStage: no stage '" + pcId + "'.") ok
		@aStages[_i_][:floor] = 0
		@aStages[_i_][:impl] = ""
		@aStages[_i_][:set] = []

		def UnpinStageQ(pcId)
			This.UnpinStage(pcId)
			return This

	# Puts every stage on its deterministic floor, whatever the pins and the measurements say.
	#
	#   returns    nothing; use UseFloorEverywhereQ to chain
	#   note       meant for a machine with no model, or a test; the pins are kept and apply again
	#              after UseRegistryChoice
	#   warning    it beats an implementation pin of a stage, because resolution looks at the floor
	#              pin first
	#   see        UseRegistryChoice, IsOnFloorEverywhere
	#@ aka  Every stage on its deterministic floor: for a machine with no model, or a test.
	def UseFloorEverywhere()
		@bFloorEverywhere = 1

		def UseFloorEverywhereQ()
			This.UseFloorEverywhere()
			return This

	# Gives the choice back to the registry and the stage pins, undoing UseFloorEverywhere.
	#
	#   returns    nothing; use UseRegistryChoiceQ to chain
	#   see        UseFloorEverywhere, IsOnFloorEverywhere
	def UseRegistryChoice()
		@bFloorEverywhere = 0

		def UseRegistryChoiceQ()
			This.UseRegistryChoice()
			return This

	# TRUE if the flow was told to run every stage on its floor.
	#
	#   returns    TRUE or FALSE
	#   note       the process-wide model policy is separate: StzModelPolicy(:deterministic) also
	#              puts every faculty on its floor
	#   see        UseFloorEverywhere, UseRegistryChoice
	def IsOnFloorEverywhere()
		return @bFloorEverywhere

	# Returns the ids of the stages that feed into a stage.
	#
	#   pcId       the id of the stage
	#   returns    a list of text; [ ] for a first stage and for an id the flow does not have
	#   note       more than one predecessor is a fan-in finding, because this slice has no merge
	#              faculty
	#   see        Edges, ConnectStages
	#@ aka  -- the order ---------------------------------------------------------------------------------
	def Predecessors(pcId)
		_a_ = []
		for _i_ = 1 to len(@aEdges)
			if @aEdges[_i_][2] = pcId add(_a_, @aEdges[_i_][1]) ok
		next
		return _a_

	# Returns the stage ids in an order where every stage comes after the stages feeding it.
	#
	#   returns    a list of text; [ ] for an empty flow and for a flow with a cycle
	#   note       stages that do not depend on each other keep the order they were added in
	#   see        CheckRules, Run
	#@ aka  Kahn's algorithm; [] with a cycle (CheckRules reports it)
	def TopologicalOrder()
		_aIn_ = []
		for _i_ = 1 to len(@aStages)
			add(_aIn_, len(This.Predecessors(@aStages[_i_][:id])))
		next
		_aOrder_ = []
		_aDone_ = []
		for _round_ = 1 to len(@aStages)
			_bFound_ = 0
			for _i_ = 1 to len(@aStages)
				if len(StzFind(@aStages[_i_][:id], _aDone_)) = 0 and _aIn_[_i_] = 0
					add(_aOrder_, @aStages[_i_][:id])
					add(_aDone_, @aStages[_i_][:id])
					for _e_ = 1 to len(@aEdges)
						if @aEdges[_e_][1] = @aStages[_i_][:id]
							_j_ = _StzFlowStageRow(@aStages, @aEdges[_e_][2])
							_aIn_[_j_] = _aIn_[_j_] - 1
						ok
					next
					_bFound_ = 1
					exit
				ok
			next
			if _bFound_ = 0 return [] ok
		next
		return _aOrder_

	# Returns the findings about the flow's wiring, without running anything.
	#
	#   returns    a list of findings, each [ rule, subject, where, severity, message ] with subject
	#              model-flow; [ ] when nothing is wrong
	#   note       the rules are empty-flow, cycle, floor-missing, fan-in, type-mismatch-on-edge and
	#              service-not-pinned as errors, and golden-set-missing as a warning
	#   see        IsSound, ResolvePlan, Run
	#@ aka  -- checking BEFORE running --------------------------------------------------------------------
	def CheckRules()
		_aF_ = []
		if len(@aStages) = 0
			add(_aF_, _StzFlowFinding("empty-flow", @cName, "the flow has no stage"))
		ok
		_aOrder_ = This.TopologicalOrder()
		if len(@aStages) > 0 and len(_aOrder_) = 0
			add(_aF_, _StzFlowFinding("cycle", @cName, "the flow has a cycle: a data flow must be acyclic"))
		ok
		for _i_ = 1 to len(@aStages)
			_cId_ = @aStages[_i_][:id]
			_oFac_ = StzFacultyQ(@aStages[_i_][:faculty])
			if _oFac_.HasFloor() = 0
				add(_aF_, _StzFlowFinding("floor-missing", _cId_, "the faculty '" + @aStages[_i_][:faculty] + "' has no floor"))
			ok
			if len(_oFac_.Goldens()) = 0
				# a WARNING: the floor can still run; it is models that cannot be auto-selected without a bar to beat
				_aW_ = _StzFlowFinding("golden-set-missing", _cId_, "the faculty '" + @aStages[_i_][:faculty] + "' has no golden set: no model may be auto-selected for it")
				_aW_[:severity] = :warning
				add(_aF_, _aW_)
			ok
			_aPre_ = This.Predecessors(_cId_)
			if len(_aPre_) > 1
				add(_aF_, _StzFlowFinding("fan-in", _cId_, "a stage with several predecessors needs an explicit merge faculty; this slice has none"))
			ok
			for _p_ = 1 to len(_aPre_)
				_oPre_ = StzFacultyQ(@aStages[_StzFlowStageRow(@aStages, _aPre_[_p_])][:faculty])
				if _oPre_.OutputType() != _oFac_.InputType()
					add(_aF_, _StzFlowFinding("type-mismatch-on-edge", _aPre_[_p_] + " -> " + _cId_,
						"'" + _aPre_[_p_] + "' yields " + _oPre_.OutputType() + " but '" + _cId_ + "' takes " + _oFac_.InputType()))
				ok
			next
			# a service is never reached implicitly: if the stage names one, it must be pinned, not left to the registry
			_aImpls_ = _oFac_.Implementations()
			for _k_ = 1 to len(_aImpls_)
				if _aImpls_[_k_][:kind] = "service" and @aStages[_i_][:impl] != _aImpls_[_k_][:id] and len(StzFind(_aImpls_[_k_][:id], @aStages[_i_][:set])) > 0
					add(_aF_, _StzFlowFinding("service-not-pinned", _cId_, "a service implementation may only be reached by pinning it by name"))
				ok
			next
		next
		return _aF_

	# TRUE if the flow has no finding of error severity, so Run will try it; warnings do not count.
	#
	#   returns    TRUE or FALSE
	#   see        CheckRules, Run
	def IsSound()
		return StzFindingsAreSound(This.CheckRules())

	# Returns, stage by stage in run order, the implementation each stage would use and why; nothing runs.
	#
	#   returns    a list of [ key, value ] pairs: stages, one plan per stage with its stage id
	#              added; findings from CheckRules; memory, the largest memory in MB among the
	#              chosen implementations
	#   note       memory is the largest resident model and not the sum, because the engine holds
	#              one model at a time
	#   warning    a flow with a cycle plans no stage, and a stage whose plan is a refusal counts
	#              nothing toward memory
	#   see        Why, CheckRules, stzModelPlan
	#@ aka  what each stage WOULD use, and why -- runs nothing. -> [ :stages = [ plan... ], :findings, :memory ]
	def ResolvePlan()
		_aPlans_ = []
		_nMem_ = 0
		_aOrder_ = This.TopologicalOrder()
		for _o_ = 1 to len(_aOrder_)
			_i_ = _StzFlowStageRow(@aStages, _aOrder_[_o_])
			_aPlan_ = StzResolveFaculty(@aStages[_i_][:faculty], This._PinsOf(_i_))
			_aPlan_[:stage] = @aStages[_i_][:id]
			add(_aPlans_, _aPlan_)
			if _aPlan_[:refusal] = 0
				_aImpl_ = This._ImplRecord(@aStages[_i_][:faculty], _aPlan_[:chosen])
				if len(_aImpl_) > 0 and _aImpl_[:memory] > _nMem_ _nMem_ = _aImpl_[:memory] ok
			ok
		next
		# the engine has one model slot: stages run one after another, so the footprint is the LARGEST resident model
		return [ :stages = _aPlans_, :findings = This.CheckRules(), :memory = _nMem_ ]

	def _PinsOf(pnRow)
		_a_ = [ :impl = @aStages[pnRow][:impl], :floor = @aStages[pnRow][:floor], :set = @aStages[pnRow][:set] ]
		if @bFloorEverywhere = 1 _a_[:floor] = 1 ok
		return _a_

	def _ImplRecord(pcFaculty, pcImplId)
		_aI_ = StzFacultyQ(pcFaculty).Implementations()
		for _i_ = 1 to len(_aI_)
			if _aI_[_i_][:id] = pcImplId return _aI_[_i_] ok
		next
		return []

	# Returns, one line per stage in run order, which implementation the stage would use and the first reason.
	#
	#   returns    a text starting with the flow's name, then a line per stage
	#   note       this plans and runs nothing; the reason shown is the first line of the stage's
	#              plan
	#   see        ResolvePlan, Explain
	#@ aka  One sentence per stage
	def Why()
		_aP_ = This.ResolvePlan()
		_c_ = "flow '" + @cName + "'"
		for _i_ = 1 to len(_aP_[:stages])
			_a_ = _aP_[:stages][_i_]
			_c_ += char(10) + "  " + _a_[:stage] + " (" + _a_[:faculty] + "): "
			if _a_[:refusal] = 1 _c_ += "REFUSED" else _c_ += _a_[:chosen] + " [" + _a_[:kind] + "]" ok
			if len(_a_[:why]) > 0 _c_ += " -- " + _a_[:why][1] ok
		next
		return _c_

	# Returns the flow as declared: its stages with faculty, payload types and pin, then its connections.
	#
	#   returns    a text, one line per stage and per connection
	#   note       it says how each stage is pinned, not which implementation the registry would
	#              pick: Why does that
	#   see        Why, Stages, Edges
	def Explain()
		_c_ = "flow '" + @cName + "': " + len(@aStages) + " stage(s)"
		for _i_ = 1 to len(@aStages)
			_a_ = @aStages[_i_]
			_cPin_ = "registry choice"
			if _a_[:floor] = 1 _cPin_ = "pinned to the floor" ok
			if _a_[:impl] != "" _cPin_ = "pinned to '" + _a_[:impl] + "'" ok
			_c_ += char(10) + "  stage " + _a_[:id] + ": faculty " + _a_[:faculty] + " (" + StzFacultyQ(_a_[:faculty]).InputType() + " -> " + StzFacultyQ(_a_[:faculty]).OutputType() + "), " + _cPin_
		next
		for _i_ = 1 to len(@aEdges)
			_c_ += char(10) + "  " + @aEdges[_i_][1] + " -> " + @aEdges[_i_][2]
		next
		return _c_

	  #-- running ----------------------------------------------------------------------------------

	# The parcel of the LAST stage in order, with the whole provenance chain; or the refusal of the first stage
	# that refused, naming it. pInput is the value fed to the stages that have no predecessor.
	def RunQ(pInput)
		@aParcels = []
		_aF_ = This.CheckRules()
		if NOT StzFindingsAreSound(_aF_)
			_oR_ = new stzParcel("refusal", [])
			_oR_._MakeRefusal(_aF_)
			return _oR_
		ok
		_aOrder_ = This.TopologicalOrder()
		_oLast_ = ""
		for _o_ = 1 to len(_aOrder_)
			_i_ = _StzFlowStageRow(@aStages, _aOrder_[_o_])
			_aPre_ = This.Predecessors(_aOrder_[_o_])
			_vIn_ = pInput
			_aChain_ = []
			if len(_aPre_) = 1
				_oPre_ = This.StageParcelQ(_aPre_[1])
				_vIn_ = _oPre_.Value()
				_aChain_ = _oPre_.Provenance()
			ok
			_oP_ = StzRunFaculty(@aStages[_i_][:faculty], _vIn_, @aStages[_i_][:params], [], This._PinsOf(_i_), 0)
			if _oP_.IsRefusal() = 1
				_aFind_ = _oP_.Findings()
				for _k_ = 1 to len(_aFind_)
					_aFind_[_k_][:where] = "stage " + @aStages[_i_][:id] + ": " + _aFind_[_k_][:where]
				next
				_oR_ = new stzParcel("refusal", [])
				_oR_._MakeRefusal(_aFind_)
				_oR_._SetProvenance(_aChain_)
				add(@aParcels, [ @aStages[_i_][:id], _oR_ ])
				return _oR_
			ok
			# extend the chain: the new parcel's provenance is the predecessors' plus its own step
			_aProv_ = _aChain_
			_aOwn_ = _oP_.Provenance()
			for _k_ = 1 to len(_aOwn_)
				add(_aProv_, _aOwn_[_k_])
			next
			_oP_._SetProvenance(_aProv_)
			_oP_._SealKey()
			_oP_._SetTrace(@cName + ":" + @aStages[_i_][:id])
			add(@aParcels, [ @aStages[_i_][:id], _oP_ ])
			_oLast_ = _oP_
		next
		return _oLast_

	# Runs the flow on an input and returns the value of the last stage in run order.
	#
	#   pInput     the value handed to every stage that has no predecessor
	#   returns    the value of the last stage, which for a refusal is the list of findings
	#   note       RunQ returns the parcel with the whole provenance chain; the value is that of the
	#              last stage in order even when the flow has several branches
	#   warning    a flow with an error finding is refused before any stage runs; the first stage
	#              that refuses stops the run and its findings, prefixed with the stage id, come
	#              back as the value; the run rewrites the stages' params with the merged defaults;
	#              not exercised with a real model: the answer shape is read from the code
	#   see        StageParcelQ, CheckRules, ResolvePlan
	def Run(pInput)
		_oP_ = This.RunQ(pInput)
		return _oP_.Value()

	# Returns the parcel a stage produced in the last run of the flow.
	#
	#   pcId       the id of the stage
	#   returns    an stzParcel; a refusal parcel with the rule stage-not-run when the stage did not
	#              run
	#   see        Run, stzParcel
	#@ aka  the parcel a stage produced in the last run
	def StageParcelQ(pcId)
		for _i_ = 1 to len(@aParcels)
			if @aParcels[_i_][1] = pcId return @aParcels[_i_][2] ok
		next
		return StzRefusalParcelQ(pcId, "stage-not-run", "the stage '" + pcId + "' did not run in the last run")
