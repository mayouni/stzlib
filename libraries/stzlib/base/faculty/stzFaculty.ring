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

# Declares one named, typed capability of a flow, with a deterministic floor, optional model implementations and a golden set.
#
# A faculty says what is done (a payload type in, a payload type out) and never which model does it,
# so an implementation can be swapped, or dropped to the floor, without touching the flow. Every
# faculty needs a floor, a plain function that always answers; a model is chosen only when it
# strictly beats the floor on the faculty's golden set. Every answer is judged by a court for its
# output type before it leaves, and an answer the court refuses comes back as a refusal and not as a
# value. The definition is kept in one process-wide table and the object is only a handle on its
# row, so copies of it agree. Scores, goldens and certainties are computed by the class from what
# the implementations state; no person has judged the quality of any model output.
#
#   receiver   o1 = StzFacultyQ("position")  o1.SetInputType(:text)  o1.SetOutputType(:number)
#              o1.SetFloor("last", "StzFindLast")
#   example    ? o1.Why()
#              #--> faculty 'position': text -> number; implementations: last (floor); golden set v1 of 0 item(s)
#              ? @@( o1.Problems() )
#              #--> [ "no golden set: no model may be auto-selected without one" ]
#              ? o1.Run("b", [ "a", "b", "c", "b" ])
#              #--> 4
#   see        StzFacultyQ, stzFlow, stzModelRegistry, stzParcel, stzRequirement
class stzFaculty from stzObject

	@cName = ""

	# Builds a handle on the faculty declared under that name; it declares nothing itself.
	#
	#   pcName     the faculty's name, as declared by StzFacultyQ
	#   returns    nothing; the object is built
	#   note       the definition lives in one process-wide table and the object is only a handle
	#              over its row, so copies of the object share one definition
	#   warning    a name that was never declared builds a handle whose readers raise Array Access
	#              (Index out of range) R2, while Run, RunWith and ResolvePlan answer with an
	#              unknown-faculty refusal; declare the faculty with StzFacultyQ first
	#   see        StzFacultyQ, Name
	def init(pcName)
		@cName = pcName

	# Returns the name the faculty is known by, lower case when it was made by StzFacultyQ.
	#
	#   returns    a text
	#   note       the handle keeps the name exactly as it was given to init, while StzFacultyQ
	#              folds it to lower case first
	#   see        init, Why
	#@ aka  -- reading (data) ---------------------------------------------------------------------
	def Name()
		return @cName

	# Returns the payload type the faculty takes in, or an empty text until one is set.
	#
	#   returns    a text such as text or label; an empty text before SetInputType
	#   note       no run checks the input value against it; a flow compares it with the output type
	#              of the stage before, in CheckRules
	#   see        SetInputType, OutputType
	def InputType()
		return $aStzFaculties[_StzFacultyRow(@cName)][:in]

	# Returns the payload type every answer of the faculty is judged against.
	#
	#   returns    a text such as label or number; an empty text before SetOutputType
	#   note       the court that judges an answer is chosen by this type, so an answer of another
	#              shape is refused
	#   see        SetOutputType, InputType
	def OutputType()
		return $aStzFaculties[_StzFacultyRow(@cName)][:out]

	# Returns the default call parameters, which every call of the faculty starts from.
	#
	#   returns    a list of [ key, value ] pairs; [ ] when none were set
	#   note       a call's own keys replace the default of the same key; the keys the courts read
	#              are labels, dim, schema, min and max
	#   see        SetParams, Run
	def Params()
		return $aStzFaculties[_StzFacultyRow(@cName)][:params]

	# Returns the full row of every implementation, the floor included, in the order declared.
	#
	#   returns    a list of rows, each a list of [ key, value ] pairs: id, kind, fn, version,
	#              deterministic, licence, memory, languages, needle
	#   note       the list is empty until a floor or an implementation is declared
	#   see        ImplementationIds, Floor, AddImplementation
	def Implementations()
		return $aStzFaculties[_StzFacultyRow(@cName)][:impls]

	# Returns the ids of the implementations in the order declared, the floor's included.
	#
	#   returns    a list of text
	#   see        Implementations, Floor
	def ImplementationIds()
		_a_ = []
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			add(_a_, _aI_[_i_][:id])
		next
		return _a_

	# Returns the row of the deterministic floor implementation, or an empty list when none is declared.
	#
	#   returns    a list of [ key, value ] pairs describing the floor (id, kind floor, fn, version,
	#              deterministic, licence, memory, languages, needle); [ ] when none
	#   see        SetFloor, HasFloor, Problems
	def Floor()
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			if _aI_[_i_][:kind] = "floor" return _aI_[_i_] ok
		next
		return []

	# TRUE if the faculty has a deterministic floor implementation; without one it is refused as incomplete.
	#
	#   returns    TRUE or FALSE
	#   warning    raises Array Access (Index out of range) R2 when the faculty was never declared
	#   see        SetFloor, Floor, IsComplete
	def HasFloor()
		return len(This.Floor()) > 0

	# Returns the golden set: the [ input, expected answer ] pairs every implementation is scored on.
	#
	#   returns    a list of pairs, in the order added; [ ] when none
	#   see        AddGolden, GoldenChecker, GoldenVersion
	def Goldens()
		return $aStzFaculties[_StzFacultyRow(@cName)][:golden]

	# Returns the name of the rule that decides whether an answer agrees with a golden's expected answer.
	#
	#   returns    a text: exact by default, or lower, contains, fields, indocs, kwmax, first
	#   note       exact compares trimmed texts or numbers, and any other value by its printed form;
	#              lower folds case; contains asks that the answer contain the expected text; fields
	#              asks that every field of the expected record agree; indocs asks that the answer
	#              record list the expected document; kwmax asks for a keyword within a word limit;
	#              first asks that the best ranked item be the expected one
	#   see        SetGoldenChecker, Goldens
	def GoldenChecker()
		return $aStzFaculties[_StzFacultyRow(@cName)][:checker]

	# Returns the label under which the faculty's measurements are filed, v1 by default.
	#
	#   returns    a text
	#   note       measurements are keyed by faculty, implementation and this label, so after
	#              SetGoldenVersion the earlier ones stop counting until the goldens are run again
	#   see        SetGoldenVersion, Goldens
	def GoldenVersion()
		return $aStzFaculties[_StzFacultyRow(@cName)][:goldenversion]

	# Returns what keeps the faculty from being complete, one sentence each.
	#
	#   returns    a list of text: no input type, no output type, no floor, no golden set; [ ] when
	#              nothing is missing
	#   note       it is a check of the declaration only: it does not say that any model beats the
	#              floor
	#   see        IsComplete, SetFloor, AddGolden
	#@ aka  a faculty is only COMPLETE with types, a floor and a golden set; Problems() says what is missing
	def Problems()
		_aP_ = []
		_i_ = _StzFacultyRow(@cName)
		if $aStzFaculties[_i_][:in] = "" add(_aP_, "no input type") ok
		if $aStzFaculties[_i_][:out] = "" add(_aP_, "no output type") ok
		if NOT This.HasFloor() add(_aP_, "no floor: a faculty without a deterministic floor is refused (LAW 2)") ok
		if len(This.Goldens()) = 0 add(_aP_, "no golden set: no model may be auto-selected without one") ok
		return _aP_

	# TRUE if the faculty has both payload types, a floor and at least one golden, so Problems is empty.
	#
	#   returns    TRUE or FALSE
	#   note       a complete faculty is only declared in full; whether a model is worth using is
	#              decided by RunGoldens and the registry
	#   see        Problems
	def IsComplete()
		return len(This.Problems()) = 0

	# Sets the payload type the faculty takes in, from the closed vocabulary; case is folded.
	#
	#   pcType     one of text, tokens, vector, record, label, labels, score, number, boolean,
	#              ranking, table, image, audio, document, geo, refusal
	#   returns    nothing; use SetInputTypeQ to chain
	#   warning    an unknown type raises an error listing the whole vocabulary, which is closed
	#   see        InputType, SetOutputType
	#@ aka  -- declaring: active verbs, each with its Q twin -------------------------------------------
	def SetInputType(pcType)
		_StzFacultyCheckType(pcType)
		$aStzFaculties[_StzFacultyRow(@cName)][:in] = lower(pcType)

		def SetInputTypeQ(pcType)
			This.SetInputType(pcType)
			return This

	# Sets the payload type every answer is judged against; case is folded.
	#
	#   pcType     one of text, tokens, vector, record, label, labels, score, number, boolean,
	#              ranking, table, image, audio, document, geo, refusal
	#   returns    nothing; use SetOutputTypeQ to chain
	#   warning    an unknown type raises an error listing the whole vocabulary, which is closed
	#   see        OutputType, SetInputType
	def SetOutputType(pcType)
		_StzFacultyCheckType(pcType)
		$aStzFaculties[_StzFacultyRow(@cName)][:out] = lower(pcType)

		def SetOutputTypeQ(pcType)
			This.SetOutputType(pcType)
			return This

	# Sets the default call parameters of the faculty, replacing those set before.
	#
	#   paParams   a list of [ key, value ] pairs such as [ :labels = [ "odd", "even" ] ], the
	#              starting point of every call
	#   returns    nothing; use SetParamsQ to chain
	#   note       the keys the courts read are labels for a label, dim for a vector, schema for a
	#              record, and min and max for a score
	#   warning    nothing is checked at the call; keep to [ key, value ] pairs, because the merge
	#              into each call is written back into the caller's list and a list of plain values
	#              grows at every call
	#   see        Params, Run
	def SetParams(paParams)
		$aStzFaculties[_StzFacultyRow(@cName)][:params] = paParams

		def SetParamsQ(paParams)
			This.SetParams(paParams)
			return This

	# Declares the deterministic floor implementation, replacing the floor declared before.
	#
	#   pcId       the floor's id, the name it is run and measured under
	#   pcFn       the NAME of a Ring function taking (pInput, aParams) and returning the value
	#   returns    nothing; use SetFloorQ to chain
	#   note       the floor is stored with kind floor, version 1, deterministic, licence n/a,
	#              memory 0 and every language
	#   warning    the function name is not checked at declaration: an unknown name shows only when
	#              the floor runs, as an implementation-failed refusal
	#   see        AddImplementation, Floor, HasFloor
	#@ aka  The floor: the deterministic implementation every faculty must have. pcFn is the NAME of a Ring function taking (pInput, aParams) and returning the value. Replaces a previous floor.
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

	# Adds a model, dlm or service implementation to the faculty from a specification.
	#
	#   paSpec     a list of [ key, value ] pairs: :id and :fn are required, optional :kind (model,
	#              dlm or service
	#   returns    nothing; use AddImplementationQ to chain
	#   note       an implementation with a :needle counts as installed only when a GGUF file whose
	#              name contains it is in the models directory; one without a needle always counts
	#              as installed
	#   warning    raises an error for a repeated id, for kind floor, for a missing id or fn and for
	#              an unknown kind; a licence left unstated is rejected by the default permissive
	#              requirement; the function name is not checked here; not exercised with a real
	#              model: the answer shape is read from the code (the :needle that names a model
	#              file, and its loading, were never run)
	#   see        SetFloor, Implementations, RunWith
	#@ aka  A model-backed (or service) implementation. paSpec: [ :id, :kind (model|dlm|service), :fn, :version, :needle (a fragment of the GGUF file name: it is "installed" when such a file is in the models directory), :licence, :memory (MB), :languages, :deterministic ]
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

	# Appends one golden to the faculty's set: an input and the answer it should produce.
	#
	#   pInput      the input handed to every implementation
	#   pExpected   the expected answer, compared by the golden checker
	#   returns     nothing; use AddGoldenQ to chain
	#   note        a golden is a stand-in for judgment computed by the class: no person has checked
	#               that the expected answers are right
	#   warning     goldens are appended and never merged, so adding the same pair twice scores it
	#               twice
	#   see         Goldens, SetGoldenChecker, SetGoldenVersion
	def AddGolden(pInput, pExpected)
		add($aStzFaculties[_StzFacultyRow(@cName)][:golden], [ pInput, pExpected ])

		def AddGoldenQ(pInput, pExpected)
			This.AddGolden(pInput, pExpected)
			return This

	# Sets the rule that compares an answer with a golden's expected answer.
	#
	#   pcChecker   exact, lower, contains, fields, indocs, kwmax or first
	#   returns     nothing; use SetGoldenCheckerQ to chain
	#   note        the comparison is made by the class and is not a human judgment of quality
	#   warning     an unknown name is accepted, and then no answer ever agrees: every
	#               implementation, the floor included, scores 0
	#   see         GoldenChecker, AddGolden
	def SetGoldenChecker(pcChecker)
		$aStzFaculties[_StzFacultyRow(@cName)][:checker] = pcChecker

		def SetGoldenCheckerQ(pcChecker)
			This.SetGoldenChecker(pcChecker)
			return This

	# Sets the label under which the faculty's measurements are filed.
	#
	#   pcVersion   the label of the golden set, such as v2
	#   returns     nothing; use SetGoldenVersionQ to chain
	#   note        change it when the goldens change, so an old score never stands for a new set
	#   warning     measurements recorded under the old label are not seen by resolution once the
	#               label changes, so the floor answers until RunGoldens is run again
	#   see         GoldenVersion, AddGolden
	def SetGoldenVersion(pcVersion)
		$aStzFaculties[_StzFacultyRow(@cName)][:goldenversion] = pcVersion

		def SetGoldenVersionQ(pcVersion)
			This.SetGoldenVersion(pcVersion)
			return This

	  #-- running ---------------------------------------------------------------------------------

	# One named implementation (a pin for ONE call): the parcel, or a refusal -- never a silent substitute.
	def RunWithQ(pcImplId, pInput, paParams)
		return StzRunImplementation(@cName, pcImplId, pInput, paParams)

	# Runs the one implementation named by its id and returns the value of its answer; the registry is not asked.
	#
	#   pcImplId   the id of the implementation to run, the floor's id included
	#   pInput     the input handed to the implementation
	#   paParams   call parameters, merged over the faculty's defaults
	#   returns    the value of the answer, which for a refusal is the list of findings
	#   note       RunWithQ returns the parcel, with its provenance, certainty and cost
	#   warning    an unknown id, a function that raises and an answer the court refuses all come
	#              back as the findings list, not as an error; the call rewrites the list passed as
	#              paParams with the merged defaults, and a deterministic implementation is
	#              remembered by its input; not exercised with a real model: the answer shape is
	#              read from the code
	#   see        RunWithQ, Run, Params
	def RunWith(pcImplId, pInput, paParams)
		return This.RunWithQ(pcImplId, pInput, paParams).Value()

	# Resolve through the registry (requirement-driven) and run: the parcel, or a refusal.
	def RunQ(pInput, paParams)
		return StzRunFaculty(@cName, pInput, paParams, [], [], 0)

	# Asks the registry for the implementation that best meets the default requirement, runs it and returns the value of its answer.
	#
	#   pInput     the input handed to the chosen implementation
	#   paParams   call parameters, merged over the faculty's defaults
	#   returns    the value of the answer, which for a refusal is the list of findings and not an
	#              empty list
	#   note       every call adds a row to the model trace; RunQ returns the parcel instead of its
	#              value
	#   warning    with no measurement the floor answers; a chosen model that fails falls back to
	#              the floor, and the parcel from RunQ says so; the call rewrites the list passed as
	#              paParams with the merged defaults; not exercised with a real model: the answer
	#              shape is read from the code
	#   see        RunQ, RunWith, ResolvePlan
	#@ aka  the VALUE of the parcel, or an empty list when it was refused (use RunQ to see why)
	def Run(pInput, paParams)
		_oP_ = StzRunFaculty(@cName, pInput, paParams, [], [], 0)
		return _oP_.Value()

	# Returns the plan the registry would follow for this faculty under the default requirement; nothing runs.
	#
	#   returns    a plan: a list of [ key, value ] pairs faculty, chosen, kind, why, rejected,
	#              floor, refusal, findings, pinned and needle
	#   warning    an unknown faculty, or one with no floor, gives a plan with refusal 1 and its
	#              findings, not an error
	#   see        stzModelRegistry, stzModelPlan, stzRequirement
	def ResolvePlan()
		return StzResolveFaculty(@cName, [])

	# Returns one sentence naming the faculty, its payload types, its implementations with their kinds and the size of its golden set.
	#
	#   returns    a text such as faculty 'parity': text -> label; implementations: last-digit
	#              (floor), better (model); golden set v1 of 8 item(s)
	#   note       this describes the declaration; the plan that says which implementation would run
	#              is ResolvePlan
	#   see        ResolvePlan, Problems
	#@ aka  -- saying what it is (LAW 3 / LAW 6) -----------------------------------------------------------
	def Why()
		_c_ = "faculty '" + @cName + "': " + This.InputType() + " -> " + This.OutputType() + "; implementations: "
		_aI_ = This.Implementations()
		for _i_ = 1 to len(_aI_)
			if _i_ > 1 _c_ += ", " ok
			_c_ += _aI_[_i_][:id] + " (" + _aI_[_i_][:kind] + ")"
		next
		return _c_ + "; golden set " + This.GoldenVersion() + " of " + len(This.Goldens()) + " item(s)"
