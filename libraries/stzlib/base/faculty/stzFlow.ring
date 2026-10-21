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

class stzFlow from stzObject

	@cName = ""
	@aStages = []
	@aEdges = []              # [ from, to ]
	@oGraph = ""
	@bFloorEverywhere = 0
	@aParcels = []            # [ id, parcel ] of the last run
	@aPlanCache = []

	def init(pcName)
		@cName = pcName
		@oGraph = new stzGraph(pcName)

	def Name()
		return @cName

	# the stzGraph this flow composes: cycle detection, reachability and the rule gate apply to it unchanged
	def Graph()
		return @oGraph

	def Stages()
		return @aStages

	def StageIds()
		_a_ = []
		for _i_ = 1 to len(@aStages)
			add(_a_, @aStages[_i_][:id])
		next
		return _a_

	def Edges()
		return @aEdges

	def NumberOfStages()
		return len(@aStages)

	  #-- building: active verbs, each with its Q twin ----------------------------------------------

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

	# Pin a stage to ONE implementation (by id), or to the floor with :floor. The registry never overrides a pin.
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

	# Let the registry choose within a set of implementations (still gated by measured quality)
	def PinStageToSet(pcId, pacImpls)
		_i_ = _StzFlowStageRow(@aStages, pcId)
		if _i_ = 0 stzraise("PinStageToSet: no stage '" + pcId + "'.") ok
		@aStages[_i_][:set] = pacImpls

		def PinStageToSetQ(pcId, pacImpls)
			This.PinStageToSet(pcId, pacImpls)
			return This

	def UnpinStage(pcId)
		_i_ = _StzFlowStageRow(@aStages, pcId)
		if _i_ = 0 stzraise("UnpinStage: no stage '" + pcId + "'.") ok
		@aStages[_i_][:floor] = 0
		@aStages[_i_][:impl] = ""
		@aStages[_i_][:set] = []

		def UnpinStageQ(pcId)
			This.UnpinStage(pcId)
			return This

	# Every stage on its deterministic floor: for a machine with no model, or a test.
	def UseFloorEverywhere()
		@bFloorEverywhere = 1

		def UseFloorEverywhereQ()
			This.UseFloorEverywhere()
			return This

	def UseRegistryChoice()
		@bFloorEverywhere = 0

		def UseRegistryChoiceQ()
			This.UseRegistryChoice()
			return This

	def IsOnFloorEverywhere()
		return @bFloorEverywhere

	  #-- the order ---------------------------------------------------------------------------------

	def Predecessors(pcId)
		_a_ = []
		for _i_ = 1 to len(@aEdges)
			if @aEdges[_i_][2] = pcId add(_a_, @aEdges[_i_][1]) ok
		next
		return _a_

	# Kahn's algorithm; [] with a cycle (CheckRules reports it)
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

	  #-- checking BEFORE running --------------------------------------------------------------------

	# findings in the house shape, subject "model-flow": the new rule family of the design (section 10)
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

	def IsSound()
		return StzFindingsAreSound(This.CheckRules())

	# what each stage WOULD use, and why -- runs nothing. -> [ :stages = [ plan... ], :findings, :memory ]
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

	# One sentence per stage
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

	def Run(pInput)
		_oP_ = This.RunQ(pInput)
		return _oP_.Value()

	# the parcel a stage produced in the last run
	def StageParcelQ(pcId)
		for _i_ = 1 to len(@aParcels)
			if @aParcels[_i_][1] = pcId return @aParcels[_i_][2] ok
		next
		return StzRefusalParcelQ(pcId, "stage-not-run", "the stage '" + pcId + "' did not run in the last run")
