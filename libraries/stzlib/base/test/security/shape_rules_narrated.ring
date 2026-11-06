load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA_ONE_HOUR.md A5 / B3 (rung W2a) -- the autumn's bug shapes as code rules.
#
# Five shapes, each fed to StzCheckCode as a planted snippet and as its clean
# sibling: the rule must fire on the one and stay silent on the other. Then the
# library itself: the rule that encodes PHP2Shell's shape must find
# SECURITY-AMBIENT-01 in stzPIAgent.Cycle (measured 2026-11-05) and nothing
# else of that shape, which is the number the memo carries.

nl = char(10)

Scenario("1. global-restored-by-hand: PHP2Shell's shape")
	cPlanted = "func Cycle()" + nl + "	_cPrev_ = $cStzCaller" + nl + "	$cStzCaller = @cName" + nl +
		"	DoWork()" + nl + "	$cStzCaller = _cPrev_" + nl
	cGuarded = "func Cycle()" + nl + "	_cPrev_ = $cStzCaller" + nl + "	$cStzCaller = @cName" + nl +
		"	try" + nl + "		DoWork()" + nl + "	catch" + nl + "		$cStzCaller = _cPrev_" + nl + "		raise(cCatchError)" + nl + "	done" + nl +
		"	$cStzCaller = _cPrev_" + nl
	cUnrelated = "func Cycle()" + nl + "	_n_ = $nCount" + nl + "	$nCount = 0" + nl + "	DoWork()" + nl
	Then("fires on a save and a hand restore with no try", Fires(:global_restored_by_hand, cPlanted), 1)
	Then("silent when a try stands between (negative sibling)", Fires(:global_restored_by_hand, cGuarded), 0)
	Then("silent when the global is never restored from the local", Fires(:global_restored_by_hand, cUnrelated), 0)
EndScenario()

Scenario("2. listener-binds-all: Node-RED's shape")
	cWide = "def Listen(nPort, cHost)" + nl + "	if cHost = " + char(34) + char(34) + " cHost = " + char(34) + "0.0.0.0" + char(34) + " ok" + nl
	cLoop = "def Listen(nPort, cHost)" + nl + "	if cHost = " + char(34) + char(34) + " cHost = " + char(34) + "127.0.0.1" + char(34) + " ok" + nl
	Then("fires on a literal 0.0.0.0", Fires(:listener_binds_all, cWide), 1)
	Then("silent on loopback (negative sibling)", Fires(:listener_binds_all, cLoop), 0)
EndScenario()

Scenario("3. text-run-as-code: R17's shape, kept closed")
	cOpen = "func Where(cCond)" + nl + "	return eval(" + char(34) + "return " + char(34) + " + cCond)" + nl
	cChecked = "func Where(cCond)" + nl + "	if NOT StzIsQueryCondition(cCond) StzRaise(" + char(34) + "no" + char(34) + ") ok" + nl +
		"	return eval(" + char(34) + "return " + char(34) + " + cCond)" + nl
	cLiteral = "func Where()" + nl + "	return eval(" + char(34) + "return 1" + char(34) + ")" + nl
	Then("fires on eval of a built text", Fires(:text_run_as_code, cOpen), 1)
	Then("silent when the body checked it (negative sibling)", Fires(:text_run_as_code, cChecked), 0)
	Then("silent on a literal", Fires(:text_run_as_code, cLiteral), 0)
EndScenario()

Scenario("4. last-error-read: the process-wide last error")
	cStale = "func Later()" + nl + "	? cCatchError" + nl
	cOwned = "func Now()" + nl + "	try" + nl + "		Work()" + nl + "	catch" + nl + "		? cCatchError" + nl + "	done" + nl
	Then("fires on a read outside a catch", Fires(:last_error_read, cStale), 1)
	Then("silent inside the catch that owns it (negative sibling)", Fires(:last_error_read, cOwned), 0)
EndScenario()

Scenario("5. handle-held-across-raise: KERN-07's residue")
	cLeak = "def Compare(cV, cC)" + nl + "	_h_ = StzEngineSecretHold(cV)" + nl + "	return StzEngineSecretEquals(_h_, cC)" + nl
	cKept = "def Compare(cV, cC)" + nl + "	_h_ = StzEngineSecretHold(cV)" + nl + "	_r_ = StzEngineSecretEquals(_h_, cC)" + nl + "	StzEngineSecretRelease(_h_)" + nl + "	return _r_" + nl
	cMember = "def FromLiteralQ(cV)" + nl + "	@nCell = StzEngineSecretHold(cV)" + nl + "	return This" + nl
	Then("fires on a cell held in a local and never released", Fires(:handle_held_across_raise, cLeak), 1)
	Then("silent when the body releases it (negative sibling)", Fires(:handle_held_across_raise, cKept), 0)
	Then("silent when the cell is kept in a member for Release() to find", Fires(:handle_held_across_raise, cMember), 0)
EndScenario()

Scenario("6. the library: PHP2Shell's shape is found where it was measured")
	cAgent = read("../../agentic/stzPIAgent.ring")
	nAgent = Fires(:global_restored_by_hand, cAgent)
	? "  NUMBER stzPIAgent.ring: " + nAgent + " site(s) restoring a global by hand with no try"
	Then("NUMBER -- SECURITY-AMBIENT-01's two sites, until stzlib-intelligence restores them in a catch", nAgent, 2)
	cSecret = read("../../security/stzSecret.ring")
	Then("the secret class itself holds nothing it does not release", Fires(:handle_held_across_raise, cSecret), 0)
	Then("the five rules are in the catalogue", len(StzCodeRuleNames()) >= 21, 1)
EndScenario()

Summary()
shutdown($_zst_fail)

func Fires(cRule, cCode)
	aF = StzCheckCode(cCode)
	n = 0
	for i = 1 to len(aF)
		if aF[i][:rule] = cRule  n++  ok
	next
	return n
