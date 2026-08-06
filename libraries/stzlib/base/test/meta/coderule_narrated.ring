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
	# 3 house rules (P3) + q-has-plain-twin + no-case-collision (P7)
	Then("the set carries the graph-portable house rules", oSet.NumberOfRules(), 5)
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
	Then("StzCodeRuleNames lists the house rules (8 with the knob rules)", len(StzCodeRuleNames()), 8)
	Then("...including dead-knob", StzFindFirst("dead-knob", StzCodeRuleNames()) > 0, TRUE)
	Then("...and setter-resets-on-reject", StzFindFirst("setter-resets-on-reject", StzCodeRuleNames()) > 0, TRUE)
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

Scenario("the code graph checks ITSELF against the code rules")
	Given("a Ring code graph built from source")
	oCG = new stzRingCodeGraph("")
	oCG.ScanSource("class Bag" + nl + "def Len()" + nl + "	return 1" + nl + "def KillAll()" + nl + "	return" + nl, "src")
	aF = oCG.CheckRules()          # the graph checks itself -- scope stays on it
	Then("CheckRules returns graph-rule findings", len(aF) >= 2, TRUE)
	Then("...in the shared [:rule,:where,:severity,:message] shape",
	     HasKey(aF[1], :rule) and HasKey(aF[1], :where), TRUE)
	Then("the graph is NOT sound (an error-severity rule fired)", oCG.RulesAreSound(), FALSE)
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

Scenario("The knob rules: a setting that cannot change anything")

	# -- WHY THESE RULES EXIST --
	#
	# Nine hand audits of this library kept finding the same defect: a public
	# setting that does nothing. SetBarChar("=") and the bars keep their old
	# character; SetTotalLabel("GRAND") and the table still says TOTAL. Nothing
	# raises. The setter runs, stores the value, and no code ever looks at it
	# again. Every one of those was invisible until a person went looking.
	#
	# The law is one sentence: IF YOU CAN SET IT, IT MUST BE ABLE TO CHANGE
	# SOMETHING. These two rules are the mechanical half.

	Given("a class with one live knob and three broken ones")
	cKnobs = KnobFixture()
	aK = StzCheckCode(cKnobs)

	# 1. WRITTEN AND READ BY NOTHING. The twin is named because that is how the
	#    real one hid: @nSteps beside @nStep, one letter apart, and the setter
	#    wrote the dead one.
	Then("the dead attribute is an error", KnobSev(aK, "nsteps"), "error")
	Then("...and the message names the live twin", KnobSaysTwin(aK, "nsteps"), TRUE)

	# 2. READ ONLY BY ITS OWN GETTER -- it answers you and changes nothing. A
	#    warning, not an error: another class may call that getter.
	Then("the getter-only attribute is a warning", KnobSev(aK, "cgetteronly"), "warning")

	# 3. A REJECTED VALUE MUST NOT DESTROY A GOOD ONE.
	Then("the resetting setter is caught", KnobHasRule(aK, "setter_resets_on_reject"), TRUE)

	# THE NEGATIVE SIBLING, and the one that matters most: a rule that flags
	# everything is worse than no rule. The live knob -- written by a setter and
	# read by the renderer -- must not appear at all.
	Then("the LIVE knob is not flagged", KnobSev(aK, "clive"), "")

	# ...nor may a comparison be mistaken for a write. Ring spells equality and
	# assignment the same way, and reading "if @x = :Foo" as an assignment hides
	# the very consumer this rule looks for -- which a first version did.
	Then("a comparison is a read, not a write", KnobSev(aK, "cmode"), "")

	Given("the shapes the audit actually found, in their pre-fix form")

	# The self-check that matters: run the rule over the real code as it stood
	# BEFORE each fix, and it must fire. A detector nobody tested against a known
	# positive is a detector that fires on nothing.
	Then("it would have caught the parser's dead twin", KnobCaught(:Parser), TRUE)
	Then("...and the diagram's getter-only pen style", KnobCaught(:Diagram), TRUE)
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

# -- knob-rule helpers ---------------------------------------------------------

# One class: a live knob, a dead one with a twin, a getter-only one, a setter
# that resets on refusal, and a comparison that must not read as a write.
func KnobFixture()
	_nl_ = char(10)
	_c_ = "class stzKnobDemo from stzObject" + _nl_
	_c_ += "	@nStep = 1" + _nl_
	_c_ += "	@cLive = ''" + _nl_
	_c_ += "	@cMode = ''" + _nl_
	_c_ += "	@cGetterOnly = ''" + _nl_
	_c_ += "	def SetNumberOfSteps(pnSteps)" + _nl_
	_c_ += "		@nSteps = pnSteps" + _nl_
	_c_ += "		This.Parse(pnSteps)" + _nl_
	_c_ += "	def SetLive(pcVal)" + _nl_
	_c_ += "		@cLive = pcVal" + _nl_
	_c_ += "	def SetMode(pcVal)" + _nl_
	_c_ += "		@cMode = pcVal" + _nl_
	_c_ += "	def SetGetterOnly(pcVal)" + _nl_
	_c_ += "		@cGetterOnly = pcVal" + _nl_
	_c_ += "	def GetterOnly()" + _nl_
	_c_ += "		return @cGetterOnly" + _nl_
	_c_ += "	def SetSplines(pcType)" + _nl_
	_c_ += "		if StzFindFirst(pcType, $acTypes) > 0" + _nl_
	_c_ += "			@cSplineType = pcType" + _nl_
	_c_ += "		else" + _nl_
	_c_ += "			@cSplineType = $cDefault" + _nl_
	_c_ += "		ok" + _nl_
	_c_ += "	def Render()" + _nl_
	_c_ += "		if @cMode = :Wide" + _nl_
	_c_ += "			return @cLive + @cSplineType" + _nl_
	_c_ += "		ok" + _nl_
	_c_ += "		return @cLive" + _nl_
	return _c_

# the severity reported for an attribute, or "" when it was not flagged
func KnobSev(paFindings, pcAttr)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if "" + paFindings[_i_][:rule] != "dead_knob"
			loop
		ok
		if StzFindFirst("@" + pcAttr + " ", "" + paFindings[_i_][:message]) > 0
			return "" + paFindings[_i_][:severity]
		ok
	next
	return ""

func KnobSaysTwin(paFindings, pcAttr)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if StzFindFirst("@" + pcAttr + " ", "" + paFindings[_i_][:message]) > 0
			return StzFindFirst("one letter away", "" + paFindings[_i_][:message]) > 0
		ok
	next
	return FALSE

func KnobHasRule(paFindings, pcRule)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if "" + paFindings[_i_][:rule] = pcRule
			return TRUE
		ok
	next
	return FALSE

# Would the rule have caught the real thing, in the real file, as it stood
# before the fix? The fixtures are written out by the guard itself so the check
# does not depend on git being reachable.
func KnobCaught(pWhich)
	_cSrc_ = ""
	if pWhich = :Parser
		_cSrc_ = KnobParserPreFix()
	else
		_cSrc_ = KnobDiagramPreFix()
	ok
	_aF_ = StzCheckCode(_cSrc_)
	return KnobHasRule(_aF_, "dead_knob")

# stzListParser as it was: the setter wrote @nSteps, Parse() set @nStep.
func KnobParserPreFix()
	_nl_ = char(10)
	_c_ = "class stzListParser from stzObject" + _nl_
	_c_ += "	@nStep = 1" + _nl_
	_c_ += "	def SetNumberOfSteps(pnSteps)" + _nl_
	_c_ += "		@nSteps = pnSteps" + _nl_
	_c_ += "		This.Parse(This.StartPosition(), This.EndPosition(), pnSteps)" + _nl_
	_c_ += "	def NumberOfSteps()" + _nl_
	_c_ += "		return @nStep" + _nl_
	return _c_

# stzDiagram as it was: the edge pen style answered its getter and drew nothing,
# while its NODE counterpart reached the emitter.
func KnobDiagramPreFix()
	_nl_ = char(10)
	_c_ = "class stzDiagram from stzObject" + _nl_
	_c_ += "	@cEdgePenStyle = 'solid'" + _nl_
	_c_ += "	@cNodePenStyle = 'solid'" + _nl_
	_c_ += "	def SetEdgePenStyle(pcStyle)" + _nl_
	_c_ += "		@cEdgePenStyle = pcStyle" + _nl_
	_c_ += "	def SetNodePenStyle(pcStyle)" + _nl_
	_c_ += "		@cNodePenStyle = pcStyle" + _nl_
	_c_ += "	def EdgePenStyle()" + _nl_
	_c_ += "		return @cEdgePenStyle" + _nl_
	_c_ += "	def ToDot()" + _nl_
	_c_ += "		return 'style=' + @cNodePenStyle" + _nl_
	return _c_
