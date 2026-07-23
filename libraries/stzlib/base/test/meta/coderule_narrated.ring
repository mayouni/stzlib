load "../../stzBase.ring"
load "../_narrated.ring"

# stzCodeRule / stzCodeRuleSet -- code rules ARE graph rules (graph-rules P3).
#
# stzCodeRules.ring was a 106-line TEXT SCANNER: read source line by line,
# prefix-match "def len(". Phase 3 makes the house rules query a stzCodeGraph
# instead: stzCodeRule IS-A stzGraphRule, stzCodeRuleSet IS-A stzGraphRuleSet,
# and StzCheckCode is now a thin wrapper that builds a Ring code graph, runs the
# rule set, and merges in the ONE rule the graph cannot model (q-returns-object,
# which needs return statements) as a text pass -- behind its FROZEN
# [ :rule, :line, :severity, :message ] shape.
#
# The payoff (scene 3) is what a MODEL gives that a text scan cannot: a `def
# substr(` DEFINITION is not a call, and a comment saying "def len" is not a
# method -- so neither is flagged, where the old scanner would false-positive.

Scenario("a code rule IS a graph rule; a code rule set IS a graph rule set")
	oRule = new stzCodeRule("no-len-method")
	Then("stzCodeRule constructs", isObject(oRule), TRUE)
	Then("...in the code domain", oRule.Domain(), "code")
	Then("...and answers the graph-rule surface (Check exists)", oRule.NumberOfClauses(), 0)
	oSet = StzCodeRuleSetQ()
	Then("the set carries the three graph-portable house rules", oSet.NumberOfRules(), 3)
	Then("...named", StzFindFirst("no-len-method", @@(oSet.RuleNames())) > 0, TRUE)
EndScenario()

Scenario("FROZEN behaviour: StzCheckCode reproduces the house findings")
	Given("the planted-bad fixture from the codegraph guard")
	cBad = "class Foo" + nl +
	       "def Len()" + nl + "	return 5" + nl +
	       "def BarQ()" + nl + "	return 42" + nl +
	       "def KillProcess()" + nl + "	return" + nl
	aF = StzCheckCode(cBad)
	Then("no-len-method fires", HasRule(aF, "no-len-method"), TRUE)
	Then("...on the Len() method's line", LineOf(aF, "no-len-method"), 2)
	Then("q-returns-object fires (BarQ returns 42, not chainable)", HasRule(aF, "q-returns-object"), TRUE)
	Then("no-aggressive-verbs fires (KillProcess)", HasRule(aF, "no-aggressive-verbs"), TRUE)
	Then("the finding shape is unchanged (:rule/:line/:severity/:message)",
	     HasKey(aF[1], :rule) and HasKey(aF[1], :line) and HasKey(aF[1], :severity) and HasKey(aF[1], :message), TRUE)
	Then("severities are still SYMBOLS", aF[1][:severity] = :error or aF[1][:severity] = :warning, TRUE)
	Then("the dirty source is refused", StzCodeIsClean(cBad), FALSE)

	cGood = "class Foo" + nl + "def BazQ()" + nl + "	return This" + nl
	Then("clean source passes", StzCodeIsClean(cGood), TRUE)
	Then("StzCodeRuleNames is unchanged", len(StzCodeRuleNames()), 4)
EndScenario()

Scenario("THE PAYOFF: the model sees what the text scan cannot")
	Given("a real CALL to substr inside a method")
	cCall = "class Foo" + nl + "def Bar()" + nl + "	x = substr(s, 2)" + nl
	Then("engine-first fires on the call", HasRule(StzCheckCode(cCall), "engine-first"), TRUE)
	Then("...at the call SITE line", LineOf(StzCheckCode(cCall), "engine-first"), 3)

	When("substr is a method DEFINITION, not a call")
	cDef = "class Foo" + nl + "def substr(x)" + nl + "	return x" + nl
	Then("engine-first does NOT fire (a text scan of 'substr(' WOULD false-positive)",
	     HasRule(StzCheckCode(cDef), "engine-first"), FALSE)

	When("'def len' appears only in a comment")
	cCmt = "class Foo" + nl + "	# def len() is banned here" + nl + "def Count()" + nl + "	return 5" + nl
	Then("no-len-method does NOT fire on the comment", HasRule(StzCheckCode(cCmt), "no-len-method"), FALSE)
	Then("...but a REAL Len method still does",
	     HasRule(StzCheckCode("class Foo" + nl + "def Len()" + nl + "	return 5" + nl), "no-len-method"), TRUE)
EndScenario()

Scenario("the rule set runs standalone over a code graph (the object API)")
	Given("a Ring code graph built from source, and the code rule set")
	oCG = new stzRingCodeGraph("")
	oCG.ScanSource("class Bag" + nl + "def Len()" + nl + "	return 1" + nl + "def KillAll()" + nl + "	return" + nl, "src")
	oSet = StzCodeRuleSetQ()
	aF = oSet.Check(oCG)
	Then("Check returns graph-rule findings", len(aF) >= 2, TRUE)
	Then("...in the shared [:rule,:where,:severity,:message] shape",
	     HasKey(aF[1], :rule) and HasKey(aF[1], :where), TRUE)
	Then("the set is NOT sound (an error-severity rule fired)", oSet.IsSound(oCG), FALSE)
	Then("...the len shadow is among the findings", HasRuleW(aF, "no-len-method"), TRUE)
EndScenario()

Scenario("multiple violations across a fuller source come back sorted by line")
	cSrc = "class Foo" + nl +
	       "def KillIt()" + nl + "	x = substr(a,1)" + nl +
	       "def Len()" + nl + "	return 9" + nl
	aF = StzCheckCode(cSrc)
	Then("all three kinds are present", len(aF) >= 3, TRUE)
	Then("...and lines are non-decreasing (merged graph + text, sorted)",
	     LinesNonDecreasing(aF), TRUE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func HasRule aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return TRUE ok
	next
	return FALSE

# for the object-API findings whose locus key is :where, not :line
func HasRuleW aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return TRUE ok
	next
	return FALSE

func LineOf aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return aF[i][:line] ok
	next
	return -1

func LinesNonDecreasing aF
	n = len(aF)
	for i = 2 to n
		if aF[i][:line] < aF[i-1][:line] return FALSE ok
	next
	return TRUE
