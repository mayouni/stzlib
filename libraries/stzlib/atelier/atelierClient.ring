# THE ATELIER'S CLIENT -- what a Ring program needs to drive an Atelier from
# outside: boot one, wait for its library, run checks over HTTP, compare two
# recordings, write a results file, stop it. The guard (base/test/atelier/
# atelier_narrated.ring) and the recorder (record.ring) load this AFTER the
# library (stzHttpClient, StzJsonToList, stzProcess are the library's; never JsonToList, whose Ring-side parser drops every element after a non-ASCII string).
#
# A booted Atelier is a child `rnxc resident <settings> atelier.ring`, started
# by its argv in the Atelier's folder, the settings a one-line Ring file the
# client writes ($aAtelierConfig: the port and the library). The rnxc is the
# RNXC environment variable, else the rnxc running this program, else `rnxc`
# on the path.
#
# A check's state is one of three words: pass, fail, err. A recording maps a
# check's id to its state; AtelierMoved() names every id whose state is not
# the same in two recordings, and the ids one has and the other has not.
#
# Locals are _underscored_: a program loading this beside its own `i` or `n`
# keeps its loop counters.

func AtelierRnxc()
	_c_ = sysget("RNXC")
	if _c_ != ""
		return _c_
	ok
	if len(sysargv) >= 1
		_c_ = "" + sysargv[1]
		if right(lower(_c_), 4) = "rnxc" or right(lower(_c_), 8) = "rnxc.exe"
			return _c_
		ok
	ok
	return "rnxc"

# writes the settings file and starts the child; returns the stzProcess
func AtelierBoot(pcAtelierDir, pnPort, pcLibrary, pcSettingsFile)
	_cSet_ = '$aAtelierConfig = [ :port = ' + pnPort + ', :library = "' + substr("" + pcLibrary, "\", "/") + '" ]' + char(10)
	write(pcSettingsFile, _cSet_)
	_oP_ = new stzProcess()
	_oP_.SpawnIn(pcAtelierDir, [ AtelierRnxc(), "resident", pcSettingsFile, pcAtelierDir + "/atelier.ring" ])
	return _oP_

# the state the Atelier answers at /atelier/state, as a list, or [] when no answer
func AtelierState(pnPort)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(5)
	_oH_.Get_("http://127.0.0.1:" + pnPort + "/atelier/state")
	if _oH_.ResponseCode() != 200
		return []
	ok
	return StzJsonToList(_oH_.ResponseBody())

# waits until the library is admitted or refused, at most pnTimeoutMs; the state
# list (its library state is "admitted", "refused", or "compiling" on a timeout,
# "" when the server never answered or the child ended first). poProcess is the
# booted child: its timed wait is the pause between two asks, and its ending
# ends the wait
func AtelierWaitReady(pnPort, pnTimeoutMs, poProcess)
	_t0_ = clock()
	_aS_ = []
	while (clock() - _t0_) * 1000 / clockspersecond() < pnTimeoutMs
		_aS_ = AtelierState(pnPort)
		if len(_aS_) > 0
			_cState_ = _aS_[:library][:state]
			if _cState_ = "admitted" or _cState_ = "refused"
				return _aS_
			ok
		ok
		_nExit_ = poProcess.WaitFor(200)
		if _nExit_ != -2
			return [ :library = [ :state = "", :why = "the child ended with exit " + _nExit_ + ": " + poProcess.ReadAvailable() ] ]
		ok
	end
	if len(_aS_) = 0
		return [ :library = [ :state = "", :why = "no answer on port " + pnPort ] ]
	ok
	return _aS_

# one check: [ :kind, :text, :ms ] -- kind pass | fail | err, as the page decides it
func AtelierRunCheck(pnPort, pcCode)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(60)
	_t0_ = clock()
	_oH_.Post("http://127.0.0.1:" + pnPort + "/atelier/run", pcCode)
	_nMs_ = (clock() - _t0_) * 1000 / clockspersecond()
	_nCode_ = _oH_.ResponseCode()
	_cText_ = _oH_.ResponseBody()
	_cKind_ = "err"
	if _nCode_ = 200
		if left(_cText_, 4) = "PASS"
			_cKind_ = "pass"
		else
			_cKind_ = "fail"
		ok
	ok
	return [ :kind = _cKind_, :text = _cText_, :status = _nCode_, :ms = _nMs_ ]

# every check of a checks list (as checks.json holds them): a hash list id -> state,
# and the counts and times in :_counts; pnSay > 0 prints a line every pnSay checks
func AtelierRunChecks(pnPort, paChecks, pnSay)
	_aStates_ = []
	_nPass_ = 0  _nFail_ = 0  _nErr_ = 0
	_aMs_ = []
	_n_ = len(paChecks)
	for _i_ = 1 to _n_
		_aC_ = paChecks[_i_]
		_aR_ = AtelierRunCheck(pnPort, _aC_[:code])
		_aStates_ + [ "" + _aC_[:id], _aR_[:kind] ]
		_aMs_ + _aR_[:ms]
		if _aR_[:kind] = "pass"
			_nPass_++
		but _aR_[:kind] = "fail"
			_nFail_++
		else
			_nErr_++
		ok
		if pnSay > 0 and (_i_ % pnSay = 0 or _i_ = _n_)
			? "  " + _i_ + " of " + _n_ + ": " + _nPass_ + " pass, " + _nFail_ + " fail, " + _nErr_ + " error"
		ok
	next
	_aMs_ = sort(_aMs_)
	_nMed_ = 0
	if len(_aMs_) > 0
		_nMed_ = _aMs_[ceil(len(_aMs_) / 2)]
	ok
	_nSum_ = 0
	for _i_ = 1 to len(_aMs_)
		_nSum_ += _aMs_[_i_]
	next
	return [ :states = _aStates_, :pass = _nPass_, :fail = _nFail_, :err = _nErr_, :median_ms = _nMed_, :total_ms = _nSum_ ]

# the ids whose state moved between two recordings (hash lists id -> state), and
# the ids only one of them has: [ [ :id, :was, :now ] ], :was or :now "" when absent
func AtelierMoved(paBefore, paNow)
	_aOut_ = []
	_nB_ = len(paBefore)
	_nN_ = len(paNow)
	for _i_ = 1 to _nB_
		_cId_ = "" + paBefore[_i_][1]
		_cWas_ = "" + paBefore[_i_][2]
		_cNow_ = ""
		for _j_ = 1 to _nN_
			if "" + paNow[_j_][1] = _cId_
				_cNow_ = "" + paNow[_j_][2]
				exit
			ok
		next
		if _cNow_ != _cWas_
			_aOut_ + [ :id = _cId_, :was = _cWas_, :now = _cNow_ ]
		ok
	next
	for _j_ = 1 to _nN_
		_cId_ = "" + paNow[_j_][1]
		_bSeen_ = 0
		for _i_ = 1 to _nB_
			if "" + paBefore[_i_][1] = _cId_
				_bSeen_ = 1
				exit
			ok
		next
		if _bSeen_ = 0
			_aOut_ + [ :id = _cId_, :was = "", :now = "" + paNow[_j_][2] ]
		ok
	next
	return _aOut_

# the states of a results file (as results.json holds them): a hash list id -> state
func AtelierStatesOf(paResults)
	_aOut_ = []
	if NOT (isList(paResults) and HasKey(paResults, :states))
		return _aOut_
	ok
	_aS_ = paResults[:states]
	for _i_ = 1 to len(_aS_)
		_aOut_ + [ "" + _aS_[_i_][1], "" + _aS_[_i_][2] ]
	next
	return _aOut_

# results.json's text: what judged the checks (from the state, without the machine's
# folders), when, the counts, and every check's state
func AtelierResultsJson(paState, paRun, pcChecksCommit, pnChecks)
	_cJ_ = "{" + char(10)
	_cJ_ += '"taken": ' + _AtelierJsonStr(date() + " " + time()) + "," + char(10)
	_cJ_ += '"library": ' + _AtelierJsonStr(paState[:library][:commit]) + "," + char(10)
	_cJ_ += '"rnxc": ' + _AtelierJsonStr(paState[:rnxc][:build]) + "," + char(10)
	_cJ_ += '"engine": ' + _AtelierJsonStr(paState[:engine]) + "," + char(10)
	_cJ_ += '"checks_from": ' + _AtelierJsonStr(pcChecksCommit) + "," + char(10)
	_cJ_ += '"checks": ' + pnChecks + "," + char(10)
	_cJ_ += '"pass": ' + paRun[:pass] + ', "fail": ' + paRun[:fail] + ', "err": ' + paRun[:err] + "," + char(10)
	_cJ_ += '"median_ms": ' + _AtelierNum(paRun[:median_ms]) + ', "total_ms": ' + _AtelierNum(paRun[:total_ms]) + "," + char(10)
	_cJ_ += '"states": {'
	_aS_ = paRun[:states]
	for _i_ = 1 to len(_aS_)
		if _i_ > 1
			_cJ_ += ", "
		ok
		if _i_ % 20 = 1
			_cJ_ += char(10)
		ok
		_cJ_ += '"' + _aS_[_i_][1] + '": "' + _aS_[_i_][2] + '"'
	next
	_cJ_ += char(10) + "}" + char(10) + "}" + char(10)
	return _cJ_

func AtelierStop(pnPort)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(5)
	_oH_.Post("http://127.0.0.1:" + pnPort + "/atelier/stop", "")
	return _oH_.ResponseCode() = 200

func _AtelierJsonStr(pcText)
	_c_ = "" + pcText
	_c_ = substr(_c_, "\", "\\")
	_c_ = substr(_c_, '"', '\"')
	_c_ = substr(_c_, char(13), "\r")
	_c_ = substr(_c_, char(10), "\n")
	_c_ = substr(_c_, char(9), "\t")
	return '"' + _c_ + '"'

# a number with two decimals, for JSON
func _AtelierNum(pn)
	return "" + (floor(pn * 100 + 0.5) / 100)
