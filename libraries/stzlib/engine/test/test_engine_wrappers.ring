# Test Ring-side engine wrapper classes
# Loads each engine DLL directly and exercises the Ring bridge functions
# Run: D:\Ring126\bin\ring.exe test_engine_wrappers.ring

cBaseDir = currentdir()
# Resolve absolute path: strip \base\test to get stzlib root
cStzlibDir = substr(cBaseDir, 1, len(cBaseDir) - len("\base\test"))
cDllDir = cStzlibDir + "\engine\zig-out\bin\"

$nPass = 0
$nFail = 0

# ===================================================================
? "=== Softanza Engine Wrapper Tests ==="
? ""

# -------------------------------------------------------------------
? "--- 1. Sequence (stz_sequence) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_sequence")
	StzEngineSeqClear()
	nResult = StzEngineSeqCreate("counter", 0, 1, 0)
	AssertTrue("seq create", nResult >= 0)
	AssertEqual("seq next 0", 0, StzEngineSeqNext("counter"))
	AssertEqual("seq next 1", 1, StzEngineSeqNext("counter"))
	AssertEqual("seq next 2", 2, StzEngineSeqNext("counter"))
	AssertEqual("seq current", 3, StzEngineSeqCurrent("counter"))
	AssertEqual("seq iteration", 3, StzEngineSeqIteration("counter"))
	StzEngineSeqReset("counter")
	AssertEqual("seq reset current", 0, StzEngineSeqCurrent("counter"))
	AssertEqual("seq count", 1, StzEngineSeqCount())
	StzEngineSeqDestroy("counter")
	AssertEqual("seq after destroy", 0, StzEngineSeqCount())
	StzEngineSeqClear()
	? "  sequence: done"
ok

# -------------------------------------------------------------------
? "--- 2. Confidence (stz_confidence) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_confidence")
	StzEngineConfClear()
	nResult = StzEngineConfSet("accuracy", 0.95, 1.0)
	AssertTrue("conf set", nResult >= 0)
	nScore = StzEngineConfGet("accuracy")
	AssertTrue("conf get ~0.95", nScore > 0.94 and nScore < 0.96)
	nResult2 = StzEngineConfSet("recall", 0.80, 2.0)
	AssertTrue("conf set 2", nResult2 >= 0)
	AssertEqual("conf count", 2, StzEngineConfCount())
	nAvg = StzEngineConfWeightedAvg()
	AssertTrue("conf weighted avg", nAvg > 0.84 and nAvg < 0.87)
	StzEngineConfRemove("accuracy")
	AssertEqual("conf after remove", 1, StzEngineConfCount())
	StzEngineConfClear()
	? "  confidence: done"
ok

# -------------------------------------------------------------------
? "--- 3. Provenance (stz_provenance) ---"
# Bridge: StzEngineProvAdd(entity, origin, author, time) -> index
# Bridge: StzEngineProvOrigin/Author/Version/BumpVersion take INDEX not name
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_provenance")
	StzEngineProvClear()
	nIdx = StzEngineProvAdd("dataset1", "csv_import", "admin", 1000)
	AssertTrue("prov add", nIdx >= 0)
	cOrigin = StzEngineProvOrigin(nIdx)
	AssertEqual("prov origin", "csv_import", cOrigin)
	cAuthor = StzEngineProvAuthor(nIdx)
	AssertEqual("prov author", "admin", cAuthor)
	AssertEqual("prov version", 1, StzEngineProvVersion(nIdx))
	StzEngineProvBumpVersion(nIdx)
	AssertEqual("prov version bumped", 2, StzEngineProvVersion(nIdx))
	AssertEqual("prov count", 1, StzEngineProvCount())
	StzEngineProvClear()
	? "  provenance: done"
ok

# -------------------------------------------------------------------
? "--- 4. Relation (stz_relations) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_relations")
	StzEngineRelClear()
	nIdx = StzEngineRelAdd("cat", "is_a", "animal", 1.0)
	AssertTrue("rel add", nIdx >= 0)
	nIdx2 = StzEngineRelAdd("dog", "is_a", "animal", 1.0)
	AssertTrue("rel add 2", nIdx2 >= 0)
	AssertEqual("rel count", 2, StzEngineRelCount())
	cSubj = StzEngineRelSubject(nIdx)
	AssertEqual("rel subject", "cat", cSubj)
	cObj = StzEngineRelObject(nIdx)
	AssertEqual("rel object", "animal", cObj)
	cType = StzEngineRelType(nIdx)
	AssertEqual("rel type", "is_a", cType)
	nWeight = StzEngineRelWeight(nIdx)
	AssertTrue("rel weight 1.0", nWeight > 0.99 and nWeight < 1.01)
	StzEngineRelRemove(nIdx)
	AssertEqual("rel after remove", 1, StzEngineRelCount())
	StzEngineRelClear()
	? "  relation: done"
ok

# -------------------------------------------------------------------
? "--- 5. Intent (stz_intent) ---"
# Bridge: SetParam not AddParam, GetParam not ParamValue, no Name
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_intent")
	StzEngineIntentClear()
	nHandle = StzEngineIntentCreate("search", 5)
	AssertTrue("intent create", nHandle >= 0)
	nResult = StzEngineIntentSetParam(nHandle, "query", "hello")
	AssertTrue("intent set param", nResult >= 0)
	AssertEqual("intent param count", 1, StzEngineIntentParamCount(nHandle))
	cVal = StzEngineIntentGetParam(nHandle, "query")
	AssertEqual("intent get param", "hello", cVal)
	AssertEqual("intent priority", 5, StzEngineIntentPriority(nHandle))
	AssertEqual("intent count", 1, StzEngineIntentCount())
	StzEngineIntentDestroy(nHandle)
	AssertEqual("intent after destroy", 0, StzEngineIntentCount())
	StzEngineIntentClear()
	? "  intent: done"
ok

# -------------------------------------------------------------------
? "--- 6. Resource (stz_resource) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_resource")
	StzEngineResClear()
	nResult = StzEngineResRegister("db_conn", "connection")
	AssertTrue("res register", nResult >= 0)
	AssertEqual("res state free", 0, StzEngineResState("db_conn"))
	StzEngineResAcquire("db_conn")
	AssertEqual("res state acquired", 1, StzEngineResState("db_conn"))
	StzEngineResRelease("db_conn")
	AssertEqual("res state released", 2, StzEngineResState("db_conn"))
	AssertEqual("res count", 1, StzEngineResCount())
	AssertEqual("res leaked", 0, StzEngineResLeakedCount())
	StzEngineResAcquire("db_conn")
	AssertEqual("res leaked after acquire", 1, StzEngineResLeakedCount())
	StzEngineResRelease("db_conn")
	AssertEqual("res acquire count", 2, StzEngineResAcquireCount("db_conn"))
	StzEngineResClear()
	? "  resource: done"
ok

# -------------------------------------------------------------------
? "--- 7. Context (stz_context) ---"
# Bridge: Create(name_str, parent_idx_num)
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_context")
	StzEngineContextClear()
	nHandle = StzEngineContextCreate("main", -1)
	AssertTrue("ctx create", nHandle >= 0)
	nResult = StzEngineContextSet(nHandle, "user", "alice")
	AssertTrue("ctx set", nResult >= 0)
	cVal = StzEngineContextGet(nHandle, "user")
	AssertEqual("ctx get", "alice", cVal)
	AssertEqual("ctx has", 1, StzEngineContextHas(nHandle, "user"))
	AssertEqual("ctx has missing", 0, StzEngineContextHas(nHandle, "nope"))
	AssertEqual("ctx pair count", 1, StzEngineContextPairCount(nHandle))
	# child context inherits parent
	nChild = StzEngineContextCreate("child", nHandle)
	cInherited = StzEngineContextGet(nChild, "user")
	AssertEqual("ctx child inherits", "alice", cInherited)
	AssertEqual("ctx scope count", 2, StzEngineContextScopeCount())
	StzEngineContextDestroy(nHandle)
	AssertEqual("ctx after destroy", 1, StzEngineContextScopeCount())
	StzEngineContextClear()
	? "  context: done"
ok

# -------------------------------------------------------------------
? "--- 8. Similarity (stz_similarity) ---"
# Bridge: DotProduct3 not Dot3
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_similarity")
	nCos = StzEngineSimCosine3(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
	AssertTrue("sim cosine same", nCos > 0.99)
	nCos2 = StzEngineSimCosine3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0)
	AssertTrue("sim cosine orthogonal", nCos2 > -0.01 and nCos2 < 0.01)
	nEuc = StzEngineSimEuclidean3(0.0, 0.0, 0.0, 3.0, 4.0, 0.0)
	AssertTrue("sim euclidean", nEuc > 4.99 and nEuc < 5.01)
	nMan = StzEngineSimManhattan3(0.0, 0.0, 0.0, 3.0, 4.0, 5.0)
	AssertTrue("sim manhattan", nMan > 11.99 and nMan < 12.01)
	nDot = StzEngineSimDotProduct3(2.0, 3.0, 4.0, 1.0, 1.0, 1.0)
	AssertTrue("sim dot product", nDot > 8.99 and nDot < 9.01)
	? "  similarity: done"
ok

# -------------------------------------------------------------------
? "--- 9. Schema (stz_schema) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_schema")
	StzEngineSchemaClear()
	nHandle = StzEngineSchemaCreate("user")
	AssertTrue("schema create", nHandle >= 0)
	nF1 = StzEngineSchemaAddField(nHandle, "name", 0, 1)
	AssertTrue("schema add field", nF1 >= 0)
	nF2 = StzEngineSchemaAddField(nHandle, "age", 1, 1)
	nF3 = StzEngineSchemaAddField(nHandle, "email", 0, 0)
	AssertEqual("schema field count", 3, StzEngineSchemaFieldCount(nHandle))
	cFieldName = StzEngineSchemaFieldName(nHandle, 0)
	AssertEqual("schema field name", "name", cFieldName)
	AssertEqual("schema field type", 1, StzEngineSchemaFieldType(nHandle, 1))
	AssertEqual("schema field required", 1, StzEngineSchemaFieldRequired(nHandle, 0))
	AssertEqual("schema field not required", 0, StzEngineSchemaFieldRequired(nHandle, 2))
	AssertEqual("schema count", 1, StzEngineSchemaCount())
	StzEngineSchemaDestroy(nHandle)
	AssertEqual("schema after destroy", 0, StzEngineSchemaCount())
	StzEngineSchemaClear()
	? "  schema: done"
ok

# -------------------------------------------------------------------
? "--- 10. Topology (stz_topology) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_topology")
	StzEngineTopoClear()
	StzEngineTopoAddNode("A")
	StzEngineTopoAddNode("B")
	StzEngineTopoAddNode("C")
	AssertEqual("topo node count", 3, StzEngineTopoNodeCount())
	StzEngineTopoAddEdge("A", "B")
	AssertEqual("topo neighbors", 1, StzEngineTopoAreNeighbors("A", "B"))
	AssertEqual("topo not neighbors", 0, StzEngineTopoAreNeighbors("A", "C"))
	AssertEqual("topo neighbor count", 1, StzEngineTopoNeighborCount("A"))
	StzEngineTopoRemoveNode("C")
	AssertEqual("topo after remove", 2, StzEngineTopoNodeCount())
	StzEngineTopoClear()
	? "  topology: done"
ok

# -------------------------------------------------------------------
? "--- 11. Embedding (stz_embedding) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_embedding")
	StzEngineEmbClear()
	nResult = StzEngineEmbStore3("cat", 1.0, 0.0, 0.0)
	AssertTrue("emb store", nResult >= 0)
	nResult2 = StzEngineEmbStore3("dog", 0.9, 0.1, 0.0)
	AssertTrue("emb store 2", nResult2 >= 0)
	AssertEqual("emb has", 1, StzEngineEmbHas("cat"))
	AssertEqual("emb not has", 0, StzEngineEmbHas("fish"))
	AssertEqual("emb dim", 3, StzEngineEmbDim("cat"))
	nCos = StzEngineEmbCosine("cat", "dog")
	AssertTrue("emb cosine high", nCos > 0.9)
	AssertEqual("emb count", 2, StzEngineEmbCount())
	StzEngineEmbRemove("cat")
	AssertEqual("emb after remove", 1, StzEngineEmbCount())
	StzEngineEmbClear()
	? "  embedding: done"
ok

# -------------------------------------------------------------------
? "--- 12. Explain (stz_explain) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_explain")
	StzEngineExplClear()
	nResult = StzEngineExplAdd("high_score", "Score above threshold", "quality")
	AssertTrue("expl add", nResult >= 0)
	cText = StzEngineExplGet("high_score")
	AssertEqual("expl get", "Score above threshold", cText)
	cCat = StzEngineExplCategory("high_score")
	AssertEqual("expl category", "quality", cCat)
	AssertEqual("expl has", 1, StzEngineExplHas("high_score"))
	AssertEqual("expl not has", 0, StzEngineExplHas("nope"))
	StzEngineExplAdd("low_latency", "Response time under 100ms", "performance")
	AssertEqual("expl count", 2, StzEngineExplCount())
	AssertEqual("expl count by cat", 1, StzEngineExplCountByCategory("quality"))
	StzEngineExplRemove("high_score")
	AssertEqual("expl after remove", 1, StzEngineExplCount())
	StzEngineExplClear()
	? "  explain: done"
ok

# -------------------------------------------------------------------
? "--- 13. Timeline (stz_timeline) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_timeline")
	StzEngineTimelineClear()
	nResult = StzEngineTimelineAddEvent("start", 100)
	AssertTrue("tl add event", nResult >= 0)
	StzEngineTimelineAddEvent("middle", 200)
	StzEngineTimelineAddEvent("end", 300)
	AssertEqual("tl event count", 3, StzEngineTimelineEventCount())
	cLabel = StzEngineTimelineEventLabel(0)
	AssertEqual("tl event label", "start", cLabel)
	AssertEqual("tl event time", 100, StzEngineTimelineEventTime(0))
	nDur = StzEngineTimelineDuration(0, 2)
	AssertEqual("tl duration", 200, nDur)
	nBetween = StzEngineTimelineEventsBetween(100, 200)
	AssertEqual("tl events between", 2, nBetween)
	StzEngineTimelineRemove(1)
	AssertEqual("tl after remove", 2, StzEngineTimelineEventCount())
	StzEngineTimelineClear()
	? "  timeline: done"
ok

# -------------------------------------------------------------------
? "--- 14. GridNav (stz_gridnav) ---"
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_gridnav")
	StzEngineGridCreate(5, 5)
	AssertEqual("grid row", 0, StzEngineGridGetRow())
	AssertEqual("grid col", 0, StzEngineGridGetCol())
	StzEngineGridSetPos(2, 3)
	AssertEqual("grid set row", 2, StzEngineGridGetRow())
	AssertEqual("grid set col", 3, StzEngineGridGetCol())
	nResult = StzEngineGridMove(2)  # down (0=up, 1=right, 2=down, 3=left)
	AssertTrue("grid move down", nResult >= 0)
	AssertEqual("grid after move", 3, StzEngineGridGetRow())
	AssertEqual("grid valid", 1, StzEngineGridIsValid(4, 4))
	AssertEqual("grid invalid", 0, StzEngineGridIsValid(5, 0))
	nDist = StzEngineGridDistance(3, 3, 0, 0)
	AssertTrue("grid distance", nDist > 0)
	StzEngineGridReset()
	AssertEqual("grid reset row", 0, StzEngineGridGetRow())
	? "  gridnav: done"
ok

# -------------------------------------------------------------------
? "--- 15. Interaction (stz_interact) ---"
# Bridge: Create(name_str, mode_str), AddTurn(handle, prompt, response, confidence)
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_interact")
	StzEngineInteractClear()
	nHandle = StzEngineInteractCreate("chat1", "qa")
	AssertTrue("interact create", nHandle >= 0)
	nResult = StzEngineInteractAddTurn(nHandle, "hello", "hi there", 1)
	AssertTrue("interact add turn", nResult >= 0)
	StzEngineInteractAddTurn(nHandle, "how are you?", "I am fine", 1)
	AssertEqual("interact turn count", 2, StzEngineInteractTurnCount(nHandle))
	cPrompt = StzEngineInteractPrompt(nHandle, 0)
	AssertEqual("interact prompt", "hello", cPrompt)
	cResp = StzEngineInteractResponse(nHandle, 0)
	AssertEqual("interact response", "hi there", cResp)
	cLast = StzEngineInteractLastPrompt(nHandle)
	AssertEqual("interact last prompt", "how are you?", cLast)
	AssertEqual("interact session count", 1, StzEngineInteractSessionCount())
	cMode = StzEngineInteractMode(nHandle)
	AssertTrue("interact mode", len(cMode) > 0)
	StzEngineInteractDestroy(nHandle)
	AssertEqual("interact after destroy", 0, StzEngineInteractSessionCount())
	StzEngineInteractClear()
	? "  interaction: done"
ok

# -------------------------------------------------------------------
? "--- 16. Skill (stz_skill) ---"
# Bridge: Register(name, category) - no max_level param
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_skill")
	StzEngineSkillClear()
	nResult = StzEngineSkillRegister("sorting", "algorithms")
	AssertTrue("skill register", nResult >= 0)
	AssertEqual("skill level 0", 0, StzEngineSkillLevel("sorting"))
	StzEngineSkillRecordAttempt("sorting", 1)
	StzEngineSkillRecordAttempt("sorting", 1)
	StzEngineSkillRecordAttempt("sorting", 0)
	AssertEqual("skill attempts", 3, StzEngineSkillAttempts("sorting"))
	AssertEqual("skill successes", 2, StzEngineSkillSuccesses("sorting"))
	nScore = StzEngineSkillScore("sorting")
	AssertTrue("skill score ~0.67", nScore > 0.6 and nScore < 0.7)
	AssertEqual("skill count", 1, StzEngineSkillCount())
	StzEngineSkillRegister("searching", "algorithms")
	AssertEqual("skill count 2", 2, StzEngineSkillCount())
	AssertEqual("skill by cat", 2, StzEngineSkillCountByCategory("algorithms"))
	StzEngineSkillAddPrereq("searching", "sorting")
	AssertEqual("skill prereqs not met", 0, StzEngineSkillPrereqsMet("searching"))
	StzEngineSkillUnregister("sorting")
	AssertEqual("skill after unregister", 1, StzEngineSkillCount())
	StzEngineSkillClear()
	? "  skill: done"
ok

# -------------------------------------------------------------------
? "--- 17. StateMachine (stz_statemachine) ---"
# Bridge: SetState not SetInitial, Send not SendEvent
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_statemachine")
	StzEngineFsmClear()
	nHandle = StzEngineFsmCreate("traffic")
	AssertTrue("fsm create", nHandle >= 0)
	StzEngineFsmAddState(nHandle, "red")
	StzEngineFsmAddState(nHandle, "green")
	StzEngineFsmAddState(nHandle, "yellow")
	StzEngineFsmSetState(nHandle, "red")
	StzEngineFsmAddTransition(nHandle, "red", "go", "green")
	StzEngineFsmAddTransition(nHandle, "green", "slow", "yellow")
	StzEngineFsmAddTransition(nHandle, "yellow", "stop", "red")
	cState = StzEngineFsmCurrentState(nHandle)
	AssertEqual("fsm initial state", "red", cState)
	nResult = StzEngineFsmSend(nHandle, "go")
	AssertTrue("fsm send event", nResult >= 0)
	cState2 = StzEngineFsmCurrentState(nHandle)
	AssertEqual("fsm after go", "green", cState2)
	StzEngineFsmSend(nHandle, "slow")
	AssertEqual("fsm after slow", "yellow", StzEngineFsmCurrentState(nHandle))
	StzEngineFsmSend(nHandle, "stop")
	AssertEqual("fsm after stop", "red", StzEngineFsmCurrentState(nHandle))
	AssertEqual("fsm state count", 3, StzEngineFsmStateCount(nHandle))
	StzEngineFsmDestroy(nHandle)
	StzEngineFsmClear()
	? "  statemachine: done"
ok

# -------------------------------------------------------------------
? "--- 18. Validator (stz_validator) ---"
# Bridge: No Create/Destroy. Global rule store.
# AddRule(field_name, rule_type, threshold, message)
# CheckInt(field_name, value)
# -------------------------------------------------------------------
if TryLoadDLL(cDllDir, "stz_validator")
	StzEngineValClear()
	# kind: 0=required, 1=min_value, 2=max_value
	nR1 = StzEngineValAddRule("age_min", 1, 0, "min is 0")
	AssertTrue("val add rule min", nR1 >= 0)
	nR2 = StzEngineValAddRule("age_max", 2, 150, "max is 150")
	AssertTrue("val add rule max", nR2 >= 0)
	AssertEqual("val rule count", 2, StzEngineValRuleCount())
	nResult = StzEngineValCheckInt("age_min", 25)
	AssertEqual("val check 25 pass min", 1, nResult)
	nResult2 = StzEngineValCheckInt("age_min", -5)
	AssertEqual("val check -5 fail min", 0, nResult2)
	nResult3 = StzEngineValCheckInt("age_max", 200)
	AssertEqual("val check 200 fail max", 0, nResult3)
	nResult4 = StzEngineValCheckInt("age_max", 100)
	AssertEqual("val check 100 pass max", 1, nResult4)
	StzEngineValClear()
	? "  validator: done"
ok

# ===================================================================
? ""
? "=== RESULTS ==="
? "  Passed: " + $nPass
? "  Failed: " + $nFail
? "  Total:  " + ($nPass + $nFail)
if $nFail = 0
	? ""
	? "=== ALL ENGINE WRAPPER TESTS PASSED ==="
else
	? ""
	? "=== " + $nFail + " TESTS FAILED ==="
ok

# ===================================================================
# Helper functions (must be at end of file in Ring)
# ===================================================================
func TryLoadDLL(cDllDirArg, cName)
	cPath = cDllDirArg + cName + ".dll"
	if fexists(cPath)
		LoadLib(cPath)
		return 1
	else
		? "  SKIP: " + cName + ".dll not found"
		return 0
	ok

func AssertEqual(cTest, pExpected, pActual)
	if pExpected = pActual
		$nPass++
	else
		$nFail++
		? "  FAIL: " + cTest + " -- expected " + pExpected + " got " + pActual
	ok

func AssertTrue(cTest, pVal)
	if pVal
		$nPass++
	else
		$nFail++
		? "  FAIL: " + cTest
	ok
