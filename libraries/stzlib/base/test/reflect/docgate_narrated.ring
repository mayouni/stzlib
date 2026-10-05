load "../../stzBase.ring"
load "../_narrated.ring"

# DOCREFORM step 5 -- the doc gate (base/meta/stzDocGate.ring): a ratchet over the extractor's checks.
# The judgement is PURE (a failing list and a baseline in, findings out), so it runs here on made-up
# lists in milliseconds; the export half runs on the small fixture library, not on the whole one.

cFxBase = currentdir() + "/docrecord_fixture"
cBase = currentdir() + "/_docgate_baseline.tmp.txt"

Scenario("The judgement: a new method must be documented, the debt may stay")
	aFailing = [ [ "stzx.old", 0, 1, 1, 1 ], [ "stzx.fresh", 0, 1, 1, 1 ], [ "stzx.restates", 1, 0, 1, 1 ],
	             [ "stzx.noparam", 1, 1, 0, 1 ], [ "stzx.noret", 1, 1, 1, 0 ] ]
	aBase = sort([ "stzx.old", "stzx.fixed" ])
	aF = StzDocGateJudge(aFailing, aBase)
	Then("a failing root that is in the baseline is let through", RuleOf(aF, "stzx.old"), "")
	Then("a new root with no proper brief is an ERROR (doc-floor)", RuleOf(aF, "stzx.fresh"), "doc-floor:error")
	Then("a new root whose brief restates its name is an ERROR", RuleOf(aF, "stzx.restates"), "doc-floor:error")
	Then("a new root with an undescribed parameter is a warning (doc-complete)",
		RuleOf(aF, "stzx.noparam"), "doc-complete:warning")
	Then("a new root with no returns is a warning", RuleOf(aF, "stzx.noret"), "doc-complete:warning")
	Then("a baseline root that now passes is reported stale", RuleOf(aF, "stzx.fixed"), "doc-baseline-stale:warning")
	Then("nothing else is reported", len(aF), 5)
	Then("findings have the unified shape (rule, subject, where, severity, message)",
		len(aF[1]), 5)
	Then("no baseline at all makes every failing root a finding, the old one too",
		len(StzDocGateJudge(aFailing, [])), 5)
EndScenario()

Scenario("The ratchet: the baseline can shrink and never grows")
	remove(cBase)
	aFail1 = [ [ "stzx.a", 0, 1, 1, 1 ], [ "stzx.b", 0, 1, 1, 1 ], [ "stzx.c", 1, 1, 0, 1 ] ]
	aR1 = StzDocGateBaselineWrite(aFail1, cBase, 0)
	Then("with no baseline the first write seeds every failing root", aR1[:written], 3)
	Then("the file is read back sorted", StzDocGateBaseline(cBase)[1], "stzx.a")
	aFail2 = [ [ "stzx.b", 0, 1, 1, 1 ], [ "stzx.c", 1, 1, 0, 1 ], [ "stzx.d", 0, 1, 1, 1 ] ]
	aR2 = StzDocGateBaselineWrite(aFail2, cBase, 0)
	Then("a root that passes now is dropped", aR2[:removed], 1)
	Then("a root that failed since the baseline was written is NOT added", aR2[:written], 2)
	aKeys = StzDocGateBaseline(cBase)
	Then("what stays is b and c", aKeys[1] + " " + aKeys[2], "stzx.b stzx.c")
	Then("so the new failing root d is an error at the next judgement",
		RuleOf(StzDocGateJudge(aFail2, aKeys), "stzx.d"), "doc-floor:error")
	aR3 = StzDocGateBaselineWrite(aFail2, cBase, 1)
	Then("an explicit seed rewrites the baseline from the failing list", aR3[:written], 3)
	remove(cBase)
EndScenario()

Scenario("The export half runs on the fixture library")
	aFail = StzDocGateFailing(cFxBase)
	Then("the failing roots come from the extractor, as [ key, c1, c2, c3, c4 ]", len(aFail) > 0, TRUE)
	Then("each has five items", len(aFail[1]), 5)
	Then("a key is class.method in lowercase", StzFindFirst("stzdocfx.", aFail[1][1]) > 0, TRUE)
	Then("the temporary export is removed", fexists(cFxBase + "/.doc_gate_export.tmp.json"), FALSE)
	aF = StzDocGateFindings(cFxBase, cBase)
	Then("with no baseline file the fixture's failing roots all show up",
		len(aF) > 0, TRUE)
EndScenario()

Summary()

func RuleOf(aFind, cKey)
	for i = 1 to len(aFind)
		if aFind[i][:subject] = cKey
			return aFind[i][:rule] + ":" + aFind[i][:severity]
		ok
	next
	return ""
