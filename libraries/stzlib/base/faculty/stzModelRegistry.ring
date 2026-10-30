#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZMODELREGISTRY               #
#--------------------------------------------------------------#
#                                                              #
#   Description  : the registry resolves a REQUIREMENT to the   #
#                  implementation(s) of a faculty, EXPLAINS     #
#                  itself (Why), and is always overridable by   #
#                  pinning. It stores what was MEASURED: an     #
#                  implementation with no measurement is        #
#                  unknown, never good; and a model earns a     #
#                  place only by STRICTLY beating the measured  #
#                  floor on the faculty's golden set.           #
#                  (Design: SOFTANZA_MODEL_FLOW.md sections 5, 9)#
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

$aStzMeasurements = []        # rows [ :faculty, :impl, :golden, :score, :n, :conformance, :date, :note ]
$cStzModelPolicy  = "auto"    # auto | deterministic   (deterministic = every faculty on its floor)
$aStzModelTrace   = []        # one row per resolution: [ :faculty, :chosen, :implicit, :why ]
$cStzResidentNeedle = ""      # the model currently resident in the engine's single slot
$aStzSwaps        = []        # [ :needle, :seconds ] -- what load-swap costs, measured

# ---- policy: one switch turns the models off -----------------------------------------------------
# StzModelPolicy(:deterministic) or the environment STZ_MODELS=off. Every faculty then resolves to its floor,
# which is exactly what the library did before models existed.
func StzModelPolicy(pcPolicy)
	pcPolicy = lower("" + pcPolicy)
	if pcPolicy != "auto" and pcPolicy != "deterministic"
		stzraise("StzModelPolicy: :auto or :deterministic -- not '" + pcPolicy + "'.")
	ok
	$cStzModelPolicy = pcPolicy

func StzModelPolicyIs()
	if lower(sysget("STZ_MODELS")) = "off" return "deterministic" ok
	return $cStzModelPolicy

func StzModelTrace()
	return $aStzModelTrace

func StzClearModelTrace()
	$aStzModelTrace = []

func StzMeasurements()
	return $aStzMeasurements

func StzClearMeasurements()
	$aStzMeasurements = []

# ---- measurements ---------------------------------------------------------------------------------------
func StzRecordMeasurement(pcFaculty, pcImpl, pcGolden, pnScore, pnN, pnConformance, pcNote)
	# one row per (faculty, implementation, golden version): a new measurement replaces the old
	for _i_ = len($aStzMeasurements) to 1 step -1
		_a_ = $aStzMeasurements[_i_]
		if _a_[:faculty] = pcFaculty and _a_[:impl] = pcImpl and _a_[:golden] = pcGolden
			del($aStzMeasurements, _i_)
		ok
	next
	add($aStzMeasurements, [ :faculty = pcFaculty, :impl = pcImpl, :golden = pcGolden, :score = pnScore, :n = pnN,
				 :conformance = pnConformance, :date = date() + " " + time(), :note = pcNote ])

func StzMeasurementOf(pcFaculty, pcImpl, pcGolden)
	for _i_ = 1 to len($aStzMeasurements)
		_a_ = $aStzMeasurements[_i_]
		if _a_[:faculty] = pcFaculty and _a_[:impl] = pcImpl and _a_[:golden] = pcGolden return _a_ ok
	next
	return []

# persisted as plain text lines:  faculty|impl|golden|score|n|conformance|date|note   (the .zmdl measurement section)
func StzSaveMeasurements(pcPath)
	_c_ = "# zmdl 1 -- measured quality per implementation (SOFTANZA_MODEL_FLOW.md 9.2)" + char(10)
	for _i_ = 1 to len($aStzMeasurements)
		_a_ = $aStzMeasurements[_i_]
		_c_ += _a_[:faculty] + "|" + _a_[:impl] + "|" + _a_[:golden] + "|" + _a_[:score] + "|" + _a_[:n] + "|" +
		       _a_[:conformance] + "|" + _a_[:date] + "|" + _a_[:note] + char(10)
	next
	write(pcPath, _c_)

func StzLoadMeasurements(pcPath)
	if NOT fexists(pcPath) return 0 ok
	_aL_ = split(read(pcPath), char(10))
	_nLoaded_ = 0
	for _i_ = 1 to len(_aL_)
		if left(_aL_[_i_], 1) = "#" or len(trim(_aL_[_i_])) = 0 loop ok
		_aF_ = split(_aL_[_i_], "|")
		if len(_aF_) >= 6
			_cNote_ = ""
			if len(_aF_) >= 8 _cNote_ = _aF_[8] ok
			_cDate_ = ""
			if len(_aF_) >= 7 _cDate_ = _aF_[7] ok
			StzRecordMeasurement(_aF_[1], _aF_[2], _aF_[3], 0 + _aF_[4], 0 + _aF_[5], 0 + _aF_[6], _cNote_)
			$aStzMeasurements[len($aStzMeasurements)][:date] = _cDate_
			_nLoaded_++
		ok
	next
	return _nLoaded_

# ---- what is installed ---------------------------------------------------------------------------------
# a model implementation is installed when a GGUF whose name contains its :needle is in the models directory
func StzModelFileFor(pcNeedle)
	if pcNeedle = "" return "" ok
	_cDir_ = StzModelsDir()
	if _cDir_ = "" or NOT direxists(_cDir_) return "" ok
	_aE_ = dir(_cDir_)
	for _i_ = 1 to len(_aE_)
		if _aE_[_i_][2] = 0 and right(lower(_aE_[_i_][1]), 5) = ".gguf" and
		   len(StzFind(lower(pcNeedle), lower(_aE_[_i_][1]))) > 0
			return _cDir_ + "/" + _aE_[_i_][1]
		ok
	next
	return ""

func StzImplementationIsInstalled(paImpl)
	if paImpl[:kind] = "floor" return 1 ok
	if paImpl[:kind] = "service" return 1 ok       # reachability is the service's own concern; it is never implicit
	if paImpl[:needle] = "" return 1 ok            # nothing to install: the implementation carries its own code or weights
	# a graph names its weights file by its path under the models directory (the engine loads it, not the slot)
	if paImpl[:kind] = "graph" return fexists(StzModelsDir() + "/" + paImpl[:needle]) ok
	return StzModelFileFor(paImpl[:needle]) != ""

# The engine has ONE model slot: making a model resident is a load-swap, and its cost is MEASURED and kept
# (the residency design, section 11, stays staged until this number says the slot manager is worth its risk).
func StzEnsureModelResident(pcNeedle)
	if pcNeedle = "" return 1 ok
	if $cStzResidentNeedle = pcNeedle and StzEngineNeuralModelLoaded() = 1 return 1 ok
	_cFile_ = StzModelFileFor(pcNeedle)
	if _cFile_ = "" stzraise("The model '" + pcNeedle + "' is not installed in the models directory.") ok
	_t0_ = clock()
	StzNeuralModelQ(_cFile_)
	_nS_ = (clock() - _t0_) / clockspersecond()
	add($aStzSwaps, [ :needle = pcNeedle, :seconds = _nS_ ])
	$cStzResidentNeedle = pcNeedle
	return 1

func StzModelSwapCosts()
	return $aStzSwaps

# ---- resolution ----------------------------------------------------------------------------------------
# paReq: the stzRequirement's Data() (or a faculty name); paPins: [ :impl, :set, :floor, :policy, :allowunmeasured ]
# -> a plan: [ :faculty, :chosen, :kind, :why (list of lines), :rejected, :floor, :refusal, :findings, :pinned ]
func StzResolveFaculty(pReq, paPins)
	_aReq_ = pReq
	if isString(pReq)
		_aReq_ = StzRequirementQ(pReq).Data()
	ok
	if isObject(pReq)
		_aReq_ = pReq.Data()
	ok
	_cFac_ = _aReq_[:faculty]
	_iF_ = _StzFacultyRow(_cFac_)
	if _iF_ = 0
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = [ "no faculty named '" + _cFac_ + "'" ], :rejected = [],
			 :floor = "", :refusal = 1, :pinned = 0,
			 :findings = [ _StzFlowFinding("unknown-faculty", _cFac_, "no faculty is declared with this name") ] ]
	ok
	_aFac_ = $aStzFaculties[_iF_]
	_aImpls_ = _aFac_[:impls]
	_aFloor_ = []
	for _i_ = 1 to len(_aImpls_)
		if _aImpls_[_i_][:kind] = "floor" _aFloor_ = _aImpls_[_i_] ok
	next
	if len(_aFloor_) = 0
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = [ "the faculty has no floor" ], :rejected = [], :floor = "",
			 :refusal = 1, :pinned = 0,
			 :findings = [ _StzFlowFinding("floor-missing", _cFac_, "a faculty without a deterministic floor is refused (LAW 2)") ] ]
	ok
	_aWhy_ = []
	_aRej_ = []
	if NOT isList(paPins) _aPins_ = [] else _aPins_ = paPins ok

	# 1. an explicit pin to the floor, or the process-wide deterministic policy
	if HasKey(_aPins_, :floor) and _aPins_[:floor] = 1
		add(_aWhy_, "pinned to the floor '" + _aFloor_[:id] + "'")
		return _StzPlan(_cFac_, _aFloor_, _aWhy_, _aRej_, _aFloor_, 1)
	ok
	if StzModelPolicyIs() = "deterministic"
		add(_aWhy_, "the model policy is deterministic (STZ_MODELS=off or StzModelPolicy(:deterministic)): every faculty is on its floor")
		return _StzPlan(_cFac_, _aFloor_, _aWhy_, _aRej_, _aFloor_, 0)
	ok

	# 2. an explicit pin to one implementation: it runs, or the plan is a refusal -- never a silent substitute
	if HasKey(_aPins_, :impl) and _aPins_[:impl] != ""
		for _i_ = 1 to len(_aImpls_)
			if _aImpls_[_i_][:id] = _aPins_[:impl]
				if StzImplementationIsInstalled(_aImpls_[_i_]) = 0
					return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = [ "'" + _aPins_[:impl] + "' is pinned but not installed" ],
						 :rejected = [], :floor = _aFloor_[:id], :refusal = 1, :pinned = 1,
						 :findings = [ _StzFlowFinding("pinned-not-installed", _cFac_ + ":" + _aPins_[:impl], "the pinned implementation is not installed; it is refused, not replaced") ] ]
				ok
				add(_aWhy_, "pinned to '" + _aImpls_[_i_][:id] + "' (" + _aImpls_[_i_][:kind] + "); the registry does not override a pin")
				_aM_ = StzMeasurementOf(_cFac_, _aImpls_[_i_][:id], _aFac_[:goldenversion])
				if len(_aM_) = 0
					add(_aWhy_, "it is UNMEASURED on golden set " + _aFac_[:goldenversion] + ": its evidence is :unknown")
				else
					add(_aWhy_, "measured " + _aM_[:score] + " on golden set " + _aFac_[:goldenversion] + " (n=" + _aM_[:n] + ")")
				ok
				return _StzPlan(_cFac_, _aImpls_[_i_], _aWhy_, _aRej_, _aFloor_, 1)
			ok
		next
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = [ "no implementation '" + _aPins_[:impl] + "'" ], :rejected = [],
			 :floor = _aFloor_[:id], :refusal = 1, :pinned = 1,
			 :findings = [ _StzFlowFinding("unknown-implementation", _cFac_ + ":" + _aPins_[:impl], "the faculty has no such implementation") ] ]
	ok

	# 3. the hard filters, each recorded when it removes a candidate
	_aCand_ = []
	_aSet_ = []
	if HasKey(_aPins_, :set) _aSet_ = _aPins_[:set] ok
	for _i_ = 1 to len(_aImpls_)
		_a_ = _aImpls_[_i_]
		if _a_[:kind] = "floor" loop ok
		if len(_aSet_) > 0 and len(StzFind(_a_[:id], _aSet_)) = 0
			add(_aRej_, [ _a_[:id], "not in the pinned set" ])
			loop
		ok
		if _a_[:kind] = "service"
			add(_aRej_, [ _a_[:id], "a service is never selected implicitly; pin it by name" ])
			loop
		ok
		if StzImplementationIsInstalled(_a_) = 0
			if _a_[:kind] = "graph"
				add(_aRej_, [ _a_[:id], "not installed (no file " + _a_[:needle] + " in the models directory)" ])
			else
				add(_aRej_, [ _a_[:id], "not installed (no GGUF whose name contains '" + _a_[:needle] + "')" ])
			ok
			loop
		ok
		if _aReq_[:licence] = "permissive" and len(StzFind(lower(_a_[:licence]), [ "apache-2.0", "mit", "bsd-3-clause", "bsd-2-clause", "isc", "n/a", "cc0-1.0" ])) = 0
			add(_aRej_, [ _a_[:id], "licence '" + _a_[:licence] + "' is not permissive" ])
			loop
		ok
		_bLangOk_ = 1
		if len(_aReq_[:languages]) > 0 and len(StzFind("*", _a_[:languages])) = 0
			for _l_ = 1 to len(_aReq_[:languages])
				if len(StzFind(_aReq_[:languages][_l_], _a_[:languages])) = 0 _bLangOk_ = 0 ok
			next
		ok
		if _bLangOk_ = 0
			add(_aRej_, [ _a_[:id], "does not cover every required language" ])
			loop
		ok
		if _aReq_[:memory] > 0 and _a_[:memory] > _aReq_[:memory]
			add(_aRej_, [ _a_[:id], "needs " + _a_[:memory] + " MB, the budget is " + _aReq_[:memory] + " MB" ])
			loop
		ok
		if _aReq_[:deterministic] = 1 and _a_[:deterministic] = 0
			add(_aRej_, [ _a_[:id], "not deterministic" ])
			loop
		ok
		add(_aCand_, _a_)
	next

	# 4. the quality gate: measured, and STRICTLY better than the measured floor -- on the requested language's
	# own measurements when the faculty is measured per language and the requirement names one language
	_cGold_ = _aFac_[:goldenversion]
	if HasKey(_aFac_, :langkey) and _aFac_[:langkey] != "" and len(_aReq_[:languages]) = 1
		_cLg_ = lower(_aReq_[:languages][1])
		if len(StzMeasurementOf(_cFac_, _aFloor_[:id], _cGold_ + "/" + _cLg_)) > 0
			_cGold_ = _cGold_ + "/" + _cLg_
			add(_aWhy_, "judged on the '" + _cLg_ + "' items of golden set " + _aFac_[:goldenversion] + " (the faculty is measured per language)")
		else
			add(_aWhy_, "the golden set " + _aFac_[:goldenversion] + " has no measured '" + _cLg_ + "' items: judged on the whole set")
		ok
	ok
	_aFM_ = StzMeasurementOf(_cFac_, _aFloor_[:id], _cGold_)
	_aElig_ = []
	for _i_ = 1 to len(_aCand_)
		_a_ = _aCand_[_i_]
		if len(_aFM_) = 0
			add(_aRej_, [ _a_[:id], "the floor is unmeasured on golden set " + _cGold_ + ": there is no bar to beat" ])
			loop
		ok
		_aM_ = StzMeasurementOf(_cFac_, _a_[:id], _cGold_)
		if len(_aM_) = 0
			add(_aRej_, [ _a_[:id], "UNMEASURED on golden set " + _cGold_ + " (unknown is not good)" ])
			loop
		ok
		if _aM_[:conformance] < 1
			add(_aRej_, [ _a_[:id], "fails conformance (" + _aM_[:conformance] + ")" ])
			loop
		ok
		if _aM_[:score] <= _aFM_[:score]
			add(_aRej_, [ _a_[:id], "does not beat the floor: measured " + _aM_[:score] + " against the floor's " + _aFM_[:score] ])
			loop
		ok
		if _aM_[:score] < _aReq_[:quality]
			add(_aRej_, [ _a_[:id], "measured " + _aM_[:score] + " < the requested quality " + _aReq_[:quality] ])
			loop
		ok
		add(_aElig_, [ _a_, _aM_ ])
	next

	# 5. rank: higher measured quality, then smaller memory, then name (a tie is reported, not hidden)
	if len(_aElig_) > 1
		for _i_ = 1 to len(_aElig_) - 1
			for _j_ = _i_ + 1 to len(_aElig_)
				_bSwap_ = 0
				if _aElig_[_j_][2][:score] > _aElig_[_i_][2][:score]
					_bSwap_ = 1
				but _aElig_[_j_][2][:score] = _aElig_[_i_][2][:score]
					if _aElig_[_j_][1][:memory] < _aElig_[_i_][1][:memory]
						_bSwap_ = 1
					but _aElig_[_j_][1][:memory] = _aElig_[_i_][1][:memory] and _aElig_[_j_][1][:id] < _aElig_[_i_][1][:id]
						_bSwap_ = 1
					ok
				ok
				if _bSwap_ = 1
					_t_ = _aElig_[_i_]
					_aElig_[_i_] = _aElig_[_j_]
					_aElig_[_j_] = _t_
				ok
			next
		next
	ok

	if len(_aElig_) > 0
		_aBest_ = _aElig_[1]
		add(_aWhy_, "'" + _aBest_[1][:id] + "' (" + _aBest_[1][:kind] + ") measured " + _aBest_[2][:score] + " on golden set " + _cGold_ +
			    " (n=" + _aBest_[2][:n] + "), which beats the floor's " + _aFM_[:score] + " and the requested " + _aReq_[:quality])
		for _i_ = 2 to len(_aElig_)
			add(_aRej_, [ _aElig_[_i_][1][:id], "eligible but ranked lower (" + _aElig_[_i_][2][:score] + " < " + _aBest_[2][:score] + " or a larger footprint)" ])
		next
		add(_aWhy_, "the floor '" + _aFloor_[:id] + "' is kept as the fallback")
		return _StzPlan(_cFac_, _aBest_[1], _aWhy_, _aRej_, _aFloor_, 0)
	ok

	# 6. fall back to the floor, SAYING SO -- or refuse, when the requirement asked not to settle for it
	add(_aWhy_, "no model qualified; the floor '" + _aFloor_[:id] + "' is used")
	if _aReq_[:refusebelow] = 1
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = _aWhy_, :rejected = _aRej_, :floor = _aFloor_[:id], :refusal = 1, :pinned = 0,
			 :findings = [ _StzFlowFinding("below-quality", _cFac_, "no implementation met the requirement and it forbids falling back to the floor") ] ]
	ok
	return _StzPlan(_cFac_, _aFloor_, _aWhy_, _aRej_, _aFloor_, 0)

func _StzPlan(pcFac, paChosen, paWhy, paRej, paFloor, pbPinned)
	return [ :faculty = pcFac, :chosen = paChosen[:id], :kind = paChosen[:kind], :why = paWhy, :rejected = paRej,
		 :floor = paFloor[:id], :refusal = 0, :findings = [], :pinned = pbPinned, :needle = paChosen[:needle] ]

# ---- RUN a faculty: resolve, make the model resident, run, FALL BACK to the floor if the model fails -----------
# -> a parcel (a refusal parcel when nothing can answer). pbImplicit marks a resolution the library made on its
# own (the implicit hooks of the design, section 8); every resolution is recorded in the trace either way.
func StzRunFaculty(pcFaculty, pInput, paParams, pReq, paPins, pbImplicit)
	_aReq_ = pReq
	if NOT isList(pReq) or len(pReq) = 0
		_aReq_ = StzRequirementQ(pcFaculty).Data()
	ok
	if isObject(pReq) _aReq_ = pReq.Data() ok
	# a faculty measured per language: the call's own language is the requirement's, unless one was stated
	if len(_aReq_[:languages]) = 0
		_cLg_ = StzGoldenLanguageOf(pcFaculty, pInput, paParams)
		if _cLg_ != "" _aReq_[:languages] = [ _cLg_ ] ok
	ok
	_aPlan_ = StzResolveFaculty(_aReq_, paPins)
	add($aStzModelTrace, [ :faculty = pcFaculty, :chosen = _aPlan_[:chosen], :implicit = pbImplicit, :refusal = _aPlan_[:refusal], :why = _aPlan_[:why] ])
	if _aPlan_[:refusal] = 1
		_oR_ = new stzParcel("refusal", [])
		_oR_._MakeRefusal(_aPlan_[:findings])
		return _oR_
	ok
	_cErr_ = ""
	if _cErr_ = ""
		_oP_ = StzRunImplementation(pcFaculty, _aPlan_[:chosen], pInput, paParams)
		if _oP_.IsRefusal() = 0 or _aPlan_[:pinned] = 1 or _aPlan_[:kind] = "floor"
			return _oP_
		ok
		_cErr_ = "the implementation's answer was refused: " + _oP_.CiteFindings()
	ok
	# the chosen model failed and nobody pinned it: the floor answers, and the provenance says it fell back
	_oF_ = StzRunImplementation(pcFaculty, _aPlan_[:floor], pInput, paParams)
	if _oF_.IsRefusal() = 0
		_aProv_ = _oF_.Provenance()
		_aProv_[1][:detail] = "fell back from '" + _aPlan_[:chosen] + "': " + _cErr_
		_oF_._SetProvenance(_aProv_)
	ok
	return _oF_

func StzModelRegistryQ()
	return new stzModelRegistry()

# score one implementation on the faculty's golden set: [ :score, :n, :conformance ]
# conformance = the share of golden inputs whose answer the faculty's COURT accepted (it must be 1 to be eligible)
func StzScoreImplementation(pcFaculty, pcImplId, paParams)
	_iF_ = _StzFacultyRow(pcFaculty)
	_aFac_ = $aStzFaculties[_iF_]
	_aG_ = _aFac_[:golden]
	_nOk_ = 0
	_nValid_ = 0
	# a re-measurement replaces the old ledger rows of this implementation (the ledger is of ONE golden version)
	for _r_ = len($aStzCalibration) to 1 step -1
		if $aStzCalibration[_r_][:faculty] = pcFaculty and $aStzCalibration[_r_][:impl] = pcImplId del($aStzCalibration, _r_) ok
	next
	_n_ = len(_aG_)
	# per language, when the faculty is measured so: rows [ lang, ok, valid, n ]
	_aLg_ = []
	for _i_ = 1 to _n_
		_cLg_ = StzGoldenLanguageOf(pcFaculty, _aG_[_i_][1], [])
		_k_ = 0
		if _cLg_ != ""
			for _j_ = 1 to len(_aLg_)
				if _aLg_[_j_][1] = _cLg_ _k_ = _j_ ok
			next
			if _k_ = 0
				add(_aLg_, [ _cLg_, 0, 0, 0 ])
				_k_ = len(_aLg_)
			ok
			_aLg_[_k_][4] = _aLg_[_k_][4] + 1
		ok
		_oP_ = StzRunImplementation(pcFaculty, pcImplId, _aG_[_i_][1], paParams)
		if _oP_.IsRefusal() = 0
			_nValid_++
			if _k_ > 0 _aLg_[_k_][3] = _aLg_[_k_][3] + 1 ok
			_bRight_ = StzGoldenAgrees(_aFac_[:checker], _oP_.Value(), _aG_[_i_][2])
			if _bRight_ = 1
				_nOk_++
				if _k_ > 0 _aLg_[_k_][2] = _aLg_[_k_][2] + 1 ok
			ok
			# the truth is KNOWN here, so an answer that carried a probability goes in the calibration ledger
			if _oP_.P() >= 0
				StzRecordCalibration(pcFaculty, pcImplId, _oP_.Certainty(), _oP_.P(), _bRight_)
			ok
		ok
	next
	if _n_ = 0 return [ :score = 0, :n = 0, :conformance = 0, :bylang = [] ] ok
	_aBy_ = []
	for _j_ = 1 to len(_aLg_)
		add(_aBy_, [ _aLg_[_j_][1], _aLg_[_j_][2] / _aLg_[_j_][4], _aLg_[_j_][4], _aLg_[_j_][3] / _aLg_[_j_][4] ])
	next
	return [ :score = _nOk_ / _n_, :n = _n_, :conformance = _nValid_ / _n_, :bylang = _aBy_ ]

func StzRunGoldens(pcFaculty, paParams)
	return StzRunGoldensFor(pcFaculty, [], paParams)

# the same, restricted to the named implementations (the floor is always measured: it is the bar)
func StzRunGoldensFor(pcFaculty, pacImplIds, paParams)
	_iF_ = _StzFacultyRow(pcFaculty)
	if _iF_ = 0 stzraise("RunGoldens: no faculty named '" + pcFaculty + "'.") ok
	_aFac_ = $aStzFaculties[_iF_]
	_aRows_ = []
	# the floor first: its score is the bar
	_aOrder_ = []
	for _i_ = 1 to len(_aFac_[:impls])
		if _aFac_[:impls][_i_][:kind] = "floor" add(_aOrder_, _aFac_[:impls][_i_]) ok
	next
	for _i_ = 1 to len(_aFac_[:impls])
		if _aFac_[:impls][_i_][:kind] != "floor" add(_aOrder_, _aFac_[:impls][_i_]) ok
	next
	for _i_ = 1 to len(_aOrder_)
		_a_ = _aOrder_[_i_]
		if StzImplementationIsInstalled(_a_) = 0 loop ok
		if len(pacImplIds) > 0 and _a_[:kind] != "floor" and len(StzFind(_a_[:id], pacImplIds)) = 0 loop ok
		if _a_[:kind] = "service" loop ok        # a service is measured only when someone pins and runs it deliberately
		_aS_ = StzScoreImplementation(pcFaculty, _a_[:id], paParams)
		StzRecordMeasurement(pcFaculty, _a_[:id], _aFac_[:goldenversion], _aS_[:score], _aS_[:n], _aS_[:conformance], "")
		add(_aRows_, StzMeasurementOf(pcFaculty, _a_[:id], _aFac_[:goldenversion]))
		# and one row per language, filed under "<version>/<lang>" (the rows returned stay the whole-set ones)
		_aBy_ = _aS_[:bylang]
		for _j_ = 1 to len(_aBy_)
			StzRecordMeasurement(pcFaculty, _a_[:id], _aFac_[:goldenversion] + "/" + _aBy_[_j_][1], _aBy_[_j_][2], _aBy_[_j_][3], _aBy_[_j_][4], "")
		next
	next
	return _aRows_

# Holds what the registry decided for a requirement: the implementation chosen, those rejected, and why.
#
# A plan is the registry's answer made readable. Chosen and Kind say what would run, Rejected lists
# every implementation turned down with its reason, and Why writes the whole explanation one line
# per fact. A plan can be a refusal, with an empty chosen id and findings, when a pin cannot be
# honoured or the requirement forbids settling for the floor. Making a plan runs nothing.
#
#   receiver   o1 = StzFacultyQ("planpos")  o1.SetInputType(:text)  o1.SetOutputType(:number)
#              o1.SetFloor("last", "StzFindLast")  o1 = StzModelRegistryQ().ResolveQ("planpos")
#   example    ? o1.Chosen()
#              #--> last
#              ? o1.Kind()
#              #--> floor
#              ? o1.IsFloor()
#              #--> 1
#              ? @@( o1.Rejected() )
#              #--> [ ]
#   see        stzModelRegistry, stzRequirement
class stzModelPlan from stzObject

	@aPlan = []

	# Wraps a plan produced by the registry so it can be read by name and explained.
	#
	#   paPlan     a plan as the registry returns it: a list of [ key, value ] pairs faculty,
	#              chosen, kind, why, rejected, floor, refusal, findings, pinned
	#   returns    nothing; the object is built
	#   note       the plan is kept as a copy, so changing the list afterwards does not change the
	#              object
	#   warning    the list is not checked: an empty list is accepted and the readers then return
	#              empty values
	#   see        stzModelRegistry, Data
	def init(paPlan)
		@aPlan = paPlan

	# Returns the plan as the list of [ key, value ] pairs it was built from.
	#
	#   returns    a list of pairs: faculty, chosen, kind, why, rejected, floor, refusal, findings,
	#              pinned and needle
	#   see        Why, Chosen
	def Data()
		return @aPlan

	# Returns the name of the faculty the plan is for.
	#
	#   returns    a text
	#   see        Chosen, Data
	def Faculty()
		return @aPlan[:faculty]

	# Returns the id of the implementation the plan picked.
	#
	#   returns    a text; an empty text when the plan is a refusal
	#   see        Kind, Floor, IsRefusal
	def Chosen()
		return @aPlan[:chosen]

	# Returns which kind of implementation the plan picked.
	#
	#   returns    a text: floor, model, dlm or service; an empty text for a refusal
	#   note       the registry picks a service only when it was pinned by name
	#   see        Chosen, IsFloor
	def Kind()
		return @aPlan[:kind]

	# Returns the id of the faculty's floor, the fallback the plan keeps.
	#
	#   returns    a text; an empty text when the faculty is unknown
	#   note       this is the floor's id and not its row: Floor of the faculty returns the row
	#   see        Chosen, IsFloor
	def Floor()
		return @aPlan[:floor]

	# TRUE if the plan is a refusal: nothing can answer, or a pin cannot be honoured, or the requirement forbids the floor.
	#
	#   returns    TRUE or FALSE
	#   note       a refusal plan has an empty chosen id and its findings say why
	#   see        Findings, Why
	def IsRefusal()
		return @aPlan[:refusal]

	# TRUE if the plan picked the faculty's floor, whether the registry fell back to it or it was pinned.
	#
	#   returns    TRUE or FALSE
	#   see        Kind, Chosen
	def IsFloor()
		return @aPlan[:kind] = "floor"

	# Returns each implementation the plan turned down, with the reason.
	#
	#   returns    a list of [ id, reason ] pairs; [ ] when nothing was rejected
	#   note       reasons name the filter: not installed, not permissive, memory, language,
	#              determinism, unmeasured, not beating the floor, a lower rank, a service
	#   see        Why, Chosen
	def Rejected()
		return @aPlan[:rejected]

	# Returns the findings of a refusal plan, in the house shape.
	#
	#   returns    a list of findings, each [ rule, subject, where, severity, message ]; [ ] when
	#              the plan is not a refusal
	#   see        IsRefusal, Why
	def Findings()
		return @aPlan[:findings]

	# Returns the whole explanation: the choice, one line per reason, then each rejection and each finding.
	#
	#   returns    a text with one line per fact, starting with the faculty and the chosen
	#              implementation or REFUSED
	#   note       the scores it quotes are measured by the registry on the golden set and are not
	#              judged by a person
	#   see        Rejected, Findings, Data
	#@ aka  the whole explanation, one line per fact
	def Why()
		_c_ = @aPlan[:faculty] + " -> "
		if @aPlan[:refusal] = 1
			_c_ += "REFUSED"
		else
			_c_ += @aPlan[:chosen] + " (" + @aPlan[:kind] + ")"
		ok
		for _i_ = 1 to len(@aPlan[:why])
			_c_ += char(10) + "  " + @aPlan[:why][_i_]
		next
		for _i_ = 1 to len(@aPlan[:rejected])
			_c_ += char(10) + "  rejected " + @aPlan[:rejected][_i_][1] + ": " + @aPlan[:rejected][_i_][2]
		next
		for _i_ = 1 to len(@aPlan[:findings])
			_c_ += char(10) + "  finding " + @aPlan[:findings][_i_][:rule] + ": " + @aPlan[:findings][_i_][:message]
		next
		return _c_

# Resolves a requirement to the implementation of a faculty that should run, from what was measured, and stores the measurements.
#
# The registry trusts only measurements: an implementation with none is unknown and never chosen,
# and a model is chosen only when its score strictly beats the measured floor on the faculty's
# golden set and reaches the requested quality. RunGoldens records those scores, SaveMeasurements
# and LoadMeasurements keep them in a text file, and a pin always overrides the registry. It is a
# handle on process-wide tables, so every object sees the same measurements.
# StzModelPolicy(:deterministic), or the environment STZ_MODELS=off, puts every faculty on its
# floor. Scores are computed by the class from the goldens; no person has judged the output of any
# model.
#
#   receiver   o1 = StzModelRegistryQ()
#   example    o2 = StzFacultyQ("regpos")
#              o2.SetInputType(:text)
#              o2.SetOutputType(:number)
#              o2.SetFloor("last", "StzFindLast")
#              o2.AddGolden("b", 2)
#              o2.AddImplementation([ :id = "first", :kind = "model", :fn = "StzFindFirst", :licence = "mit" ])
#              ? o1.Resolve("regpos")[:chosen]
#              #--> last
#              StzRecordMeasurement("regpos", "last", "v1", 0.5, 2, 1, "")
#              StzRecordMeasurement("regpos", "first", "v1", 1, 2, 1, "")
#              ? o1.Resolve("regpos")[:chosen]
#              #--> first
#              ? o1.MeasurementOf("regpos", "first")[:score]
#              #--> 1
#   see        stzFaculty, stzRequirement, stzModelPlan, stzFlow
class stzModelRegistry from stzObject

	# Builds a handle on the process-wide registry of measurements; it holds no state of its own.
	#
	#   returns    nothing; the object is built
	#   note       every handle reads the same measurements, the same model trace and the same
	#              policy, so there is one registry per process
	#   see        StzModelRegistryQ, Measurements
	def init()
	# Resolves a requirement to the implementation that should run and returns the plan as data.
	#
	#   pReq       a faculty name, an stzRequirement, or the list its Data returns
	#   returns    a plan: a list of [ key, value ] pairs faculty, chosen, kind, why, rejected,
	#              floor, refusal, findings, pinned and needle
	#   note       a model is chosen only when its measured score strictly beats the floor's and
	#              reaches the requested quality, and the floor stays as the fallback; under
	#              StzModelPolicy(:deterministic) or STZ_MODELS=off every faculty resolves to its
	#              floor; ResolveQ returns the same plan as an stzModelPlan, ready to explain
	#   warning    an unknown faculty, or one with no floor, gives a plan with refusal 1 and its
	#              findings, not an error; with no measurement the floor is chosen, because an
	#              unmeasured model is unknown and never good
	#   see        ResolveQ, MeasurementOf, stzRequirement
	#@ aka  stateless handle over the global tables
	def Resolve(pReq)
		return StzResolveFaculty(pReq, [])

	def ResolveQ(pReq)
		return new stzModelPlan(StzResolveFaculty(pReq, []))

	# Returns every measurement recorded in the process, in the order recorded.
	#
	#   returns    a list of rows, each a list of [ key, value ] pairs: faculty, impl, golden,
	#              score, n, conformance, date, note
	#   note       a new measurement of the same implementation on the same golden version replaces
	#              the old row and goes to the end
	#   see        MeasurementOf, RunGoldens, SaveMeasurements
	def Measurements()
		return StzMeasurements()

	# Returns the measurement recorded for one implementation under the faculty's current golden version.
	#
	#   pcFaculty   the faculty's name
	#   pcImpl      the id of the implementation
	#   returns     a row of [ key, value ] pairs faculty, impl, golden, score, n, conformance,
	#               date, note; [ ] when none
	#   note        score is the share of golden inputs whose answer the checker accepted, and
	#               conformance the share the court accepted: both are computed by the class, not
	#               judged by a person
	#   warning     an unknown faculty gives [ ] and not an error; after SetGoldenVersion the
	#               earlier rows are not found
	#   see         Measurements, RunGoldens
	def MeasurementOf(pcFaculty, pcImpl)
		_iF_ = _StzFacultyRow(pcFaculty)
		if _iF_ = 0 return [] ok
		return StzMeasurementOf(pcFaculty, pcImpl, $aStzFaculties[_iF_][:goldenversion])

	# Runs the faculty's golden set through every installed implementation, the floor first, and records the scores.
	#
	#   pcFaculty   the name of the faculty to measure
	#   returns     the rows recorded: one measurement per implementation run
	#   note        the floor is run first because its score is the bar a model must strictly beat
	#   warning     raises an error for an unknown faculty; a model whose file is not in the models
	#               directory is skipped and a service is never run; an answer that stated a
	#               probability also enters the calibration ledger; the golden loop writes the
	#               merged defaults back into the list it passes, so a faculty whose default params
	#               are not [ key, value ] pairs is scored on grown params; not exercised with a
	#               real model: the answer shape is read from the code
	#   see         RunGoldensFor, Measurements, Resolve
	#@ aka  RUN a faculty's golden set through EVERY implementation that is installed -- the floor first, because its score is the bar -- and record what was measured. Returns the rows recorded.
	# The measurement of one implementation on the items of one language of the faculty's golden set, [ ] when
	# the faculty is not measured per language or that language was not measured.
	#
	#   pcFaculty  the faculty's name
	#   pcImpl     the implementation's id
	#   pcLang     a language code or tag ("ru", "ru-RU")
	#   returns    a measurement row (faculty, impl, golden, score, n, conformance, date, note), or [ ]
	#   see        MeasurementOf, RunGoldens, stzFaculty.SetGoldenLanguageKey
	def MeasurementOfIn(pcFaculty, pcImpl, pcLang)
		_iF_ = _StzFacultyRow(pcFaculty)
		if _iF_ = 0 return [] ok
		return StzMeasurementOf(pcFaculty, pcImpl, $aStzFaculties[_iF_][:goldenversion] + "/" + lower(left("" + pcLang, 2)))

	def RunGoldens(pcFaculty)
		return StzRunGoldens(pcFaculty, [])

	# Measures the floor and the named implementations on the golden set and records the scores.
	#
	#   pcFaculty    the name of the faculty to measure
	#   pacImplIds   the ids of the non-floor implementations to measure
	#   returns      the rows recorded: the floor and each named implementation that is installed
	#   note         the floor is always measured, because it is the bar; implementations not named
	#                keep their earlier rows
	#   warning      raises an error for an unknown faculty; ids that are not installed, and
	#                services, are skipped; not exercised with a real model: the answer shape is
	#                read from the code
	#   see          RunGoldens, Measurements
	def RunGoldensFor(pcFaculty, pacImplIds)
		return StzRunGoldensFor(pcFaculty, pacImplIds, [])

	# Writes every measurement to a text file, one line per row after a header, overwriting the file.
	#
	#   pcPath     the file to write
	#   returns    nothing; the file is written
	#   note       each line holds faculty, impl, golden, score, n, conformance, date and note
	#              separated by vertical bars, so a note containing a bar would not read back whole
	#   see        LoadMeasurements, Measurements
	def SaveMeasurements(pcPath)
		StzSaveMeasurements(pcPath)

	# Reads a file written by SaveMeasurements back into the registry and returns how many rows it took.
	#
	#   pcPath     the file to read
	#   returns    a number: the rows loaded; 0 for a missing file
	#   note       a row for an implementation already measured on the same golden version replaces
	#              it, the saved date is kept, and lines with fewer than six fields are skipped
	#   see        SaveMeasurements, Measurements
	def LoadMeasurements(pcPath)
		return StzLoadMeasurements(pcPath)
