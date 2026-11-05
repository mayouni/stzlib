# Testoor -- IMPACT: which tours must be re-walked after a change. Phase P1a of
# SOFTANZA_TESTOOR_ROADMAP.md, the first step of graph-first testing.
#
# THE IDEA. Today Testoor reads the TESTS and guesses the program. Inverted, the
# program's own code graph (stzCodeGraph, here its Ring peer) says what a change
# to one method REACHES, and Testoor re-walks only the tours that walk that
# reach. A tour costs a child process, so choosing the three that matter out of
# thirty is where the time goes, for an agent in a loop as for a person.
#
# HOW. The reach of a change is the transitive CLOSURE OF CALLERS of the changed
# name, read from the graph's raw call entries [class, method, callee, line]
# (those, and not CallersOf, because only the raw entries hold the edges to a
# class, `new stzTax()`; CallersOf answers for defined methods alone, measured
# 2026-11-03). A tour is impacted when it NAMES any name in the reach, by the same
# static name join the untouched-method report uses (_RouteCalledNames).
#
# WHAT IT IS NOT, and the rule that keeps it honest. A name join over-approximates
# (two classes with a method called Total are one name) and so may select a tour
# it did not need; that costs time and never costs a verdict. What would cost a
# verdict is an edge the graph cannot see: a call by a name built at run time
# (`eval(...)`, `call cName()`). The graph reads such a subject as INCOMPLETE and
# says so, and selection then falls back to EVERY tour, exactly as the code graph
# itself raises instead of guessing when it has no call edges. A selection is only
# ever as small as the graph is complete. The guard measures the claim: for every
# mutant of a planted subject, every tour that fails is in the selected set.
#
# WHO DOES WHAT (P3.3). The FACE reads Ring: the subject's source, its code graph, the
# seed of a change (a constructor reaches whoever builds its class), the line that
# dispatches by a built name, and the names a tour's source calls. The Zig CORE
# (engine/src/testoor_graph.zig, StzEngineTestoorImpact) takes those as a graph record
# of protocol 2 -- names are the ids, an edge per raw call entry, a second edge from the
# class when the caller is its constructor -- and does the closure and the selection.
# The loop in _ImpactClosureRing and the selection in StzImpactedTours are the
# REFERENCE the core was written from; they run when the core is absent or
# TestoorCore("ring") says so. Same names in the same order, same tours selected.
#
# Locals are _underscored_; nothing here touches a top-level name (Rule A clean).

# the first line of a source that dispatches by a name built at run time, or 0
func StzImpactDynamicLine(pcSource)
	_acL_ = str2list(substr("" + pcSource, char(13), ""))
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		_lt_ = lower(trim(_acL_[_i_]))
		if left(_lt_, 1) = "#"  loop  ok
		if substr(_lt_, "eval(") > 0 or substr(_lt_, "eval (") > 0 or
		   substr(_lt_, "call ") = 1 or substr(_lt_, " call ") > 0
			return _i_
		ok
	next
	return 0

# THE FACE'S HALF: read the subject and say what a change seeds and whether every edge is seen:
# [ :readable, :seeds = lower-cased names, :raw = the graph's call entries, :complete, :why, :dynamic_line ]
func _ImpactFace(pcSubjectFile, pcMethod)
	_cSrc_ = ""
	try
		_cSrc_ = read("" + pcSubjectFile)
	catch
		return [ :readable = 0, :seeds = [ lower("" + pcMethod) ], :raw = [], :complete = 0,
		         :why = "cannot read " + pcSubjectFile, :dynamic_line = 0 ]
	done
	_oG_ = StzRingCodeGraphFromSource(_cSrc_)
	_aRaw_ = _oG_.RawCallEntries()
	# "Class.init" names one class's constructor; any other method is joined by
	# its name alone
	_cM_ = lower("" + pcMethod)
	_cOnly_ = ""
	_nDot_ = substr(_cM_, ".")
	if _nDot_ > 0
		_cOnly_ = substr(_cM_, 1, _nDot_ - 1)
		_cM_ = substr(_cM_, _nDot_ + 1, len(_cM_) - _nDot_)
	ok
	_acNames_ = [ _cM_ ]
	# a change to a constructor reaches whoever builds the class
	if _cM_ = "init" and _cOnly_ != ""
		_acNames_ = [ _cOnly_ ]
	ok
	if _cM_ = "init" and _cOnly_ = ""
		_aML_ = _oG_.MethodsWithLines()
		_nM_ = len(_aML_)
		for _i_ = 1 to _nM_
			if lower("" + _aML_[_i_][2]) = "init"
				_c_ = lower("" + _aML_[_i_][1])
				if ring_find(_acNames_, _c_) = 0  _acNames_ + _c_  ok
			ok
		next
	ok
	_nDyn_ = StzImpactDynamicLine(_cSrc_)
	_cWhy_ = ""
	if _nDyn_ > 0
		_cWhy_ = "line " + _nDyn_ + " dispatches by a name built at run time, so the graph cannot see every edge"
	ok
	return [ :readable = 1, :seeds = _acNames_, :raw = _aRaw_, :complete = (_nDyn_ = 0), :why = _cWhy_, :dynamic_line = _nDyn_ ]

# THE REFERENCE closure of callers: [ :names, :complete, :why, :dynamic_line ]
func _ImpactClosureRing(paFace)
	_aRaw_ = paFace[:raw]
	_nRaw_ = len(_aRaw_)
	_acNames_ = paFace[:seeds]
	_nAt_ = 1
	while _nAt_ <= len(_acNames_)
		_cName_ = _acNames_[_nAt_]
		for _i_ = 1 to _nRaw_
			if lower("" + _aRaw_[_i_][3]) = _cName_
				_cCaller_ = lower("" + _aRaw_[_i_][2])
				if ring_find(_acNames_, _cCaller_) = 0  _acNames_ + _cCaller_  ok
				# a changed constructor reaches whoever builds the class that owns it
				if _cCaller_ = "init"
					_cClass_ = lower("" + _aRaw_[_i_][1])
					if ring_find(_acNames_, _cClass_) = 0  _acNames_ + _cClass_  ok
				ok
			ok
		next
		_nAt_++
	end
	return [ :names = _acNames_, :complete = paFace[:complete], :why = paFace[:why], :dynamic_line = paFace[:dynamic_line] ]

# THE CORE'S closure, and with tours its selection too: [ :names, :selected, :skipped ], or [] when
# the core is not there or cannot answer (the caller then runs the reference).
func _ImpactCore(paFace, pacTourFiles)
	if TestoorCoreIs() != "engine"  return []  ok
	_aRaw_ = paFace[:raw]
	_nRaw_ = len(_aRaw_)
	_c_ = '{"graph":{"fold":"ascii","complete":' + paFace[:complete] + ',"why":' + _TourJsonStr(paFace[:why]) + ',"nodes":[],"edges":['
	_bFirst_ = 1
	for _i_ = 1 to _nRaw_
		_cFrom_ = lower("" + _aRaw_[_i_][2])
		_cTo_ = lower("" + _aRaw_[_i_][3])
		if NOT _bFirst_  _c_ += ","  ok
		_bFirst_ = 0
		_c_ += '{"from":' + _TourJsonStr(_cFrom_) + ',"to":' + _TourJsonStr(_cTo_) + "}"
		# a constructor that calls a name is the class calling it: the class is reached with it
		if _cFrom_ = "init"
			_c_ += ',{"from":' + _TourJsonStr(lower("" + _aRaw_[_i_][1])) + ',"to":' + _TourJsonStr(_cTo_) + "}"
		ok
	next
	_c_ += ']},"changed":['
	_nS_ = len(paFace[:seeds])
	for _i_ = 1 to _nS_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr(paFace[:seeds][_i_])
	next
	_c_ += '],"tours":['
	_nT_ = len(pacTourFiles)
	for _i_ = 1 to _nT_
		if _i_ > 1  _c_ += ","  ok
		_c_ += '{"file":' + _TourJsonStr("" + pacTourFiles[_i_]) + ',"names":['
		# a graph that is not complete selects every tour, so what a tour names is not read
		if paFace[:complete]
			_cT_ = ""
			try
				_cT_ = read("" + pacTourFiles[_i_])
			catch
				_cT_ = ""
			done
			_acC_ = _RouteCalledNames(_cT_)
			_nC_ = len(_acC_)
			for _k_ = 1 to _nC_
				if _k_ > 1  _c_ += ","  ok
				_c_ += _TourJsonStr(_acC_[_k_])
			next
		ok
		_c_ += "]}"
	next
	_c_ += "]}"
	_cOut_ = ""
	try
		_cOut_ = StzEngineTestoorImpact(_c_)
	catch
		return []
	done
	_aR_ = StzJsonToList(_cOut_)
	if len(_aR_) = 0  return []  ok
	return [ :names = _aR_[:names], :selected = _aR_[:selected], :skipped = _aR_[:skipped] ]

# The reach of a change to pcMethod in one subject file:
# [ :names = lower-cased names that reach it, :complete = 1/0, :why, :dynamic_line ]
func StzImpactOf(pcSubjectFile, pcMethod)
	_aF_ = _ImpactFace(pcSubjectFile, pcMethod)
	if NOT _aF_[:readable]
		return [ :names = _aF_[:seeds], :complete = 0, :why = _aF_[:why], :dynamic_line = 0 ]
	ok
	_aC_ = _ImpactCore(_aF_, [])
	if len(_aC_) > 0
		return [ :names = _aC_[:names], :complete = _aF_[:complete], :why = _aF_[:why], :dynamic_line = _aF_[:dynamic_line] ]
	ok
	return _ImpactClosureRing(_aF_)

# Which tours to re-walk after a change to pcMethod: [ :selected, :skipped,
# :names, :complete, :why ]. An incomplete graph selects every tour.
func StzImpactedTours(pcSubjectFile, pcMethod, pacTourFiles)
	if TestoorCoreIs() = "engine"
		_aF_ = _ImpactFace(pcSubjectFile, pcMethod)
		if _aF_[:readable]
			_aC_ = _ImpactCore(_aF_, pacTourFiles)
			if len(_aC_) > 0
				return [ :selected = _aC_[:selected], :skipped = _aC_[:skipped], :names = _aC_[:names],
				         :complete = _aF_[:complete], :why = _aF_[:why] ]
			ok
		ok
	ok
	_aI_ = StzImpactOf(pcSubjectFile, pcMethod)
	_acSel_ = []
	_acSkip_ = []
	_acNames_ = sort(_aI_[:names])
	_nT_ = len(pacTourFiles)
	for _i_ = 1 to _nT_
		if NOT _aI_[:complete]
			_acSel_ + pacTourFiles[_i_]
			loop
		ok
		_cT_ = ""
		try
			_cT_ = read("" + pacTourFiles[_i_])
		catch
			_cT_ = ""
		done
		_acC_ = _RouteCalledNames(_cT_)
		_bHit_ = 0
		_nN_ = len(_acNames_)
		for _k_ = 1 to _nN_
			if _RouteIndexOf(_acC_, _acNames_[_k_]) > 0  _bHit_ = 1  exit  ok
		next
		if _bHit_
			_acSel_ + pacTourFiles[_i_]
		else
			_acSkip_ + pacTourFiles[_i_]
		ok
	next
	return [ :selected = _acSel_, :skipped = _acSkip_, :names = _aI_[:names],
	         :complete = _aI_[:complete], :why = _aI_[:why] ]

func StzImpactProse(paRes, pcMethod)
	_c_ = "a change to " + pcMethod + " reaches " + len(paRes[:names]) + " names; " +
	      len(paRes[:selected]) + " tours to re-walk, " + len(paRes[:skipped]) + " skipped by name" + char(10)
	if NOT paRes[:complete]
		_c_ += "  GRAPH INCOMPLETE: " + paRes[:why] + "; every tour is selected" + char(10)
	ok
	_n_ = len(paRes[:selected])
	for _i_ = 1 to _n_
		_c_ += "  RE-WALK  " + paRes[:selected][_i_] + char(10)
	next
	_n_ = len(paRes[:skipped])
	for _i_ = 1 to _n_
		_c_ += "  skipped  " + paRes[:skipped][_i_] + char(10)
	next
	return _c_

func StzImpactJson(paRes, pcMethod)
	_c_ = '{"testoor":"logbook","kind":"impact","method":' + _TourJsonStr(pcMethod) +
	      ',"complete":' + paRes[:complete] + ',"why":' + _TourJsonStr(paRes[:why]) + ',"names":['
	_n_ = len(paRes[:names])
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr(paRes[:names][_i_])
	next
	_c_ += '],"selected":['
	_n_ = len(paRes[:selected])
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr(paRes[:selected][_i_])
	next
	_c_ += '],"skipped":['
	_n_ = len(paRes[:skipped])
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr(paRes[:skipped][_i_])
	next
	return _c_ + "]}"
