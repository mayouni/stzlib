# DISTRIBUTION D2 -- registry + location-transparent Send/Ask.
#
# The phase's ONE JOB: the caller's code must be identical whether the
# node is a local child or a machine across the wire. So this guard's
# central instrument is a single test body -- D2Body(cAddr) -- run TWICE:
# once against a LOCAL child ("worker"), once against a REMOTE-simulated
# child on another port addressed as name@host ("far@127.0.0.1"). The
# two runs must produce IDENTICAL results from IDENTICAL caller code;
# the kill criterion ("any API where the caller must know locality")
# fails the moment those bodies would need to differ.
#
# Also proven here, because Ask's honesty is the plane's honesty:
# - the timeout is MANDATORY (a non-positive one is refused)
# - a timed-out Ask's LATE reply is discarded by correlation id, never
#   mis-delivered to the next Ask (at-most-once residue)
# - unreachable and unregistered are distinct, observable verdicts
#   (:Down / :Unknown), and a died-mid-conversation peer is :Down

load "../../stzBase.ring"
load "../_narrated.ring"

$oSpawner = new stzReactor()

nBase = 45900 + (StzEngineTimeNowMs() % 200)
$nPortLocal = nBase
$nPortFar   = nBase + 1
$nPortDoom  = nBase + 2

cExe = D2RingExe()
nJobLocal = $oSpawner.SubmitSpawn([ cExe, "_d2_worker.ring", "" + $nPortLocal ])
nJobFar   = $oSpawner.SubmitSpawn([ cExe, "_d2_worker.ring", "" + $nPortFar ])
nJobDoom  = $oSpawner.SubmitSpawn([ cExe, "_d1_node_basic.ring", "" + $nPortDoom ])

# the registry: a local name, a far name (addressed via @host), a name
# registered at a port where NOTHING listens, and the doomed node
NodeRegister("worker", "127.0.0.1", $nPortLocal)
NodeRegister("far", "127.0.0.1", $nPortFar)
NodeRegister("ghost", "127.0.0.1", 49996)
NodeRegister("doomed", "127.0.0.1", $nPortDoom)

D2AwaitBoot("worker", 15000)
D2AwaitBoot("far@127.0.0.1", 15000)
D2AwaitBoot("doomed", 15000)

Scenario("the SAME caller body runs against local and remote -- identically")
	Given("one test body, parameterized ONLY by the address string")
	When("it runs against the local child ('worker')")
	aLocal = D2Body("worker")
	Then("the local run completed its whole conversation", aLocal[1], :Ok)
	When("it runs against the remote-simulated child ('far@127.0.0.1')")
	aFar = D2Body("far@127.0.0.1")
	Then("the remote run completed its whole conversation", aFar[1], :Ok)
	Then("the two runs produced IDENTICAL results", D2PackEq(aLocal, aFar), TRUE)
EndScenario()

Scenario("Ask's timeout is mandatory -- infinite waits do not exist")
	Given("a live node and a non-positive timeout")
	vR = Ask("worker", [ "ping", 1 ], 0)
	Then("the ask is refused outright", NodeAskStatus(), :BadTimeout)
	Then("nothing was returned", vR, "")
EndScenario()

Scenario("a timed-out Ask leaves no residue: the late reply is discarded")
	Given("a handler that takes ~800 ms and an Ask that waits only 200")
	vR = Ask("worker", [ "slow", 7 ], 200)
	Then("the ask timed out", NodeAskStatus(), :Timeout)
	When("the very next Ask runs on the same link")
	vR2 = Ask("worker", [ "ping", 99 ], 3000)
	Then("it gets ITS OWN reply, not the stale slow one",
		D2PackEq(vR2, [ "pong", 99 ]), TRUE)
	Then("and the plane reports :Ok again", NodeAskStatus(), :Ok)
EndScenario()

Scenario("unreachable and unregistered are distinct, observable verdicts")
	Given("a name registered where nothing listens")
	vR = Ask("ghost", [ "ping", 1 ], 1500)
	Then("the verdict is :Down", NodeAskStatus(), :Down)
	Given("a name never registered at all")
	vR = Ask("never-was", [ "ping", 1 ], 1500)
	Then("the verdict is :Unknown", NodeAskStatus(), :Unknown)
	Given("a send to the same unknown name")
	bSent = Send("never-was", [ "warm" ])
	Then("the send reports failure, not silence", bSent, FALSE)
EndScenario()

Scenario("a peer that dies mid-conversation becomes :Down, then recovers as :Down too")
	Given("a doomed node that answers normally first")
	vR = Ask("doomed", [ "ping", 5 ], 3000)
	Then("it answered while alive", D2PackEq(vR, [ "pong", 5 ]), TRUE)
	When("its raising handler kills it and the guard asks again")
	Send("doomed", [ "boom" ])
	vR = Ask("doomed", [ "ping", 6 ], 3000)
	cV1 = NodeAskStatus()
	if cV1 = :Ok
		# the boom raced the ask; the NEXT ask must see the death
		vR = Ask("doomed", [ "ping", 7 ], 3000)
		cV1 = NodeAskStatus()
	ok
	Then("the death is a plain :Down or :Timeout verdict, never a hang",
		cV1 = :Down or cV1 = :Timeout, TRUE)
	When("the guard asks once more (re-dial against a dead port)")
	vR = Ask("doomed", [ "ping", 8 ], 3000)
	Then("still :Down -- unreachable and dead are the same observable",
		NodeAskStatus(), :Down)
EndScenario()

Scenario("teardown: both workers stop cleanly through the SAME surface")
	Given("stz.stop sent by NAME, local and remote alike")
	Send("worker", [ "stz.stop" ])
	Send("far@127.0.0.1", [ "stz.stop" ])
	cL = $oSpawner.AwaitSpawn(nJobLocal, 8000)
	cF = $oSpawner.AwaitSpawn(nJobFar, 8000)
	Then("both exited with the clean marker",
		StzFindFirst("d2-worker: done", cL) > 0 and
		StzFindFirst("d2-worker: done", cF) > 0, TRUE)
	$oSpawner.AwaitSpawn(nJobDoom, 5000)
	StzNodePlane().Destroy()
	$oSpawner.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- the ONE body (identical caller code for any locality) -----------

# Runs the whole conversation against whatever address it is given and
# returns every observation. NOTHING in here knows where the node is.
func D2Body(cAddr)
	_aOut_ = []
	_vPing_ = Ask(cAddr, [ "ping", 42 ], 3000)
	if NodeAskStatus() != :Ok
		return [ NodeAskStatus() ]
	ok
	_aOut_ + _vPing_
	for _i_ = 1 to 10
		Send(cAddr, [ "seq", _i_ ])
	next
	_vSeq_ = Ask(cAddr, [ "drain" ], 3000)
	if NodeAskStatus() != :Ok
		return [ NodeAskStatus() ]
	ok
	_aOut_ + _vSeq_
	_vEcho_ = Ask(cAddr, [ "echo", [ "nested", [ 1.5, "deep" ] ], 7 ], 3000)
	if NodeAskStatus() != :Ok
		return [ NodeAskStatus() ]
	ok
	_aOut_ + _vEcho_
	return [ :Ok, _aOut_ ]

#--- helpers ---------------------------------------------------------

func D2RingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

# Wait (bounded) until a spawned node answers pings at its address.
func D2AwaitBoot(cAddr, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		Ask(cAddr, [ "ping", 0 ], 1000)
		if NodeAskStatus() = :Ok
			return TRUE
		ok
	end
	return FALSE

func D2PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)
