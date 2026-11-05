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
$aStzCourt        = []        # rows [ :faculty, :golden, :challenger, :other, :gains, :losses, :p, :verdict, :date, :note ]
$nStzCourtAlpha   = 0.05      # the court's level: a challenger's gains must be this improbable as chance
$aStzCourtIncumbents = []     # rows [ :faculty, :golden, :impl ] -- who holds the faculty when the court sits
$cStzPlacementOS  = ""        # MP0: "" = this machine; MP2 sets it to resolve for a declared target
$aStzPlacementProbes = []     # MP2: [ probe name, the target's answer fn ] pairs that stand in for this machine's probes

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

# ---- the court (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8, written 2026-11-05) ----------------------
# A measurement that beats another by ONE pair on the same golden set passes "strictly more" and is noise. When two implementations are judged
# on the SAME items, the evidence is in the DISCORDANT items -- the ones where one agrees and the other does not. The court upholds a
# challenger over another implementation only when its gains among them are improbable as chance: the exact one-sided sign test (McNemar's,
# exact), P(X >= gains | discordant, 1/2) <= $nStzCourtAlpha, computed by the engine on the regularized incomplete beta. The verdict is DERIVED
# from the gains and losses every time it is recorded or loaded; only the counts are evidence. A faculty whose golden set has court records is
# judged by them. THE COURT IS THE DEFAULT GATE (the author's ruling, 2026-11-05): step 5b runs for EVERY faculty, and a model with no
# court evidence against the incumbent and the floor is not chosen -- a missing record is not an acquittal. The evidence is made where the
# measurement is made: StzRunGoldens records, for every ordered pair of the implementations it scored, the gains and losses item by item
# (and per language, when the faculty is measured per language). A measurement recorded by hand (StzRecordMeasurement) carries no evidence;
# its author records the counts with StzRecordCourtVerdict, or the model stays out.
# THE BURDEN IS ON THE CHANGE: the court sits with an INCUMBENT (the implementation that holds the faculty when the challengers are judged;
# the floor when none is declared). The incumbent must be upheld against the floor; every other implementation must be upheld against the
# incumbent AND the floor. The incumbent never has to prove itself against a challenger -- a tie leaves things as they were.
func StzRecordCourtVerdict(pcFaculty, pcGolden, pcChallenger, pcOther, pnGains, pnLosses, pcNote)
	for _i_ = len($aStzCourt) to 1 step -1
		_a_ = $aStzCourt[_i_]
		if _a_[:faculty] = pcFaculty and _a_[:golden] = pcGolden and _a_[:challenger] = pcChallenger and _a_[:other] = pcOther
			del($aStzCourt, _i_)
		ok
	next
	_n_ = pnGains + pnLosses
	_p_ = StzEngineBinomialUpperTail(pnGains, _n_, 0.5)
	_cV_ = "refused"
	if pnGains > pnLosses and _p_ <= $nStzCourtAlpha _cV_ = "upheld" ok
	add($aStzCourt, [ :faculty = pcFaculty, :golden = pcGolden, :challenger = pcChallenger, :other = pcOther, :gains = pnGains,
			  :losses = pnLosses, :p = _p_, :verdict = _cV_, :date = date() + " " + time(), :note = pcNote ])
	return _cV_

func StzCourtVerdictOf(pcFaculty, pcGolden, pcChallenger, pcOther)
	for _i_ = 1 to len($aStzCourt)
		_a_ = $aStzCourt[_i_]
		if _a_[:faculty] = pcFaculty and _a_[:golden] = pcGolden and _a_[:challenger] = pcChallenger and _a_[:other] = pcOther return _a_ ok
	next
	return []

func StzCourtHasRecords(pcFaculty, pcGolden)
	for _i_ = 1 to len($aStzCourt)
		if $aStzCourt[_i_][:faculty] = pcFaculty and $aStzCourt[_i_][:golden] = pcGolden return 1 ok
	next
	return 0

func StzCourt()
	return $aStzCourt

func StzSetCourtIncumbent(pcFaculty, pcGolden, pcImpl)
	for _i_ = len($aStzCourtIncumbents) to 1 step -1
		if $aStzCourtIncumbents[_i_][:faculty] = pcFaculty and $aStzCourtIncumbents[_i_][:golden] = pcGolden del($aStzCourtIncumbents, _i_) ok
	next
	add($aStzCourtIncumbents, [ :faculty = pcFaculty, :golden = pcGolden, :impl = pcImpl ])

# the incumbent the court sits with; "" when none is declared (the floor then). A per-language golden ("v2/fr") sits with the incumbent of
# its whole set ("v2") unless one is declared for the language itself.
func StzCourtIncumbent(pcFaculty, pcGolden)
	for _i_ = 1 to len($aStzCourtIncumbents)
		if $aStzCourtIncumbents[_i_][:faculty] = pcFaculty and $aStzCourtIncumbents[_i_][:golden] = pcGolden return $aStzCourtIncumbents[_i_][:impl] ok
	next
	_n_ = StzFind("/", pcGolden)
	if len(_n_) > 0
		return StzCourtIncumbent(pcFaculty, left(pcGolden, _n_[1] - 1))
	ok
	return ""

# the counts of one implementation against another from two verdict lists of the same items (1 right, 0 wrong or refused)
func StzCourtCounts(paA, paB)
	_nG_ = 0
	_nL_ = 0
	_n_ = len(paA)
	if len(paB) < _n_ _n_ = len(paB) ok
	for _i_ = 1 to _n_
		if paA[_i_] = 1 and paB[_i_] = 0 _nG_++ ok
		if paA[_i_] = 0 and paB[_i_] = 1 _nL_++ ok
	next
	return [ _nG_, _nL_ ]

# the court file as lines (StzLoadCourt reads them back): the incumbents, then every record's counts
func StzSaveCourt(pcPath)
	_c_ = "# zcourt 1 -- the court's evidence per faculty and golden set (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8)" + char(10) +
	      "# faculty|golden|challenger|other|gains|losses|p|verdict|date|note   (p and the verdict are recomputed from the counts on load)" + char(10)
	for _i_ = 1 to len($aStzCourtIncumbents)
		_a_ = $aStzCourtIncumbents[_i_]
		_c_ += "incumbent|" + _a_[:faculty] + "|" + _a_[:golden] + "|" + _a_[:impl] + char(10)
	next
	for _i_ = 1 to len($aStzCourt)
		_a_ = $aStzCourt[_i_]
		_c_ += _a_[:faculty] + "|" + _a_[:golden] + "|" + _a_[:challenger] + "|" + _a_[:other] + "|" + _a_[:gains] + "|" + _a_[:losses] + "|" +
		       _a_[:p] + "|" + _a_[:verdict] + "|" + _a_[:date] + "|" + _a_[:note] + char(10)
	next
	write(pcPath, _c_)
	return len($aStzCourt)

func StzClearCourt()
	$aStzCourt = []
	$aStzCourtIncumbents = []

# persisted as plain text lines:  faculty|golden|challenger|other|gains|losses|p|verdict|date|note  -- p and the verdict are written for a
# reader, and RECOMPUTED from the gains and losses when the file is loaded; and  incumbent|faculty|golden|impl  for who holds the faculty
func StzLoadCourt(pcPath)
	if NOT fexists(pcPath) return 0 ok
	_aL_ = split(read(pcPath), char(10))
	_nLoaded_ = 0
	for _i_ = 1 to len(_aL_)
		if left(_aL_[_i_], 1) = "#" or len(trim(_aL_[_i_])) = 0 loop ok
		_aF_ = split(_aL_[_i_], "|")
		if len(_aF_) = 4 and _aF_[1] = "incumbent"
			StzSetCourtIncumbent(_aF_[2], _aF_[3], trim(_aF_[4]))
			loop
		ok
		if len(_aF_) >= 6
			_cNote_ = ""
			if len(_aF_) >= 10 _cNote_ = trim(_aF_[10]) ok
			StzRecordCourtVerdict(_aF_[1], _aF_[2], _aF_[3], _aF_[4], 0 + _aF_[5], 0 + _aF_[6], _cNote_)
			if len(_aF_) >= 9 $aStzCourt[len($aStzCourt)][:date] = _aF_[9] ok
			_nLoaded_++
		ok
	next
	return _nLoaded_

# ---- MP0: can it run HERE? (SOFTANZA_MODEL_PLACEMENT.md) -------------------------------------------------------------------
# [ 1|0, reason ] for an implementation row and a language ("" = no particular one). Two checks, cheap, running nothing heavy: the operating
# system against :platforms, then the implementation's own probe. $cStzPlacementOS, when set, stands for the operating system (MP2 resolves
# for a declared target that way); $aStzPlacementProbes, when set, answers the probes of that target instead of this machine (both are
# declared with the registry's other globals at the top of this file: an assignment after a func would belong to that func).

func StzPlacementOS()
	if $cStzPlacementOS != "" return $cStzPlacementOS ok
	if isWindows() return "windows" ok
	if isLinux() return "linux" ok
	if isMacOSX() return "macos" ok
	return "other"

func StzImplementationAvailable(paImpl, pcLang)
	_aP_ = []
	if HasKey(paImpl, :platforms) _aP_ = paImpl[:platforms] ok
	if isList(_aP_) and len(_aP_) > 0
		if len(StzFind(StzPlacementOS(), _aP_)) = 0
			return [ 0, "exists only on " + _StzJoinComma(_aP_) + "; this is " + StzPlacementOS() ]
		ok
	ok
	# MP3: the files the catalogue says it needs (for this language) must be here -- a floor that needs a model file included
	if HasKey(paImpl, :faculty) and isString(paImpl[:faculty]) and paImpl[:faculty] != ""
		_aFiles_ = StzImplementationFilesAvailable(paImpl[:faculty], paImpl[:id], pcLang)
		if _aFiles_[1] = 0 return _aFiles_ ok
	ok
	_cFn_ = ""
	if HasKey(paImpl, :available) _cFn_ = paImpl[:available] ok
	if NOT isString(_cFn_) or _cFn_ = "" return [ 1, "" ] ok
	for _i_ = 1 to len($aStzPlacementProbes)
		if $aStzPlacementProbes[_i_][1] = _cFn_ return call $aStzPlacementProbes[_i_][2](pcLang) ok
	next
	return call _cFn_(pcLang)

func _StzJoinComma(paList)
	_c_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1 _c_ += ", " ok
		_c_ += "" + paList[_i_]
	next
	return _c_

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

	# MP0: CAPABILITY BEFORE QUALITY. The floor first: one that cannot run here (no pack, not this OS) is set aside like an uninstalled
	# model, and the court then sits without it
	_cLgR_ = ""
	if len(_aReq_[:languages]) = 1 _cLgR_ = lower(_aReq_[:languages][1]) ok
	_aFloorAv_ = StzImplementationAvailable(_aFloor_, _cLgR_)
	_bFloorAv_ = _aFloorAv_[1]
	if _bFloorAv_ = 0
		add(_aRej_, [ _aFloor_[:id], "unavailable here: " + _aFloorAv_[2] ])
		add(_aWhy_, "the floor '" + _aFloor_[:id] + "' is unavailable here (" + _aFloorAv_[2] + "): the court sits without it")
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
		_aAvC_ = StzImplementationAvailable(_a_, _cLgR_)
		if _aAvC_[1] = 0
			add(_aRej_, [ _a_[:id], "unavailable here: " + _aAvC_[2] ])
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
		if _StzAnyMeasuredIn(_cFac_, _aImpls_, _cGold_ + "/" + _cLg_) = 1
			_cGold_ = _cGold_ + "/" + _cLg_
			add(_aWhy_, "judged on the '" + _cLg_ + "' items of golden set " + _aFac_[:goldenversion] + " (the faculty is measured per language)")
		else
			add(_aWhy_, "the golden set " + _aFac_[:goldenversion] + " has no measured '" + _cLg_ + "' items: judged on the whole set")
		ok
	ok
	_aFM_ = StzMeasurementOf(_cFac_, _aFloor_[:id], _cGold_)
	if _bFloorAv_ = 0 _aFM_ = [] ok
	_aElig_ = []
	for _i_ = 1 to len(_aCand_)
		_a_ = _aCand_[_i_]
		if len(_aFM_) = 0 and _bFloorAv_ = 1
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
		if _bFloorAv_ = 1
			if _aM_[:score] <= _aFM_[:score]
				add(_aRej_, [ _a_[:id], "does not beat the floor: measured " + _aM_[:score] + " against the floor's " + _aFM_[:score] ])
				loop
			ok
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

	# 5b. THE COURT, the default gate for every faculty: the incumbent stays if it is upheld against the floor, and any other candidate
	# stays only if it is upheld against the incumbent AND the floor; a missing record is not an acquittal
	if len(_aElig_) > 0
		_cInc_ = StzCourtIncumbent(_cFac_, _cGold_)
		if _cInc_ = "" _cInc_ = _aFloor_[:id] ok
		# MP0: the court compares only implementations that can both run here: an unavailable floor or incumbent is not a bar
		_bIncAv_ = 0
		if _cInc_ = _aFloor_[:id]
			_bIncAv_ = _bFloorAv_
		else
			for _j_ = 1 to len(_aElig_)
				if _aElig_[_j_][1][:id] = _cInc_ _bIncAv_ = 1 ok
			next
		ok
		_aKept_ = []
		for _i_ = 1 to len(_aElig_)
			_cId_ = _aElig_[_i_][1][:id]
			_aOthers_ = []
			if _bFloorAv_ = 1 add(_aOthers_, _aFloor_[:id]) ok
			if _cId_ != _cInc_ and _cInc_ != _aFloor_[:id] and _bIncAv_ = 1 add(_aOthers_, _cInc_) ok
			_bOk_ = 1
			for _k_ = 1 to len(_aOthers_)
				_aV_ = StzCourtVerdictOf(_cFac_, _cGold_, _cId_, _aOthers_[_k_])
				if len(_aV_) = 0
					add(_aRej_, [ _cId_, "no court evidence against '" + _aOthers_[_k_] + "' on golden set " + _cGold_ + " (RunGoldens records it; a hand-recorded measurement does not)" ])
					_bOk_ = 0
					exit
				ok
				if _aV_[:verdict] != "upheld"
					add(_aRej_, [ _cId_, "the court REFUSED it against '" + _aOthers_[_k_] + "' on golden set " + _cGold_ + ": " + _aV_[:gains] +
						" gains and " + _aV_[:losses] + " losses among " + (_aV_[:gains] + _aV_[:losses]) + " discordant items, P = " + _aV_[:p] ])
					_bOk_ = 0
					exit
				ok
			next
			if _bOk_ = 1 add(_aKept_, _aElig_[_i_]) ok
		next
		if len(_aKept_) > 0
			if _bFloorAv_ = 0 and (_bIncAv_ = 0 or _cInc_ = _aKept_[1][1][:id])
				add(_aWhy_, "the court had no implementation to compare '" + _aKept_[1][1][:id] + "' with here: neither the floor nor an incumbent can run")
			else
				add(_aWhy_, "the court (incumbent '" + _cInc_ + "') upheld '" + _aKept_[1][1][:id] + "' on golden set " + _cGold_)
			ok
		ok
		_aElig_ = _aKept_
	ok

	if len(_aElig_) > 0
		_aBest_ = _aElig_[1]
		if len(_aFM_) > 0
			add(_aWhy_, "'" + _aBest_[1][:id] + "' (" + _aBest_[1][:kind] + ") measured " + _aBest_[2][:score] + " on golden set " + _cGold_ +
				    " (n=" + _aBest_[2][:n] + "), which beats the floor's " + _aFM_[:score] + " and the requested " + _aReq_[:quality])
		else
			add(_aWhy_, "'" + _aBest_[1][:id] + "' (" + _aBest_[1][:kind] + ") measured " + _aBest_[2][:score] + " on golden set " + _cGold_ +
				    " (n=" + _aBest_[2][:n] + "), the best measured implementation that can run here")
		ok
		for _i_ = 2 to len(_aElig_)
			add(_aRej_, [ _aElig_[_i_][1][:id], "eligible but ranked lower (" + _aElig_[_i_][2][:score] + " < " + _aBest_[2][:score] + " or a larger footprint)" ])
		next
		if _bFloorAv_ = 1
			add(_aWhy_, "the floor '" + _aFloor_[:id] + "' is kept as the fallback")
		else
			add(_aWhy_, "there is no fallback here: the floor '" + _aFloor_[:id] + "' cannot run")
		ok
		return _StzPlan(_cFac_, _aBest_[1], _aWhy_, _aRej_, _aFloor_, 0)
	ok

	# 6. fall back to the floor, SAYING SO -- or refuse, when the requirement asked not to settle for it. MP0: a floor that cannot run here
	# is no fallback; the refusal then says what is missing, implementation by implementation
	if _bFloorAv_ = 0
		_cWhat_ = "nothing can answer '" + _cFac_ + "' here: the floor " + _aFloorAv_[2]
		for _r_ = 1 to len(_aRej_)
			if _aRej_[_r_][1] != _aFloor_[:id] _cWhat_ += "; " + _aRej_[_r_][1] + ": " + _aRej_[_r_][2] ok
		next
		add(_aWhy_, _cWhat_)
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = _aWhy_, :rejected = _aRej_, :floor = _aFloor_[:id], :refusal = 1, :pinned = 0,
			 :findings = [ _StzFlowFinding("unavailable-here", _cFac_, _cWhat_) ] ]
	ok
	add(_aWhy_, "no model qualified; the floor '" + _aFloor_[:id] + "' is used")
	if _aReq_[:refusebelow] = 1
		return [ :faculty = _cFac_, :chosen = "", :kind = "", :why = _aWhy_, :rejected = _aRej_, :floor = _aFloor_[:id], :refusal = 1, :pinned = 0,
			 :findings = [ _StzFlowFinding("below-quality", _cFac_, "no implementation met the requirement and it forbids falling back to the floor") ] ]
	ok
	return _StzPlan(_cFac_, _aFloor_, _aWhy_, _aRej_, _aFloor_, 0)

# 1 when any implementation of the faculty has a measurement on that golden set (a per-language one included)
func _StzAnyMeasuredIn(pcFac, paImpls, pcGold)
	for _i_ = 1 to len(paImpls)
		if len(StzMeasurementOf(pcFac, paImpls[_i_][:id], pcGold)) > 0 return 1 ok
	next
	return 0

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
		_StzNoteFacultyCall(pcFaculty, "", _oR_)
		return _oR_
	ok
	_cErr_ = ""
	if _cErr_ = ""
		_oP_ = StzRunImplementation(pcFaculty, _aPlan_[:chosen], pInput, paParams)
		if _oP_.IsRefusal() = 0 or _aPlan_[:pinned] = 1 or _aPlan_[:kind] = "floor"
			_StzNoteFacultyCall(pcFaculty, _aPlan_[:chosen], _oP_)
			return _oP_
		ok
		_cErr_ = "the implementation's answer was refused: " + _oP_.CiteFindings()
	ok
	# the chosen model failed and nobody pinned it: the floor answers, and the provenance says it fell back -- if it can run here (MP0);
	# a floor that cannot is no fallback, and the refusal says both things
	_aAvF_ = StzImplementationAvailable(_StzImplRow(pcFaculty, _aPlan_[:floor]), _StzLangOfItem(pcFaculty, pInput))
	if _aAvF_[1] = 0
		_oR_ = new stzParcel("refusal", [])
		_oR_._MakeRefusal([ _StzFlowFinding("unavailable-here", pcFaculty, "'" + _aPlan_[:chosen] + "' failed (" + _cErr_ + ") and the floor '" +
			_aPlan_[:floor] + "' cannot run here: " + _aAvF_[2]) ])
		_StzNoteFacultyCall(pcFaculty, "", _oR_)
		return _oR_
	ok
	_oF_ = StzRunImplementation(pcFaculty, _aPlan_[:floor], pInput, paParams)
	if _oF_.IsRefusal() = 0
		_aProv_ = _oF_.Provenance()
		_aProv_[1][:detail] = "fell back from '" + _aPlan_[:chosen] + "': " + _cErr_
		_oF_._SetProvenance(_aProv_)
	ok
	_StzNoteFacultyCall(pcFaculty, _aPlan_[:floor], _oF_)
	return _oF_

# IM9a: a faculty asked by an AGENT is filed in the ledger under the agent's name -- who asked, which
# implementation answered, and whether anything ran or the memo answered (a memo hit never reaches a model's
# door, so without this line the agent's ask would leave no trace at all). Anyone else is not filed here: the
# models' own doors already record every run.
func _StzNoteFacultyCall(pcFaculty, pcImpl, poParcel)
	if $cStzCaller = ""
		return
	ok
	if NOT StzSecurityLedgerIsOpen()
		StzOpenSecurityLedger(4096)
	ok
	_cHow_ = "answered"
	if poParcel.IsRefusal() = 1
		_cHow_ = "refused"
	ok
	_cRan_ = "it ran"
	if $bStzMemoHit = 1
		_cRan_ = "from the memo, nothing ran"
	ok
	StzNoteFact("faculty.call", $cStzCaller, pcFaculty + ":" + pcImpl, _cHow_ + ", " + _cRan_)

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
	# the verdict of every item, in golden order (1 right, 0 wrong or refused): the court's evidence -- and per language, rows [ lang, verdicts ]
	_aV_ = []
	_aLgV_ = []
	_nUnavail_ = 0
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
		# MP0: an item this implementation cannot run HERE (no pack, wrong OS) is UNAVAILABLE: it is neither right nor wrong, it is not in
		# the score's n, and the court skips it (verdict -1)
		_aAv_ = StzImplementationAvailable(_StzImplRow(pcFaculty, pcImplId), _StzLangOfItem(pcFaculty, _aG_[_i_][1]))
		if _aAv_[1] = 0
			add(_aV_, -1)
			if _cLg_ != ""
				_aLg_[_k_][4] = _aLg_[_k_][4] - 1
				_q_ = 0
				for _j_ = 1 to len(_aLgV_)
					if _aLgV_[_j_][1] = _cLg_ _q_ = _j_ ok
				next
				if _q_ = 0
					add(_aLgV_, [ _cLg_, [] ])
					_q_ = len(_aLgV_)
				ok
				add(_aLgV_[_q_][2], -1)
			ok
			_nUnavail_++
			loop
		ok
		_oP_ = StzRunImplementation(pcFaculty, pcImplId, _aG_[_i_][1], paParams)
		_nV_ = 0
		if _oP_.IsRefusal() = 0
			_nValid_++
			if _k_ > 0 _aLg_[_k_][3] = _aLg_[_k_][3] + 1 ok
			_bRight_ = StzGoldenAgrees(_aFac_[:checker], _oP_.Value(), _aG_[_i_][2])
			if _bRight_ = 1
				_nOk_++
				_nV_ = 1
				if _k_ > 0 _aLg_[_k_][2] = _aLg_[_k_][2] + 1 ok
			ok
			# the truth is KNOWN here, so an answer that carried a probability goes in the calibration ledger
			if _oP_.P() >= 0
				StzRecordCalibration(pcFaculty, pcImplId, _oP_.Certainty(), _oP_.P(), _bRight_)
			ok
		ok
		add(_aV_, _nV_)
		if _cLg_ != ""
			_q_ = 0
			for _j_ = 1 to len(_aLgV_)
				if _aLgV_[_j_][1] = _cLg_ _q_ = _j_ ok
			next
			if _q_ = 0
				add(_aLgV_, [ _cLg_, [] ])
				_q_ = len(_aLgV_)
			ok
			add(_aLgV_[_q_][2], _nV_)
		ok
	next
	# the score is over the items this implementation could run here
	_nA_ = _n_ - _nUnavail_
	if _nA_ <= 0 return [ :score = 0, :n = 0, :conformance = 0, :bylang = [], :verdicts = _aV_, :bylangverdicts = _aLgV_, :unavailable = _nUnavail_ ] ok
	_aBy_ = []
	for _j_ = 1 to len(_aLg_)
		if _aLg_[_j_][4] > 0
			add(_aBy_, [ _aLg_[_j_][1], _aLg_[_j_][2] / _aLg_[_j_][4], _aLg_[_j_][4], _aLg_[_j_][3] / _aLg_[_j_][4] ])
		ok
	next
	return [ :score = _nOk_ / _nA_, :n = _nA_, :conformance = _nValid_ / _nA_, :bylang = _aBy_, :verdicts = _aV_, :bylangverdicts = _aLgV_, :unavailable = _nUnavail_ ]

func _StzForgetRows(pcFaculty, pcImplId, pcVersion)
	for _r_ = len($aStzMeasurements) to 1 step -1
		_a_ = $aStzMeasurements[_r_]
		if _a_[:faculty] = pcFaculty and _a_[:impl] = pcImplId
			if _a_[:golden] = pcVersion or left(_a_[:golden], len(pcVersion) + 1) = pcVersion + "/"
				del($aStzMeasurements, _r_)
			ok
		ok
	next

func _StzImplRow(pcFaculty, pcImplId)
	_iF_ = _StzFacultyRow(pcFaculty)
	if _iF_ = 0 return [] ok
	_aI_ = $aStzFaculties[_iF_][:impls]
	for _i_ = 1 to len(_aI_)
		if _aI_[_i_][:id] = pcImplId return _aI_[_i_] ok
	next
	return []

# the two-letter language of a golden item ("" when the faculty is not measured per language)
func _StzLangOfItem(pcFaculty, pInput)
	return StzGoldenLanguageOf(pcFaculty, pInput, [])

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
	_aScored_ = []    # [ id, verdicts, bylangverdicts ] of every implementation scored here: the court's evidence
	for _i_ = 1 to len(_aOrder_)
		_a_ = _aOrder_[_i_]
		if StzImplementationIsInstalled(_a_) = 0 loop ok
		if len(pacImplIds) > 0 and _a_[:kind] != "floor" and len(StzFind(_a_[:id], pacImplIds)) = 0 loop ok
		if _a_[:kind] = "service" loop ok        # a service is measured only when someone pins and runs it deliberately
		_aS_ = StzScoreImplementation(pcFaculty, _a_[:id], paParams)
		add(_aScored_, [ _a_[:id], _aS_[:verdicts], _aS_[:bylangverdicts] ])
		# a re-measurement REPLACES this implementation's rows on this golden version, its per-language ones included: a language it can
		# no longer run here must not keep an old row (MP0)
		_StzForgetRows(pcFaculty, _a_[:id], _aFac_[:goldenversion])
		if _aS_[:n] = 0 loop ok    # it could run none of the items here: no measurement, rather than a false zero
		_cNoteM_ = ""
		if _aS_[:unavailable] > 0 _cNoteM_ = "measured on " + StzPlacementOS() + "; " + _aS_[:unavailable] + " item(s) unavailable here, not counted" ok
		StzRecordMeasurement(pcFaculty, _a_[:id], _aFac_[:goldenversion], _aS_[:score], _aS_[:n], _aS_[:conformance], _cNoteM_)
		add(_aRows_, StzMeasurementOf(pcFaculty, _a_[:id], _aFac_[:goldenversion]))
		# and one row per language, filed under "<version>/<lang>" (the rows returned stay the whole-set ones)
		_aBy_ = _aS_[:bylang]
		for _j_ = 1 to len(_aBy_)
			StzRecordMeasurement(pcFaculty, _a_[:id], _aFac_[:goldenversion] + "/" + _aBy_[_j_][1], _aBy_[_j_][2], _aBy_[_j_][3], _aBy_[_j_][4], "")
		next
	next
	# THE COURT'S EVIDENCE, made where the measurement is made: every ordered pair of the implementations scored on the same items
	_StzRecordCourtFromScores(pcFaculty, _aFac_[:goldenversion], _aScored_)
	return _aRows_

# The court's evidence from verdict lists made elsewhere: paScored is [ [ id, verdicts, bylangverdicts ] ... ], every verdict list over the SAME
# items in the same order (1 right, 0 wrong or refused); bylangverdicts is [ [ lang, verdicts ] ... ] or []. A guard that scores implementations
# by hand calls this, so its measurement carries the evidence the default gate asks for.
func StzRecordCourtFromVerdicts(pcFaculty, pcGolden, paScored)
	_StzRecordCourtFromScores(pcFaculty, pcGolden, paScored)
	return len(paScored) * (len(paScored) - 1)

func _StzRecordCourtFromScores(pcFaculty, pcGolden, paScored)
	for _a_ = 1 to len(paScored)
		for _b_ = 1 to len(paScored)
			if _a_ = _b_ loop ok
			_aC_ = StzCourtCounts(paScored[_a_][2], paScored[_b_][2])
			StzRecordCourtVerdict(pcFaculty, pcGolden, paScored[_a_][1], paScored[_b_][1], _aC_[1], _aC_[2], "RunGoldens")
			# per language, on the items of that language both were scored on
			_aLa_ = paScored[_a_][3]
			_aLb_ = paScored[_b_][3]
			for _i_ = 1 to len(_aLa_)
				for _j_ = 1 to len(_aLb_)
					if _aLa_[_i_][1] = _aLb_[_j_][1]
						_aC_ = StzCourtCounts(_aLa_[_i_][2], _aLb_[_j_][2])
						StzRecordCourtVerdict(pcFaculty, pcGolden + "/" + _aLa_[_i_][1], paScored[_a_][1], paScored[_b_][1], _aC_[1], _aC_[2], "RunGoldens")
					ok
				next
			next
		next
	next

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

	# Measures a faculty on its golden set and records the scores.
	#
	#   pcFaculty  the name of the faculty to measure
	#   returns    the rows recorded
	#   see        RunGoldensFor, Measurements
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
