load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 7 -- the NEW code rules the graph makes possible + StzCheckProject.
#
# A text scanner sees one line at a time. A code GRAPH sees the whole picture,
# so it can enforce rules that were impossible before:
#   q-has-plain-twin   -- a ...Q() MUTATOR must have a plain twin (compares a
#                         class's whole method set). This is the rule that would
#                         have flagged the 62 Q-only mutators of the naming
#                         campaign -- and it does NOT flag a noun accessor.
#   no-case-collision  -- two names differing ONLY in case are a Ring C22 crash;
#                         a line scan can never see the pair, a graph always can.
#   no-dead-code       -- a defined name no recorded call reaches (needs the full
#                         call graph -> project-level).
#   no-cyclic-calls    -- mutual recursion (expensive -> opt-in "deep" audit).
#
# StzCheckProject builds ONE graph across a whole directory and runs them.

$cFix = WorkingDirectory() + "/_p7_fixture"

Scenario("q-has-plain-twin: a Q mutator with no plain twin (the campaign's bug)")
	Given("a class with SetLevelQ (no twin), AddItemQ (has AddItem), and ReactorQ")
	cSrc = "class Bag" + nl +
	       "def SetLevelQ()" + nl + "	return This" + nl +
	       "def AddItemQ()" + nl + "	return This" + nl +
	       "def AddItem()" + nl + "	return" + nl +
	       "def ReactorQ()" + nl + "	return oReactorObj" + nl
	aF = StzCheckCode(cSrc)
	Then("q-has-plain-twin fires on SetLevelQ", HasAt(aF, "q-has-plain-twin", 2), TRUE)
	Then("...only ONCE (AddItemQ has its twin; ReactorQ is a noun accessor)",
	     CountRule(aF, "q-has-plain-twin"), 1)
EndScenario()

Scenario("no-case-collision: the Ring C22 a line scan cannot see")
	Given("a class defining NthStz and NthSTZ")
	cSrc = "class Bag" + nl +
	       "def NthStz()" + nl + "	return 1" + nl +
	       "def NthSTZ()" + nl + "	return 2" + nl
	aF = StzCheckCode(cSrc)
	Then("no-case-collision fires", HasRule(aF, "no-case-collision"), TRUE)
	Then("...as an error (it is a hard crash)", SevOf(aF, "no-case-collision"), :error)

	Given("a class with no case-colliding names")
	Then("it does not fire", HasRule(StzCheckCode("class Bag" + nl + "def One()" + nl + "	return 1" + nl), "no-case-collision"), FALSE)
EndScenario()

Scenario("StzCheckCode stays FROZEN -- the new rules add no false positives")
	cBad = "class Foo" + nl +
	       "def Len()" + nl + "	return 5" + nl +
	       "def BarQ()" + nl + "	return 42" + nl +
	       "def KillProcess()" + nl + "	return" + nl
	aF = StzCheckCode(cBad)
	Then("still exactly the three house findings", CountRule(aF, "no-len-method") +
	     CountRule(aF, "q-returns-object") + CountRule(aF, "no-aggressive-verbs"), 3)
	Then("...q-has-plain-twin does NOT fire (BarQ is not a mutator verb)",
	     HasRule(aF, "q-has-plain-twin"), FALSE)
	Then("StzCodeRuleNames now lists six", len(StzCodeRuleNames()), 6)
EndScenario()

Scenario("StzCheckProject: no-dead-code over a whole directory")
	Given("a fixture directory with an uncalled private method and a used one")
	StzEngineDirCreatePath($cFix)
	write($cFix + "/widget.ring", "class Widget" + nl +
	      "def Render()" + nl + "	This._Used()" + nl +
	      "def _Used()" + nl + "	return 1" + nl +
	      "def _Orphan()" + nl + "	return 2" + nl)
	aF = StzCheckProject($cFix)
	Then("no-dead-code flags the orphan private method", HasRule(aF, "no-dead-code"), TRUE)
	Then("...findings are in the unified shape (:subject = code)",
	     HasKey(aF[1], :subject) and aF[1][:subject] = "code", TRUE)
	Then("the project has no ERROR -> clean (dead-code is a warning)",
	     StzProjectIsClean($cFix), TRUE)
EndScenario()

Scenario("StzCheckProjectDeep: no-cyclic-calls (opt-in, the slow audit)")
	Given("a fixture with two mutually-recursive methods")
	write($cFix + "/pinger.ring", "class Pinger" + nl +
	      "def Ping()" + nl + "	This.Pong()" + nl +
	      "def Pong()" + nl + "	This.Ping()" + nl)
	When("the DEEP audit runs")
	aF = StzCheckProjectDeep($cFix)
	Then("no-cyclic-calls catches the Ping/Pong cycle", HasRule(aF, "no-cyclic-calls"), TRUE)
	When("the FAST gate runs")
	aFast = StzCheckProject($cFix)
	Then("...the fast gate does NOT run the expensive cyclic check",
	     HasRule(aFast, "no-cyclic-calls"), FALSE)
	StzDirDeleteAll($cFix)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func HasRule aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return TRUE ok
	next
	return FALSE

func HasAt aF, cRule, nLine
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule and aF[i][:line] = nLine return TRUE ok
	next
	return FALSE

func CountRule aF, cRule
	c = 0
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule c++ ok
	next
	return c

func SevOf aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return aF[i][:severity] ok
	next
	return ""
