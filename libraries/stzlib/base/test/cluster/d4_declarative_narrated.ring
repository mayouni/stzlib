# DISTRIBUTION D4 -- the declarative surface + pseudo-distributed
# RunLocal.
#
# The KILL CRITERION is the first scenario: a topology that cannot
# round-trip through its own description (declare -> describe ->
# redeclare identically) is not declarative yet. Here the description
# is plain DATA -- handlers are Ring code STRINGS (the W-string spirit:
# a closure cannot cross an OS process boundary; code-as-data can, and
# is inspectable on the way).
#
# Then the declaration RUNS: RunLocal() turns every declared node into
# a real child OS process under a real supervisor over the real STZM
# wire on loopback. The declaration is proven to REACH the running
# processes (stz.info reports the node's own view of its identity,
# binding and inbox contract), supervision heals a killed node, and
# Deploy(name, host) moves one node with ZERO caller changes -- the
# same Ask by name lands on the new host, and the node itself reports
# serving from there.

load "../../stzBase.ring"
load "../_narrated.ring"

$oPause = new stzReactor()

Scenario("KILL CRITERION: declare -> describe -> redeclare, identically")
	Given("a topology declared fluently: nodes, handlers-as-code, inbox, supervision")
	oApp = new stzNodeApp("shop")
	oApp.Node("indexer")
	oApp.On("embed", 'return [ "vec", aMsg[2] ]')
	oApp.On("boom", 'raise("indexer exploded")')
	oApp.Node("search")
	oApp.Requires([ "neural" ])
	oApp.On("query", 'return "found: " + aMsg[2]')
	oApp.InboxOf("indexer", 1000, :Refuse)
	oApp.Supervise([ "indexer", "search" ], :OneForOne)
	oApp.RestartBudget(4, 20000)
	When("the app describes itself")
	aDesc = oApp.Describe()
	Then("the description is plain DATA (a list, printable)", isList(aDesc), TRUE)
	Then("it names the app and both nodes",
		aDesc[2] = "shop" and ring_len(aDesc[3]) = 2, TRUE)
	When("a SECOND app is rebuilt from that description alone")
	oApp2 = StzNodeAppFromDescription(aDesc)
	Then("its description is IDENTICAL to the original",
		D4PackEq(aDesc, oApp2.Describe()), TRUE)
EndScenario()

Scenario("RunLocal: the declaration becomes real processes that serve")
	Given("a two-node app with handlers declared as code strings")
	$oApp = new stzNodeApp("d4shop")
	$oApp.Node("calc")
	$oApp.On("double", 'return aMsg[2] * 2')
	$oApp.On("boom", 'raise("calc exploded on purpose")')
	$oApp.Node("greeter")
	$oApp.On("greet", 'return "hello " + aMsg[2]')
	$oApp.InboxOf("calc", 64, :DropNewest)
	$oApp.Supervise([ "calc", "greeter" ], :OneForOne)
	When("RunLocal() starts the whole topology on this machine")
	$oApp.RunLocal()
	Then("both nodes boot and answer BY NAME",
		D4AwaitBoot("calc", 20000) and D4AwaitBoot("greeter", 20000), TRUE)
	vR = Ask("calc", [ "double", 21 ], 3000)
	Then("the declared calc handler runs (double 21 = 42)", vR, 42)
	vR = Ask("greeter", [ "greet", "node" ], 3000)
	Then("the declared greeter handler runs", vR, "hello node")
	When("calc is asked for ITS OWN view of its declaration (stz.info)")
	vInfo = Ask("calc", [ "stz.info" ], 3000)
	Then("it knows its name", vInfo[1], "calc")
	Then("it bound loopback", vInfo[2], "127.0.0.1")
	Then("the DECLARED inbox reached the running process (cap 64)",
		vInfo[3], 64)
	Then("with the declared policy", vInfo[4], "dropnewest")
EndScenario()

Scenario("supervision is live under RunLocal: a killed node heals")
	Given("the running d4shop topology")
	When("calc's raising handler kills it")
	Send("calc", [ "boom" ])
	bHealed = D4DriveUntil($oApp, "calc", 1, 25000)
	Then("the supervisor restarted it (counted once)",
		$oApp.RestartsOf("calc"), 1)
	Then("it answers again", D4AwaitBoot("calc", 20000), TRUE)
	vR = Ask("calc", [ "double", 8 ], 3000)
	Then("with its declared behavior intact", vR, 16)
EndScenario()

Scenario("Deploy: ONE line moves a node; no caller changes anything")
	Given("the running topology, calc living on 127.0.0.1")
	When("Deploy('calc', '127.0.0.2') -- the one changed line")
	$oApp.Deploy("calc", "127.0.0.2")
	D4DriveUntil($oApp, "calc", 2, 25000)
	Then("the move rode supervision (a counted respawn)",
		$oApp.RestartsOf("calc"), 2)
	Then("the SAME Ask by name still works", D4AwaitBoot("calc", 20000), TRUE)
	vR = Ask("calc", [ "double", 50 ], 3000)
	Then("and computes the same (double 50 = 100)", vR, 100)
	When("calc reports its own binding")
	vInfo = Ask("calc", [ "stz.info" ], 3000)
	Then("it now SERVES FROM the new host", vInfo[2], "127.0.0.2")
	Then("the greeter never noticed",
		Ask("greeter", [ "greet", "still" ], 3000), "hello still")
EndScenario()

Scenario("teardown: StopAll ends the topology and removes its artifacts")
	Given("the generated node scripts on disk")
	cF1 = ".stznode_d4shop_calc_gen.ring"
	cF2 = ".stznode_d4shop_greeter_gen.ring"
	Then("they existed while running", fexists(cF1) and fexists(cF2), TRUE)
	When("the app stops")
	$oApp.StopAll()
	Then("the generated scripts are gone", fexists(cF1) or fexists(cF2), FALSE)
	StzNodePlane().Destroy()
	$oPause.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- helpers ---------------------------------------------------------

func D4AwaitBoot(cAddr, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		Ask(cAddr, [ "stz.info" ], 1000)
		if NodeAskStatus() = :Ok
			return TRUE
		ok
	end
	return FALSE

func D4DriveUntil(oApp, cChild, nWant, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		oApp.Cycle()
		if oApp.RestartsOf(cChild) >= nWant
			return TRUE
		ok
		_nT_ = $oPause.SubmitTimer(100)
		$oPause.AwaitTimer(_nT_, 500)
	end
	return FALSE

func D4PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)
