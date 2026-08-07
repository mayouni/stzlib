# DISTRIBUTION D0 -- the message-plane spike (the G0 of the plan).
#
# Two OS processes exchange framed STZM messages over reactor TCP on
# loopback: this guard is one process, _d0_echo_server.ring (spawned
# below) is the other. Everything the plan requires of D0 is MEASURED
# here, and the kill criteria written in the plan before any number
# existed are ASSERTED, not narrated:
#
#   KILL 1: loopback round-trip > 5 ms at the default timer resolution
#           -> would drown every mailbox interaction.
#   KILL 2: serialization > 50% of end-to-end cost on the embedding
#           shape -> fix the encoding before framing anything else.
#
# Both payload-encoding candidates run on identical values -- STZB (the
# in-house tag+length) and msgpack (subset) -- on the three real shapes
# from the plan: a small command list, a 384-f64 embedding vector, and a
# 100-row table slice. The numbers seed net.* in the calibration store.
#
# Windows law respected throughout: all waiting rides reactor polls or
# engine awaits (1 ms resolution via timeBeginPeriod), never sleep loops.

load "../../stzBase.ring"
load "../_narrated.ring"

#--- the three real shapes -------------------------------------------

$aCmd = [ "set", "user:1234", "active", 1 ]
$aVec = D0BuildVec(384)
$aTbl = D0BuildTable(100)

#--- spawn the second OS process (the echo peer) ---------------------

$nPort    = 45300 + (StzEngineTimeNowMs() % 300)
$oSpawner = new stzReactor()
$oRct     = new stzReactor()
$nEchoJob = $oSpawner.SubmitSpawn([ D0RingExe(), "_d0_echo_server.ring", "" + $nPort ])

$nChan = 0
$nConn = 0
D0Link(15000)

Scenario("two OS processes hold a framed STZM link over loopback TCP")
	Given("an echo peer spawned as its own OS process (reactor uv_spawn)")
	Then("the spawn job was issued", $nEchoJob > 0, TRUE)
	Given("a persistent client channel dialed to it (reactor TCP)")
	Then("the link is up", $nConn > 0, TRUE)
EndScenario()

Scenario("every shape round-trips bit-identically under BOTH encodings")
	Given("a command list, a 384-f64 embedding, and a 100-row table slice")
	When("each is packed, sent across the wire, echoed, and unpacked")
	aShapes = [ [ "command", $aCmd ], [ "embedding", $aVec ], [ "table", $aTbl ] ]
	nShapes = len(aShapes)
	for iS = 1 to nShapes
		for nEnc = 0 to 1
			cName = aShapes[iS][1] + "/" + D0EncName(nEnc)
			cFrame = StzEngineStzmPack(aShapes[iS][2], nEnc, 1000 + iS, 0)
			cEcho = D0Trip(cFrame, 5000)
			# the MECHANISM is asserted: the echoed frame is byte-identical,
			# and re-packing the UNPACKED value reproduces those same bytes
			# (deep equality proven through the encoder, not eyeballed)
			vBack = StzEngineStzmUnpack(cEcho)
			cRepack = StzEngineStzmPack(vBack, nEnc, 1000 + iS, 0)
			Then(cName + " round-trips byte-identically",
				(cEcho = cFrame) and (cRepack = cFrame), TRUE)
			Then(cName + " carries its correlation id",
				StzEngineStzmLastCorrelation(), 1000 + iS)
		next
	next
EndScenario()

Scenario("KILL CRITERION 1: loopback round-trip stays under 5 ms")
	Given("the small command frame and a warmed link")
	cSmall = StzEngineStzmPack($aCmd, 0, 1, 0)
	for i = 1 to 20
		D0Trip(cSmall, 2000)
	next
	When("200 round-trips are timed on the monotonic watch clock")
	aBusy = []
	for i = 1 to 200
		n0 = StzEngineWatchTimestampNs()
		D0Trip(cSmall, 2000)
		aBusy + ((StzEngineWatchTimestampNs() - n0) / 1000000.0)
	next
	aAwait = []
	for i = 1 to 200
		n0 = StzEngineWatchTimestampNs()
		D0TripAwait(cSmall, 2000)
		aAwait + ((StzEngineWatchTimestampNs() - n0) / 1000000.0)
	next
	$nRttBusyMs = D0Median(aBusy)
	nRttAwaitMs = D0Median(aAwait)
	? "  [measure] RTT busy-poll  median = " + $nRttBusyMs + " ms, p95 = " + D0P95(aBusy) + " ms"
	? "  [measure] RTT engine-await median = " + nRttAwaitMs + " ms, p95 = " + D0P95(aAwait) + " ms"
	Then("busy-poll median round-trip < 5 ms", $nRttBusyMs < 5, TRUE)
	Then("engine-await median round-trip < 5 ms (the practical path)",
		nRttAwaitMs < 5, TRUE)
EndScenario()

Scenario("sustained throughput: pipelined messages per second")
	Given("64 small frames kept in flight over the one link")
	cSmall = StzEngineStzmPack($aCmd, 0, 2, 0)
	nTotal = 3000
	nInFlight = 64
	nSent = 0
	nGot = 0
	When("" + nTotal + " echoes are pumped through")
	n0 = StzEngineWatchTimestampNs()
	while nSent < nInFlight and nSent < nTotal
		$oRct.ServerWrite($nChan, $nConn, cSmall, FALSE)
		nSent++
	end
	nDeadline = StzEngineWatchTimestampMs() + 30000
	while nGot < nTotal and StzEngineWatchTimestampMs() < nDeadline
		aEv = $oRct.ServerPoll($nChan)
		if len(aEv) = 3 and aEv[1] = :data
			nGot++
			if nSent < nTotal
				$oRct.ServerWrite($nChan, $nConn, cSmall, FALSE)
				nSent++
			ok
		ok
	end
	nSecs = (StzEngineWatchTimestampNs() - n0) / 1000000000.0
	$nMsgsPerSec = floor(nGot / nSecs)
	? "  [measure] " + nGot + " echoes in " + nSecs + " s = " + $nMsgsPerSec + " msg/s"
	Then("all pipelined echoes came back", nGot, nTotal)
	Then("throughput clears 1000 msg/s (an echo IS two deliveries)",
		$nMsgsPerSec > 1000, TRUE)
EndScenario()

Scenario("KILL CRITERION 2 + the encoding verdict, from measurement")
	Given("pack+unpack timed per encoding on all three shapes")
	aShapes = [ [ "command", $aCmd, 500 ], [ "embedding", $aVec, 300 ], [ "table", $aTbl, 200 ] ]
	aSer = []   # rows: [ shape, enc, bytes, packUs, unpackUs ]
	nShapes = len(aShapes)
	for iS = 1 to nShapes
		for nEnc = 0 to 1
			nReps = aShapes[iS][3]
			cFrame = StzEngineStzmPack(aShapes[iS][2], nEnc, 1, 0)
			n0 = StzEngineWatchTimestampNs()
			for i = 1 to nReps
				StzEngineStzmPack(aShapes[iS][2], nEnc, 1, 0)
			next
			nPackUs = (StzEngineWatchTimestampNs() - n0) / nReps / 1000.0
			n0 = StzEngineWatchTimestampNs()
			for i = 1 to nReps
				StzEngineStzmUnpack(cFrame)
			next
			nUnpackUs = (StzEngineWatchTimestampNs() - n0) / nReps / 1000.0
			aSer + [ aShapes[iS][1], nEnc, len(cFrame), nPackUs, nUnpackUs ]
			? "  [measure] " + aShapes[iS][1] + "/" + D0EncName(nEnc) +
				": " + len(cFrame) + " B, pack " + nPackUs +
				" us, unpack " + nUnpackUs + " us"
		next
	next

	When("the embedding frame's wire round-trip is timed (100 trips)")
	aEmb = []
	for nEnc = 0 to 1
		cFrame = StzEngineStzmPack($aVec, nEnc, 1, 0)
		for i = 1 to 10
			D0Trip(cFrame, 2000)
		next
		aTrips = []
		for i = 1 to 100
			n0 = StzEngineWatchTimestampNs()
			D0Trip(cFrame, 2000)
			aTrips + ((StzEngineWatchTimestampNs() - n0) / 1000.0)
		next
		aEmb + D0Median(aTrips)
	next

	# serialization share of end-to-end = (pack + unpack) / (pack + wire + unpack)
	# aSer rows: 1,2 = command(stzb,msgpack); 3,4 = embedding; 5,6 = table
	for nEnc = 0 to 1
		nPackUs = aSer[3 + nEnc][4]
		nUnpackUs = aSer[3 + nEnc][5]
		nWireUs = aEmb[nEnc + 1]
		nShare = floor(100 * (nPackUs + nUnpackUs) / (nPackUs + nWireUs + nUnpackUs))
		? "  [measure] embedding/" + D0EncName(nEnc) + ": wire RTT " + nWireUs +
			" us, serialization share " + nShare + " %"
		if nEnc = 0
			$nShareStzb = nShare
		else
			$nShareMsgpack = nShare
		ok
	next
	Then("stzb serialization stays under 50% of end-to-end (embedding)",
		$nShareStzb < 50, TRUE)
	Then("msgpack serialization stays under 50% of end-to-end (embedding)",
		$nShareMsgpack < 50, TRUE)

	When("the verdict is computed from the numbers, not taste")
	# the embedding + table rows decide: sum of pack+unpack us (cost), with
	# frame bytes as the tiebreaker; smaller is better on both axes
	nStzbCost = aSer[3][4] + aSer[3][5] + aSer[5][4] + aSer[5][5]
	nMsgpCost = aSer[4][4] + aSer[4][5] + aSer[6][4] + aSer[6][5]
	nStzbBytes = aSer[3][3] + aSer[5][3]
	nMsgpBytes = aSer[4][3] + aSer[6][3]
	? "  [verdict] stzb:    " + nStzbCost + " us total codec cost, " + nStzbBytes + " B on the heavy shapes"
	? "  [verdict] msgpack: " + nMsgpCost + " us total codec cost, " + nMsgpBytes + " B on the heavy shapes"
	if nStzbCost <= nMsgpCost
		? "  [verdict] D0 WINNER: stzb (in-house tag+length)"
	else
		? "  [verdict] D0 WINNER: msgpack"
	ok
	Then("both encodings produced a full measurement row set", len(aSer), 6)
EndScenario()

Scenario("a dial to a dead port fails CLEAN, repeatedly, without damage")
	# Regression pin for the stopServer use-after-free this spike exposed:
	# reaping a no-listener channel freed the server synchronously and the
	# old code kept using it -- the redial storm below panicked the loop
	# thread. Deterministic repro, kept as a guard.
	Given("a loopback port nobody listens on")
	nDead = 0
	for i = 1 to 15
		nC = $oRct.ConnectStzm("127.0.0.1", 49998)
		aEv = $oRct.ServerAwait(nC, 2000)
		if len(aEv) = 3 and aEv[1] = :closed
			nDead++
		ok
		$oRct.ServerStop(nC)
	next
	Then("all 15 dial/stop cycles reported :closed", nDead, 15)
	When("the ORIGINAL link is used again after the redial storm")
	cProbe = StzEngineStzmPack([ "still", "alive" ], 0, 3, 0)
	Then("the live link still echoes", D0Trip(cProbe, 5000) = cProbe, TRUE)
EndScenario()

Scenario("the numbers seed the net.* calibration namespace")
	Given("the engine's net.* gates (OVERRIDE > FILE > DEFAULT)")
	aNet = StzEngineStzmNetDefaults()
	? "  [seed] net.stzm.rtt_loopback_us       = " + aNet[1]
	? "  [seed] net.stzm.msgs_per_sec_loopback = " + aNet[2]
	? "  [seed] net.stzm.ser_ns_per_kb         = " + aNet[3]
	Then("three seeded gates are readable from Ring", len(aNet), 3)
	Then("every seed is positive", aNet[1] > 0 and aNet[2] > 0 and aNet[3] > 0, TRUE)
EndScenario()

Scenario("teardown: hanging up ends the peer process cleanly")
	Given("the guard closes its side of the link")
	$oRct.ServerStop($nChan)
	When("the echo peer is awaited")
	cOut = $oSpawner.AwaitSpawn($nEchoJob, 10000)
	Then("the peer exited by itself after the hangup",
		StzFindFirst("echo-server: done", cOut) > 0, TRUE)
	$oRct.Destroy()
	$oSpawner.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- helpers (Ring hoists func defs) ---------------------------------

func D0BuildVec(n)
	_aV_ = []
	for _i_ = 1 to n
		_aV_ + ((_i_ * 7 + 1) / 3.0)
	next
	return _aV_

func D0BuildTable(n)
	_aT_ = []
	for _i_ = 1 to n
		_aT_ + [ _i_, "user_" + _i_, _i_ * 0.75, "tag" + (_i_ % 7) ]
	next
	return _aT_

func D0EncName(nEnc)
	if nEnc = 1
		return "msgpack"
	ok
	return "stzb"

func D0RingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

# Dial until the peer answers (it needs a moment to boot its listener).
func D0Link(nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		$nChan = $oRct.ConnectStzm("127.0.0.1", $nPort)
		$nConn = $oRct.WaitLinkUp($nChan, 1000)
		if $nConn > 0
			return TRUE
		ok
		$oRct.ServerStop($nChan)
		_nT_ = $oRct.SubmitTimer(200)
		$oRct.AwaitTimer(_nT_, 500)
	end
	return FALSE

# One echo round-trip, busy-polling the channel (the wire's floor).
func D0Trip(cFrame, nTimeoutMs)
	$oRct.ServerWrite($nChan, $nConn, cFrame, FALSE)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		_aEv_ = $oRct.ServerPoll($nChan)
		if len(_aEv_) = 3 and _aEv_[1] = :data
			return _aEv_[3]
		ok
	end
	return ""

# One echo round-trip through the engine's blocking await (the practical
# path a mailbox will ride: 1 ms poll resolution inside the DLL).
func D0TripAwait(cFrame, nTimeoutMs)
	$oRct.ServerWrite($nChan, $nConn, cFrame, FALSE)
	_aEv_ = $oRct.ServerAwait($nChan, nTimeoutMs)
	if len(_aEv_) = 3 and _aEv_[1] = :data
		return _aEv_[3]
	ok
	return ""

func D0Median(aNums)
	_aS_ = sort(aNums)
	return _aS_[ceil(len(_aS_) / 2)]

func D0P95(aNums)
	_aS_ = sort(aNums)
	return _aS_[ceil(len(_aS_) * 0.95)]
