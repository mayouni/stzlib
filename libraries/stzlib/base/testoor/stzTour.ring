# Testoor -- the reader. A test file is a TOUR read as DATA, and the reader
# rewrites nothing: the framework fits the files, never the files the
# framework. TR0 of SOFTANZA_TESTOOR_PLAN.md (COMPASS-TESTOOR-01).
#
# THE TEN WORDS, as far as TR0 reaches. Tour, Stop, Traveller, Route, Map,
# Clock, Weather, Logbook, Souvenir, Court -- each one class or method, each
# naming one thing a tester does. This file is three of them:
#
#   Tour     one test file, read as data. Tour(path) is the record,
#            TourQ(path) chains over it.
#   Stop     a place the traveller stops and looks -- a Scenario(), a scene
#            banner, a sec() section, a Zin STEP. What is seen there are its
#            CLAIMS (a Then(), a chk(), a `#--> value`). A stop has five
#            states and no sixth -- kept, diverged, unreached, unjudged,
#            unperceived -- and the READER assigns none of them: a read is
#            not a run.
#   Logbook  the read of many tours. JSON on a pipe, prose on a terminal,
#            from one read; what was skipped is named.
#
# THE RECORD OF ONE TOUR (what Tour(path) answers):
#   :file      the path as given
#   :readable  1, or 0 with :why saying what stopped the read
#   :dialect   narrated | chk | gate | promises | markers | zst:KIND | unknown
#   :helpers   the assertion helpers the file DEFINES, found by what their
#              body does (prints a verdict marker, or raises on a failure)
#   :lines     line count
#   :ending    finished-timed (pf()) | summary (Summary()) | own-total
#              (prints TOTAL:) | plain
#   :asserts   1 when the file carries at least one claim, else 0 -- a file
#              with 0 "runs, asserts nothing", which is a state, not a fault
#   :promises  how many `#-->` promises it carries, trailing or next-line
#   :markers   how many printed [ok] / [PASS] / [FAIL] lines, any case --
#              a planted lower-case [ok] counts, where _sweepall.sh did not
#   :stops     [ [ :title, :line, :claims = [ [ :line, :kind, :claim, :want ] ] ] ]
#              :kind is sees (a helper call), promise, or marker (a hand-
#              printed verdict at top level)
#   :routes    [ [ :item, :stop, :line ] ] -- a gate's discharges("GG6")
#              naming the plan item a section walks (ruling 8: routes before
#              roads)
#
# THE DIALECTS (ruling 4: faces of one grammar; read, never edited):
#   narrated   Given/When/Then from base/test/_narrated.ring -- Scenario() is
#              a stop, Then() a claim
#   chk        a self-contained helper under any name (chk, Chk, Assert ...),
#              recognised by its BODY; `? "-- Scene 1: ..."` banners are stops
#   gate       sec() / chk() / chkeq(), with discharges("GG6") as routes
#   promises   `? expr  #--> value`, on the same line or the next
#   markers    no helper at all, but a printed [ok]/[PASS]/[FAIL] -- a hand
#              verdict, counted
#   zst:KIND   Zin's DEFINE NARRATED_TEST / UNIT_TEST / INTEGRATION_TEST /
#              INTEGRATION_SUITE / SCENARIO_SUITE / LOAD_TEST / SIMULATION_TEST
#   unknown    named in the logbook, and left exactly as it was
#
# Claims are gathered from EVERY form the file uses, whatever its dominant
# dialect: a chk file that also makes promises has both counted.
#
# MEASURED, TR0 probe 2026-10-05: 13 files including the 18,800-line
# graphics gate read in 0.20 s, standalone Ring. The reader walks each line
# once with substr() on the LINE, never on the file -- the O(buffer) trap of
# CLAUDE.md does not reach it.
#
# Locals are _underscored_: Ring assigns to an existing GLOBAL when a function
# has no local of that name, and a test file loading this beside its own `n`
# or `i` would have its loop counter reset by the reader.

#--- Tour -------------------------------------------------------------------

func Tour(pcPath)
	return _TourRead("" + pcPath)

func TourQ(pcPath)
	return new stzTour(pcPath)

func StzLogbookQ()
	return new stzLogbook()

#--- the read ---------------------------------------------------------------

func _TourRead(pcPath)
	_aRec_ = [ :file = pcPath, :readable = 1, :why = "", :dialect = "unknown",
	           :helpers = [], :lines = 0, :ending = "plain", :asserts = 0,
	           :promises = 0, :markers = 0, :stops = [], :routes = [] ]
	_cSrc_ = ""
	try
		_cSrc_ = read(pcPath)
	catch
		_aRec_[:readable] = 0
		_aRec_[:why] = "cannot read: " + cCatchError
		return _aRec_
	done
	_cSrc_ = substr(_cSrc_, char(13), "")
	_acL_ = str2list(_cSrc_)
	_nL_ = len(_acL_)
	_aRec_[:lines] = _nL_
	if lower(right(pcPath, 4)) = ".zst"
		return _TourReadZst(_aRec_, _acL_)
	ok

	# ---- pass 1: what the file DEFINES and CALLS decides its face ----
	_bSec_ = 0  _bChkEq_ = 0  _bChk_ = 0  _bScenario_ = 0  _bNarr_ = 0
	_nProm_ = 0  _bPf_ = 0  _bSummary_ = 0  _bTotal_ = 0  _nMark_ = 0
	_aHelpers_ = []
	for _i_ = 1 to _nL_
		_t_ = trim(_acL_[_i_])
		_lt_ = lower(_t_)
		if substr(_lt_, "func ") = 1 and _TourIsFuncBoundary(_lt_)
			_cName_ = _TourFuncName(_lt_)
			if _cName_ = "sec"    _bSec_ = 1    ok
			if _cName_ = "chkeq"  _bChkEq_ = 1  ok
			if _cName_ = "chk"    _bChk_ = 1    ok
			if _TourBodyIsHelper(_acL_, _i_ + 1)  _aHelpers_ + _cName_  ok
		but substr(_lt_, "load ") = 1 and substr(_lt_, "_narrated.ring") > 0
			_bNarr_ = 1
		but substr(_lt_, "scenario(") = 1
			_bScenario_ = 1
		but _lt_ = "pf()"
			_bPf_ = 1
		but _lt_ = "summary()"
			_bSummary_ = 1
		ok
		if substr(_lt_, "?") = 1 and substr(_lt_, "#-->") > 0  _nProm_++  ok
		if substr(_lt_, "#-->") = 1  _nProm_++  ok
		if substr(_lt_, "?") = 1 and substr(_lt_, "total:") > 0  _bTotal_ = 1  ok
		if _TourIsVerdictLine(_lt_)  _nMark_++  ok
	next
	_aRec_[:promises] = _nProm_
	_aRec_[:markers] = _nMark_
	_aRec_[:helpers] = _aHelpers_
	if _bSec_ or _bChkEq_
		_aRec_[:dialect] = "gate"
	but _bChk_ or len(_aHelpers_) > 0
		_aRec_[:dialect] = "chk"
	but _bScenario_ or _bNarr_
		_aRec_[:dialect] = "narrated"
	but _nProm_ > 0
		_aRec_[:dialect] = "promises"
	but _nMark_ > 0
		_aRec_[:dialect] = "markers"
	else
		_aRec_[:dialect] = "unknown"
	ok
	if _bPf_
		_aRec_[:ending] = "finished-timed"
	but _bSummary_
		_aRec_[:ending] = "summary"
	but _bTotal_
		_aRec_[:ending] = "own-total"
	ok

	# ---- pass 2: stops, and the claims made at each ----
	#
	# Claims are read at the top level AND inside the file's own functions --
	# world_contract_narrated.ring makes every claim inside Part1_..Part5_,
	# called from Main(). What is NOT read is the body of a HELPER (chk, sec,
	# Assert ...): the "[OK]" it prints is the verdict's shape, not a claim of
	# the file. A class body is not read either.
	_cDia_ = _aRec_[:dialect]
	_bBanners_ = (_cDia_ = "chk" or _cDia_ = "markers" or _cDia_ = "promises")
	_acMute_ = [ "sec", "chk", "chkeq", "discharges", "class" ]
	_nH_ = len(_aHelpers_)
	for _k_ = 1 to _nH_
		_acMute_ + _aHelpers_[_k_]
	next
	_aStops_ = []
	_aBy_ = []            # claims of stop k, kept beside until the end
	_aRoutes_ = []
	_nCur_ = 0
	_cIn_ = ""            # the function whose body this line is in
	for _i_ = 1 to _nL_
		_t_ = trim(_acL_[_i_])
		_lt_ = lower(_t_)
		if _TourIsFuncBoundary(_lt_)
			if substr(_lt_, "class ") = 1
				_cIn_ = "class"
			else
				_cIn_ = _TourFuncName(_lt_)
			ok
			loop
		ok
		if _cIn_ != "" and ring_find(_acMute_, _cIn_) > 0  loop  ok
		# a stop
		_bStop_ = 0
		if substr(_lt_, "scenario(") = 1 or substr(_lt_, "sec(") = 1
			_bStop_ = 1
		but _bBanners_ and substr(_lt_, "?") = 1 and _TourIsBanner(_lt_)
			_bStop_ = 1
		ok
		if _bStop_
			_aStops_ + [ :title = _TourFirstString(_t_), :line = _i_, :claims = [] ]
			_aBy_ + []
			_nCur_ = len(_aStops_)
			loop
		ok
		# a route
		if substr(_lt_, "discharges(") = 1
			_cAt_ = ""
			if _nCur_ > 0  _cAt_ = _aStops_[_nCur_][:title]  ok
			_aRoutes_ + [ :item = _TourFirstString(_t_), :stop = _cAt_, :line = _i_ ]
			loop
		ok
		# a claim, in any of the forms the file uses
		_aC_ = []
		if substr(_lt_, "then(") = 1 or substr(_lt_, "chk(") = 1 or
		   substr(_lt_, "chkeq(") = 1 or _TourCallsHelper(_lt_, _aHelpers_)
			_cClaim_ = _TourFirstString(_t_)
			if _cClaim_ = "" and _i_ < _nL_  _cClaim_ = _TourFirstString(trim(_acL_[_i_ + 1]))  ok
			_aC_ = [ :line = _i_, :kind = "sees", :claim = _cClaim_, :want = "" ]
		but substr(_lt_, "?") = 1 and substr(_lt_, "#-->") > 0
			_nAt_ = substr(_t_, "#-->")
			_aC_ = [ :line = _i_, :kind = "promise",
			         :claim = trim(substr(_t_, 2, _nAt_ - 2)),
			         :want = trim(substr(_t_, _nAt_ + 4, len(_t_) - _nAt_ - 3)) ]
		but substr(_lt_, "?") = 1
			_j_ = _i_ + 1
			while _j_ <= _nL_ and trim(_acL_[_j_]) = ""  _j_++  end
			if _j_ <= _nL_ and substr(trim(_acL_[_j_]), "#-->") = 1
				_cW_ = trim(_acL_[_j_])
				_aC_ = [ :line = _i_, :kind = "promise",
				         :claim = trim(substr(_t_, 2, len(_t_) - 1)),
				         :want = trim(substr(_cW_, 5, len(_cW_) - 4)) ]
			but _TourIsVerdictLine(_lt_)
				_aC_ = [ :line = _i_, :kind = "marker", :claim = _TourFirstString(_t_), :want = "" ]
			ok
		ok
		if len(_aC_) = 0  loop  ok
		if _nCur_ = 0
			_aStops_ + [ :title = "(the file)", :line = 1, :claims = [] ]
			_aBy_ + []
			_nCur_ = 1
		ok
		_aBy_[_nCur_] + _aC_
	next
	_nS_ = len(_aStops_)
	_nClaims_ = 0
	for _k_ = 1 to _nS_
		_aStops_[_k_][:claims] = _aBy_[_k_]
		_nClaims_ += len(_aBy_[_k_])
	next
	if _nS_ = 0  _aStops_ + [ :title = "(the file)", :line = 1, :claims = [] ]  ok
	_aRec_[:stops] = _aStops_
	_aRec_[:routes] = _aRoutes_
	if _nClaims_ > 0  _aRec_[:asserts] = 1  ok
	return _aRec_

# Zin's .zst: a DEFINE opens a tour kind; STEP / TEST / SCENARIO are stops;
# EXPECT* and ASSERT are claims. Only the kinds the Zst spec declares are a
# dialect; anything else is unknown, named.
func _TourReadZst(paRec, pacL)
	_aRec_ = paRec
	_nL_ = len(pacL)
	_acKinds_ = [ "NARRATED_TEST", "UNIT_TEST", "INTEGRATION_TEST",
	              "INTEGRATION_SUITE", "SCENARIO_SUITE", "LOAD_TEST",
	              "SIMULATION_TEST" ]
	_aStops_ = []
	_aBy_ = []
	_nCur_ = 0
	_cKind_ = ""
	for _i_ = 1 to _nL_
		_t_ = trim(pacL[_i_])
		_aW_ = _TourWords(_t_)
		if len(_aW_) = 0  loop  ok
		if _aW_[1] = "DEFINE" and len(_aW_) >= 3
			if _cKind_ = ""  _cKind_ = _aW_[2]  ok
			# a single test IS a stop (its ASSERTs are the claims); a suite or a
			# narrated test is the container of its STEPs / TESTs / SCENARIOs
			if _aW_[2] = "UNIT_TEST" or _aW_[2] = "INTEGRATION_TEST" or
			   _aW_[2] = "LOAD_TEST" or _aW_[2] = "SIMULATION_TEST"
				_aStops_ + [ :title = _aW_[2] + " " + _aW_[3], :line = _i_, :claims = [] ]
				_aBy_ + []
				_nCur_ = len(_aStops_)
			ok
		but (_aW_[1] = "STEP" or _aW_[1] = "TEST" or _aW_[1] = "SCENARIO") and len(_aW_) >= 2
			_aStops_ + [ :title = _aW_[1] + " " + _aW_[2], :line = _i_, :claims = [] ]
			_aBy_ + []
			_nCur_ = len(_aStops_)
		but substr(_aW_[1], "EXPECT") = 1 or _aW_[1] = "ASSERT"
			if _nCur_ = 0
				_aStops_ + [ :title = "(the file)", :line = 1, :claims = [] ]
				_aBy_ + []
				_nCur_ = 1
			ok
			_aBy_[_nCur_] + [ :line = _i_, :kind = "sees", :claim = _t_, :want = "" ]
		ok
	next
	_nS_ = len(_aStops_)
	_nClaims_ = 0
	for _k_ = 1 to _nS_
		_aStops_[_k_][:claims] = _aBy_[_k_]
		_nClaims_ += len(_aBy_[_k_])
	next
	if _nS_ = 0  _aStops_ + [ :title = "(the file)", :line = 1, :claims = [] ]  ok
	if _cKind_ = "" or ring_find(_acKinds_, _cKind_) = 0
		_aRec_[:dialect] = "unknown"
		if _cKind_ = ""
			_aRec_[:why] = "a .zst file with no DEFINE"
		else
			_aRec_[:why] = "a .zst DEFINE kind the Zst spec does not declare: " + _cKind_
		ok
	else
		_aRec_[:dialect] = "zst:" + _cKind_
	ok
	_aRec_[:stops] = _aStops_
	if _nClaims_ > 0  _aRec_[:asserts] = 1  ok
	return _aRec_

#--- the small readers of a line -------------------------------------------

# A line that opens a function or a class body. `func x { ... }` on one line
# is an ANONYMOUS function passed as a value (refine/gate_deepening_narrated
# .ring hands one to a rule) and opens nothing: the file's own code goes on
# below it.
func _TourIsFuncBoundary(pcLowerLine)
	if substr(pcLowerLine, "class ") = 1  return 1  ok
	if substr(pcLowerLine, "func ") != 1  return 0  ok
	if substr(pcLowerLine, "{") > 0  return 0  ok
	return 1

# "func chk cWhat, bCond" / "func chk(cWhat, bCond)" / "func Chk(cLabel, bCond)"
func _TourFuncName(pcLowerLine)
	_c_ = trim(substr(pcLowerLine, 6, len(pcLowerLine) - 5))
	_n_ = len(_c_)
	_cOut_ = ""
	for _k_ = 1 to _n_
		_ch_ = _c_[_k_]
		if _ch_ = "(" or _ch_ = " " or _ch_ = char(9)  exit  ok
		_cOut_ += _ch_
	next
	return _cOut_

# A helper is known by its body: before the next func, it prints a verdict
# marker, or it raises with "fail" in the message (world_contract's Assert).
func _TourBodyIsHelper(pacL, pnFrom)
	_n_ = len(pacL)
	for _k_ = pnFrom to _n_
		_lt_ = lower(trim(pacL[_k_]))
		if _TourIsFuncBoundary(_lt_)  return 0  ok
		if _TourIsVerdictLine(_lt_)  return 1  ok
		if substr(_lt_, "raise(") > 0 and substr(_lt_, "fail") > 0  return 1  ok
	next
	return 0

# a line that PRINTS a verdict marker -- [ok] [pass] [fail], any case. The
# print may sit after an `if` on the same line (`if bCond ? "[OK] " + c`),
# so the test is "contains a print and a marker", never "opens with ?". A
# comment is not a print.
func _TourIsVerdictLine(pcLowerLine)
	if substr(pcLowerLine, "#") = 1  return 0  ok
	if substr(pcLowerLine, "?") = 0 and substr(pcLowerLine, "see ") = 0  return 0  ok
	if substr(pcLowerLine, "[ok]") > 0 or substr(pcLowerLine, "[pass]") > 0 or
	   substr(pcLowerLine, "[fail]") > 0
		return 1
	ok
	return 0

func _TourCallsHelper(pcLowerLine, pacHelpers)
	_n_ = len(pacHelpers)
	for _k_ = 1 to _n_
		if substr(pcLowerLine, pacHelpers[_k_] + "(") = 1  return 1  ok
	next
	return 0

# the first quoted string on a line, either quote style; "" when none
func _TourFirstString(pcLine)
	_n_ = len(pcLine)
	_nOpen_ = 0
	_cQ_ = ""
	for _k_ = 1 to _n_
		if pcLine[_k_] = '"' or pcLine[_k_] = "'"
			_cQ_ = pcLine[_k_]
			_nOpen_ = _k_
			exit
		ok
	next
	if _nOpen_ = 0  return ""  ok
	for _k_ = _nOpen_ + 1 to _n_
		if pcLine[_k_] = _cQ_
			return substr(pcLine, _nOpen_ + 1, _k_ - _nOpen_ - 1)
		ok
	next
	return substr(pcLine, _nOpen_ + 1, _n_ - _nOpen_)

# a printed line that names a scene, a section or a part is a stop
func _TourIsBanner(pcLowerLine)
	_c_ = trim(_TourFirstString(pcLowerLine))
	if _c_ = ""  return 0  ok
	if substr(_c_, "scene") > 0 or substr(_c_, "section") > 0 or substr(_c_, "part ") = 1
		return 1
	ok
	if substr(_c_, "--") = 1 or substr(_c_, "==") = 1 or substr(_c_, "##") = 1
		return 1
	ok
	return 0

func _TourWords(pcLine)
	_aW_ = []
	_c_ = ""
	_n_ = len(pcLine)
	for _k_ = 1 to _n_
		if pcLine[_k_] = " " or pcLine[_k_] = char(9)
			if _c_ != ""  _aW_ + _c_  _c_ = ""  ok
		else
			_c_ += pcLine[_k_]
		ok
	next
	if _c_ != ""  _aW_ + _c_  ok
	return _aW_

#--- the logbook faces of one record ---------------------------------------

func _TourClaimsOf(paRec)
	_aOut_ = []
	_nS_ = len(paRec[:stops])
	for _s_ = 1 to _nS_
		_nC_ = len(paRec[:stops][_s_][:claims])
		for _c_ = 1 to _nC_
			_aOut_ + paRec[:stops][_s_][:claims][_c_]
		next
	next
	return _aOut_

func _TourProse(paRec)
	if paRec[:readable] = 0
		return paRec[:file] + " : UNREADABLE -- " + paRec[:why]
	ok
	_c_ = paRec[:file] + " : " + paRec[:dialect] + ", " + len(paRec[:stops]) +
	      " stops, " + len(_TourClaimsOf(paRec)) + " claims"
	if paRec[:promises] > 0  _c_ += " (" + paRec[:promises] + " promises)"  ok
	_c_ += ", ends " + paRec[:ending]
	_nH_ = len(paRec[:helpers])
	if _nH_ > 0
		_c_ += ", helper "
		for _k_ = 1 to _nH_
			if _k_ > 1  _c_ += "/"  ok
			_c_ += paRec[:helpers][_k_]
		next
	ok
	if len(paRec[:routes]) > 0  _c_ += ", " + len(paRec[:routes]) + " routes"  ok
	if paRec[:asserts] = 0  _c_ += " -- RUNS, ASSERTS NOTHING"  ok
	if paRec[:dialect] = "unknown"
		_c_ += " -- UNKNOWN DIALECT, named, not edited"
		if paRec[:why] != ""  _c_ += " (" + paRec[:why] + ")"  ok
	ok
	return _c_

# JSON by hand. Ring has NO escapes in its string literals (measured
# 2026-10-05: len("\\") is 2), so "\" below is one backslash and "\\" two.
func _TourJsonStr(px)
	_c_ = "" + px
	_c_ = substr(_c_, "\", "\\")
	_c_ = substr(_c_, '"', '\"')
	_c_ = substr(_c_, char(9), "\t")
	_c_ = substr(_c_, char(10), "\n")
	_c_ = substr(_c_, char(13), "\r")
	return '"' + _c_ + '"'

func _TourJson(paRec)
	_c_ = '{"file":' + _TourJsonStr(paRec[:file]) +
	      ',"readable":' + paRec[:readable] +
	      ',"why":' + _TourJsonStr(paRec[:why]) +
	      ',"dialect":' + _TourJsonStr(paRec[:dialect]) +
	      ',"helpers":['
	_nH_ = len(paRec[:helpers])
	for _k_ = 1 to _nH_
		if _k_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr(paRec[:helpers][_k_])
	next
	_c_ += '],"lines":' + paRec[:lines] +
	       ',"ending":' + _TourJsonStr(paRec[:ending]) +
	       ',"asserts":' + paRec[:asserts] +
	       ',"promises":' + paRec[:promises] +
	       ',"markers":' + paRec[:markers] +
	       ',"stops":['
	_nS_ = len(paRec[:stops])
	for _s_ = 1 to _nS_
		if _s_ > 1  _c_ += ","  ok
		_aS_ = paRec[:stops][_s_]
		_c_ += '{"title":' + _TourJsonStr(_aS_[:title]) + ',"line":' + _aS_[:line] + ',"claims":['
		_nC_ = len(_aS_[:claims])
		for _k_ = 1 to _nC_
			if _k_ > 1  _c_ += ","  ok
			_aC_ = _aS_[:claims][_k_]
			_c_ += '{"line":' + _aC_[:line] + ',"kind":' + _TourJsonStr(_aC_[:kind]) +
			       ',"claim":' + _TourJsonStr(_aC_[:claim])
			if _aC_[:want] != ""  _c_ += ',"want":' + _TourJsonStr(_aC_[:want])  ok
			_c_ += "}"
		next
		_c_ += "]}"
	next
	_c_ += '],"routes":['
	_nR_ = len(paRec[:routes])
	for _k_ = 1 to _nR_
		if _k_ > 1  _c_ += ","  ok
		_c_ += '{"item":' + _TourJsonStr(paRec[:routes][_k_][:item]) +
		       ',"stop":' + _TourJsonStr(paRec[:routes][_k_][:stop]) +
		       ',"line":' + paRec[:routes][_k_][:line] + "}"
	next
	_c_ += "]}"
	return _c_

#--- walking a folder -------------------------------------------------------

# every .ring and .zst file under pcDir, recursively, sorted, whose name ends
# with pcSuffix ("" for all); names opening with "_" are helpers and scratch,
# skipped and NAMED in the second list. Answers [ files, skipped ].
func _TourFilesUnder(pcDir, pcSuffix)
	_aFiles_ = []
	_aSkipped_ = []
	_aDirs_ = [ "" + pcDir ]
	_cSuf_ = lower("" + pcSuffix)
	while len(_aDirs_) > 0
		_cD_ = _aDirs_[1]
		del(_aDirs_, 1)
		_aE_ = []
		try
			_aE_ = dir(_cD_)
		catch
			_aSkipped_ + (_cD_ + " (cannot list)")
			loop
		done
		_aNames_ = []
		_nE_ = len(_aE_)
		for _k_ = 1 to _nE_
			_aNames_ + _aE_[_k_][1]
		next
		_aNames_ = sort(_aNames_)
		_nN_ = len(_aNames_)
		for _k_ = 1 to _nN_
			_cN_ = _aNames_[_k_]
			_bDir_ = 0
			for _m_ = 1 to _nE_
				if _aE_[_m_][1] = _cN_  _bDir_ = _aE_[_m_][2]  exit  ok
			next
			_cP_ = _cD_ + "/" + _cN_
			if _bDir_
				if _cN_ = "." or _cN_ = ".."  loop  ok
				if left(_cN_, 1) = "_" or left(_cN_, 1) = "."  _aSkipped_ + _cP_  loop  ok
				_aDirs_ + _cP_
				loop
			ok
			_cLow_ = lower(_cN_)
			if right(_cLow_, 5) != ".ring" and right(_cLow_, 4) != ".zst"  loop  ok
			if left(_cN_, 1) = "_"  _aSkipped_ + _cP_  loop  ok
			if _cSuf_ != "" and right(_cLow_, len(_cSuf_)) != _cSuf_  loop  ok
			_aFiles_ + _cP_
		next
	end
	return [ _aFiles_, _aSkipped_ ]

#--- stzTour ----------------------------------------------------------------

class stzTour from stzObject

	@aRec = []

	def init(pcPath)
		@aRec = _TourRead("" + pcPath)

	def Record()
		return @aRec

	def File()
		return @aRec[:file]

	def Readable()
		return @aRec[:readable] = 1

	def Why()
		return @aRec[:why]

	def Dialect()
		return @aRec[:dialect]

	def Helpers()
		return @aRec[:helpers]

	def Lines()
		return @aRec[:lines]

	def Ending()
		return @aRec[:ending]

	def Asserts()
		return @aRec[:asserts] = 1

	def Promises()
		return @aRec[:promises]

	def Markers()
		return @aRec[:markers]

	def Stops()
		return @aRec[:stops]

	def Claims()
		return _TourClaimsOf(@aRec)

	def Routes()
		return @aRec[:routes]

	def Json()
		return _TourJson(@aRec)

	def Prose()
		return _TourProse(@aRec)

#--- stzLogbook -------------------------------------------------------------

class stzLogbook from stzObject

	@aRecords = []
	@acSkipped = []
	@cRoot = ""

	def init()
		@aRecords = []
		@acSkipped = []

	def Read(pcPath)
		@aRecords + _TourRead("" + pcPath)
		return This

	# every test file under a folder, recursively; "" reads them all
	def ReadTree(pcDir, pcSuffix)
		@cRoot = "" + pcDir
		_aTwo_ = _TourFilesUnder(pcDir, pcSuffix)
		_aF_ = _aTwo_[1]
		_nF_ = ring_len(_aF_)
		for _k_ = 1 to _nF_
			@aRecords + _TourRead(_aF_[_k_])
		next
		_nS_ = ring_len(_aTwo_[2])
		for _k_ = 1 to _nS_
			@acSkipped + _aTwo_[2][_k_]
		next
		return This

	def Records()
		return @aRecords

	def Count()
		return ring_len(@aRecords)

	def Skipped()
		return @acSkipped

	def Unreadable()
		return This._Where(:readable, 0)

	def Unknown()
		return This._Where(:dialect, "unknown")

	def AssertingNothing()
		_aOut_ = []
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			if @aRecords[_k_][:readable] = 1 and @aRecords[_k_][:asserts] = 0
				_aOut_ + @aRecords[_k_]
			ok
		next
		return _aOut_

	def _Where(pcKey, pValue)
		_aOut_ = []
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			if @aRecords[_k_][pcKey] = pValue  _aOut_ + @aRecords[_k_]  ok
		next
		return _aOut_

	# dialect -> how many tours wear it
	def ByDialect()
		_aOut_ = []
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			_cD_ = @aRecords[_k_][:dialect]
			_nAt_ = 0
			_nO_ = ring_len(_aOut_)
			for _m_ = 1 to _nO_
				if _aOut_[_m_][1] = _cD_  _nAt_ = _m_  exit  ok
			next
			if _nAt_ = 0
				_aOut_ + [ _cD_, 1 ]
			else
				_aOut_[_nAt_][2]++
			ok
		next
		return _aOut_

	def ClaimsCount()
		_n_ = 0
		_nR_ = ring_len(@aRecords)
		for _k_ = 1 to _nR_
			_n_ += ring_len(_TourClaimsOf(@aRecords[_k_]))
		next
		return _n_

	def ProseOf(pnI)
		return _TourProse(@aRecords[pnI])

	# one line per tour, then the counts -- what a terminal shows
	def Prose()
		_c_ = ""
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			_c_ += _TourProse(@aRecords[_k_]) + char(10)
		next
		_c_ += This.Summary()
		return _c_

	def Summary()
		_c_ = "read " + ring_len(@aRecords) + " tours, " + This.ClaimsCount() + " claims" + char(10)
		_aD_ = This.ByDialect()
		_nD_ = ring_len(_aD_)
		for _k_ = 1 to _nD_
			_c_ += "  " + _aD_[_k_][1] + ": " + _aD_[_k_][2] + char(10)
		next
		_c_ += "  unreadable: " + ring_len(This.Unreadable()) +
		       "  unknown: " + ring_len(This.Unknown()) +
		       "  asserting nothing: " + ring_len(This.AssertingNothing()) + char(10)
		_nS_ = ring_len(@acSkipped)
		_c_ += "  skipped by name: " + _nS_
		for _k_ = 1 to _nS_
			_c_ += char(10) + "    " + @acSkipped[_k_]
		next
		return _c_

	# the same read, as one JSON object -- what a pipe carries
	def Json()
		_c_ = '{"testoor":"logbook","kind":"read","root":' + _TourJsonStr(@cRoot) +
		      ',"read":' + ring_len(@aRecords) + ',"claims":' + This.ClaimsCount() +
		      ',"skipped":['
		_nS_ = ring_len(@acSkipped)
		for _k_ = 1 to _nS_
			if _k_ > 1  _c_ += ","  ok
			_c_ += _TourJsonStr(@acSkipped[_k_])
		next
		_c_ += '],"tours":['
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += _TourJson(@aRecords[_k_])
		next
		_c_ += "]}"
		return _c_
