#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZFACULTY                     #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzFaculty -- a NAMED, TYPED capability with #
#                  a deterministic FLOOR and zero or more        #
#                  model-backed IMPLEMENTATIONS. The flow names  #
#                  faculties and never models, so a model can be #
#                  swapped, or downgraded to its floor, without  #
#                  touching the solution.                         #
#                  A faculty is declared once and JUDGED AT       #
#                  DECLARATION (a missing floor, an unknown type, #
#                  an implementation whose types disagree, all    #
#                  raise before anything runs).                   #
#                  Design: SOFTANZA_MODEL_FLOW.md sections 3-4.   #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# The definitions live in ONE global table of plain lists, and an stzFaculty is a thin HANDLE over a row
# of it. Ring copies an object on assignment, so a registry holding copies of stateful objects would fork
# silently (perf law 1, "the engine-wrapper copy law"); a handle over shared data cannot.
$aStzFaculties = []
$aStzParcelMemo = []        # content-key -> parcel, for deterministic implementations
$aStzImplNote  = []          # the side channel an implementation uses to state its evidence / token counts

# The closed vocabulary of payload types (SOFTANZA_MODEL_FLOW.md 3.2). `record` is judged by C9, unchanged.
func StzFlowTypes()
	return [ "text", "tokens", "vector", "record", "label", "labels", "score", "number", "boolean",
		 "ranking", "table", "image", "audio", "document", "geo", "refusal" ]

func StzFlowTypeIsKnown(pcType)
	return len(StzFind(lower(pcType), StzFlowTypes())) > 0

func _StzFacultyRow(pcName)
	_n_ = len($aStzFaculties)
	for _i_ = 1 to _n_
		if $aStzFaculties[_i_][:name] = lower(pcName) return _i_ ok
	next
	return 0

# create-or-open: the entry object of the faculty domain (LAW 1)
func StzFacultyQ(pcName)
	if _StzFacultyRow(pcName) = 0
		add($aStzFaculties, [ :name = lower(pcName), :in = "", :out = "", :params = [], :impls = [],
				      :golden = [], :checker = "exact", :goldenversion = "v1" ])
	ok
	return new stzFaculty(lower(pcName))

func StzHasFaculty(pcName)
	return _StzFacultyRow(pcName) > 0

func StzFacultyNames()
	_a_ = []
	_n_ = len($aStzFaculties)
	for _i_ = 1 to _n_
		add(_a_, $aStzFaculties[_i_][:name])
	next
	return _a_

func StzRemoveFaculty(pcName)
	_i_ = _StzFacultyRow(pcName)
	if _i_ > 0 del($aStzFaculties, _i_) ok

# ---- the courts: one per output type ----------------------------------------------------------
# -> [ :ok, :value, :findings ]. A record is judged by C9 (stzOutputSchema.Verify), unchanged.
func StzJudgeParcelValue(pcType, pValue, paParams)
	_cT_ = lower(pcType)
	_aF_ = []
	if _cT_ = "refusal"
		return [ :ok = 1, :value = pValue, :findings = [] ]
	ok
	if _cT_ = "text"
		if NOT isString(pValue) add(_aF_, _StzFlowFinding("type", "text", "a text must be a string")) ok
	but _cT_ = "number" or _cT_ = "score"
		if NOT isNumber(pValue)
			add(_aF_, _StzFlowFinding("type", _cT_, "a " + _cT_ + " must be a number"))
		but _cT_ = "score"
			_nMin_ = 0 _nMax_ = 1
			if HasKey(paParams, :min) _nMin_ = paParams[:min] ok
			if HasKey(paParams, :max) _nMax_ = paParams[:max] ok
			if pValue < _nMin_ or pValue > _nMax_
				add(_aF_, _StzFlowFinding("band", "score", "the score " + pValue + " is outside its band " + _nMin_ + ".." + _nMax_))
			ok
		ok
	but _cT_ = "boolean"
		if NOT isNumber(pValue) or (pValue != 0 and pValue != 1)
			add(_aF_, _StzFlowFinding("type", "boolean", "a boolean must be 0 or 1"))
		ok
	but _cT_ = "label"
		if NOT isString(pValue)
			add(_aF_, _StzFlowFinding("type", "label", "a label must be a string"))
		but HasKey(paParams, :labels)
			_cV_ = lower(trim(pValue))
			_bIn_ = 0
			_acL_ = paParams[:labels]
			for _i_ = 1 to len(_acL_)
				if lower(trim(_acL_[_i_])) = _cV_ _bIn_ = 1 ok
			next
			if _bIn_ = 0
				add(_aF_, _StzFlowFinding("oneof", "label", "'" + pValue + "' is not one of the declared labels; a closed enumeration is CLOSED"))
			else
				pValue = _cV_
			ok
		ok
	but _cT_ = "vector"
		if NOT isList(pValue) or len(pValue) = 0
			add(_aF_, _StzFlowFinding("type", "vector", "a vector must be a non-empty list of numbers"))
		else
			if HasKey(paParams, :dim) and len(pValue) != paParams[:dim]
				add(_aF_, _StzFlowFinding("dim", "vector", "the vector has " + len(pValue) + " dimensions, " + paParams[:dim] + " declared; vectors of different dimensions never compare"))
			ok
			for _i_ = 1 to len(pValue)
				if NOT isNumber(pValue[_i_])
					add(_aF_, _StzFlowFinding("type", "vector[" + _i_ + "]", "a vector holds numbers only"))
					exit
				ok
			next
		ok
	but _cT_ = "ranking"
		# a list of [ item, score ] pairs, best first
		if NOT isList(pValue)
			add(_aF_, _StzFlowFinding("type", "ranking", "a ranking must be a list"))
		else
			for _i_ = 1 to len(pValue)
				if NOT isList(pValue[_i_]) or len(pValue[_i_]) != 2 or NOT isNumber(pValue[_i_][2])
					add(_aF_, _StzFlowFinding("shape", "ranking[" + _i_ + "]", "an entry must be [ item, score ]"))
					exit
				ok
				if _i_ > 1 and isList(pValue[_i_ - 1]) and pValue[_i_][2] > pValue[_i_ - 1][2]
					add(_aF_, _StzFlowFinding("order", "ranking[" + _i_ + "]", "a ranking is ordered best first"))
					exit
				ok
			next
		ok
	but _cT_ = "record"
		if HasKey(paParams, :schema)
			_oS_ = paParams[:schema]
			_aV_ = _oS_.Verify(pValue)
			if _aV_[:ok] = 1
				return [ :ok = 1, :value = _aV_[:value], :findings = _aV_[:findings] ]
			ok
			return [ :ok = 0, :value = [], :findings = _aV_[:findings] ]
		ok
		if NOT isList(pValue)
			add(_aF_, _StzFlowFinding("type", "record", "a record must be a structure"))
		ok
	but _cT_ = "labels"
		if NOT isList(pValue) add(_aF_, _StzFlowFinding("type", "labels", "labels must be a list")) ok
	ok
	if len(_aF_) > 0
		return [ :ok = 0, :value = [], :findings = _aF_ ]
	ok
	return [ :ok = 1, :value = pValue, :findings = [] ]

func _StzFlowFinding(pcRule, pcWhere, pcMessage)
	return [ :rule = pcRule, :subject = "model-flow", :where = pcWhere, :severity = :error, :message = pcMessage ]

# ---- running ONE implementation of a faculty: a validated parcel, or a refusal -----------------------
func StzRunImplementation(pcFaculty, pcImplId, pInput, paParams)
	_iF_ = _StzFacultyRow(pcFaculty)
	if _iF_ = 0
		return StzRefusalParcelQ(pcFaculty, "unknown-faculty", "no faculty is declared with the name '" + pcFaculty + "'")
	ok
	_nI_ = len($aStzFaculties[_iF_][:impls])
	_iImpl_ = 0
	for _k_ = 1 to _nI_
		if $aStzFaculties[_iF_][:impls][_k_][:id] = pcImplId _iImpl_ = _k_ ok
	next
	if _iImpl_ = 0
		return StzRefusalParcelQ(pcFaculty, "unknown-implementation", "the faculty '" + pcFaculty + "' has no implementation '" + pcImplId + "'")
	ok
	_aImpl_ = $aStzFaculties[_iF_][:impls][_iImpl_]
	_cOut_ = $aStzFaculties[_iF_][:out]
	_fFn_ = _aImpl_[:fn]
	# the faculty's declared parameters (its closed label set, its schema, its dimension) are the DEFAULTS of every
	# call; a call's own parameters override them. Without this the court would accept anything on a bare call.
	paParams = _StzMergeParams($aStzFaculties[_iF_][:params], paParams)

	# the memo: a parcel made by the same implementation (same version) from the same input is deterministic and free
	_cMemo_ = ""
	if _aImpl_[:deterministic] = 1 and _StzParamsAreMemoisable(paParams)
		_cMemo_ = StzEngineCryptoSha256(pcFaculty + "|" + pcImplId + "|" + _aImpl_[:version] + "|" + StzParcelCanonical(pInput) + "|" + @@(paParams))
		_nM_ = _StzMemoRow(_cMemo_)
		if _nM_ > 0
			return $aStzParcelMemo[_nM_][2]
		ok
	ok

	$aStzImplNote = []
	_vRaw_ = ""
	_cErr_ = ""
	# a model implementation needs its model in the engine's single slot (a load-swap, whose cost is measured)
	if _aImpl_[:kind] = "model" or _aImpl_[:kind] = "dlm"
		try
			StzEnsureModelResident(_aImpl_[:needle])
		catch
			_cErr_ = cCatchError
		done
	ok
	_t0_ = clock()
	if _cErr_ = ""
		try
			_vRaw_ = call _fFn_(pInput, paParams)
		catch
			_cErr_ = cCatchError
		done
	ok
	_nMs_ = (clock() - _t0_) / clockspersecond() * 1000

	if _cErr_ != ""
		return StzRefusalParcelQ(pcFaculty + ":" + pcImplId, "implementation-failed", _cErr_)
	ok

	_aJ_ = StzJudgeParcelValue(_cOut_, _vRaw_, paParams)
	if _aJ_[:ok] = 0
		_oR_ = new stzParcel("refusal", [])
		_oR_._MakeRefusal(_aJ_[:findings])
		_oR_._SetProvenance([ [ :faculty = pcFaculty, :implementation = pcImplId, :version = _aImpl_[:version], :kind = _aImpl_[:kind], :detail = "refused by its court" ] ])
		return _oR_
	ok

	_oP_ = new stzParcel(_cOut_, _aJ_[:value])
	_cCert_ = "unknown"
	_nP_ = -1
	_cDetail_ = ""
	_nTi_ = 0 _nTo_ = 0
	if isList($aStzImplNote)
		if HasKey($aStzImplNote, :certainty) _cCert_ = $aStzImplNote[:certainty] ok
		if HasKey($aStzImplNote, :p) _nP_ = $aStzImplNote[:p] ok
		if HasKey($aStzImplNote, :detail) _cDetail_ = $aStzImplNote[:detail] ok
		if HasKey($aStzImplNote, :tokens_in) _nTi_ = $aStzImplNote[:tokens_in] ok
		if HasKey($aStzImplNote, :tokens_out) _nTo_ = $aStzImplNote[:tokens_out] ok
	ok
	# a deterministic floor can say what it is sure of; everything else says :unknown unless it stated more
	_oP_._SetEvidence(_cCert_, _nP_)
	_oP_._SetProvenance([ [ :faculty = pcFaculty, :implementation = pcImplId, :version = _aImpl_[:version],
				:kind = _aImpl_[:kind], :detail = _cDetail_ ] ])
	_oP_._SetCost([ :ms = _nMs_, :tokens_in = _nTi_, :tokens_out = _nTo_ ])
	_oP_._SealKey()
	if _cMemo_ != ""
		add($aStzParcelMemo, [ _cMemo_, _oP_ ])
	ok
	return _oP_


# defaults first, the call's own keys on top
func _StzMergeParams(paDefaults, paCall)
	_a_ = []
	if isList(paDefaults)
		for _i_ = 1 to len(paDefaults)
			add(_a_, paDefaults[_i_])
		next
	ok
	if isList(paCall)
		for _i_ = 1 to len(paCall)
			_bFound_ = 0
			for _k_ = 1 to len(_a_)
				if isList(paCall[_i_]) and isList(_a_[_k_]) and _a_[_k_][1] = paCall[_i_][1]
					_a_[_k_] = paCall[_i_]
					_bFound_ = 1
					exit
				ok
			next
			if _bFound_ = 0 add(_a_, paCall[_i_]) ok
		next
	ok
	return _a_

func _StzMemoRow(pcKey)
	_n_ = len($aStzParcelMemo)
	for _i_ = 1 to _n_
		if $aStzParcelMemo[_i_][1] = pcKey return _i_ ok
	next
	return 0

# params that hold a Softanza object (a schema) cannot be hashed by value: such a call is not memoised here
# (the typed call stzLLMFunction memoises by its own content hash)
func _StzParamsAreMemoisable(paParams)
	if NOT isList(paParams) return 1 ok
	for _i_ = 1 to len(paParams)
		if isList(paParams[_i_]) and len(paParams[_i_]) = 2 and isObject(paParams[_i_][2]) return 0 ok
	next
	return 1

func StzClearParcelMemo()
	$aStzParcelMemo = []

# how a golden answer is compared (deterministic checkers only; there is no model judge)
func StzGoldenAgrees(pcChecker, pGot, pExpected)
	if pcChecker = "exact"
		if isString(pGot) and isString(pExpected) return trim(pGot) = trim(pExpected) ok
		if isNumber(pGot) and isNumber(pExpected) return pGot = pExpected ok
		return @@(pGot) = @@(pExpected)
	but pcChecker = "lower"
		return lower(trim("" + pGot)) = lower(trim("" + pExpected))
	but pcChecker = "contains"
		return len(StzFind(lower("" + pExpected), lower("" + pGot))) > 0
	but pcChecker = "fields"
		# every field the expected record states must agree (extra fields in the answer are ignored)
		if NOT isList(pGot) or NOT isList(pExpected) return 0 ok
		for _i_ = 1 to len(pExpected)
			_cK_ = pExpected[_i_][1]
			if NOT HasKey(pGot, _cK_) return 0 ok
			if lower(trim("" + pGot[_cK_])) != lower(trim("" + pExpected[_i_][2])) return 0 ok
		next
		return 1
	but pcChecker = "indocs"
		# a record whose :docs list contains the expected document
		if NOT isList(pGot) or NOT HasKey(pGot, :docs) return 0 ok
		for _i_ = 1 to len(pGot[:docs])
			if trim("" + pGot[:docs][_i_]) = trim("" + pExpected) return 1 ok
		next
		return 0
	but pcChecker = "kwmax"
		# expected is "keyword|maxwords": the answer keeps the keyword AND stays within the word limit
		_aE_ = split("" + pExpected, "|")
		if len(_aE_) != 2 return 0 ok
		if len(StzFind(lower(_aE_[1]), lower("" + pGot))) = 0 return 0 ok
		return len(split(trim("" + pGot), " ")) <= (0 + _aE_[2])
	but pcChecker = "first"
		# a ranking whose best item is the expected one
		if NOT isList(pGot) or len(pGot) = 0 return 0 ok
		return lower(trim("" + pGot[1][1])) = lower(trim("" + pExpected))
	ok
	return 0

# normalise an implementation spec into a full row with the defaults a floor-or-model needs
func _StzImplRecord(paSpec)
	_a_ = [ :id = "", :kind = "model", :fn = "", :version = "1", :deterministic = 1, :licence = "unstated",
		:memory = 0, :languages = [ "*" ], :needle = "" ]
	for _i_ = 1 to len(paSpec)
		_a_[paSpec[_i_][1]] = paSpec[_i_][2]
	next
	_a_[:kind] = lower(_a_[:kind])
	if len(StzFind(_a_[:kind], [ "floor", "model", "dlm", "service" ])) = 0
		stzraise("An implementation's :kind is floor, model, dlm or service -- not '" + _a_[:kind] + "'.")
	ok
	return _a_

func _StzFacultyCheckType(pcType)
	if NOT StzFlowTypeIsKnown(pcType)
		stzraise("Unknown payload type '" + pcType + "'. The vocabulary is closed: " + @@(StzFlowTypes()))
	ok

class stzFaculty from stzObject

	@cName = ""

	def init(pcName)
		@cName = pcName

	  #-- reading (data) ---------------------------------------------------------------------

	def Name()
		return @cName

	def InputType()
		return $aStzFaculties[_StzFacultyRow(@cName)][:in]

	def OutputType()
		return $aStzFaculties[_StzFacultyRow(@cName)][:out]

	def Params()
		return $aStzFaculties[_StzFacultyRow(@cName)][:params]

	def Implementations()
		return $aStzFaculties[_StzFacultyRow(@cName)][:impls]

	def ImplementationIds()
		_a_ = []
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			add(_a_, _aI_[_i_][:id])
		next
		return _a_

	def Floor()
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			if _aI_[_i_][:kind] = "floor" return _aI_[_i_] ok
		next
		return []

	def HasFloor()
		return len(This.Floor()) > 0

	def Goldens()
		return $aStzFaculties[_StzFacultyRow(@cName)][:golden]

	def GoldenChecker()
		return $aStzFaculties[_StzFacultyRow(@cName)][:checker]

	def GoldenVersion()
		return $aStzFaculties[_StzFacultyRow(@cName)][:goldenversion]

	# a faculty is only COMPLETE with types, a floor and a golden set; Problems() says what is missing
	def Problems()
		_aP_ = []
		_i_ = _StzFacultyRow(@cName)
		if $aStzFaculties[_i_][:in] = "" add(_aP_, "no input type") ok
		if $aStzFaculties[_i_][:out] = "" add(_aP_, "no output type") ok
		if NOT This.HasFloor() add(_aP_, "no floor: a faculty without a deterministic floor is refused (LAW 2)") ok
		if len(This.Goldens()) = 0 add(_aP_, "no golden set: no model may be auto-selected without one") ok
		return _aP_

	def IsComplete()
		return len(This.Problems()) = 0

	  #-- declaring: active verbs, each with its Q twin -------------------------------------------

	def SetInputType(pcType)
		_StzFacultyCheckType(pcType)
		$aStzFaculties[_StzFacultyRow(@cName)][:in] = lower(pcType)

		def SetInputTypeQ(pcType)
			This.SetInputType(pcType)
			return This

	def SetOutputType(pcType)
		_StzFacultyCheckType(pcType)
		$aStzFaculties[_StzFacultyRow(@cName)][:out] = lower(pcType)

		def SetOutputTypeQ(pcType)
			This.SetOutputType(pcType)
			return This

	def SetParams(paParams)
		$aStzFaculties[_StzFacultyRow(@cName)][:params] = paParams

		def SetParamsQ(paParams)
			This.SetParams(paParams)
			return This

	# The floor: the deterministic implementation every faculty must have. pcFn is the NAME of a Ring function
	# taking (pInput, aParams) and returning the value. Replaces a previous floor.
	def SetFloor(pcId, pcFn)
		_i_ = _StzFacultyRow(@cName)
		_aI_ = $aStzFaculties[_i_][:impls]
		for _k_ = len(_aI_) to 1 step -1
			if _aI_[_k_][:kind] = "floor" del($aStzFaculties[_i_][:impls], _k_) ok
		next
		add($aStzFaculties[_i_][:impls], _StzImplRecord([ :id = pcId, :kind = "floor", :fn = pcFn, :version = "1",
			:deterministic = 1, :licence = "n/a", :memory = 0, :languages = [ "*" ], :needle = "" ]))

		def SetFloorQ(pcId, pcFn)
			This.SetFloor(pcId, pcFn)
			return This

	# A model-backed (or service) implementation. paSpec: [ :id, :kind (model|dlm|service), :fn, :version,
	# :needle (a fragment of the GGUF file name: it is "installed" when such a file is in the models directory),
	# :licence, :memory (MB), :languages, :deterministic ]
	def AddImplementation(paSpec)
		_aR_ = _StzImplRecord(paSpec)
		if _aR_[:kind] = "floor"
			stzraise("AddImplementation: a floor is declared with SetFloor, one per faculty.")
		ok
		if _aR_[:id] = "" or _aR_[:fn] = ""
			stzraise("AddImplementation: an implementation needs an :id and a :fn (the name of a Ring function).")
		ok
		_i_ = _StzFacultyRow(@cName)
		_aI_ = $aStzFaculties[_i_][:impls]
		for _k_ = 1 to len(_aI_)
			if _aI_[_k_][:id] = _aR_[:id]
				stzraise("AddImplementation: the faculty '" + @cName + "' already has an implementation '" + _aR_[:id] + "'.")
			ok
		next
		add($aStzFaculties[_i_][:impls], _aR_)

		def AddImplementationQ(paSpec)
			This.AddImplementation(paSpec)
			return This

	def AddGolden(pInput, pExpected)
		add($aStzFaculties[_StzFacultyRow(@cName)][:golden], [ pInput, pExpected ])

		def AddGoldenQ(pInput, pExpected)
			This.AddGolden(pInput, pExpected)
			return This

	def SetGoldenChecker(pcChecker)
		$aStzFaculties[_StzFacultyRow(@cName)][:checker] = pcChecker

		def SetGoldenCheckerQ(pcChecker)
			This.SetGoldenChecker(pcChecker)
			return This

	def SetGoldenVersion(pcVersion)
		$aStzFaculties[_StzFacultyRow(@cName)][:goldenversion] = pcVersion

		def SetGoldenVersionQ(pcVersion)
			This.SetGoldenVersion(pcVersion)
			return This

	  #-- running ---------------------------------------------------------------------------------

	# One named implementation (a pin for ONE call): the parcel, or a refusal -- never a silent substitute.
	def RunWithQ(pcImplId, pInput, paParams)
		return StzRunImplementation(@cName, pcImplId, pInput, paParams)

	def RunWith(pcImplId, pInput, paParams)
		return This.RunWithQ(pcImplId, pInput, paParams).Value()

	# Resolve through the registry (requirement-driven) and run: the parcel, or a refusal.
	def RunQ(pInput, paParams)
		return StzRunFaculty(@cName, pInput, paParams, [], [], 0)

	# the VALUE of the parcel, or an empty list when it was refused (use RunQ to see why)
	def Run(pInput, paParams)
		_oP_ = StzRunFaculty(@cName, pInput, paParams, [], [], 0)
		return _oP_.Value()

	def ResolvePlan()
		return StzResolveFaculty(@cName, [])

	  #-- saying what it is (LAW 3 / LAW 6) -----------------------------------------------------------

	def Why()
		_c_ = "faculty '" + @cName + "': " + This.InputType() + " -> " + This.OutputType() + "; implementations: "
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			if _i_ > 1 _c_ += ", " ok
			_c_ += _aI_[_i_][:id] + " (" + _aI_[_i_][:kind] + ")"
		next
		return _c_ + "; golden set " + This.GoldenVersion() + " of " + len(This.Goldens()) + " item(s)"
