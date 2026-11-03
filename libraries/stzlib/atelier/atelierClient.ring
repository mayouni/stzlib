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

# the rnxc to boot with: testoor's own answer (RNXC, else the rnxc running
# this program, else `rnxc` on the path) -- TestoorProgram()
# the log of the last Atelier this process booted (its output goes to a file)
$cAtelierLastLog = ""

func AtelierRnxc()
	return TestoorProgram()

# writes the settings file and starts the child; returns the stzProcess.
# The child's output goes to a FILE beside the Atelier (_atelier_<port>.log),
# not to a pipe: a booted Atelier prints what its tours print, and a pipe
# nobody drains blocks the server after a few kilobytes (measured 2026-11-03:
# a court of four whole files stalled the guard for 25 minutes). So the child
# is started through the shell with its output redirected -- which means
# Kill() reaches the shell, not the server: AtelierKill() ends the server by
# the pid it writes once its library is admitted (_atelier_<port>.pid).
func AtelierBoot(pcAtelierDir, pnPort, pcLibrary, pcSettingsFile)
	_cDir_ = substr("" + pcAtelierDir, "\", "/")
	_cSet_ = '$aAtelierConfig = [ :port = ' + pnPort + ', :library = "' + substr("" + pcLibrary, "\", "/") + '" ]' + char(10)
	write(pcSettingsFile, _cSet_)
	_cLog_ = _cDir_ + "/_atelier_" + pnPort + ".log"
	_cPid_ = _cDir_ + "/_atelier_" + pnPort + ".pid"
	if fexists(_cPid_)  remove(_cPid_)  ok
	# appended, not truncated: a boot that dies at once leaves its words after the last boot's
	_cCmd_ = _AtelierShellPath(AtelierRnxc()) + " resident " + _AtelierShellPath(pcSettingsFile) + " " + _AtelierShellPath(_cDir_ + "/atelier.ring") + " >> " + _AtelierShellPath(_cLog_) + " 2>&1"
	$cAtelierLastLog = _cLog_
	_oP_ = new stzProcess()
	_oP_.Spawn(_cCmd_)
	return _oP_

# a path for the shell line: the shell form dies silently on a double quote,
# so a path with a space is refused here rather than mangled there
func _AtelierShellPath(pcPath)
	_c_ = "" + pcPath
	if isWindows()
		_c_ = substr(_c_, "/", "\")
	ok
	if substr(_c_, " ") > 0
		StzRaise("the Atelier cannot be booted from a path with a space in it: " + _c_)
	ok
	return _c_

# ends a booted Atelier that no longer answers (a tour that never ends): by
# the pid it wrote once admitted, else by the process listening on its port.
# TRUE when a process was found and the kill was asked
func AtelierKill(pcAtelierDir, pnPort)
	_cPid_ = substr("" + pcAtelierDir, "\", "/") + "/_atelier_" + pnPort + ".pid"
	_cId_ = ""
	if fexists(_cPid_)
		_cId_ = trim(substr(substr(read(_cPid_), char(13), ""), char(10), ""))
		remove(_cPid_)
	ok
	if _cId_ = ""
		_cId_ = _AtelierListenerPid(pnPort)
	ok
	if _cId_ = ""  return 0  ok
	if isWindows()
		system("taskkill /F /PID " + _cId_ + " > nul 2>&1")
	else
		system("kill -9 " + _cId_ + " > /dev/null 2>&1")
	ok
	return 1

# the pid of the process listening on 127.0.0.1:port, from the system's own
# listing (netstat on Windows, lsof elsewhere); "" when none
func _AtelierListenerPid(pnPort)
	_oP_ = new stzProcess()
	_cOut_ = ""
	try
		if isWindows()
			_oP_.Spawn("netstat -ano -p tcp")
		else
			_oP_.Spawn("lsof -t -i tcp:" + pnPort + " -s tcp:LISTEN")
		ok
		_cOut_ = _oP_.ReadOutputAll()
		_oP_.Wait()
		_oP_.Close()
	catch
		return ""
	done
	if NOT isWindows()
		return trim(substr(substr(_cOut_, char(13), ""), char(10), " "))
	ok
	_acL_ = str2list(substr(_cOut_, char(13), ""))
	for _i_ = 1 to len(_acL_)
		_cL_ = _acL_[_i_]
		if substr(_cL_, ":" + pnPort + " ") > 0 and substr(upper(_cL_), "LISTEN") > 0
			_acW_ = StzSplit(trim(_cL_), " ")
			_cLast_ = _acW_[len(_acW_)]
			if _cLast_ != ""  return trim(_cLast_)  ok
		ok
	next
	return ""

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
			return [ :library = [ :state = "", :why = "the child ended with exit " + _nExit_ + ": " + _AtelierLogTail() ] ]
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

#--- whole files as tours (A1) ------------------------------------------------
# A narrated test file runs WHOLE as one admission on the resident Atelier
# (POST /atelier/tour): its top level runs there, in its own folder, and the
# trail answered is what _narrated.ring would have printed. testoor's judge
# (_TravJudge, base/testoor/stzTraveller.ring) pairs that trail with the
# reader's claims exactly as it pairs a child's output -- the same court, the
# same five states, no second judge.

# the file as the Atelier admits it: its loads of the library and of the
# narrated helper dropped (both live in the base already), any other load
# kept (it resolves in the file's own folder, where the Atelier moves), a
# top-level shutdown() or bye rewritten to AtelierShutdown(), which records
# the ask and lets the tour go on. [ :folder, :source ]
func AtelierTourSource(pcPath)
	_cPath_ = substr("" + pcPath, "\", "/")
	_cFolder_ = _cPath_
	for _k_ = len(_cPath_) to 1 step -1
		if _cPath_[_k_] = "/"
			_cFolder_ = left(_cPath_, _k_ - 1)
			exit
		ok
	next
	_cSrc_ = substr(read(_cPath_), char(13), "")
	_acL_ = str2list(_cSrc_)
	_cOut_ = ""
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		_cLine_ = _acL_[_i_]
		_lt_ = lower(trim(_cLine_))
		if substr(_lt_, "load ") = 1
			if substr(_lt_, "stzbase.ring") > 0 or substr(_lt_, "stzlib.ring") > 0 or
			   substr(_lt_, "_narrated.ring") > 0 or substr(_lt_, "stdlibcore.ring") > 0 or
			   substr(_lt_, '"stdlib.ring"') > 0
				_cLine_ = "# " + _cLine_ + "   (the Atelier's base holds it)"
			ok
		but substr(_lt_, "shutdown(") = 1
			_cLine_ = "AtelierShutdown(" + substr(trim(_cLine_), 10)
		but _lt_ = "bye"
			_cLine_ = "AtelierShutdown(0)"
		ok
		_cOut_ += _cLine_ + char(10)
	next
	return [ :folder = _cFolder_, :source = _cOut_ ]

# one file as one tour on the Atelier: read by testoor's reader, admitted
# whole, judged by testoor's judge. The record is the reader's with :run
# (as the traveller fills it), :ms, :why, :release and :hung
func AtelierRunTour(pnPort, pcPath, pnTimeoutS)
	_aRec_ = Tour(pcPath)
	_aRec_[:hung] = 0
	_aRec_[:why] = ""
	_aRec_[:release] = ""
	_aRec_[:ms] = 0
	if _aRec_[:readable] = 0
		_aRec_[:run] = _TravJudge(_aRec_, [], "unreadable", -1, 0)
		_aRec_[:run][:end] = "unreadable"
		return _aRec_
	ok
	_aS_ = AtelierTourSource(pcPath)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(pnTimeoutS)
	_t0_ = clock()
	_oH_.Post("http://127.0.0.1:" + pnPort + "/atelier/tour", _aS_[:folder] + char(10) + _aS_[:source])
	_nWall_ = floor((clock() - _t0_) * 1000 / clockspersecond())
	_aRec_[:ms] = _nWall_
	if _oH_.ResponseCode() != 200
		# no answer in time: the tour holds the Atelier, which the sweep reboots
		_aRec_[:hung] = 1
		_aRec_[:why] = "no answer in " + pnTimeoutS + " s (" + _oH_.ResponseCode() + ")"
		_aRec_[:run] = _TravJudge(_aRec_, [], "hung", -3, _nWall_)
		_aRec_[:run][:end] = "hung"
		return _aRec_
	ok
	_cBody_ = substr(_oH_.ResponseBody(), char(13), "")
	_acL_ = str2list(_cBody_)
	_cEnd_ = "finished"
	_nExit_ = 0
	_aLines_ = []
	if len(_acL_) > 0 and left(_acL_[1], 4) = "end" + char(9)
		_acH_ = StzSplit(_acL_[1], char(9))
		if len(_acH_) >= 5
			_cEnd_ = _acH_[2]
			_aRec_[:release] = _acH_[4]
			_aRec_[:why] = _acH_[5]
		ok
		if _cEnd_ = "broke" or _cEnd_ = "not-started"  _nExit_ = 1  ok
		for _i_ = 2 to len(_acL_)
			_aLines_ + [ _acL_[_i_], 0 ]
		next
		if _aRec_[:why] != ""
			_aLines_ + [ _aRec_[:why], 0 ]
		ok
	else
		for _i_ = 1 to len(_acL_)
			_aLines_ + [ _acL_[_i_], 0 ]
		next
	ok
	if _cEnd_ = "finished" and _aRec_[:ending] = "finished-timed"
		_cEnd_ = "finished-timed"
	ok
	_aRec_[:run] = _TravJudge(_aRec_, _aLines_, _cEnd_, _nExit_, _nWall_)
	_aRec_[:run][:end] = _cEnd_
	_aRec_[:output] = _aLines_
	return _aRec_

# the claims of a run that the reader read (line > 0), by state; verdicts the
# reader had no claim for (a Then in a loop, a dynamic text) counted apart
func AtelierClaimCounts(paRun)
	_a_ = [ :claims = 0, :kept = 0, :diverged = 0, :unreached = 0, :unjudged = 0, :unperceived = 0, :extra = 0 ]
	_nS_ = len(paRun[:stops])
	for _s_ = 1 to _nS_
		_aC_ = paRun[:stops][_s_][:claims]
		_nC_ = len(_aC_)
		for _c_ = 1 to _nC_
			if _aC_[_c_][:line] = 0
				_a_[:extra]++
				loop
			ok
			_a_[:claims]++
			_cSt_ = _aC_[_c_][:state]
			if _cSt_ = "kept"
				_a_[:kept]++
			but _cSt_ = "diverged"
				_a_[:diverged]++
			but _cSt_ = "unreached"
				_a_[:unreached]++
			but _cSt_ = "unperceived"
				_a_[:unperceived]++
			else
				_a_[:unjudged]++
			ok
		next
	next
	return _a_

# where two runs of the same tour disagree: the tour's state, and every claim
# the reader read whose state differs. [ [ :where, :a, :b ] ]
func AtelierDisagreements(paRunA, paRunB)
	_aOut_ = []
	if paRunA[:state] != paRunB[:state]
		_aOut_ + [ :where = "the tour", :a = paRunA[:state], :b = paRunB[:state] ]
	ok
	_nS_ = len(paRunA[:stops])
	for _s_ = 1 to _nS_
		if _s_ > len(paRunB[:stops])  exit  ok
		_aCA_ = paRunA[:stops][_s_][:claims]
		_aCB_ = paRunB[:stops][_s_][:claims]
		_nC_ = len(_aCA_)
		for _c_ = 1 to _nC_
			if _aCA_[_c_][:line] = 0  loop  ok
			_cB_ = ""
			for _k_ = 1 to len(_aCB_)
				if _aCB_[_k_][:line] = _aCA_[_c_][:line] and _aCB_[_k_][:claim] = _aCA_[_c_][:claim]
					_cB_ = _aCB_[_k_][:state]
					exit
				ok
			next
			if _cB_ != _aCA_[_c_][:state]
				_aOut_ + [ :where = "line " + _aCA_[_c_][:line] + ": " + _aCA_[_c_][:claim], :a = _aCA_[_c_][:state], :b = _cB_ ]
			ok
		next
	next
	return _aOut_

# one row of counts: a hash list the sweep adds into
func AtelierCountsRow()
	return [ :files = 0, :finished = 0, :broke = 0, :not_started = 0, :hung = 0, :unreadable = 0, :kept_code = 0,
	         :claims = 0, :judged = 0, :kept = 0, :diverged = 0, :unreached = 0, :unjudged = 0, :unperceived = 0, :extra = 0, :ms = 0 ]

func AtelierCountsAdd(paRow, paRec)
	_aC_ = AtelierClaimCounts(paRec[:run])
	paRow[:files]++
	_cEnd_ = paRec[:run][:end]
	if _cEnd_ = "finished" or _cEnd_ = "finished-timed"
		paRow[:finished]++
	but _cEnd_ = "broke"
		paRow[:broke]++
	but _cEnd_ = "not-started"
		paRow[:not_started]++
	but _cEnd_ = "hung"
		paRow[:hung]++
	else
		paRow[:unreadable]++
	ok
	if left("" + paRec[:release], 5) = "kept:"  paRow[:kept_code]++  ok
	paRow[:claims] += _aC_[:claims]
	paRow[:judged] += _aC_[:kept] + _aC_[:diverged]
	paRow[:kept] += _aC_[:kept]
	paRow[:diverged] += _aC_[:diverged]
	paRow[:unreached] += _aC_[:unreached]
	paRow[:unjudged] += _aC_[:unjudged]
	paRow[:unperceived] += _aC_[:unperceived]
	paRow[:extra] += _aC_[:extra]
	paRow[:ms] += paRec[:ms]
	return paRow

func _AtelierCountsJson(paRow)
	_c_ = "{"
	_acK_ = [ "files", "finished", "broke", "not_started", "hung", "unreadable", "kept_code", "claims", "judged", "kept", "diverged", "unreached", "unjudged", "unperceived", "extra", "ms" ]
	for _k_ = 1 to len(_acK_)
		if _k_ > 1  _c_ += ", "  ok
		_c_ += '"' + _acK_[_k_] + '": ' + paRow[_acK_[_k_]]
	next
	return _c_ + "}"

# tours.json's text: what judged the tours, the totals, the domains, the files
func AtelierToursJson(paState, pcTestsCommit, paTotal, paDomains, paFiles)
	_cJ_ = "{" + char(10)
	_cJ_ += '"taken": ' + _AtelierJsonStr(date() + " " + time()) + "," + char(10)
	_cJ_ += '"library": ' + _AtelierJsonStr(paState[:library][:commit]) + "," + char(10)
	_cJ_ += '"rnxc": ' + _AtelierJsonStr(paState[:rnxc][:build]) + "," + char(10)
	_cJ_ += '"engine": ' + _AtelierJsonStr(paState[:engine]) + "," + char(10)
	_cJ_ += '"tests_from": ' + _AtelierJsonStr(pcTestsCommit) + "," + char(10)
	_cJ_ += '"totals": ' + _AtelierCountsJson(paTotal) + "," + char(10)
	_cJ_ += '"domains": {' + char(10)
	for _k_ = 1 to len(paDomains)
		if _k_ > 1  _cJ_ += "," + char(10)  ok
		_cJ_ += '"' + paDomains[_k_][1] + '": ' + _AtelierCountsJson(paDomains[_k_][2])
	next
	_cJ_ += char(10) + "}," + char(10) + '"files": [' + char(10)
	for _k_ = 1 to len(paFiles)
		if _k_ > 1  _cJ_ += "," + char(10)  ok
		_aF_ = paFiles[_k_]
		_cJ_ += '{"file": ' + _AtelierJsonStr(_aF_[:file]) + ', "domain": ' + _AtelierJsonStr(_aF_[:domain]) +
		        ', "end": ' + _AtelierJsonStr(_aF_[:end]) + ', "state": ' + _AtelierJsonStr(_aF_[:state]) +
		        ', "claims": ' + _aF_[:claims] + ', "kept": ' + _aF_[:kept] + ', "diverged": ' + _aF_[:diverged] +
		        ', "unreached": ' + _aF_[:unreached] + ', "unjudged": ' + _aF_[:unjudged] + ', "extra": ' + _aF_[:extra] +
		        ', "ms": ' + _aF_[:ms] + ', "why": ' + _AtelierJsonStr(_aF_[:why]) + '}'
	next
	_cJ_ += char(10) + "]" + char(10) + "}" + char(10)
	return _cJ_

# the last lines the booted Atelier wrote to its log (its stdout and stderr)
func _AtelierLogTail()
	if $cAtelierLastLog = "" or NOT fexists($cAtelierLastLog)
		return ""
	ok
	_c_ = substr(read($cAtelierLastLog), char(13), "")
	if len(_c_) > 600
		_c_ = right(_c_, 600)
	ok
	return _c_
