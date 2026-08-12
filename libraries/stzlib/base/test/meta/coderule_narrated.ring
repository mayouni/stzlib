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
	Then("StzCodeRuleNames lists the house rules (14 with the knob rules)", len(StzCodeRuleNames()), 14)
	Then("...including dead-knob", StzFindFirst("dead-knob", StzCodeRuleNames()) > 0, TRUE)
	Then("...and setter-resets-on-reject", StzFindFirst("setter-resets-on-reject", StzCodeRuleNames()) > 0, TRUE)
	Then("...and the three shapes learned after them", NNamed(["setter-only-moves-one-way", "misspelled-name", "library-prints"]), 3)
	Then("...and empty-method-body", StzFindFirst("empty-method-body", StzCodeRuleNames()) > 0, TRUE)
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

Scenario("Documentation is not code")

	# -- THE BLIND SPOT UNDER ALL OF THEM --
	#
	# Almost every method in this library carries a worked sample in a /* */
	# block: real Ring lines, showing real calls, sitting inside the method body.
	# The text passes had never heard of block comments, so they read those
	# samples as statements. On the first honest run of the print rule, 245 of
	# 259 findings were documentation.
	#
	# It runs the other way too, and quieter: a sample that merely MENTIONS an
	# attribute counted as a consumer, so a doc block could hide a dead knob from
	# the very rule written to find it.

	Given("a method whose body holds a doc sample and a real statement")
	cDoc = DocFixture()

	# lines as a string: Then() compares values, not lists
	Then("the sample's print is not a print", PrintLines(cDoc), "6,10")

	# Blanked, never removed. If the stripper dropped the lines instead of
	# emptying them, every finding after the first comment would point at the
	# wrong place -- and be harder to disbelieve than a wrong finding, because
	# the line it names does exist.
	Then("line numbers survive the blanking", StzLen(StzSplit(_StzStripBlockComments(cDoc), char(10))) >= 10, TRUE)
	Then("...and code beside an inline block is kept", StzFindFirst("x = 1", _StzStripBlockComments(cDoc)) > 0, TRUE)
EndScenario()

Scenario("Three more shapes, learned from three more audits")

	# The knob rules shipped, and sixteen module audits followed. The gate found
	# the defect twice; the rest a person found by hand -- and each was a SHAPE
	# that came back. These are the three that recurred often enough to teach.

	Given("a class carrying one of each, and a correct sibling for each")
	cThree = ThreeFixture()
	aT = StzCheckCode(cThree)

	# 1. A RATCHET. max() against the attribute being set: the value can only
	#    ever rise, and the other direction is swallowed without a word.
	Then("bounding a knob against itself is an error", RuleSev(aT, "setter_only_moves_one_way"), "error")
	Then("...and the message names the method", SaysIn(aT, "setter_only_moves_one_way", "SetHeight"), TRUE)

	# THE NEGATIVE SIBLING: flooring against a separate MINIMUM is what was
	# meant, and is the shape the real fix took. It must not fire.
	Then("a floor against a minimum is fine", SaysIn(aT, "setter_only_moves_one_way", "SetWidth"), FALSE)

	# 2. A NAME THAT IS NOT THERE. Recieve, RecieveMany, OnRecieved,
	#    SetCurrenCell -- four across three classes, and in every case the name a
	#    caller reaches for simply did not exist.
	Then("a misspelling with no correct twin is flagged", SaysIn(aT, "misspelled_name", "Recieve"), TRUE)
	Then("...and so is Curren without its T", SaysIn(aT, "misspelled_name", "SetCurrenCell"), TRUE)

	# THE NEGATIVE SIBLINGS. The old spelling is not the defect, the MISSING one
	# is -- so a class offering both is left alone. And Occurrence contains
	# c-u-r-r-e-n, which is how a lowercase search called every
	# CountOccurrencesOf() in the library a typo: 878 findings, all noise.
	Then("a kept alias beside the right name is fine", SaysIn(aT, "misspelled_name", "Seperate"), FALSE)
	Then("...and Occurrence is spelled correctly", SaysIn(aT, "misspelled_name", "Occurrence"), FALSE)

	# 3. A LIBRARY TALKING OVER ITS CALLER.
	Then("an unconditional print is flagged", SaysIn(aT, "library_prints", "Work"), TRUE)

	# THE NEGATIVE SIBLINGS, and the one that decided the rule's worth: a print
	# the caller ASKED for is not the library talking. 152 of the 183 surviving
	# findings sat behind "if @bDebugMode" -- the correct shape, off by default.
	Then("a print behind a debug flag is not flagged", SaysIn(aT, "library_prints", "Parse"), FALSE)
	Then("...nor is one in a method whose job is to display", SaysIn(aT, "library_prints", "ShowIt"), FALSE)
	Then("...even when the display helper is internal", SaysIn(aT, "library_prints", "_showTable"), FALSE)

	Given("the shapes as they really stood, before each fix")

	# The same self-check the knob rules got: run each rule over the real code as
	# it was, and it must fire. Three commits, three known positives.
	Then("it would have caught the calendar's ratchet", ThreeCaught(:Ratchet), TRUE)
	Then("...the stream's three missing spellings", ThreeCaught(:Spelling), 3)
	Then("...and its four prints from inside an overflow", ThreeCaught(:Prints), 4)
EndScenario()

Scenario("A method that is declared and does nothing")

	# stzReactiveSystem.SetTimeoutXT was one: declared, and the next line was the
	# next method. Every call scheduled no timer and answered nothing, while
	# SetTimeout one screen down delegates correctly. Nothing raised, and nothing
	# could -- the method existed.

	Given("a class holding an empty method beside working ones")
	cE = EmptyFixture()
	aE = StzCheckCode(cE)

	Then("the empty one is found", SaysIn(aE, "empty_method_body", "Vanish"), TRUE)

	# A PREDICATE is the worse half. Ring returns NULL from a method with no
	# return, and NULL reads as FALSE -- so an empty ContainsValues() does not
	# fail, it says "no" about everything, confidently and forever.
	Then("a do-nothing predicate is an ERROR", SevOf(aE, "empty_method_body", "ContainsValues"), "error")
	Then("...while a plain action is only a warning", SevOf(aE, "empty_method_body", "Vanish"), "warning")
	Then("...and explains the FALSE", SaysIn(aE, "empty_method_body", "reads as FALSE"), TRUE)

	# THE NEGATIVE SIBLINGS, and the reason this rule took four drafts. Ring
	# writes a whole body on the def line in two ordinary ways, and neither is
	# an empty method. Earlier drafts reported 83, 51 and 32 sites where the
	# truth was 28.
	Then("a brace body on the def line is fine", SaysIn(aE, "empty_method_body", "Braced"), FALSE)
	Then("...and a bare body on the def line too", SaysIn(aE, "empty_method_body", "Bare"), FALSE)
	Then("...and an ordinary indented body", SaysIn(aE, "empty_method_body", "Normal"), FALSE)

	# init is exempt: a class keeping its state in the engine, or having none,
	# legitimately has nothing to initialise.
	Then("an empty init is not flagged", SaysIn(aE, "empty_method_body", "init"), FALSE)

	# ...but a comment IS flagged. Saying nothing happens does not make the
	# caller less misled.
	Then("a comment-only body is still empty", SaysIn(aE, "empty_method_body", "Commented"), TRUE)

	Given("the shape as it really stood, before the fix")

	# StzMid is (start, COUNT), not (start, end) -- the same-line check walked
	# with StzMid(s, i, i) and fell straight through, so the first run of this
	# rule called five live one-line setters empty. This is the assertion that
	# would have caught it.
	Then("it would have caught SetTimeoutXT", EmptyCaught(), TRUE)
EndScenario()

Scenario("Writing to a constant everyone shares")

	# In Ring these are ordinary globals and Ring is case-insensitive, so
	# `nL = len(cPixels)` replaces the NL newline constant with a NUMBER for the
	# whole process. That one was found in the field -- library code built a
	# string with NL and raised deep inside StzReplaceCS, with nothing pointing
	# back at the caller.
	#
	# TRUE / FALSE / NULL are the same mechanism with a worse ending. NL raises;
	# these do not. With TRUE clobbered, `(1=1) = TRUE` is 0 -- the logic simply
	# runs backwards and nothing errors.
	#
	# The rule catches the WRITE. It found FOUR live ones in the library on its
	# first run, including stzWordStream.MostFrequentWords doing exactly the
	# reported `nL = len(...)`.

	Given("a method that assigns to two of them")
	cW = ConstantWriteFixture()
	aW = StzCheckCode(cW)

	Then("clobbering NL is an error", SevOf(aW, "writes_a_mutable_constant", "NL"), "error")
	Then("...and so is clobbering TRUE", SevOf(aW, "writes_a_mutable_constant", "TRUE"), "error")
	Then("...the message says why it is silent", SaysIn(aW, "writes_a_mutable_constant", "invert"), TRUE)

	# THE NEGATIVE SIBLINGS. A rule that flagged every line with these names in
	# it would be useless -- READING them is what the library does 4,460 times.
	Then("an ordinary assignment is not flagged", SaysIn(aW, "writes_a_mutable_constant", "nOther"), FALSE)
	Then("...nor is a COMPARISON against one", NWrites(aW), 2)
EndScenario()

Scenario("Calling a value as though it were a function")

	# The other half of the constant story. The NL sweep replaced the NAME
	# NL with char(10) everywhere -- including at CALL sites, where `NL()`
	# became `char(10)()`. Ring has no currying and no call-on-result, so
	# that is never valid; but it PARSES, and only dies when the line runs,
	# as R20 "Calling function with extra number of parameters" -- an error
	# naming the arity of a function that was never wrong.
	#
	# Eighteen sites survived in stzGrid and stzTile because the only guard
	# that would have executed them was itself dead for an unrelated reason.
	# The damage hid behind someone else's failure.

	Given("a method whose NL() call was rewritten to char(10)()")
	cV = ValueCallFixture()
	aV = StzCheckCode(cV)

	Then("it is an error", SevOf(aV, "value_called_as_function", "R20"), "error")
	Then("...and the message names the shape", SaysIn(aV, "value_called_as_function", ")("), TRUE)

	Given("a definition NAME glued to a call, the other damage shape")
	aG = StzCheckCode(GluedDefNameFixture())
	Then("func char(10)@@NL(p) is an error",
	     SaysIn(aG, "value_called_as_function", "parameter list begins"), TRUE)

	# THE NEGATIVE SIBLINGS, and this rule needed them badly. Two earlier
	# drafts were measured against the whole library before being trusted:
	# blanking strings PER LINE reported 549 findings (ASCII art, embedded C,
	# SVG and DOT templates all contain ')('), and skipping whitespace before
	# the following character flagged every same-line method body in the tree.
	# Both now report nothing; the rule finds 0 across the library.

	Given("the repaired code, and shapes that only look similar")
	Then("the repaired call is clean", NValueCalls(StzCheckCode(NoValueCallFixture())), 0)
	Then("a same-line body `def W() return @n` is not flagged", NValueCalls(StzCheckCode(SameLineBodyFixture())), 0)
	Then("nested calls are not flagged", NValueCalls(StzCheckCode(NestedCallFixture())), 0)
	Then("')(' inside a STRING is not flagged", NValueCalls(StzCheckCode(ParensInStringFixture())), 0)
	Then("...even when the string spans LINES", NValueCalls(StzCheckCode(MultiLineStringFixture())), 0)
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


#-- the three shapes learned after the knob rules -----------------------------

# A method body holding a doc sample (lines 3-5), a real print (6), code either
# side of an inline block (8), and a second real print (10).
func DocFixture()
	_nl_ = char(10)
	_q_ = char(34)
	_c_ = "class stzDocDemo from stzObject" + _nl_          # 1
	_c_ += "	def Go()" + _nl_                              # 2
	_c_ += "		/*" + _nl_                                 # 3
	_c_ += "		? oX.Go()   #--> 42" + _nl_                # 4  documentation
	_c_ += "		*/" + _nl_                                 # 5
	_c_ += "		? " + _q_ + "live" + _q_ + _nl_            # 6  a real print
	_c_ += "	def Mid()" + _nl_                             # 7
	_c_ += "		x = 1 /* inline */ + 2" + _nl_             # 8
	_c_ += "	def Tail()" + _nl_                            # 9
	_c_ += "		? " + _q_ + "also live" + _q_ + _nl_       # 10 a real print
	return _c_

# which lines the print rule flags, as "6,10"
func PrintLines(pcSource)
	_aF_ = StzCheckCode(pcSource)
	_c_ = ""
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if "" + _aF_[_i_][:rule] != "library_prints"
			loop
		ok
		if _c_ != ""
			_c_ += ","
		ok
		_c_ += "" + _aF_[_i_][:line]
	next
	return _c_

# One class carrying a ratchet, a missing spelling and a bare print -- each
# beside the CORRECT sibling that must stay silent.
func ThreeFixture()
	_nl_ = char(10)
	_q_ = char(34)
	_c_ = "class stzThreeDemo from stzObject" + _nl_
	_c_ += "	@nHeight = 3" + _nl_
	_c_ += "	@nWidth = 3" + _nl_
	_c_ += "	@nMinWidth = 3" + _nl_
	_c_ += "	@bDebugMode = FALSE" + _nl_

	# 1a. the ratchet: bounded against ITSELF
	_c_ += "	def SetHeight(pn)" + _nl_
	_c_ += "		@nHeight = max([@nHeight, pn])" + _nl_
	# 1b. the correct sibling: floored against a separate minimum
	_c_ += "	def SetWidth(pn)" + _nl_
	_c_ += "		@nWidth = max([@nMinWidth, pn])" + _nl_

	# 2a. a misspelling with no correct twin
	_c_ += "	def Recieve(pV)" + _nl_
	_c_ += "		return pV" + _nl_
	# 2b. Curren without its T
	_c_ += "	def SetCurrenCell(pV)" + _nl_
	_c_ += "		return pV" + _nl_
	# 2c. a kept alias BESIDE the right name -- not a gap
	_c_ += "	def Seperate()" + _nl_
	_c_ += "		return This.Separate()" + _nl_
	_c_ += "	def Separate()" + _nl_
	_c_ += "		return TRUE" + _nl_
	# 2d. Occurrence: correctly spelled, and contains c-u-r-r-e-n
	_c_ += "	def CountOccurrences()" + _nl_
	_c_ += "		return 0" + _nl_

	# 3a. a bare print in a working method
	_c_ += "	def Work()" + _nl_
	_c_ += "		? " + _q_ + "working" + _q_ + _nl_
	# 3b. a print the caller asked for
	_c_ += "	def Parse()" + _nl_
	_c_ += "		if @bDebugMode" + _nl_
	_c_ += "			? " + _q_ + "parsing" + _q_ + _nl_
	_c_ += "		ok" + _nl_
	# 3c/3d. methods whose job IS to display, one of them internal
	_c_ += "	def ShowIt()" + _nl_
	_c_ += "		? " + _q_ + "shown" + _q_ + _nl_
	_c_ += "	def _showTable()" + _nl_
	_c_ += "		? " + _q_ + "table" + _q_ + _nl_
	# ...and the readers, so the knob rules stay quiet about this fixture
	_c_ += "	def Render()" + _nl_
	_c_ += "		return @nHeight + @nWidth + @nMinWidth" + _nl_
	return _c_

# the severity a rule reported, or "" when it never fired
func RuleSev(paFindings, pcRule)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if "" + paFindings[_i_][:rule] = pcRule
			return "" + paFindings[_i_][:severity]
		ok
	next
	return ""

# The severity of the finding of that rule which names pcText, or "" when none
# does. RuleSev answers about the FIRST finding, which is a different question
# and the wrong one whenever a rule grades its verdicts.
func SevOf(paFindings, pcRule, pcText)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if "" + paFindings[_i_][:rule] != pcRule
			loop
		ok
		if StzFindFirst(pcText, "" + paFindings[_i_][:message]) > 0
			return "" + paFindings[_i_][:severity]
		ok
	next
	return ""

# TRUE when SOME finding of that rule names pcText
func SaysIn(paFindings, pcRule, pcText)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if "" + paFindings[_i_][:rule] != pcRule
			loop
		ok
		if StzFindFirst(pcText, "" + paFindings[_i_][:message]) > 0
			return TRUE
		ok
	next
	return FALSE

func NNamed(pacWanted)
	_n_ = len(pacWanted)
	_nFound_ = 0
	for _i_ = 1 to _n_
		if StzFindFirst(pacWanted[_i_], StzCodeRuleNames()) > 0
			_nFound_++
		ok
	next
	return _nFound_

# THE SELF-CHECK. Each rule run over the real code as it stood before its fix,
# reproduced here so the guard needs no git.
func ThreeCaught(pWhich)
	if pWhich = :Ratchet
		return SaysIn(StzCheckCode(RatchetPreFix()), "setter_only_moves_one_way", "SetVizHeight")
	ok
	_aF_ = StzCheckCode(StreamPreFix())
	_cWant_ = "misspelled_name"
	if pWhich = :Prints
		_cWant_ = "library_prints"
	ok
	_nCount_ = 0
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if "" + _aF_[_i_][:rule] = _cWant_
			_nCount_++
		ok
	next
	return _nCount_

# stzCalendar as it was: SetVizWidth floored against a minimum, SetVizHeight
# against ITSELF -- one line apart, and only the second could not go down.
func RatchetPreFix()
	_nl_ = char(10)
	_c_ = "class stzCalendar from stzObject" + _nl_
	_c_ += "	@nVizWidth = 21" + _nl_
	_c_ += "	@nVizMinWidth = 21" + _nl_
	_c_ += "	@nVizHeight = 3" + _nl_
	_c_ += "	def SetVizWidth(pn)" + _nl_
	_c_ += "		@nVizWidth = max([@nVizMinWidth, pn])" + _nl_
	_c_ += "	def SetVizHeight(pn)" + _nl_
	_c_ += "		@nVizHeight = max([@nVizHeight, pn])" + _nl_
	_c_ += "	def Show()" + _nl_
	_c_ += "		return @nVizWidth + @nVizHeight + @nVizMinWidth" + _nl_
	return _c_

# stzReactiveStream as it was: three names with i before e, and an overflow
# switch that printed four different warnings past a handler seam.
func StreamPreFix()
	_nl_ = char(10)
	_q_ = char(34)
	_c_ = "class stzReactiveStream from stzObject" + _nl_
	_c_ += "	@buffer = []" + _nl_
	_c_ += "	def OnRecieved(pF)" + _nl_
	_c_ += "		return pF" + _nl_
	_c_ += "	def Recieve(pV)" + _nl_
	_c_ += "		return pV" + _nl_
	_c_ += "	def RecieveMany(paV)" + _nl_
	_c_ += "		return paV" + _nl_
	_c_ += "	def HandleOverflow(pS)" + _nl_
	_c_ += "		if pS = :Expand" + _nl_
	_c_ += "			? " + _q_ + "buffer expanded" + _q_ + _nl_
	_c_ += "		but pS = :Reject" + _nl_
	_c_ += "			? " + _q_ + "newest rejected" + _q_ + _nl_
	_c_ += "		but pS = :Evict" + _nl_
	_c_ += "			? " + _q_ + "oldest evicted" + _q_ + _nl_
	_c_ += "		else" + _nl_
	_c_ += "			? " + _q_ + "blocked" + _q_ + _nl_
	_c_ += "		ok" + _nl_
	_c_ += "		return @buffer" + _nl_
	return _c_


#-- the empty-body rule ---------------------------------------------------------

# One class carrying every form the rule must tell apart.
func EmptyFixture()
	_nl_ = char(10)
	_c_ = "class stzEmptyDemo from stzObject" + _nl_
	_c_ += "	@nX = 0" + _nl_

	# empty, and it is a plain action
	_c_ += "	def Vanish()" + _nl_

	# empty, and it is a PREDICATE -- the harsher verdict
	_c_ += "	def ContainsValues()" + _nl_

	# empty apart from a comment
	_c_ += "	def Commented()" + _nl_
	_c_ += "		# nothing to do here" + _nl_

	# NOT empty: Ring's brace form
	_c_ += "	def Braced(pn)  { @nX = pn ; return This }" + _nl_

	# NOT empty: Ring's bare same-line form
	_c_ += "	def Bare(pn) @nX = pn" + _nl_

	# NOT empty: an ordinary indented body
	_c_ += "	def Normal(pn)" + _nl_
	_c_ += "		@nX = pn" + _nl_
	_c_ += "		return This" + _nl_

	# exempt: a class with nothing to initialise
	_c_ += "	def init()" + _nl_
	return _c_

# stzReactiveSystem as it stood: the XT alias declared, and the next line the
# next method.
func EmptyCaught()
	_nl_ = char(10)
	_c_ = "class stzReactiveSystem from stzObject" + _nl_
	_c_ += "	def RunAfterXT(pn, pcUnit, pf)" + _nl_
	_c_ += "		return This.RunAfter(pn, pf)" + _nl_
	_c_ += "" + _nl_
	_c_ += "		def SetTimeoutXT(pn, pcUnit, pf)" + _nl_
	_c_ += "" + _nl_
	_c_ += "	def RunAfter(pn, pf)" + _nl_
	_c_ += "		return TRUE" + _nl_
	return SaysIn(StzCheckCode(_c_), "empty_method_body", "SetTimeoutXT")


#-- the mutable-constant rule ---------------------------------------------------

func ConstantWriteFixture()
	_nl_ = char(10)
	_c_ = "class stzClobberDemo from stzObject" + _nl_
	_c_ += "	def Go(paItems)" + _nl_
	_c_ += "		nL = len(paItems)" + _nl_          # THE reported shape
	_c_ += "		true = 0" + _nl_                   # the silent one
	_c_ += "		nOther = len(paItems)" + _nl_      # fine
	_c_ += "		if nOther = TRUE" + _nl_           # a READ, not a write
	_c_ += "			return 1" + _nl_
	_c_ += "		ok" + _nl_
	_c_ += "		return 0" + _nl_
	return _c_

#-- the value-called-as-function rule -------------------------------------------

func ValueCallFixture()
	_nl_ = char(10)
	_c_ = "class stzGridDemo from stzObject" + _nl_
	_c_ += "	def ToString()" + _nl_
	_c_ += "		_r_ = """"" + _nl_
	_c_ += "		_r_ += char(10)()" + _nl_        # THE damage the NL sweep left
	_c_ += "		return _r_" + _nl_
	return _c_

func NoValueCallFixture()
	_nl_ = char(10)
	_c_ = "class stzGridDemo from stzObject" + _nl_
	_c_ += "	def ToString()" + _nl_
	_c_ += "		_r_ = """"" + _nl_
	_c_ += "		_r_ += char(10)" + _nl_          # repaired
	_c_ += "		return _r_" + _nl_
	return _c_

func GluedDefNameFixture()
	# What the sweep did to a DEFINITION: `func NL@@NL(p)` keeps its
	# parameter list but the name now carries a call.
	return "func char(10)@@NL(p)" + char(10) + "	return p" + char(10)

func SameLineBodyFixture()
	return "class stzZ" + char(10) + "	def W()   return @nW" + char(10)

func NestedCallFixture()
	_q_ = char(34)
	return "class stzZ" + char(10) + "	def W()" + char(10) +
	       "		return StzLower(StzUpper(" + _q_ + "ab" + _q_ + "))" + char(10)

func ParensInStringFixture()
	_q_ = char(34)
	return "class stzZ" + char(10) + "	def W()" + char(10) +
	       "		return " + _q_ + "a)(b" + _q_ + char(10)

func MultiLineStringFixture()
	# The case that a per-line blanker gets wrong: from line two on, the
	# INSIDE of this literal reads as code, and ')(' is everywhere in the
	# ASCII art and embedded C the library actually stores this way.
	_q_ = char(34)
	return "class stzZ" + char(10) + "	def Art()" + char(10) +
	       "		return " + _q_ + "  )(  " + char(10) +
	       " )( " + char(10) + "   )(   " + _q_ + char(10)

func NValueCalls(paFindings)
	_n_ = 0
	for _i_ = 1 to len(paFindings)
		if "" + paFindings[_i_][:rule] = "value_called_as_function"
			_n_++
		ok
	next
	return _n_

func NWrites(paFindings)
	_n_ = 0
	for _i_ = 1 to len(paFindings)
		if "" + paFindings[_i_][:rule] = "writes_a_mutable_constant"
			_n_++
		ok
	next
	return _n_
