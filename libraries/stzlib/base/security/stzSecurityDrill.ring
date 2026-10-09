/*
	stzSecurityDrill -- adversary emulation (incident I8).

	A detection nobody has ever seen fire is a hypothesis. The drill
	turns the hypothesis into a fact the way P11's load driver did for
	the R-vs-X knee: with REAL PROCESSES. It spawns a target
	application -- its own ledger open, its own auth and its own
	signed-request gate -- attacks it over REAL HTTP, then makes the
	evidence cross the process boundary the way evidence should: as a
	SEALED, ATTESTED FILE (I7) that must be verified before it may be
	believed (I8's acquisition path).

		oDrill = StzSecurityDrill("nightly")
		oDrill.SpawnTarget(0)
		oDrill.FireCredentialStuffing("victim", 5)
		oDrill.FireForgery()
		oDrill.FireReplay()
		oDrill.CollectEvidence()          # seal -> verify -> acquire
		? oDrill.FiredDetections()
		oDrill.Show()                     # expected vs fired, per attack
		oDrill.Destroy()

	WHY THE FILE MATTERS: the parent never touches the target's memory.
	It learns what happened only from evidence the target sealed and
	the parent verified -- which is exactly the position a real
	investigator is in, and it exercises I1's chain, I7's attestation
	and the acquisition path in one motion. If the drill can conclude
	anything, so can an auditor.

	The attacks are real, not scripted events: a bad password really
	fails an stzAuth, a forged MAC really fails an stzRequestSigner,
	and a replayed nonce really trips the replay cache -- in another
	process, through a socket.

	Mechanics reuse the fleet's recipes (generated script with the
	absolute stzBase path, ring exe from sysargv, readiness probe, TTL
	self-termination) -- the same ones stzLoadDriver uses.
*/

func StzSecurityDrill(pcName)
	return new stzSecurityDrill(pcName)

# Rehearses an attack on a spawned target application and reports whether the detections fired, from sealed and verified evidence.
#
# A drill spawns a target (its own ledger, auth and signed-request gate), attacks it with credential
# stuffing, a forged signature and a replayed request, and then learns what happened only from the
# ledger the target sealed to a file and the drill verified. Contain then derives a plan from that
# evidence, commits it as an operator, and ContainmentHolds proves from outside that the account is
# locked. Timings are measured: TimeToDetectMs and TimeToContainMs. SpawnTarget starts a second
# process and opens a port on 127.0.0.1, so a drill belongs on a machine set aside for it; the
# methods that only read state work without a target.
#
#   receiver   o1 = new stzSecurityDrill("nightly")
#   example    ? o1.Name()
#              #--> nightly
#              ? o1.Passed()
#              #--> 0
#              ? o1.TimeToDetectMs()
#              #--> -1
#              ? o1.AcquisitionWhy() = ""
#              #--> 1
#   see        stzDrillRemoteResponder, stzResponsePlan, stzSecurityLedger, stzRequestSigner
class stzSecurityDrill from stzObject

	@cName = ""
	@oReactor = ""
	@cRingExe = "ring"
	@cBaseRing = ""
	@cScript = ""
	@cHost = "127.0.0.1"
	@nPort = 0
	@nJob = 0
	@cKey = "drill-shared-secret"
	@cSealKey = "drill-evidence-key"
	@cEvidence = ""
	@nTtlMs = 60000
	@aExpected = []		# [ detectionName, attackLabel ]
	@aFired = []
	@oLedger = ""
	@cAcquireWhy = ""
	@cAttestor = ""
	bSpawned = 0
	@nAttackStartMs = 0	# wall ms of the first attack sent
	@nDetectedMs = 0	# wall ms when the evidence showed every expected detection
	@nContainedMs = 0	# wall ms when containment was applied AND verified
	@aContainment = []	# what Contain() did and verified
	@cVictimToken = ""	# a real session opened before the attack

	# Builds a named drill with a default evidence file path in the current folder; nothing is started or contacted yet.
	#
	#   pcName     the drill's name
	#   returns    nothing; the object is built
	#   note       the evidence path is absolute, built from the current folder at construction
	#   warning    nothing is spawned or contacted until SpawnTarget
	#   see        SpawnTarget, SetEvidencePath
	def init(pcName)
		@cName = "" + pcName
		@oReactor = new stzReactor()
		@cRingExe = This._RingExecutable()
		@cBaseRing = This._DeriveStzBasePath()
		# ABSOLUTE: the target is another process and resolves relative
		# paths against ITS working directory, not ours.
		@cEvidence = currentdir() + "/_drill_" + @cName + "_evidence.stzledger"

	# Returns the drill's name.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Sets the shared secret of the target's signed-request gate, which FireReplay also signs with.
	#
	#   pcKey      the secret, as text
	#   returns    the drill itself, so calls chain
	#   note       an invented key only: it is a rehearsal secret, never a real one
	#   warning    the key is handed to the target at SpawnTarget, so set it before
	#   see        FireReplay, SpawnTarget
	def SetKey(pcKey)
		@cKey = "" + pcKey
		return This

	# Sets the file where the target seals its ledger and from which the drill reads it back.
	#
	#   pcPath     the evidence file path, absolute because the target resolves paths in its own
	#              folder
	#   returns    the drill itself, so calls chain
	#   warning    Destroy deletes this file if it exists
	#   see        EvidencePath, CollectEvidence, Destroy
	def SetEvidencePath(pcPath)
		@cEvidence = "" + pcPath
		return This

	# Returns the path of the evidence file.
	#
	#   returns    a text
	#   see        SetEvidencePath, CollectEvidence
	def EvidencePath()
		return @cEvidence

	# Returns the port the target listens on, 0 before SpawnTarget.
	#
	#   returns    a number
	#   see        SpawnTarget
	def Port()
		return @nPort

	# Starts the application under attack as a child ring process on 127.0.0.1 and waits for it to answer.
	#
	#   pnPort     the port to listen on
	#   returns    1 (TRUE) when the target answered within 20 seconds, else 0
	#   note       the target has its own ledger, auth, signed-request gate and /seal route, and
	#              ends by itself after 60000 ms
	#   warning    not run here: it starts a second process, opens a port and writes a generated
	#              script .stzdrilltarget_gen.ring beside the security sources; a drill is for a
	#              machine set aside for it, and Destroy stops the child
	#   see        WaitReady, Destroy, CollectEvidence
	#@ aka  -- the target ----------------------------------------------------
	def SpawnTarget(pnPort)
		if pnPort = 0
			pnPort = 38000 + (StzEngineTimeWallMs() % 900)
		ok
		@nPort = pnPort
		This._GenerateTargetScript()
		@nJob = @oReactor.SubmitSpawn([ @cRingExe, @cScript, "" + @nPort,
			@cKey, @cSealKey, @cEvidence, "" + @nTtlMs ])
		bSpawned = 1
		return This.WaitReady(20000)

	# Polls the target's /health route until it answers 200 OK or the time is up.
	#
	#   pnTimeoutMs   how long to wait, in milliseconds
	#   returns       1 (TRUE) when the target answered; 0 on timeout
	#   warning       not run here: it sends requests to the target's port; on a drill that never
	#                 spawned a target it can only time out
	#   see           SpawnTarget
	def WaitReady(pnTimeoutMs)
		_nDeadline_ = StzEngineTimeNowMs() + pnTimeoutMs
		while StzEngineTimeNowMs() < _nDeadline_
			if StzFindFirst("200 OK", This._Get("/health")) > 0
				return 1
			ok
			StzEngineTimeSleepMs(120)
		end
		return 0

	# Sends a number of login requests with wrong passwords for one account and expects the credential-stuffing detection to fire.
	#
	#   pcUser     the account to attack
	#   pnTimes    how many wrong passwords to send, one request each
	#   returns    the drill itself, so calls chain
	#   note       the first attack sent stamps the start of TimeToDetectMs
	#   warning    the passwords are wrong-1, wrong-2 and so on; the expectation is recorded whether
	#              or not the target answered
	#   see        FireForgery, FireReplay, CollectEvidence, Expectations
	#@ aka  -- the attacks ---------------------------------------------------
	def FireCredentialStuffing(pcUser, pnTimes)
		This._MarkAttackStart()
		for _i_ = 1 to pnTimes
			This._Get("/login?user=" + pcUser + "&pass=wrong-" + _i_)
		next
		This._Expect("credential-stuffing", "credential stuffing (" + pnTimes + " bad passwords)")
		return This

	# Sends one signed request whose signature does not verify and expects the forged-request detection to fire.
	#
	#   returns    the drill itself, so calls chain
	#   note       the request carries the current time and the nonce forge-1
	#   see        FireCredentialStuffing, FireReplay
	#@ aka  Present a signature that does not verify.
	def FireForgery()
		This._MarkAttackStart()
		_nTs_ = StzEngineTimeNowMs()
		This._Get("/signed?kid=drill&ts=" + _nTs_ + "&nonce=forge-1&sig=00deadbeef00")
		This._Expect("forged-request", "a forged signature")
		return This

	# Sends one validly signed request twice, so the second is a replay, and expects the replayed-request detection.
	#
	#   returns    the drill itself, so calls chain
	#   note       it signs with the drill's key (SetKey) and assigns the global $oDrillServer, a
	#              stzRequestSigner, in the calling process
	#   see        FireForgery, SetKey
	#@ aka  Send a VALID signed request twice -- the second is a replay.
	def FireReplay()
		This._MarkAttackStart()
		$oDrillServer = new stzRequestSigner("attacker")
		$oDrillServer.AddKey("drill", @cKey)
		_nTs_ = StzEngineTimeNowMs()
		_cSig_ = $oDrillServer.Sign("drill", "GET", "/signed", "", _nTs_, "rep-1")[:sig]
		_cQ_ = "/signed?kid=drill&ts=" + _nTs_ + "&nonce=rep-1&sig=" + _cSig_
		This._Get(_cQ_)
		This._Get(_cQ_)
		This._Expect("replayed-request", "a replayed nonce")
		return This

	# Returns what the attacks fired so far expect to see detected.
	#
	#   returns    a list of [ detection name, attack label ] rows, in the order fired; [ ] before
	#              any attack
	#   see        FiredDetections, Passed
	def Expectations()
		return @aExpected

	# Asks the target to seal its ledger, verifies the sealed file, rebuilds a working ledger from it and notes which detections fired in it.
	#
	#   returns    1 (TRUE) when the evidence was verified and acquired; 0 when the file is missing
	#              or fails verification, and AcquisitionWhy says why
	#   note       when every expectation is met, the time of detection is stamped; the rebuilt
	#              ledger recomputes its own chain
	#   warning    the drill believes only the sealed and verified file, never the target's memory
	#   see        AcquiredLedger, FiredDetections, Passed, AcquisitionWhy
	#@ aka  -- acquisition: evidence crosses the boundary --------------------
	def CollectEvidence()
		This._Get("/seal")
		StzEngineTimeSleepMs(200)
		_a_ = StzLedgerFromSealedFile(@cEvidence, @cSealKey)
		@cAcquireWhy = _a_[:why]
		if NOT _a_[:ok]
			return 0
		ok
		@oLedger = _a_[:ledger]
		@cAttestor = _a_[:attestor]
		@aFired = StzDefaultDetectionSet().FiredNames(@oLedger)
		if This.Passed()
			@nDetectedMs = StzEngineTimeWallMs()
		ok
		return 1

	# Logs the victim in for real before the attack, so containment has a live session to end.
	#
	#   pcUser       the account to log in
	#   pcPassword   its password
	#   returns      TRUE if the target returned a session token; FALSE when it refused
	#   warning      the token is kept inside the drill for ContainmentHolds
	#   see          Contain, ContainmentHolds
	#@ aka  -- containment: the loop closes ----------------------------------
	def OpenVictimSession(pcUser, pcPassword)
		_cR_ = This._Get("/login?user=" + pcUser + "&pass=" + pcPassword)
		@cVictimToken = This._Body(_cR_)
		return @cVictimToken != "" and @cVictimToken != "no"

	# Turns the acquired evidence into a response plan and performs on the target what the operator may commit.
	#
	#   poOperator   the actor who commits, for example HumanActor("oncall")
	#   returns      the number of actions committed, 0 when the operator is refused
	#   note         the plan holds one incident per credential-stuffing finding; when something was
	#                committed and ContainmentHolds is TRUE, the time of containment is stamped
	#   warning      raises an error when no evidence was acquired yet; a refused operator commits
	#                nothing and the plan records the refusal
	#   see          ContainmentHolds, Containment, CollectEvidence
	#@ aka  Contain what the evidence shows, as poOperator. The plan is derived FROM THE ACQUIRED EVIDENCE (an incident per credential-stuffing finding), governed HERE -- MayCommit is judged on the operator, and an LLM actor is refused -- and carried to the target, whose REAL responder (stzAuthResponder over its own stzAuth) performs it. Then containment is VERIFIED from outside: the right password must now b
	def Contain(poOperator)
		@aContainment = []
		if @oLedger = ""
			stzraise("Contain(): no acquired evidence -- CollectEvidence() first.")
		ok
		_oPlan_ = StzResponsePlan("contain-" + @cName)
		_aF_ = StzDefaultDetectionSet().CheckAgainst(@oLedger)
		_n_ = ring_len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:rule] = "credential-stuffing"
				_oInc_ = new stzIncident("drill-" + _i_)
				_oInc_.FromFinding(_aF_[_i_], @oLedger)
				_oPlan_.ProposeForIncident(_oInc_)
			ok
		next
		_oRemote_ = new stzDrillRemoteResponder(This)
		_nDone_ = _oPlan_.ExecuteOn(_oRemote_, poOperator)
		@aContainment + [ :planned = _oPlan_.NumberOfActions(), :committed = _nDone_,
			:refused = _oPlan_.RefusedCount() ]
		if _nDone_ > 0 and This.ContainmentHolds()
			@nContainedMs = StzEngineTimeWallMs()
		ok
		return _nDone_

	# TRUE if the right password is refused and the pre-attack session is dead, checked from outside the target.
	#
	#   returns    TRUE or FALSE; FALSE before containment
	#   note       it sends two requests to the target for the account named victim
	#   see        Contain, OpenVictimSession
	#@ aka  Verified from outside the target: the correct password is refused, and the pre-attack session no longer answers.
	def ContainmentHolds()
		_cLogin_ = This._Get("/login?user=victim&pass=correct-horse")
		_cWho_ = This._Get("/whoami?token=" + @cVictimToken)
		return StzFindFirst("401", _cLogin_) > 0 and StzFindFirst("401", _cWho_) > 0

	# Returns the milliseconds from the first attack sent to the evidence showing every expected detection.
	#
	#   returns    a number; -1 when that point was not reached
	#   see        TimeToContainMs, Explain
	#@ aka  The two numbers a drill exists to produce, in milliseconds of wall time: from the first attack sent to the evidence showing every expected detection, and from there to containment applied and verified. -1 when that point was never reached.
	def TimeToDetectMs()
		if @nDetectedMs = 0 or @nAttackStartMs = 0  return -1  ok
		return @nDetectedMs - @nAttackStartMs

	# Returns the milliseconds from the detection to a containment that was applied and verified.
	#
	#   returns    a number; -1 when that point was not reached
	#   see        TimeToDetectMs, Contain
	def TimeToContainMs()
		if @nContainedMs = 0 or @nDetectedMs = 0  return -1  ok
		return @nContainedMs - @nDetectedMs

	# Returns what Contain did: how many actions were planned, committed and refused.
	#
	#   returns    a list of [ :planned, :committed, :refused ] rows, one list per Contain call; [ ]
	#              before any
	#   see        Contain
	def Containment()
		return @aContainment

	# called by stzDrillRemoteResponder: one committed action, sent to
	# the target's /contain route. Raises when the target did not do it.
	def _ContainRemote(pcVerb, pcTarget)
		_cR_ = This._Get("/contain?do=" + pcVerb + "&target=" + pcTarget)
		if StzFindFirst("contained", _cR_) = 0
			stzraise("the target did not perform " + pcVerb + " on '" + pcTarget + "': " + This._Body(_cR_))
		ok

	# Returns the ledger rebuilt from the verified evidence.
	#
	#   returns    a ledger object; the empty text before a successful CollectEvidence
	#   see        CollectEvidence, Attestor
	def AcquiredLedger()
		return @oLedger

	# Returns who attested the sealed evidence.
	#
	#   returns    a text, such as target-process; the empty text before a successful
	#              CollectEvidence
	#   see        AcquiredLedger
	def Attestor()
		return @cAttestor

	# Returns the verdict of the last evidence acquisition, in words.
	#
	#   returns    a text such as "acquired 9 verified entr(ies)", or the reason it was refused,
	#              such as a missing file; empty before CollectEvidence
	#   see        CollectEvidence
	def AcquisitionWhy()
		return @cAcquireWhy

	# Returns the names of the detections found in the acquired evidence.
	#
	#   returns    a list of text; [ ] before CollectEvidence
	#   see        Expectations, Passed, MissedDetections
	def FiredDetections()
		return @aFired

	# TRUE if at least one attack was fired and every expected detection fired in the evidence.
	#
	#   returns    TRUE or FALSE
	#   see        MissedDetections, Explain
	#@ aka  Did every expected detection actually fire?
	def Passed()
		_n_ = ring_len(@aExpected)
		for _i_ = 1 to _n_
			if ring_find(@aFired, @aExpected[_i_][1]) = 0
				return 0
			ok
		next
		return _n_ > 0

	# Returns the expected detections that did not fire.
	#
	#   returns    a list of text; [ ] when none missed
	#   see        Passed, Expectations
	def MissedDetections()
		_a_ = []
		_n_ = ring_len(@aExpected)
		for _i_ = 1 to _n_
			if ring_find(@aFired, @aExpected[_i_][1]) = 0
				_a_ + @aExpected[_i_][1]
			ok
		next
		return _a_

	# Returns the drill's report as lines: verdict, evidence, one line per expected detection, and the timings.
	#
	#   returns    a list of text lines
	#   warning    one line per expected detection is marked fired or MISSED, and the two timings
	#              follow when known; with an acquired ledger but no attack fired, the verdict reads
	#              "MISSED: ." with nothing after it
	#   see        Show, Passed
	#@ aka  -- legibility ----------------------------------------------------
	def Explain()
		_aL_ = []
		_cV_ = "NOT RUN"
		if ring_len(@aFired) > 0 or ring_len(@aExpected) > 0
			if This.Passed()
				_cV_ = "every expected detection fired"
			else
				_cV_ = "MISSED: " + This._Join(This.MissedDetections(), ", ")
			ok
		ok
		_aL_ + ("Drill " + @cName + " against 127.0.0.1:" + @nPort + " -- " + _cV_ + ".")
		if @oLedger != ""
			_aL_ + ("  evidence : " + @cEvidence + " (" + @oLedger.Count() +
				" verified event(s), attested by " + @cAttestor + ")")
		else
			_aL_ + ("  evidence : NOT ACQUIRED -- " + @cAcquireWhy)
		ok
		_n_ = ring_len(@aExpected)
		for _i_ = 1 to _n_
			_cMark_ = "[fired]  "
			if ring_find(@aFired, @aExpected[_i_][1]) = 0
				_cMark_ = "[MISSED] "
			ok
			_aL_ + ("  " + _cMark_ + @aExpected[_i_][2] + " -> " + @aExpected[_i_][1])
		next
		if This.TimeToDetectMs() >= 0
			_aL_ + ("  time to detect  : " + This.TimeToDetectMs() + " ms (first attack -> every expected detection, evidence verified)")
		ok
		if This.TimeToContainMs() >= 0
			_aL_ + ("  time to contain : " + This.TimeToContainMs() + " ms (detection -> account locked + sessions ended, verified from outside)")
		ok
		return _aL_

	# Prints the lines of Explain.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Kills the child target if one was spawned and deletes the evidence file if it exists.
	#
	#   returns    the drill itself, so calls chain
	#   note       on a drill that spawned nothing it only deletes the evidence file
	#   see        SpawnTarget, SetEvidencePath
	def Destroy()
		if bSpawned and @nJob > 0
			@oReactor.KillSpawnHard(@nJob)
			@nJob = 0
			bSpawned = 0
		ok
		if fexists(@cEvidence)
			remove(@cEvidence)
		ok
		return This

	  #-- internals -----------------------------------------------------

	def _Expect(pcDetection, pcLabel)
		@aExpected + [ pcDetection, pcLabel ]

	def _MarkAttackStart()
		if @nAttackStartMs = 0
			@nAttackStartMs = StzEngineTimeWallMs()
		ok

	# the body of a raw HTTP response
	def _Body(pcResp)
		_n_ = StzFindFirst(char(13) + char(10) + char(13) + char(10), pcResp)
		if _n_ = 0  return ""  ok
		return StzMidToEnd(pcResp, _n_ + 4)

	def _Get(pcPath)
		_cCRLF_ = char(13) + char(10)
		_cReq_ = "GET " + pcPath + " HTTP/1.1" + _cCRLF_ + "Host: local" + _cCRLF_
		_cReq_ += ("Connection: close" + _cCRLF_ + _cCRLF_)
		_nJ_ = @oReactor.SubmitTcp(@cHost, @nPort, _cReq_)
		return @oReactor.AwaitTcp(_nJ_, 5000)

	def _RingExecutable()
		_a_ = sysargv
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			_c_ = StzLower("" + _a_[_i_])
			if StzFindFirst("ring.exe", _c_) > 0 or StzRight(_c_, 5) = "/ring" or _c_ = "ring"
				return "" + _a_[_i_]
			ok
		next
		return "ring"

	def _DeriveStzBasePath()
		_nSlash_ = 0
		_nL_ = len($cEngineDir)
		for _i_ = 1 to _nL_
			if $cEngineDir[_i_] = "/"
				_nSlash_ = _i_
			ok
		next
		return StzLeft($cEngineDir, _nSlash_ - 1) + "/base/stzBase.ring"

	# The application under attack: real auth, a real signing gate, its
	# own ledger, and one route that seals the evidence on request.
	def _GenerateTargetScript()
		@cScript = $cEngineDir + "/../base/security/.stzdrilltarget_gen.ring"
		_nl_ = char(10)
		_c_ = 'load "' + @cBaseRing + '"' + _nl_
		# THE TARGET'S GLOBALS ARE $-PREFIXED AND UNIQUE ON PURPOSE. They were
		# _a_ / _n_ / _nTtl_ / _nPort_ / _oS_: top-level names, hence GLOBALS,
		# and Ring lets a function or method that assigns _n_ write the global
		# when one exists. Library code uses _n_ as a loop bound everywhere, so
		# inside a handler a nested call rewrote the bound of an outer loop
		# mid-iteration (found 2026-09-29: stzAuth.RevokeAllSessions failed with
		# R2 in the target only). It is the likely cause of the 'degraded actor'
		# recorded below, and the NL/TRUE lesson of CLAUDE.md in another costume.
		_c_ += '$aDrillArgs = sysargv' + _nl_
		_c_ += '$nDrillArgs = len($aDrillArgs)' + _nl_
		_c_ += '$nDrillTtl = number($aDrillArgs[$nDrillArgs])' + _nl_
		_c_ += '$cEvi = $aDrillArgs[$nDrillArgs-1]' + _nl_
		_c_ += '$cSealKey = $aDrillArgs[$nDrillArgs-2]' + _nl_
		_c_ += '$cKey = $aDrillArgs[$nDrillArgs-3]' + _nl_
		_c_ += '$nDrillPort = number($aDrillArgs[$nDrillArgs-4])' + _nl_
		_c_ += 'StzOpenSecurityLedger(2048)' + _nl_
		_c_ += '$oAuth = new stzAuth()' + _nl_
		_c_ += '$oAuth.Register("victim", "correct-horse")' + _nl_
		# THE REAL RESPONDER lives with the auth it acts on
		_c_ += '$oResponder = StzAuthResponder($oAuth)' + _nl_
		_c_ += '$oSigner = new stzRequestSigner("gate")' + _nl_
		_c_ += '$oSigner.AddKey("drill", $cKey)' + _nl_
		_c_ += '$oDrillServer = new stzAppServer()' + _nl_
		_c_ += '$oDrillServer.Get_("/health", func oReq, oResp { oResp.Text("ok") })' + _nl_
		_c_ += '$oDrillServer.Get_("/login", func oReq, oResp {' + _nl_
		_c_ += '    _t_ = $oAuth.Login(oReq.Query("user"), oReq.Query("pass"))' + _nl_
		_c_ += '    if _t_ = "" oResp.Status(401, "Unauthorized").Text("no") else oResp.Text(_t_) ok })' + _nl_
		_c_ += '$oDrillServer.Get_("/whoami", func oReq, oResp {' + _nl_
		_c_ += '    _u_ = $oAuth.UserOfSession(oReq.Query("token"))' + _nl_
		_c_ += '    if _u_ = "" oResp.Status(401, "Unauthorized").Text("no session") else oResp.Text(_u_) ok })' + _nl_
		# committed actions arrive here, already governed by the parent's plan
		_c_ += '$oDrillServer.Get_("/contain", func oReq, oResp {' + _nl_
		_c_ += '    _d_ = oReq.Query("do")' + _nl_
		_c_ += '    _t_ = oReq.Query("target")' + _nl_
		_c_ += '    if _d_ = "lockaccount" $oResponder.LockAccount(_t_) oResp.Text("contained")' + _nl_
		_c_ += '    but _d_ = "revokesession" $oResponder.RevokeSession(_t_) oResp.Text("contained")' + _nl_
		_c_ += '    else oResp.Status(400, "Bad Request").Text("not wired: " + _d_) ok })' + _nl_
		_c_ += '$oDrillServer.Get_("/signed", func oReq, oResp {' + _nl_
		_c_ += '    _ok_ = $oSigner.VerifyNow(oReq.Query("kid"), "GET", "/signed", "",' + _nl_
		_c_ += '        number(oReq.Query("ts")), oReq.Query("nonce"), oReq.Query("sig"), 60000)' + _nl_
		_c_ += '    if _ok_ oResp.Text("verified") else oResp.Status(401, "Unauthorized").Text($oSigner.Why()) ok })' + _nl_
		# The target seals its OWN evidence directly. It deliberately does
		# NOT build a capability-bearing actor here: an stzSystemActor
		# constructed (or read from a global) inside a spawned child's
		# anonymous handler arrives with its capability set degraded --
		# 1 kind instead of 3 -- so the governed-export gate is proven
		# where it belongs, in-process, by the I7 guard. This route's
		# job is only to put the evidence on disk.
		# It also REPORTS what it did: a route that always answers
		# "sealed" hides its own failure (learned here).
		_c_ += '$oDrillServer.Get_("/seal", func oReq, oResp {' + _nl_
		_c_ += '    _oL_ = StzSecurityLedgerQ()' + _nl_
		_c_ += '    _oL_.SealAttestedTo($cEvi, $cSealKey, "target-process")' + _nl_
		_c_ += '    oResp.Text("sealed=" + fexists($cEvi) + " count=" + _oL_.Count()) })' + _nl_
		_c_ += '$oDrillServer.Start($nDrillPort, "127.0.0.1")' + _nl_
		_c_ += '$oDrillServer.RunFor($nDrillTtl)' + _nl_
		_c_ += '$oDrillServer.Stop()' + _nl_
		write(@cScript, _c_)

	def _Join(paList, pcSep)
		_c_ = ""
		_n_ = ring_len(paList)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += pcSep
			ok
			_c_ += ("" + paList[_i_])
		next
		return _c_

# Carries the verbs of a containment plan to a drill's target, one request per verb.
#
# A response plan calls a responder's verbs for each committed action. This one is the drill's: each
# verb is sent to the target's /contain route by the drill, which raises an error when the target
# did not perform it. The stock target wires LockAccount and RevokeSession; the other four verbs
# raise an error naming them as not wired.
#
#   receiver   o1 = new stzDrillRemoteResponder(new stzSecurityDrill("nightly"))
#   example    ? classname(o1)
#              #--> stzdrillremoteresponder
#   see        stzSecurityDrill, stzResponsePlan
class stzDrillRemoteResponder from stzObject

	@pDrill = ""

	# Builds the responder that carries a containment plan's actions to a drill's target.
	#
	#   poDrill    the stzSecurityDrill whose target performs the actions
	#   returns    nothing; the object is built
	#   note       each verb below is one call to the drill's _ContainRemote with the verb in lower
	#              case
	#   see        LockAccount, stzResponsePlan
	def init(poDrill)
		@pDrill = object2pointer(poDrill)

	# Asks the drill's target to lock an account, closing its logins and sessions.
	#
	#   pcTarget   the account to lock
	#   returns    nothing
	#   note       the target wires this verb and RevokeSession only
	#   warning    the drill raises an error when the target does not answer that it contained it
	#   see        RevokeSession, Contain
	def LockAccount(pcTarget)
		pointer2object(@pDrill)._ContainRemote("lockaccount", pcTarget)

	# Asks the drill's target to end the sessions of an account.
	#
	#   pcTarget   the account whose sessions to end
	#   returns    nothing
	#   warning    same error as LockAccount when the target does not contain it
	#   see        LockAccount
	def RevokeSession(pcTarget)
		pointer2object(@pDrill)._ContainRemote("revokesession", pcTarget)

	# Asks the drill's target to rotate a secret.
	#
	#   pcTarget   the name of the secret
	#   returns    nothing
	#   note       the verb is sent as rotatesecret
	#   warning    read from the code, not run: the stock target does not wire this verb and the
	#              drill raises an error
	#   see        LockAccount
	def RotateSecret(pcTarget)
		pointer2object(@pDrill)._ContainRemote("rotatesecret", pcTarget)

	# Asks the drill's target to revoke a capability.
	#
	#   pcTarget   the capability or actor to cut
	#   returns    nothing
	#   warning    read from the code, not run: the stock target does not wire this verb and the
	#              drill raises an error
	#   see        LockAccount
	def RevokeCapability(pcTarget)
		pointer2object(@pDrill)._ContainRemote("revokecapability", pcTarget)

	# Asks the drill's target to block a source, such as a client address.
	#
	#   pcTarget   the source to block
	#   returns    nothing
	#   warning    read from the code, not run: the stock target does not wire this verb and the
	#              drill raises an error
	#   see        LockAccount
	def ShedSource(pcTarget)
		pointer2object(@pDrill)._ContainRemote("shedsource", pcTarget)

	# Asks the drill's target to quarantine a part, such as an agent.
	#
	#   pcTarget   the part to quarantine
	#   returns    nothing
	#   warning    read from the code, not run: the stock target does not wire this verb and the
	#              drill raises an error
	#   see        LockAccount
	def QuarantinePart(pcTarget)
		pointer2object(@pDrill)._ContainRemote("quarantinepart", pcTarget)
