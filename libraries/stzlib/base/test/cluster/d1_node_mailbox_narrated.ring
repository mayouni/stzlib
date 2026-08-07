# DISTRIBUTION D1 -- node + mailbox, one machine.
#
# stzNode: an OS process serving STZM messages through ONE bounded inbox
# with a declared overflow policy, dispatching [ tag, args... ] to
# On(tag, f) handlers. This guard proves the plan's D1 claims against
# REAL child processes (six of them), not simulations:
#
# - delivery order per sender is FIFO (content asserted, not counted)
# - overflow is counted EXACTLY, and each policy keeps the messages it
#   promises to keep: :DropNewest the FIRST cap, :DropOldest the LAST
#   cap, :Refuse hangs up (the sender OBSERVES the refusal)
# - a handler that raises kills the node LOUDLY: its death is observable
#   from outside (link closes, process exits) -- it never wedges
# - KILL CRITERION (from the plan): per-message dispatch overhead must
#   not exceed the D0 round-trip itself -- node echo RTT < 2x raw echo
#   RTT, measured side by side in this run.

load "../../stzBase.ring"
load "../_narrated.ring"

$oSpawner = new stzReactor()
$oRct = new stzReactor()
$nCorr = 100
$bAskCorrOk = FALSE

nBase = 45600 + (StzEngineTimeNowMs() % 200)
$nPortBasic = nBase
$nPortBoom  = nBase + 1
$nPortRaw   = nBase + 2
$nPortFA    = nBase + 3
$nPortFB    = nBase + 4
$nPortFC    = nBase + 5

cExe = D1RingExe()
nJobBasic = $oSpawner.SubmitSpawn([ cExe, "_d1_node_basic.ring", "" + $nPortBasic ])
nJobBoom  = $oSpawner.SubmitSpawn([ cExe, "_d1_node_basic.ring", "" + $nPortBoom ])
nJobRaw   = $oSpawner.SubmitSpawn([ cExe, "_d0_echo_server.ring", "" + $nPortRaw ])
nJobFA = $oSpawner.SubmitSpawn([ cExe, "_d1_node_flood.ring", "" + $nPortFA, "10", "dropnewest", "2500" ])
nJobFB = $oSpawner.SubmitSpawn([ cExe, "_d1_node_flood.ring", "" + $nPortFB, "10", "dropoldest", "2500" ])
nJobFC = $oSpawner.SubmitSpawn([ cExe, "_d1_node_flood.ring", "" + $nPortFC, "5", "refuse", "2500" ])

Scenario("a node answers an Ask with a correlated reply")
	Given("a basic node process with a ping handler")
	aLink = D1Connect($nPortBasic, 15000)
	Then("the link is up", aLink[2] > 0, TRUE)
	When("the guard asks [ ping, 42 ] with reply-expected")
	vR = D1Ask(aLink, [ "ping", 42 ], 5000)
	Then("the reply is [ pong, 42 ]", D1PackEq(vR, [ "pong", 42 ]), TRUE)
	Then("the reply carried the ask's correlation id", $bAskCorrOk, TRUE)
	$aBasic = aLink
EndScenario()

# flood the three bounded nodes NOW, while they are still in their
# declared pause window (nothing drains; the ENGINE enforces the bound)
$aFA = D1Connect($nPortFA, 15000)
$aFB = D1Connect($nPortFB, 15000)
$aFC = D1Connect($nPortFC, 15000)
for i = 1 to 30
	D1Send($aFA, [ "seq", i ])
	D1Send($aFB, [ "seq", i ])
next
for i = 1 to 12
	D1Send($aFC, [ "seq", i ])
next

Scenario("delivery order per sender is FIFO -- content, not counts")
	Given("50 numbered fire-and-forget messages sent down one link")
	for i = 1 to 50
		D1Send($aBasic, [ "seq", i ])
	next
	When("the node is asked to drain its accumulation")
	vSeq = D1Ask($aBasic, [ "drain" ], 5000)
	aWant = []
	for i = 1 to 50
		aWant + i
	next
	Then("the node saw exactly 1..50 in order", D1PackEq(vSeq, aWant), TRUE)
EndScenario()

Scenario("KILL CRITERION: dispatch overhead under one D0 round-trip")
	Given("a RAW echo peer (D0's) and the node's echo handler, side by side")
	aRaw = D1Connect($nPortRaw, 15000)
	cRawFrame = StzEngineStzmPack([ "echo", 42 ], 0, 7, 0)
	for i = 1 to 20
		D1RawTrip(aRaw, cRawFrame, 2000)
		D1Ask($aBasic, [ "echo", 42 ], 2000)
	next
	When("100 round-trips of each are timed on the monotonic clock")
	aRawMs = []
	aNodeMs = []
	for i = 1 to 100
		n0 = StzEngineWatchTimestampNs()
		D1RawTrip(aRaw, cRawFrame, 2000)
		aRawMs + ((StzEngineWatchTimestampNs() - n0) / 1000000.0)
		n0 = StzEngineWatchTimestampNs()
		D1Ask($aBasic, [ "echo", 42 ], 2000)
		aNodeMs + ((StzEngineWatchTimestampNs() - n0) / 1000000.0)
	next
	nRawMed = D1Median(aRawMs)
	nNodeMed = D1Median(aNodeMs)
	? "  [measure] raw echo RTT median  = " + nRawMed + " ms"
	? "  [measure] node echo RTT median = " + nNodeMed + " ms (overhead " +
		(nNodeMed - nRawMed) + " ms)"
	Then("node dispatch adds less than one raw round-trip",
		nNodeMed < 2 * nRawMed, TRUE)
	$oRct.ServerStop(aRaw[1])
EndScenario()

# let the flood windows close and the queues drain before asking for truth
D1Pause(4200)

Scenario(":DropNewest keeps the FIRST cap messages and counts the rest")
	Given("a node with inbox cap 10 :DropNewest flooded with 30 while paused")
	When("it reports [ processed, overflow, survivors ]")
	vStats = D1Ask($aFA, [ "stats" ], 10000)
	Then("exactly 10 messages were processed", vStats[1], 10)
	Then("exactly 20 overflows were counted", vStats[2], 20)
	aWant = []
	for i = 1 to 10
		aWant + i
	next
	Then("the survivors are the FIRST ten, in order",
		D1PackEq(vStats[3], aWant), TRUE)
EndScenario()

Scenario(":DropOldest keeps the LAST cap messages and counts the rest")
	Given("a node with inbox cap 10 :DropOldest flooded with 30 while paused")
	When("it reports [ processed, overflow, survivors ]")
	vStats = D1Ask($aFB, [ "stats" ], 10000)
	Then("exactly 10 messages were processed", vStats[1], 10)
	Then("exactly 20 overflows were counted", vStats[2], 20)
	aWant = []
	for i = 21 to 30
		aWant + i
	next
	Then("the survivors are the LAST ten (21..30), in order",
		D1PackEq(vStats[3], aWant), TRUE)
EndScenario()

Scenario(":Refuse hangs up -- the SENDER observes the refusal")
	Given("a node with inbox cap 5 :Refuse flooded with 12 while paused")
	When("the guard waits for its own link to that node")
	bClosed = FALSE
	nDl = StzEngineWatchTimestampMs() + 8000
	while StzEngineWatchTimestampMs() < nDl
		aEv = $oRct.ServerPoll($aFC[1])
		if len(aEv) = 3 and aEv[1] = :closed
			bClosed = TRUE
			exit
		ok
	end
	Then("the flooding link was CLOSED on the sender", bClosed, TRUE)
	When("a fresh link asks the still-alive node for the truth")
	aFC2 = D1Connect($nPortFC, 8000)
	vStats = D1Ask(aFC2, [ "stats" ], 10000)
	Then("exactly 5 messages were processed", vStats[1], 5)
	Then("exactly 1 refusal was counted (the hang-up ended the flood)",
		vStats[2], 1)
	aWant = [ 1, 2, 3, 4, 5 ]
	Then("the survivors are the first five, in order",
		D1PackEq(vStats[3], aWant), TRUE)
	D1Send(aFC2, [ "stz.stop" ])
	$oRct.ServerStop(aFC2[1])
EndScenario()

Scenario("a handler that raises kills the node LOUDLY -- no wedge")
	Given("a second basic node and a link to it")
	aBoom = D1Connect($nPortBoom, 15000)
	Then("the link is up", aBoom[2] > 0, TRUE)
	When("the guard sends [ boom ] (the handler raises)")
	D1Send(aBoom, [ "boom" ])
	bClosed = FALSE
	nDl = StzEngineWatchTimestampMs() + 8000
	while StzEngineWatchTimestampMs() < nDl
		aEv = $oRct.ServerPoll(aBoom[1])
		if len(aEv) = 3 and aEv[1] = :closed
			bClosed = TRUE
			exit
		ok
	end
	Then("the node's death is observable: the link closed", bClosed, TRUE)
	n0 = StzEngineWatchTimestampMs()
	cOut = $oSpawner.AwaitSpawn(nJobBoom, 8000)
	nElapsed = StzEngineWatchTimestampMs() - n0
	Then("the OS process exited (no wedge, await returned early)",
		nElapsed < 7500, TRUE)
	Then("it did NOT reach the clean-shutdown marker",
		StzFindFirst("node-basic: done", cOut), 0)
	$oRct.ServerStop(aBoom[1])
EndScenario()

Scenario("stz.stop is a clean shutdown, observable in the exit marker")
	Given("the first basic node, still serving")
	When("the guard sends [ stz.stop ]")
	D1Send($aBasic, [ "stz.stop" ])
	cOut = $oSpawner.AwaitSpawn(nJobBasic, 8000)
	Then("the node ran its Run() to completion and printed its marker",
		StzFindFirst("node-basic: done", cOut) > 0, TRUE)
	$oRct.ServerStop($aBasic[1])
EndScenario()

Scenario("teardown: every child process is accounted for")
	Given("stop messages to the remaining flood nodes")
	D1Send($aFA, [ "stz.stop" ])
	D1Send($aFB, [ "stz.stop" ])
	cA = $oSpawner.AwaitSpawn(nJobFA, 8000)
	cB = $oSpawner.AwaitSpawn(nJobFB, 8000)
	Then("both flood nodes shut down cleanly",
		StzFindFirst("node-flood: done", cA) > 0 and
		StzFindFirst("node-flood: done", cB) > 0, TRUE)
	$oRct.ServerStop($aFA[1])
	$oRct.ServerStop($aFB[1])
	cR = $oSpawner.AwaitSpawn(nJobRaw, 8000)
	Then("the raw echo peer ended with the hangup",
		StzFindFirst("echo-server: done", cR) > 0, TRUE)
	# the refuse node exits on its TTL if stz.stop raced the reconnect;
	# await it long enough to prove it is not wedged either way
	$oSpawner.AwaitSpawn(nJobFC, 12000)
	$oRct.Destroy()
	$oSpawner.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- helpers (Ring hoists func defs) ---------------------------------

func D1RingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

# Dial until the peer's listener answers. Returns [ nChan, nConn ].
func D1Connect(nPort, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		_nChan_ = $oRct.ConnectStzm("127.0.0.1", nPort)
		_nConn_ = $oRct.WaitLinkUp(_nChan_, 1000)
		if _nConn_ > 0
			return [ _nChan_, _nConn_ ]
		ok
		$oRct.ServerStop(_nChan_)
		_nT_ = $oRct.SubmitTimer(200)
		$oRct.AwaitTimer(_nT_, 500)
	end
	return [ 0, 0 ]

func D1Send(aLink, vMsg)
	_cF_ = StzEngineStzmPack(vMsg, 0, 0, 0)
	$oRct.ServerWrite(aLink[1], aLink[2], _cF_, FALSE)

# Ask: reply-expected frame; busy-poll until the reply with the SAME
# correlation id arrives. Sets $bAskCorrOk. Returns the value ("" on
# timeout).
func D1Ask(aLink, vMsg, nTimeoutMs)
	$nCorr++
	_nWant_ = $nCorr
	_cF_ = StzEngineStzmPack(vMsg, 0, _nWant_, 2)
	$oRct.ServerWrite(aLink[1], aLink[2], _cF_, FALSE)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		_aEv_ = $oRct.ServerPoll(aLink[1])
		if len(_aEv_) = 3 and _aEv_[1] = :data
			_vR_ = StzEngineStzmUnpack(_aEv_[3])
			$bAskCorrOk = (StzEngineStzmLastCorrelation() = _nWant_)
			return _vR_
		ok
	end
	$bAskCorrOk = FALSE
	return ""

# One raw echo round-trip (pre-packed frame, busy-poll).
func D1RawTrip(aLink, cFrame, nTimeoutMs)
	$oRct.ServerWrite(aLink[1], aLink[2], cFrame, FALSE)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		_aEv_ = $oRct.ServerPoll(aLink[1])
		if len(_aEv_) = 3 and _aEv_[1] = :data
			return _aEv_[3]
		ok
	end
	return ""

# Deep equality proven THROUGH the encoder: identical values pack to
# identical bytes.
func D1PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)

func D1Median(aNums)
	_aS_ = sort(aNums)
	return _aS_[ceil(len(_aS_) / 2)]

func D1Pause(nMs)
	_nT_ = $oRct.SubmitTimer(nMs)
	$oRct.AwaitTimer(_nT_, nMs + 2000)
