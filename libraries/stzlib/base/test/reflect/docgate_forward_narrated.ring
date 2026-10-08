load "../../stzBase.ring"
load "../_narrated.ring"

# DOCREFORM step 5 -- the dead-forward ratchet of the doc gate. The judgement is PURE (the extractor's findings and a
# sorted baseline in, the gate's findings out), so it runs here on made-up findings in milliseconds.

cTmp = currentdir() + "/_fwd_baseline.tmp.txt"

Scenario("A new dead forward fails the gate, a listed one is debt")
	aX = [ [ :rule = "doc-dead-forward", :subject = "stzx.old", :where = "x.ring:1", :severity = "error", :message = "old() forwards to nothing" ],
	       [ :rule = "doc-dead-forward", :subject = "stzx.fresh", :where = "x.ring:2", :severity = "error", :message = "fresh() forwards to nothing" ],
	       [ :rule = "doc-internal-shown", :subject = "stzx.pvtgo", :where = "x.ring:3", :severity = "warning", :message = "pvtGo() is public" ],
	       [ :rule = "doc-typo-word", :subject = "stzx.wrtite", :where = "x.ring:4", :severity = "warning", :message = "wrtite" ] ]
	aF = StzDocGateForwardJudge(aX, sort([ "stzx.old", "stzx.fixed" ]))
	Then("a listed dead forward is let through", RuleOf(aF, "stzx.old"), "")
	Then("a new dead forward is an ERROR", RuleOf(aF, "stzx.fresh"), "doc-dead-forward:error")
	Then("an internal shown as public is a warning", RuleOf(aF, "stzx.pvtgo"), "doc-internal-shown:warning")
	Then("a typo-shaped word is a warning", RuleOf(aF, "stzx.wrtite"), "doc-typo-word:warning")
	Then("a listed name that forwards well now is reported stale", RuleOf(aF, "stzx.fixed"), "doc-forward-stale:warning")
	Then("nothing else is reported", len(aF), 4)
	Then("with no baseline every dead forward is an error", len(StzDocGateForwardJudge(aX, [])), 4)
EndScenario()

Scenario("The forward baseline shrinks and never grows")
	remove(cTmp)
	aD1 = [ [ :rule = "doc-dead-forward", :subject = "StzX.A", :where = "w", :severity = "error", :message = "m" ],
	        [ :rule = "doc-dead-forward", :subject = "StzX.B", :where = "w", :severity = "error", :message = "m" ] ]
	aR1 = StzDocGateForwardBaselineWrite(aD1, cTmp, 0)
	Then("with no baseline the first write seeds every dead forward, lowercase", aR1[:written], 2)
	Then("read back sorted", StzDocGateBaseline(cTmp)[1], "stzx.a")
	aD2 = [ [ :rule = "doc-dead-forward", :subject = "StzX.B", :where = "w", :severity = "error", :message = "m" ],
	        [ :rule = "doc-dead-forward", :subject = "StzX.C", :where = "w", :severity = "error", :message = "m" ] ]
	aR2 = StzDocGateForwardBaselineWrite(aD2, cTmp, 0)
	Then("a name fixed since is dropped", aR2[:removed], 1)
	Then("a name that went dead since is NOT added", aR2[:written], 1)
	Then("what stays is b", StzDocGateBaseline(cTmp)[1], "stzx.b")
	remove(cTmp)
EndScenario()

Scenario("The findings file is a pure function of the findings")
	aX = [ [ :rule = "doc-typo-word", :subject = "b", :where = "w2", :severity = "warning", :message = 'say "hi"' ],
	       [ :rule = "doc-dead-forward", :subject = "a", :where = "w1", :severity = "error", :message = "m" ] ]
	cJ = currentdir() + "/_findings.tmp.json"
	Then("it reports how many it wrote", StzDocFindingsWriteJson(aX, cJ), 2)
	cT = read(cJ)
	Then("rows are sorted by rule, dead forward first", StzFindFirst("doc-dead-forward", cT) < StzFindFirst("doc-typo-word", cT), TRUE)
	Then("a double quote in a message is escaped", StzFindFirst(char(92) + char(34) + "hi" + char(92) + char(34), cT) > 0, TRUE)
	remove(cJ)
EndScenario()

Summary()

func RuleOf(aFind, cKey)
	for i = 1 to len(aFind)
		if aFind[i][:subject] = cKey
			return aFind[i][:rule] + ":" + aFind[i][:severity]
		ok
	next
	return ""
