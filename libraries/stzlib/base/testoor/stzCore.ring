# Testoor -- the CORE GLUE. Phase P3.1 of SOFTANZA_TESTOOR_ROADMAP.md, TESTOOR_ZIG_CORE.md section 5.
#
# The judge is written in Zig (engine/src/testoor_*.zig, the stz_testoor library). This file is
# the Ring side of that seam: it turns a tour record, the lines a child printed and the walk's
# facts into the request the engine reads, and turns the engine's answer back into the record
# the rest of Testoor already consumes. NOTHING ELSE CHANGES: stzTraveller.ring keeps its
# signatures, and TestoorVerdict is the one function that asks the core first.
#
# THE RING REFERENCE STAYS. It is what the goldens were made from and what the core is held
# to. TestoorCore("ring") makes TestoorVerdict use it (and so does TESTOOR_CORE=ring in the
# environment), TestoorCore("engine") the core, TestoorCore("auto") the core when its library
# is loaded. When the library is absent -- Ring 1.27 without the engine built, or any machine
# that did not build stz_testoor -- the reference judges, and the verdict is the same bytes.
#
# A verdict the core cannot give (a request it cannot read, an answer the library's JSON reader
# refuses -- a tour that printed a raw control byte) falls back to the reference for that tour.
#
# Locals are _underscored_; the one mutable global is $cTestoorCore.

$cTestoorCore = "auto"

# choose who judges: "engine", "ring" or "auto"; answers who WILL judge
func TestoorCore(pcWhich)
	$cTestoorCore = lower("" + pcWhich)
	# the world of a tour (stzClock.ring) lives in ONE place, the core's or the reference's:
	# choosing who runs it forgets what was declared, so nothing is left behind in the other
	_TestoorWorldForget()
	return TestoorCoreIs()

# "engine" when the verdict is taken in the Zig core, "ring" when the Ring reference takes it
func TestoorCoreIs()
	if $cTestoorCore = "ring"  return "ring"  ok
	if NOT $bStzTestoorCore  return "ring"  ok
	if $cTestoorCore = "auto" and sysget("TESTOOR_CORE") = "ring"  return "ring"  ok
	return "engine"

# the tour record as the engine reads it (the golden record.json shape)
func _CoreRecordJson(paRec)
	_c_ = '{"file":' + _TourJsonStr(paRec[:file]) + ',"dialect":' + _TourJsonStr(paRec[:dialect]) +
	      ',"asserts":' + paRec[:asserts] + ',"stops":['
	_nS_ = len(paRec[:stops])
	for _s_ = 1 to _nS_
		if _s_ > 1  _c_ += ","  ok
		_c_ += '{"title":' + _TourJsonStr(paRec[:stops][_s_][:title]) + ',"line":' + paRec[:stops][_s_][:line] + ',"claims":['
		_nC_ = len(paRec[:stops][_s_][:claims])
		for _k_ = 1 to _nC_
			if _k_ > 1  _c_ += ","  ok
			_aK_ = paRec[:stops][_s_][:claims][_k_]
			_c_ += '{"line":' + _aK_[:line] + ',"kind":' + _TourJsonStr(_aK_[:kind]) +
			       ',"claim":' + _TourJsonStr(_aK_[:claim]) + ',"want":' + _TourJsonStr(_aK_[:want]) + "}"
		next
		_c_ += "]}"
	next
	_c_ += '],"routes":['
	_nR_ = len(paRec[:routes])
	for _r_ = 1 to _nR_
		if _r_ > 1  _c_ += ","  ok
		_c_ += '{"item":' + _TourJsonStr(paRec[:routes][_r_][:item]) + ',"stop":' + _TourJsonStr(paRec[:routes][_r_][:stop]) +
		       ',"line":' + paRec[:routes][_r_][:line] + "}"
	next
	return _c_ + "]}"

# what the child printed: [ [ text, milliseconds ] ... ]; an arrival is rounded to a millisecond
func _CoreLinesJson(paLines)
	_c_ = "["
	_n_ = len(paLines)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += "[" + _TourJsonStr(paLines[_i_][1]) + "," + floor(paLines[_i_][2] * 1000 + 0.5) + "]"
	next
	return _c_ + "]"

# the face's ending rules and the walk's facts
func _CoreMetaJson(pcErr, pnExit, pbHung, paFace, pnWallMs, pnSeed)
	_cIgnore_ = ""
	_cEnd_ = ""
	if len(paFace) > 0
		_cIgnore_ = paFace[:ignore]
		_nE_ = len(paFace[:endings])
		for _k_ = 1 to _nE_
			if _k_ > 1  _cEnd_ += ","  ok
			_cEnd_ += "[" + _TourJsonStr(paFace[:endings][_k_][1]) + "," + _TourJsonStr(paFace[:endings][_k_][2]) + "]"
		next
	ok
	_nHung_ = 0
	if pbHung  _nHung_ = 1  ok
	return '{"exit":' + pnExit + ',"hung":' + _nHung_ + ',"stderr":' + _TourJsonStr(pcErr) + ',"wall_ms":' + pnWallMs +
	       ',"seed":' + pnSeed + ',"unreadable":0,"face":{"ignore":' + _TourJsonStr(_cIgnore_) + ',"endings":[' + _cEnd_ + "]}}"

# the engine's tour, as a record the rest of Testoor reads; 0 when the answer cannot be read
func _CoreRecordFrom(paRec, pcJson, paLines, pcErr, pnSeed)
	_aT_ = StzJsonToList(pcJson)
	if len(_aT_) = 0  return 0  ok
	_aStops_ = []
	_aPlain_ = []
	# what a promise WANTED is not in the engine's answer; it is the record's own, by place, unless
	# the tour described itself (its claims then have none)
	_bOwn_ = (_aT_[:dialect] != "protocol")
	_nS_ = len(_aT_[:stops])
	for _s_ = 1 to _nS_
		_aSj_ = _aT_[:stops][_s_]
		_aC_ = []
		_aP_ = []
		_nC_ = len(_aSj_[:claims])
		for _k_ = 1 to _nC_
			_aCj_ = _aSj_[:claims][_k_]
			_cWant_ = ""
			if _bOwn_ and _s_ <= len(paRec[:stops])
				if _k_ <= len(paRec[:stops][_s_][:claims])  _cWant_ = paRec[:stops][_s_][:claims][_k_][:want]  ok
			ok
			_aC_ + [ :claim = _aCj_[:claim], :kind = _aCj_[:kind], :line = _aCj_[:line], :want = _cWant_, :state = _aCj_[:state], :at = -1 ]
			_aP_ + [ :line = _aCj_[:line], :kind = _aCj_[:kind], :claim = _aCj_[:claim], :want = "" ]
		next
		_nOpened_ = -1
		_nClosed_ = -1
		if _aSj_[:opened_ms] >= 0  _nOpened_ = _aSj_[:opened_ms] / 1000  ok
		if _aSj_[:closed_ms] >= 0  _nClosed_ = _aSj_[:closed_ms] / 1000  ok
		_aStops_ + [ :title = _aSj_[:title], :line = _aSj_[:line], :state = _aSj_[:state], :opened = _nOpened_, :closed = _nClosed_,
		             :wall_ms = _aSj_[:wall_ms], :claims = _aC_ ]
		_aPlain_ + [ :title = _aSj_[:title], :line = _aSj_[:line], :claims = _aP_ ]
	next
	_aRoutes_ = []
	_nR_ = len(_aT_[:routes])
	for _r_ = 1 to _nR_
		_aRoutes_ + [ :item = _aT_[:routes][_r_][:item], :stop = _aT_[:routes][_r_][:stop], :line = _aT_[:routes][_r_][:line] ]
	next
	_acW_ = []
	_nW_ = len(_aT_[:weather])
	for _w_ = 1 to _nW_
		_acW_ + _aT_[:weather][_w_]
	next
	_nSeed_ = pnSeed
	if isNumber(_aT_[:seed])  _nSeed_ = _aT_[:seed]  ok
	_aRec_ = paRec
	_aRec_[:flaky] = 0
	_aRec_[:flaky_why] = ""
	_aRec_[:weather] = _acW_
	_aRec_[:routes] = _aRoutes_
	if _aT_[:dialect] = "protocol" and paRec[:dialect] != "protocol"
		# a self-describing tour: the core built its record from what it said
		_aRec_[:dialect] = "protocol"
		_aRec_[:asserts] = 1
		_aRec_[:stops] = _aPlain_
	ok
	_aRec_[:run] = [ :end = _aT_[:end], :exit = _aT_[:exit], :wall_ms = _aT_[:wall_ms], :seed = _nSeed_,
	                 :state = _aT_[:state], :kept = _aT_[:kept], :diverged = _aT_[:diverged],
	                 :unreached = _aT_[:unreached], :unjudged = _aT_[:unjudged], :stops = _aStops_,
	                 :printed = len(paLines) ]
	_aRec_[:output] = paLines
	_aRec_[:stderr] = pcErr
	return _aRec_

# THE VERDICT, taken in the core. Answers the judged record, or 0 when the reference must judge.
func _CoreVerdict(paRec, paLines, pcErr, pnExit, pbHung, paFace, pnWallMs, pnSeed)
	_cReq_ = '{"detail":1,"record":' + _CoreRecordJson(paRec) + ',"output":' + _CoreLinesJson(paLines) +
	         ',"meta":' + _CoreMetaJson(pcErr, pnExit, pbHung, paFace, pnWallMs, pnSeed) + "}"
	_cOut_ = ""
	try
		_cOut_ = StzEngineTestoorVerdict(_cReq_)
	catch
		return 0
	done
	return _CoreRecordFrom(paRec, _cOut_, paLines, pcErr, pnSeed)
