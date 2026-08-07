# DISTRIBUTION D6 -- THE SUCCESS SCENE, stated up front in the plan:
#
#   "The plan succeeds when the semantic-search demo from the neural
#    module runs as stzNodeApp with the indexer on a second machine --
#    same guard assertions, one changed line (Deploy) -- and when
#    killing the indexer process mid-run produces a supervised restart
#    and a clean timeout instead of a hang."
#
# The indexer node BOOTS its resident state (BERT model + embedded
# corpus) from its declaration -- so a supervised restart REBUILDS the
# index, because a fresh process has no memory but its boot knows how
# to make some. The assertion body below is D6Assertions(): the same
# meaning-not-keywords assertions as the neural module's
# semantic_search_narrated.ring, now flowing through Ask("indexer", ...)
# -- and it runs UNCHANGED before and after the ONE deploy line.
# (127.0.0.2 stands in for the second machine: RunLocal is the
# pseudo-distributed mode -- same wire, same semantics, only the
# latency of a real second machine differs.)
#
# On a machine without the model file the scene is SKIPPED and says so
# -- a missing capability is reported, never silently green.

load "../../stzBase.ring"
load "../_narrated.ring"

$oPause = new stzReactor()
$cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"

if NOT fexists($cModel)
	? "MODEL FILE NOT PRESENT (" + $cModel + ")"
	? "The D6 scene needs it. SKIPPED -- reported, not silently green."
	? "STATUS: SKIPPED"
	bye
ok

Scenario("the semantic-search demo becomes a NODE APP declaration")
	Given("an app whose indexer node boots the model + corpus and serves search")
	$oApp = new stzNodeApp("semsearch")
	$oApp.Node("indexer")
	$oApp.Boot(D6BootCode())
	$oApp.On("search", 'return $oIdx.SearchXT(aMsg[2], aMsg[3])')
	$oApp.On("count", 'return $oIdx.Count()')
	$oApp.On("dim", 'return $oIdx.EmbeddingDim()')
	$oApp.Supervise([ "indexer" ], :OneForOne)
	$oApp.NodeTtl(300000)
	When("the topology runs")
	$oApp.RunLocal()
	Then("the indexer boots (model loaded, corpus embedded)",
		D6AwaitBoot("indexer", 90000), TRUE)
	Then("eight documents are indexed", Ask("indexer", [ "count" ], 5000), 8)
	Then("the embedding dimension is MiniLM's 384",
		Ask("indexer", [ "dim" ], 5000), 384)
EndScenario()

Scenario("the SAME assertions as the neural guard, over the node plane")
	Given("the assertion body of semantic_search_narrated, asking by NAME")
	$aLocalRun = D6Assertions()
	Then("'How do I bake bread?' retrieves BOTH baking sentences (no shared keyword)",
		$aLocalRun[1], TRUE)
	Then("'Will the weather be nice?' retrieves both weather sentences",
		$aLocalRun[2], TRUE)
	Then("'My program runs slowly' lands on a programming sentence",
		$aLocalRun[3], TRUE)
	Then("scores come back best-first", $aLocalRun[4], TRUE)
	Then("every score is a cosine in [-1, 1]", $aLocalRun[5], TRUE)
	Then("a verbatim query finds itself at ~1", $aLocalRun[6], TRUE)
EndScenario()

Scenario("ONE changed line moves the indexer to the second machine")
	Given("the running app and the single line the plan promised")
	$oApp.Deploy("indexer", "127.0.0.2")
	When("supervision carries the move and the indexer re-boots THERE")
	D6DriveUntil($oApp, "indexer", 1, 30000)
	Then("the deploy rode supervision (a counted respawn)",
		$oApp.RestartsOf("indexer") >= 1, TRUE)
	Then("the indexer answers again", D6AwaitBoot("indexer", 90000), TRUE)
	vInfo = Ask("indexer", [ "stz.info" ], 5000)
	Then("it now serves FROM the second machine", vInfo[2], "127.0.0.2")
	When("the IDENTICAL assertion body runs again -- zero caller changes")
	aFarRun = D6Assertions()
	Then("every assertion passes on the deployed indexer",
		aFarRun[1] and aFarRun[2] and aFarRun[3] and aFarRun[4] and
		aFarRun[5] and aFarRun[6], TRUE)
	Then("local and deployed runs agree EXACTLY (results + winning texts)",
		D6PackEq($aLocalRun, aFarRun), TRUE)
EndScenario()

Scenario("a mid-run KILL heals: clean timeout, supervised restart, no hang")
	Given("the live deployed indexer")
	When("its process is killed and an Ask goes out MID-RUN")
	$oApp.KillNode("indexer")
	n0 = StzEngineWatchTimestampMs()
	vR = Ask("indexer", [ "search", "How do I bake bread?", 2 ], 3000)
	nElapsed = StzEngineWatchTimestampMs() - n0
	Then("the in-flight Ask fails PLAINLY (no ghost reply)",
		NodeAskStatus() != :Ok, TRUE)
	Then("and returns within its timeout -- a clean timeout, never a hang",
		nElapsed < 6000, TRUE)
	When("supervision cycles")
	D6DriveUntil($oApp, "indexer", 2, 30000)
	Then("the restart was counted", $oApp.RestartsOf("indexer") >= 2, TRUE)
	Then("the reborn indexer serves again (boot rebuilt the index)",
		D6AwaitBoot("indexer", 90000), TRUE)
	aReborn = D6Assertions()
	Then("with every semantic assertion intact after the restart",
		aReborn[1] and aReborn[2] and aReborn[3] and aReborn[4] and
		aReborn[5] and aReborn[6], TRUE)
EndScenario()

Scenario("teardown")
	$oApp.StopAll()
	StzNodePlane().Destroy()
	$oPause.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- the ONE assertion body (identical before/after Deploy) ----------

# The semantic assertions of semantic_search_narrated.ring, expressed
# through the node plane. Returns booleans + the winning texts so the
# local and deployed runs can be compared EXACTLY.
func D6Assertions()
	_aHits_ = Ask("indexer", [ "search", "How do I bake bread?", 2 ], 15000)
	_cBoth_ = _aHits_[1][1] + _aHits_[2][1]
	_b1_ = (StzFindFirst("dough", _cBoth_) > 0) and (StzFindFirst("flour", _cBoth_) > 0)
	_aW_ = Ask("indexer", [ "search", "Will the weather be nice?", 2 ], 15000)
	_cWB_ = _aW_[1][1] + _aW_[2][1]
	_b2_ = (StzFindFirst("rain", _cWB_) > 0) and (StzFindFirst("Sunny", _cWB_) > 0)
	_aC_ = Ask("indexer", [ "search", "My program runs slowly", 1 ], 15000)
	_b3_ = StzFindFirst("compiler", _aC_[1][1]) > 0 or StzFindFirst("garbage", _aC_[1][1]) > 0
	_aAll_ = Ask("indexer", [ "search", "How do I bake bread?", 8 ], 15000)
	_b4_ = TRUE
	for _i_ = 2 to len(_aAll_)
		if _aAll_[_i_][2] > _aAll_[_i_ - 1][2]
			_b4_ = FALSE
		ok
	next
	_b5_ = TRUE
	for _i_ = 1 to len(_aAll_)
		if _aAll_[_i_][2] < -1.000001 or _aAll_[_i_][2] > 1.000001
			_b5_ = FALSE
		ok
	next
	_aS_ = Ask("indexer", [ "search",
		"The compiler optimizes the inner loop aggressively", 1 ], 15000)
	_b6_ = (StzFindFirst("compiler", _aS_[1][1]) > 0) and (_aS_[1][2] > 0.999)
	return [ _b1_, _b2_, _b3_, _b4_, _b5_, _b6_,
		_aHits_[1][1], _aW_[1][1], _aC_[1][1], _aS_[1][1] ]

#--- helpers ---------------------------------------------------------

# The indexer's BOOT: the resident state a fresh process rebuilds.
func D6BootCode()
	_cN_ = char(10)
	return 'oM = new stzNeuralModel("' + $cModel + '")' + _cN_ +
		'$oIdx = new stzSemanticIndex([' + _cN_ +
		'"The oven must be preheated before the dough goes in",' + _cN_ +
		'"The compiler optimizes the inner loop aggressively",' + _cN_ +
		'"A cold front brings heavy rain tomorrow morning",' + _cN_ +
		'"Knead the flour and water until the mixture is elastic",' + _cN_ +
		'"The unit tests cover every branch of the parser",' + _cN_ +
		'"Sunny skies are expected for the whole weekend",' + _cN_ +
		'"Whisk the eggs with sugar until the cream thickens",' + _cN_ +
		'"The garbage collector pauses the virtual machine briefly"' + _cN_ +
		'])'

func D6AwaitBoot(cAddr, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		Ask(cAddr, [ "stz.info" ], 2000)
		if NodeAskStatus() = :Ok
			return TRUE
		ok
	end
	return FALSE

func D6DriveUntil(oApp, cChild, nWant, nTimeoutMs)
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

func D6PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)
