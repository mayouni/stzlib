# Testoor -- the traveller walks tours and keeps the logbook. TR1 of
# SOFTANZA_TESTOOR_PLAN.md: ONE runner, one process per batch, many tours.
#
# WHAT A WALK IS. The traveller starts ONE child Ring per tour, from the
# tour's own folder (Ring resolves `load` against the current directory, not
# the file -- measured 2026-10-05, and the reason `softanza test` failed every
# file it ran), reads the child's output AS IT ARRIVES (the engine's
# non-blocking read, stz_process_read_stdout_available), holds a deadline on
# it (the engine's timed wait, stz_process_wait_for; a tour past the deadline
# is killed and reported HUNG, never waited for), and then JUDGES the tour by
# pairing what the child printed with what the reader read:
#
#   kept        the claim printed its verdict and the verdict was good
#   diverged    the claim printed its verdict and the verdict was bad -- or
#               a promise's value appeared nowhere in the output after it
#   unreached   the claim printed nothing and the tour did not run to its
#               end (it broke, hung, or never started)
#   unjudged    the claim printed nothing and the tour DID run to its end
#               (a branch not taken, a loop not entered, a `?` nobody paired)
#   unperceived a perceptual claim nobody has named a perceiver for (TR6)
#
# Five states and no sixth (ruling 2). A stop's state is the worst of its
# claims: diverged > unreached > unjudged > kept; a stop with no claim is
# unjudged. The reader assigned none of these; the traveller assigns all.
#
# THE TOUR'S OWN STATE, read from how its child ended:
#   finished        exit 0, ran to its end
#   finished-timed  pf()'s STOPPED! banner -- "finished, timed", NEVER a
#                   failure (ruling 7); Ring exits 1 on it and that exit is
#                   Ring's, not the runner's
#   not-started     a compile or load error (Error (C..) / Error (E..)) --
#                   the 1,265 #ERR files of the launch prompt land here
#   broke           a runtime error (Error (R..)) or an uncaught raise()
#                   after it started; the claims after it are unreached
#   hung            killed at the deadline
#   unreadable      the reader could not read the file
#
# THE EXIT CODE IS THE RUNNER'S, NOT RING'S (ruling 5):
#   0  every stop kept or unperceived (unjudged stops are reported, not
#      counted against -- ruling 2 says they are not a failure)
#   1  a stop diverged, or a tour did not start -- and a tour that BROKE or
#      HUNG counts here too, because its stops are unreached through its own
#      fault and a shell told 0 about a crashed tour is the defect the sweep
#      had for months (recorded in CONCLUSIONS 2026-10-05; the author may
#      rule otherwise)
#   2  the runner itself refused: no such root, no such topic, a bad
#      argument -- nothing was walked
#
# OWNED AND RUN ARE TWO FIGURES AND ARE NEVER SUMMED: owned is every tour
# found in scope, run is every child actually started. What was skipped is
# named -- the files skipped by name (a leading "_"), and under --topic the
# other topics not walked.
#
# WALL TIME PER STOP is read from the ARRIVAL of the child's lines: Ring
# flushes each `?` (measured: a second line printed 1.5 s after the first
# arrived at +1.54 s), so a stop's time is the time between its opening line
# (SCENARIO: ..., a banner, a sec() title) and the next stop's. Seed: TR4.
#
# NO QUOTES IN A CHILD COMMAND. The engine hands one string to cmd.exe /c or
# /bin/sh -c, and a double quote inside it dies silently (exit 1, no output --
# measured). Paths are passed bare; `cd /d D:\a b` is accepted by cmd as is.
#
# Locals are _underscored_ for the reason stzTour.ring gives.

func TravellerQ()
	return new stzTraveller()

#--- judging, as plain functions so no class method shadows a builtin -------

# the verdict a printed line carries -- [ "kept"|"diverged"|"", claim text ]
func _TravVerdictOf(pcLine)
	_t_ = trim(pcLine)
	_lt_ = lower(_t_)
	if substr(_lt_, "[pass]") > 0 or substr(_lt_, "[ok]") > 0
		return [ "kept", _TravClaimText(_t_) ]
	but substr(_lt_, "[fail]") > 0
		return [ "diverged", _TravClaimText(_t_) ]
	but substr(_t_, "ok   ") = 1
		return [ "kept", trim(substr(_t_, 6, len(_t_) - 5)) ]
	but substr(_t_, "FAIL  ") = 1
		return [ "diverged", trim(substr(_t_, 7, len(_t_) - 6)) ]
	ok
	return [ "", "" ]

# "THEN  the bare form is 32 chars  [PASS]" -> "the bare form is 32 chars"
# "[OK] the version is a gate"            -> "the version is a gate"
func _TravClaimText(pcTrimmed)
	_c_ = pcTrimmed
	if substr(_c_, "THEN ") = 1  _c_ = trim(substr(_c_, 6, len(_c_) - 5))  ok
	_acM_ = [ "[PASS]", "[FAIL]", "[OK]", "[ok]", "[pass]", "[fail]", "[Ok]" ]
	_nM_ = len(_acM_)
	for _k_ = 1 to _nM_
		_n_ = substr(_c_, _acM_[_k_])
		if _n_ > 0
			_c_ = substr(_c_, 1, _n_ - 1) + substr(_c_, _n_ + len(_acM_[_k_]), len(_c_))
			exit
		ok
	next
	return trim(_c_)

# a printed line that opens a stop: its title, or ""
func _TravStopOpened(pcLine, paStops)
	_t_ = trim(pcLine)
	if _t_ = ""  return 0  ok
	if substr(_t_, "SCENARIO: ") = 1  _t_ = substr(_t_, 11, len(_t_) - 10)  ok
	_n_ = len(paStops)
	for _k_ = 1 to _n_
		if paStops[_k_][:title] = _t_  return _k_  ok
	next
	return 0

# the claim (stop index, claim index) a verdict text names, by exact text,
# else by the longest claim text the verdict text begins with (chkeq adds
# "  [got x, want y]" after the claim); [0, 0] when none
func _TravClaimNamed(pcText, paStops, pnFromStop)
	_nS_ = len(paStops)
	_aBest_ = [ 0, 0 ]
	_nBest_ = 0
	for _s_ = 1 to _nS_
		_nC_ = len(paStops[_s_][:claims])
		for _c_ = 1 to _nC_
			_cT_ = paStops[_s_][:claims][_c_][:claim]
			if _cT_ = ""  loop  ok
			if _cT_ = pcText
				if paStops[_s_][:claims][_c_][:state] = ""  return [ _s_, _c_ ]  ok
				if _aBest_[1] = 0  _aBest_ = [ _s_, _c_ ]  ok
			but substr(pcText, _cT_) = 1 and len(_cT_) > _nBest_ and paStops[_s_][:claims][_c_][:state] = ""
				_aBest_ = [ _s_, _c_ ]
				_nBest_ = len(_cT_)
			ok
		next
	next
	return _aBest_

func _TravWorst(pcA, pcB)
	_acOrder_ = [ "kept", "unperceived", "unjudged", "unreached", "diverged" ]
	_nA_ = ring_find(_acOrder_, pcA)
	_nB_ = ring_find(_acOrder_, pcB)
	if _nB_ > _nA_  return pcB  ok
	return pcA

# a promise's wanted text, as the child prints it: outer quotes dropped
func _TravWantText(pcWant)
	_c_ = trim(pcWant)
	_n_ = len(_c_)
	if _n_ >= 2
		if (_c_[1] = '"' and _c_[_n_] = '"') or (_c_[1] = "'" and _c_[_n_] = "'")
			_c_ = substr(_c_, 2, _n_ - 2)
		ok
	ok
	return _c_

# THE JUDGEMENT of one tour. paRec is the reader's record; paLines is what
# the child printed, each [ text, seconds since the tour started ]; pcEnd is
# how the child ended (finished, finished-timed, not-started, broke, hung).
# Answers the run record: state, stops with claim states and wall times.
func _TravJudge(paRec, paLines, pcEnd, pnExit, pnWall)
	_aStops_ = []
	_nS_ = len(paRec[:stops])
	for _s_ = 1 to _nS_
		_aC_ = []
		_nC_ = len(paRec[:stops][_s_][:claims])
		for _c_ = 1 to _nC_
			_aIn_ = paRec[:stops][_s_][:claims][_c_]
			_aC_ + [ :claim = _aIn_[:claim], :kind = _aIn_[:kind], :line = _aIn_[:line],
			         :want = _aIn_[:want], :state = "", :at = -1 ]
		next
		_aStops_ + [ :title = paRec[:stops][_s_][:title], :line = paRec[:stops][_s_][:line],
		             :state = "", :opened = -1, :closed = -1, :wall_ms = 0, :claims = _aC_ ]
	next

	# pass 1: stops open, verdicts land, promises are searched in order
	_nL_ = len(paLines)
	_nCur_ = 0
	_nCursor_ = 1          # for promises: the next output line a value may appear at
	for _i_ = 1 to _nL_
		_cLine_ = paLines[_i_][1]
		_nAt_ = paLines[_i_][2]
		_nOpen_ = _TravStopOpened(_cLine_, _aStops_)
		if _nOpen_ > 0 and _nOpen_ != _nCur_
			if _nCur_ > 0 and _aStops_[_nCur_][:closed] < 0  _aStops_[_nCur_][:closed] = _nAt_  ok
			_nCur_ = _nOpen_
			if _aStops_[_nCur_][:opened] < 0  _aStops_[_nCur_][:opened] = _nAt_  ok
			loop
		ok
		_aV_ = _TravVerdictOf(_cLine_)
		if _aV_[1] != ""
			_aWho_ = _TravClaimNamed(_aV_[2], _aStops_, _nCur_)
			if _aWho_[1] > 0
				_aStops_[_aWho_[1]][:claims][_aWho_[2]][:state] = _aV_[1]
				_aStops_[_aWho_[1]][:claims][_aWho_[2]][:at] = _nAt_
				if _aStops_[_aWho_[1]][:opened] < 0  _aStops_[_aWho_[1]][:opened] = _nAt_  ok
			else
				# a verdict the reader had no claim for (a dynamic text, a
				# Then() in a loop): it joins the stop in progress as its own
				_nTo_ = _nCur_
				if _nTo_ = 0  _nTo_ = 1  ok
				_aStops_[_nTo_][:claims] + [ :claim = _aV_[2], :kind = "sees", :line = 0,
				                              :want = "", :state = _aV_[1], :at = _nAt_ ]
			ok
		ok
	next
	if _nCur_ > 0 and _aStops_[_nCur_][:closed] < 0 and _nL_ > 0
		_aStops_[_nCur_][:closed] = paLines[_nL_][2]
	ok

	# promises: each wanted value must appear at or after the cursor
	for _s_ = 1 to _nS_
		_nC_ = len(_aStops_[_s_][:claims])
		for _c_ = 1 to _nC_
			if _aStops_[_s_][:claims][_c_][:kind] != "promise"  loop  ok
			_cWant_ = _TravWantText(_aStops_[_s_][:claims][_c_][:want])
			_bHit_ = 0
			for _i_ = _nCursor_ to _nL_
				_cT_ = trim(paLines[_i_][1])
				if _cT_ = _cWant_ or (_cWant_ != "" and substr(_cT_, _cWant_) > 0)
					_bHit_ = 1
					_nCursor_ = _i_ + 1
					_aStops_[_s_][:claims][_c_][:at] = paLines[_i_][2]
					exit
				ok
			next
			if _bHit_
				_aStops_[_s_][:claims][_c_][:state] = "kept"
			else
				_aStops_[_s_][:claims][_c_][:state] = "diverged"
			ok
		next
	next

	# pass 2: what printed nothing is unreached or unjudged by how the tour ended
	_cSilent_ = "unjudged"
	if pcEnd = "broke" or pcEnd = "hung" or pcEnd = "not-started"  _cSilent_ = "unreached"  ok
	_cTour_ = "kept"
	_nKept_ = 0  _nDiv_ = 0  _nUnr_ = 0  _nUnj_ = 0
	for _s_ = 1 to _nS_
		_cSt_ = "kept"
		_nC_ = len(_aStops_[_s_][:claims])
		if _nC_ = 0  _cSt_ = "unjudged"  ok
		for _c_ = 1 to _nC_
			if _aStops_[_s_][:claims][_c_][:state] = ""
				_aStops_[_s_][:claims][_c_][:state] = _cSilent_
			ok
			_cSt_ = _TravWorst(_cSt_, _aStops_[_s_][:claims][_c_][:state])
			switch _aStops_[_s_][:claims][_c_][:state]
			on "kept"      _nKept_++
			on "diverged"  _nDiv_++
			on "unreached" _nUnr_++
			on "unjudged"  _nUnj_++
			off
		next
		_aStops_[_s_][:state] = _cSt_
		_cTour_ = _TravWorst(_cTour_, _cSt_)
		# wall time: from the stop's opening line to the next stop's, else
		# from its first verdict to its last
		_nO_ = _aStops_[_s_][:opened]
		_nCl_ = _aStops_[_s_][:closed]
		if _nO_ >= 0 and _nCl_ < 0
			if _s_ < _nS_ and _aStops_[_s_ + 1][:opened] >= 0
				_nCl_ = _aStops_[_s_ + 1][:opened]
			else
				_nCl_ = pnWall / 1000
			ok
		ok
		if _nO_ >= 0 and _nCl_ >= _nO_  _aStops_[_s_][:wall_ms] = floor((_nCl_ - _nO_) * 1000)  ok
	next

	return [ :end = pcEnd, :exit = pnExit, :wall_ms = pnWall, :seed = "",
	         :state = _cTour_, :kept = _nKept_, :diverged = _nDiv_,
	         :unreached = _nUnr_, :unjudged = _nUnj_, :stops = _aStops_,
	         :printed = _nL_ ]

# how the child ended, from its output, its stderr and its exit code
func _TravEndingOf(paLines, pcErr, pnExit, pbHung)
	if pbHung  return "hung"  ok
	_cAll_ = pcErr
	_nL_ = len(paLines)
	for _i_ = 1 to _nL_
		_cAll_ += char(10) + paLines[_i_][1]
	next
	if substr(_cAll_, "STOPPED!") > 0  return "finished-timed"  ok
	if substr(_cAll_, "Error (E") > 0 or substr(_cAll_, "Error (C") > 0  return "not-started"  ok
	if substr(_cAll_, "Error (R") > 0  return "broke"  ok
	if substr(_cAll_, "Can't open file") > 0  return "not-started"  ok
	if pnExit != 0  return "broke"  ok
	return "finished"

# the folder and the name of a path, split at its last separator
func _TravSplitPath(pcPath)
	_c_ = "" + pcPath
	_n_ = len(_c_)
	_nAt_ = 0
	for _k_ = _n_ to 1 step -1
		if _c_[_k_] = "/" or _c_[_k_] = char(92)
			_nAt_ = _k_
			exit
		ok
	next
	if _nAt_ = 0  return [ ".", _c_ ]  ok
	return [ substr(_c_, 1, _nAt_ - 1), substr(_c_, _nAt_ + 1, _n_ - _nAt_) ]

# a path in the host's own separators, with no quote in it
func _TravHostPath(pcPath)
	_c_ = "" + pcPath
	if isWindows()
		_c_ = substr(_c_, "/", char(92))
	else
		_c_ = substr(_c_, char(92), "/")
	ok
	return _c_

#--- the run as JSON and prose --------------------------------------------

func _TravRunJson(paRec)
	_aR_ = paRec[:run]
	_c_ = '{"file":' + _TourJsonStr(paRec[:file]) +
	      ',"dialect":' + _TourJsonStr(paRec[:dialect]) +
	      ',"state":' + _TourJsonStr(_aR_[:state]) +
	      ',"end":' + _TourJsonStr(_aR_[:end]) +
	      ',"exit":' + _aR_[:exit] + ',"wall_ms":' + _aR_[:wall_ms] +
	      ',"seed":null,"kept":' + _aR_[:kept] + ',"diverged":' + _aR_[:diverged] +
	      ',"unreached":' + _aR_[:unreached] + ',"unjudged":' + _aR_[:unjudged] +
	      ',"stops":['
	_nS_ = len(_aR_[:stops])
	for _s_ = 1 to _nS_
		if _s_ > 1  _c_ += ","  ok
		_aS_ = _aR_[:stops][_s_]
		_c_ += '{"title":' + _TourJsonStr(_aS_[:title]) + ',"line":' + _aS_[:line] +
		       ',"state":' + _TourJsonStr(_aS_[:state]) + ',"wall_ms":' + _aS_[:wall_ms] +
		       ',"seed":null,"claims":['
		_nC_ = len(_aS_[:claims])
		for _k_ = 1 to _nC_
			if _k_ > 1  _c_ += ","  ok
			_aC_ = _aS_[:claims][_k_]
			_c_ += '{"claim":' + _TourJsonStr(_aC_[:claim]) + ',"kind":' + _TourJsonStr(_aC_[:kind]) +
			       ',"line":' + _aC_[:line] + ',"state":' + _TourJsonStr(_aC_[:state]) + "}"
		next
		_c_ += "]}"
	next
	_c_ += "]}"
	return _c_

func _TravRunProse(paRec)
	_aR_ = paRec[:run]
	_cTag_ = upper(_aR_[:state])
	if _aR_[:end] = "not-started" or _aR_[:end] = "broke" or _aR_[:end] = "hung" or _aR_[:end] = "unreadable"
		_cTag_ = upper(_aR_[:end])
	ok
	while len(_cTag_) < 11  _cTag_ += " "  end
	_c_ = _cTag_ + " " + paRec[:file] + "  " + len(_aR_[:stops]) + " stops: " +
	      _aR_[:kept] + " kept"
	if _aR_[:diverged] > 0   _c_ += ", " + _aR_[:diverged] + " diverged"  ok
	if _aR_[:unreached] > 0  _c_ += ", " + _aR_[:unreached] + " unreached"  ok
	if _aR_[:unjudged] > 0   _c_ += ", " + _aR_[:unjudged] + " unjudged"  ok
	_c_ += "  (" + (_aR_[:wall_ms] / 1000) + " s"
	if _aR_[:end] = "finished-timed"  _c_ += ", finished, timed"  ok
	_c_ += ")"
	_nS_ = len(_aR_[:stops])
	for _s_ = 1 to _nS_
		_aS_ = _aR_[:stops][_s_]
		if _aS_[:state] = "kept"  loop  ok
		_c_ += char(10) + "    " + _aS_[:state] + "  " + _aS_[:title] + "  (" + (_aS_[:wall_ms] / 1000) + " s)"
		_nC_ = len(_aS_[:claims])
		for _k_ = 1 to _nC_
			if _aS_[:claims][_k_][:state] = "kept"  loop  ok
			_c_ += char(10) + "        " + _aS_[:claims][_k_][:state] + "  " + _aS_[:claims][_k_][:claim]
		next
	next
	return _c_

#--- stzTraveller ---------------------------------------------------------

class stzTraveller from stzObject

	@cBy = "shell"
	@nTimeoutMs = 120000
	@bStream = 1              # prose, one line per tour, as each ends
	@aRecords = []
	@acSkipped = []
	@acTopicsSkipped = []
	@cRoot = ""
	@cTopic = ""
	@nOwned = 0
	@nRun = 0
	@nWallMs = 0
	@cRefusal = ""
	@bWalked = 0

	def init()
		@aRecords = []
		@acSkipped = []
		@acTopicsSkipped = []

	def By(pcWho)
		@cBy = "" + pcWho
		return This

	def Timeout(pnMs)
		@nTimeoutMs = 0 + pnMs
		return This

	def Silent()
		@bStream = 0
		return This

	def Streaming()
		@bStream = 1
		return This

	#-- what to walk ----------------------------------------------------

	# every tour under root/topic; topic "" walks every topic folder under
	# root. The topics NOT walked are named.
	def WalkTopic(pcRoot, pcTopic)
		@cRoot = "" + pcRoot
		@cTopic = "" + pcTopic
		if NOT This._IsDir(@cRoot)
			@cRefusal = "no such root: " + @cRoot
			return This
		ok
		_cDir_ = @cRoot
		if @cTopic != ""
			_cDir_ = @cRoot + "/" + @cTopic
			if NOT This._IsDir(_cDir_)
				@cRefusal = "no such topic under " + @cRoot + ": " + @cTopic
				return This
			ok
			# name the siblings not walked
			_aE_ = dir(@cRoot)
			_nE_ = ring_len(_aE_)
			for _k_ = 1 to _nE_
				if _aE_[_k_][2] and _aE_[_k_][1] != @cTopic and
				   left(_aE_[_k_][1], 1) != "." and left(_aE_[_k_][1], 1) != "_"
					@acTopicsSkipped + _aE_[_k_][1]
				ok
			next
		ok
		return This.WalkTree(_cDir_)

	def WalkTree(pcDir)
		if @cRoot = ""  @cRoot = "" + pcDir  ok
		if NOT This._IsDir("" + pcDir)
			@cRefusal = "no such folder: " + pcDir
			return This
		ok
		_aTwo_ = _TourFilesUnder("" + pcDir, "")
		_nS_ = ring_len(_aTwo_[2])
		for _k_ = 1 to _nS_
			@acSkipped + _aTwo_[2][_k_]
		next
		_nF_ = ring_len(_aTwo_[1])
		for _k_ = 1 to _nF_
			This.Walk(_aTwo_[1][_k_])
		next
		return This

	# ONE tour: one child, from the tour's own folder, read as it prints,
	# held to the deadline, then judged
	def Walk(pcPath)
		@bWalked = 1
		@nOwned++
		_aRec_ = _TourRead("" + pcPath)
		if _aRec_[:readable] = 0
			_aRec_[:run] = _TravJudge(_aRec_, [], "unreadable", -1, 0)
			_aRec_[:run][:end] = "unreadable"
			This._Keep(_aRec_)
			return This
		ok
		_aFD_ = _TravSplitPath("" + pcPath)
		_cFolder_ = _TravHostPath(_aFD_[1])
		# by argv, in the tour's own folder, no shell between: Ring resolves
		# `load` against the working directory, and Kill() must reach ring
		# itself (through cmd.exe it reached only cmd.exe -- measured)
		_oP_ = new stzProcess()
		_oP_.SpawnIn(_cFolder_, [ "ring", _aFD_[2] ])
		@nRun++
		_nT0_ = clock()
		_cBuf_ = ""
		_aLines_ = []
		_bHung_ = 0
		_nExit_ = -2
		# THE LOOP: read what arrived (stamping each complete line), and when
		# nothing arrived, give the child 10 ms to exit (the poll's sleep).
		# Once the stream has ended nothing more can come: leave. Past the
		# deadline with the child still running: kill it, it is hung. The
		# engine's timed wait leaves the pipes open, so a child that exits
		# between two polls is still drained to its last line.
		while 1
			_cChunk_ = _oP_.ReadAvailable()
			if _cChunk_ != ""
				_cBuf_ += _cChunk_
				_nNow_ = (clock() - _nT0_) / clockspersecond()
				_nNl_ = substr(_cBuf_, char(10))
				while _nNl_ > 0
					_cL_ = substr(_cBuf_, 1, _nNl_ - 1)
					_cL_ = substr(_cL_, char(13), "")
					_aLines_ + [ _cL_, _nNow_ ]
					_cBuf_ = substr(_cBuf_, _nNl_ + 1, ring_len(_cBuf_) - _nNl_)
					_nNl_ = substr(_cBuf_, char(10))
				end
				loop
			ok
			if _oP_.StdoutEnded()  exit  ok
			if _nExit_ = -2
				_nExit_ = _oP_.WaitFor(10)
				if _nExit_ = -2 and (clock() - _nT0_) / clockspersecond() * 1000 > @nTimeoutMs
					_oP_.Kill()
					_bHung_ = 1
					_nExit_ = -3
					exit
				ok
			ok
		end
		if _cBuf_ != ""
			_aLines_ + [ substr(_cBuf_, char(13), ""), (clock() - _nT0_) / clockspersecond() ]
		ok
		_cErr_ = ""
		if NOT _bHung_
			# the stream ended; the child may still be a few ms from its exit
			if _nExit_ = -2  _nExit_ = _oP_.WaitFor(@nTimeoutMs)  ok
			if _nExit_ = -2
				_oP_.Kill()
				_bHung_ = 1
				_nExit_ = -3
			else
				_cErr_ = _oP_.ReadErrorAll()
			ok
		ok
		_nWall_ = floor((clock() - _nT0_) / clockspersecond() * 1000)
		_oP_.Close()
		@nWallMs += _nWall_
		_cEnd_ = _TravEndingOf(_aLines_, _cErr_, _nExit_, _bHung_)
		_aRec_[:run] = _TravJudge(_aRec_, _aLines_, _cEnd_, _nExit_, _nWall_)
		_aRec_[:output] = _aLines_
		_aRec_[:stderr] = _cErr_
		This._Keep(_aRec_)
		return This

	def _Keep(paRec)
		@aRecords + paRec
		if @bStream  ? _TravRunProse(paRec)  ok

	def _IsDir(pcPath)
		_b_ = 0
		try
			_aE_ = dir("" + pcPath)
			_b_ = 1
		catch
			_b_ = 0
		done
		return _b_

	#-- the logbook of the run -------------------------------------------

	def Records()
		return @aRecords

	def Owned()
		return @nOwned

	def Run()
		return @nRun

	def Skipped()
		return @acSkipped

	def TopicsSkipped()
		return @acTopicsSkipped

	def Refusal()
		return @cRefusal

	def Refused()
		return @cRefusal != ""

	def WallMs()
		return @nWallMs

	# tours in a given state, or whose child ended a given way
	def ToursInState(pcState)
		_aOut_ = []
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			if @aRecords[_k_][:run][:state] = pcState or @aRecords[_k_][:run][:end] = pcState
				_aOut_ + @aRecords[_k_]
			ok
		next
		return _aOut_

	def Counts()
		_aOut_ = [ :kept = 0, :diverged = 0, :unreached = 0, :unjudged = 0,
		           :finished = 0, :finished_timed = 0, :not_started = 0,
		           :broke = 0, :hung = 0, :unreadable = 0 ]
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			_aR_ = @aRecords[_k_][:run]
			_aOut_[:kept] += _aR_[:kept]
			_aOut_[:diverged] += _aR_[:diverged]
			_aOut_[:unreached] += _aR_[:unreached]
			_aOut_[:unjudged] += _aR_[:unjudged]
			switch _aR_[:end]
			on "finished"        _aOut_[:finished]++
			on "finished-timed"  _aOut_[:finished_timed]++
			on "not-started"     _aOut_[:not_started]++
			on "broke"           _aOut_[:broke]++
			on "hung"            _aOut_[:hung]++
			on "unreadable"      _aOut_[:unreadable]++
			off
		next
		return _aOut_

	# THE RUNNER'S exit code, as ruled
	def ExitCode()
		if @cRefusal != ""  return 2  ok
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			_aR_ = @aRecords[_k_][:run]
			if _aR_[:diverged] > 0  return 1  ok
			if _aR_[:end] = "not-started" or _aR_[:end] = "broke" or
			   _aR_[:end] = "hung" or _aR_[:end] = "unreadable"
				return 1
			ok
		next
		return 0

	def Summary()
		if @cRefusal != ""
			return "REFUSED: " + @cRefusal + char(10) + "exit 2"
		ok
		_aC_ = This.Counts()
		_c_ = "owned " + @nOwned + " tours, run " + @nRun + " (two figures, never summed)" + char(10) +
		      "  claims: " + _aC_[:kept] + " kept, " + _aC_[:diverged] + " diverged, " +
		      _aC_[:unreached] + " unreached, " + _aC_[:unjudged] + " unjudged" + char(10) +
		      "  tours: " + _aC_[:finished] + " finished, " + _aC_[:finished_timed] + " finished-timed, " +
		      _aC_[:not_started] + " not-started, " + _aC_[:broke] + " broke, " +
		      _aC_[:hung] + " hung, " + _aC_[:unreadable] + " unreadable" + char(10) +
		      "  wall: " + (@nWallMs / 1000) + " s, by " + @cBy + char(10)
		_nS_ = ring_len(@acSkipped)
		_c_ += "  skipped by name: " + _nS_
		for _k_ = 1 to _nS_
			_c_ += char(10) + "    " + @acSkipped[_k_]
		next
		_nT_ = ring_len(@acTopicsSkipped)
		if _nT_ > 0
			_c_ += char(10) + "  topics not walked (--topic " + @cTopic + "): " + _nT_
			for _k_ = 1 to _nT_
				_c_ += char(10) + "    " + @acTopicsSkipped[_k_]
			next
		ok
		_c_ += char(10) + "exit " + This.ExitCode()
		return _c_

	def Prose()
		_c_ = ""
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			_c_ += _TravRunProse(@aRecords[_k_]) + char(10)
		next
		return _c_ + This.Summary()

	def Json()
		_aC_ = This.Counts()
		_c_ = '{"testoor":"logbook","kind":"run","by":' + _TourJsonStr(@cBy) +
		      ',"root":' + _TourJsonStr(@cRoot) + ',"topic":' + _TourJsonStr(@cTopic) +
		      ',"refusal":' + _TourJsonStr(@cRefusal) +
		      ',"exit":' + This.ExitCode() + ',"owned":' + @nOwned + ',"run":' + @nRun +
		      ',"wall_ms":' + @nWallMs + ',"timeout_ms":' + @nTimeoutMs +
		      ',"claims":{"kept":' + _aC_[:kept] + ',"diverged":' + _aC_[:diverged] +
		      ',"unreached":' + _aC_[:unreached] + ',"unjudged":' + _aC_[:unjudged] + "}" +
		      ',"tours_by_end":{"finished":' + _aC_[:finished] + ',"finished-timed":' + _aC_[:finished_timed] +
		      ',"not-started":' + _aC_[:not_started] + ',"broke":' + _aC_[:broke] +
		      ',"hung":' + _aC_[:hung] + ',"unreadable":' + _aC_[:unreadable] + "}" +
		      ',"skipped":['
		_nS_ = ring_len(@acSkipped)
		for _k_ = 1 to _nS_
			if _k_ > 1  _c_ += ","  ok
			_c_ += _TourJsonStr(@acSkipped[_k_])
		next
		_c_ += '],"topics_skipped":['
		_nT_ = ring_len(@acTopicsSkipped)
		for _k_ = 1 to _nT_
			if _k_ > 1  _c_ += ","  ok
			_c_ += _TourJsonStr(@acTopicsSkipped[_k_])
		next
		_c_ += '],"tours":['
		_n_ = ring_len(@aRecords)
		for _k_ = 1 to _n_
			if _k_ > 1  _c_ += ","  ok
			_c_ += _TravRunJson(@aRecords[_k_])
		next
		_c_ += "]}"
		return _c_
