load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR TR3 -- ROUTES BEFORE ROADS, AND THE MAP. Coverage is first the
# count of ROUTES (plan items) that have a TOUR (a test that declares it walks
# them with discharges("X") or Route("X")), joined from the court's own plan
# reader and the tour reader. OWNED and WALKED are two figures and are never
# summed, and no percentage is printed (ruling 8). Then the map: the public
# methods of a class that no tour NAMES, from the code graph -- a static name
# join, a proxy for a route and not execution coverage, said in every report.
#
# WHAT IS PLANTED. A plan of three items, ZA1 and ZA2 read closed and ZA3 reads
# open; tours that walk them; a class with three public methods, an init and a
# private one. The planted files live in _planted_routes/ beside this guard
# (a leading "_" is what the reader skips; git ignores it) and are removed.
#
# THE GUARD THE LAUNCH PROMPT ASKED FOR: one plan item with no tour reports
# ONE route unwalked; adding the tour clears it. Every positive has its
# sibling: a closed route is a WARNING and an open one is INFO; a tour naming
# a route the plan does not define is a finding and a tour naming a known one
# is not; a method defined in a tour is not a method touched.
#
# AND AN INDEPENDENT CHECK on the real gate: the routes the tour reader finds
# in gg_adversarial.ring equal what the court's own StzSuiteDischargesOf finds
# in it -- two readers written apart, one answer.

? "TESTOOR TR3 -- routes and the map"
nTrStart = clock()
cTrHere = currentdir()
cTrPlant = cTrHere + "/_planted_routes"
_TrPlantAll(cTrPlant)
cTrPlan2 = "### ZA1 -- first" + char(10) + "CLOSED: shipped." + char(10) +
           "### ZA2 -- second" + char(10) + "CLOSED: shipped." + char(10)

#============================================================================
Scenario("Route() and discharges() are read as walks, in every dialect")
	nTrSec = clock()
	Given('a plain tour that declares Route("ZA1"), and a gate section that discharges("ZA2")')
	aA = Tour(cTrPlant + "/tours/one.ring")
	aB = Tour(cTrPlant + "/tours/two_gate.ring")
	Then("the plain tour has one route", len(aA[:routes]), 1)
	Then("it names the plan item", aA[:routes][1][:item], "ZA1")
	Then("the gate has one route", len(aB[:routes]), 1)
	Then("it names its item and the section it sits in", aB[:routes][1][:item] + "|" + aB[:routes][1][:stop], "ZA2|-- 1. the second route --")
	Then("a tour that declares nothing has none", len(Tour(cTrPlant + "/tours/silent.ring")[:routes]), 0)
	Then("Route() is harmless when the tour runs", Route("ZA1"), 1)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("One plan item with no tour is ONE route unwalked; adding the tour clears it")
	nTrSec = clock()
	Given("a plan of two closed items and only the tour for ZA1")
	oM = StzRouteMapQ().AddPlan("plan", cTrPlan2).AddTour(Tour(cTrPlant + "/tours/one.ring"))
	Then("two routes are owned", oM.OwnedCount(), 2)
	Then("one is walked", oM.WalkedCount(), 1)
	Then("one is unwalked", oM.UnwalkedCount(), 1)
	Then("and it is ZA2", oM.Unwalked()[1][1], "ZA2")
	Then("the court has exactly one route_without_tour", _TrCountRule(oM.Findings(), :route_without_tour), 1)
	Then("the prose names it, as counts and never a percentage",
		StzFindFirst("owned 2, walked 1, unwalked 1", oM.Prose()) > 0 and StzFindFirst("%", oM.Prose()) = 0, TRUE)
	Given("the same plan once the tour for ZA2 is added")
	oM.AddTour(Tour(cTrPlant + "/tours/two_gate.ring"))
	Then("two are walked", oM.WalkedCount(), 2)
	Then("none is unwalked", oM.UnwalkedCount(), 0)
	Then("the court has no route_without_tour", _TrCountRule(oM.Findings(), :route_without_tour), 0)
	Then("and nothing needs attention", oM.NeedsAttention(), 0)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A closed route nobody walks is a warning; an open one is information; a typo is a finding")
	nTrSec = clock()
	Given("a plan with ZA1 closed and ZA3 open, and no tour at all")
	oM = StzRouteMapQ().AddPlan("plan", "### ZA1 -- a" + char(10) + "CLOSED." + char(10) + "### ZA3 -- c" + char(10) + "NEXT: not started." + char(10))
	aF = oM.Findings()
	Then("two routes are unwalked", oM.UnwalkedCount(), 2)
	Then("the closed one is a WARNING", _TrSeverityOf(aF, "ZA1"), "warning")
	Then("the open one is INFO", _TrSeverityOf(aF, "ZA3"), "info")
	Then("the warning needs attention", oM.NeedsAttention(), 1)
	Given("only the open route unwalked")
	oO = StzRouteMapQ().AddPlan("plan", "### ZA3 -- c" + char(10) + "NEXT: not started." + char(10))
	Then("an open route alone needs no attention", oO.NeedsAttention(), 0)
	Given("a tour that declares a route the plan does not define")
	oU = StzRouteMapQ().AddPlan("plan", cTrPlan2).AddTour(Tour(cTrPlant + "/tours/typo.ring"))
	Then("the typo is one unknown walk", len(oU.UnknownWalks()), 1)
	Then("named", oU.UnknownWalks()[1][1], "ZA9")
	Then("the court says so, under its own rule", _TrCountRule(oU.Findings(), :guard_discharges_unknown_item), 1)
	Then("whereas a tour naming a known route says nothing of the kind",
		_TrCountRule(StzRouteMapQ().AddPlan("plan", cTrPlan2).AddTour(Tour(cTrPlant + "/tours/one.ring")).Findings(), :guard_discharges_unknown_item), 0)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The findings are the court's shape and one rule report ingests them")
	nTrSec = clock()
	Given("a map with an unwalked closed route and an untouched method")
	oM = StzRouteMapQ().AddPlan("plan", cTrPlan2).AddTour(Tour(cTrPlant + "/tours/one.ring"))
	oM.MapMethods(cTrPlant + "/classes/stzPlanted.ring", [ cTrPlant + "/tours/calls_alpha.ring" ])
	aF = oM.Findings()
	Then("every finding has the five keys",
		_TrAllHaveKeys(aF), TRUE)
	oRep = new stzRuleReport("tr3")
	oRep.Ingest(aF)
	Then("the one rule report holds them all", len(oRep.Findings()), len(aF))
	Then("and counts the warning by severity", len(oRep.FindingsOfSeverity(:warning)) >= 1, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The map names the public methods no tour names, by a static name join")
	nTrSec = clock()
	Given("a class with Alpha, Beta, Gamma, init and _Hidden, and a tour calling .Alpha() and beta(1)")
	aU = StzUntouchedMethods(cTrPlant + "/classes/stzPlanted.ring", [ cTrPlant + "/tours/calls_alpha.ring" ])
	Then("exactly one method is untouched", len(aU), 1)
	Then("it is Gamma", aU[1][3], "Gamma")
	Then("it is named with its class", aU[1][1], "stzPlanted")
	Then("Beta is touched though the tour wrote it in another case", _TrListHas(aU, "Beta"), FALSE)
	Then("init and the private method are not public surface", _TrListHas(aU, "init") or _TrListHas(aU, "_Hidden"), FALSE)
	Given("a tour that only DEFINES Gamma")
	aD = StzUntouchedMethods(cTrPlant + "/classes/stzPlanted.ring", [ cTrPlant + "/tours/calls_alpha.ring", cTrPlant + "/tours/defines_gamma.ring" ])
	Then("a definition is not a touch: Gamma is still untouched", _TrListHas(aD, "Gamma"), TRUE)
	Given("a tour that calls Gamma")
	aC = StzUntouchedMethods(cTrPlant + "/classes/stzPlanted.ring", [ cTrPlant + "/tours/calls_alpha.ring", cTrPlant + "/tours/calls_gamma.ring" ])
	Then("nothing is untouched any more", len(aC), 0)
	Then("the court names the one untouched method as information",
		_TrCountRule(StzRouteMapQ().MapMethods(cTrPlant + "/classes/stzPlanted.ring", [ cTrPlant + "/tours/calls_alpha.ring" ]).Findings(), :method_without_tour), 1)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("On the real gate, the tour reader and the court's own reader find the same routes")
	nTrSec = clock()
	cGate = cTrHere + "/../graphics/gg_adversarial.ring"
	Given("gg_adversarial.ring, 161 sections, read by two readers written apart")
	aRec = Tour(cGate)
	acMine = _TrIdsOf(aRec[:routes], 1)
	aTheirs = StzSuiteDischargesOf([ cGate ])
	acTheirs = _TrIdsOf(aTheirs, 1)
	? "        (the tour reader: " + len(acMine) + " discharges; the court's: " + len(acTheirs) + ")"
	Then("both found some", len(acMine) > 0 and len(acTheirs) > 0, TRUE)
	Then("the same number", len(acMine), len(acTheirs))
	Then("the same items, in the same order", _TrJoin(acMine), _TrJoin(acTheirs))
	Given("the real graphics plan and every graphics tour, read and not run")
	oRg = StzRouteMapQ().AddPlanFile(cTrHere + "/../../graphics/SOFTANZA_GRAPHICS_PLAN.md").AddToursUnder(cTrHere + "/../graphics")
	? "        " + _TrFirstLine(oRg.Prose())
	Then("the plan owns routes", oRg.OwnedCount() > 0, TRUE)
	Then("some are walked", oRg.WalkedCount() > 0, TRUE)
	Then("walked never exceeds owned", oRg.WalkedCount() <= oRg.OwnedCount(), TRUE)
	Given("the real uuid class and the real uuid tours")
	aUu = StzUntouchedMethods(cTrHere + "/../../system/stzUUID.ring", _TrFilesOf(cTrHere + "/../uuid"))
	? "        (stzUUID: " + len(aUu) + " public methods named by no uuid tour)"
	Then("the map ran on a real class", len(aUu) >= 0, TRUE)
	Then("Content() is touched: the uuid tours call it", _TrListHas(aUu, "Content"), FALSE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

_TrUnplantAll(cTrPlant)
? ""
? "[TR3 took " + ((clock() - nTrStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _TrPlantAll(cRoot)
	_TrUnplantAll(cRoot)
	StzMakeDir(cRoot)
	StzMakeDir(cRoot + "/tours")
	StzMakeDir(cRoot + "/classes")
	_nl_ = char(10)
	write(cRoot + "/tours/one.ring",
		'Route("ZA1")' + _nl_ + '? "  [OK] a claim on route one"' + _nl_)
	write(cRoot + "/tours/two_gate.ring",
		'nOk = 0' + _nl_ + 'sec("-- 1. the second route --")' + _nl_ +
		'discharges("ZA2")' + _nl_ + 'chk("a claim on route two", 1 = 1)' + _nl_ +
		"func sec cTitle" + _nl_ + char(9) + "? cTitle" + _nl_ +
		"func chk cWhat, bCond" + _nl_ + char(9) + "if bCond nOk++ ok" + _nl_ +
		"func discharges cItem" + _nl_ + char(9) + "? cItem" + _nl_)
	write(cRoot + "/tours/typo.ring",
		'Route("ZA9")' + _nl_ + '? "  [OK] a claim on a route nobody defined"' + _nl_)
	write(cRoot + "/tours/silent.ring", '? "  [OK] a claim that declares no route"' + _nl_)
	write(cRoot + "/classes/stzPlanted.ring",
		"class stzPlanted" + _nl_ +
		char(9) + "def init()" + _nl_ + char(9) + char(9) + "return" + _nl_ +
		char(9) + "def Alpha()" + _nl_ + char(9) + char(9) + "return 1" + _nl_ +
		char(9) + "def Beta(n)" + _nl_ + char(9) + char(9) + "return n" + _nl_ +
		char(9) + "def Gamma()" + _nl_ + char(9) + char(9) + "return 3" + _nl_ +
		char(9) + "def _Hidden()" + _nl_ + char(9) + char(9) + "return 0" + _nl_)
	write(cRoot + "/tours/calls_alpha.ring",
		'o = new stzPlanted()' + _nl_ + '? o.Alpha()' + _nl_ + '? BETA(1)' + _nl_)
	write(cRoot + "/tours/defines_gamma.ring",
		'func Gamma()' + _nl_ + char(9) + 'return 0' + _nl_)
	write(cRoot + "/tours/calls_gamma.ring",
		'o = new stzPlanted()' + _nl_ + '? o.Gamma()' + _nl_)

func _TrUnplantAll(cRoot)
	if fexists(cRoot + "/tours/one.ring")
		StzDirDeleteAll(cRoot)
	ok

func _TrCountRule(aFindings, cRule)
	n = 0
	nF = len(aFindings)
	for i = 1 to nF
		if "" + aFindings[i][:rule] = "" + cRule  n++  ok
	next
	return n

func _TrSeverityOf(aFindings, cRoute)
	nF = len(aFindings)
	for i = 1 to nF
		if "" + aFindings[i][:rule] = "route_without_tour" and StzFindFirst("route " + cRoute + " ", aFindings[i][:message]) > 0
			return "" + aFindings[i][:severity]
		ok
	next
	return ""

func _TrAllHaveKeys(aFindings)
	nF = len(aFindings)
	if nF = 0  return FALSE  ok
	for i = 1 to nF
		f = aFindings[i]
		if len(f) != 5  return FALSE  ok
		if NOT (isString("" + f[:rule]) and ("" + f[:subject]) != "" and ("" + f[:where]) != "" and ("" + f[:severity]) != "" and ("" + f[:message]) != "")
			return FALSE
		ok
	next
	return TRUE

func _TrListHas(aU, cMethod)
	n = len(aU)
	for i = 1 to n
		if lower("" + aU[i][3]) = lower(cMethod)  return TRUE  ok
	next
	return FALSE

func _TrIdsOf(aList, nCol)
	ac = []
	n = len(aList)
	for i = 1 to n
		if isList(aList[i]) and nCol = 1 and len(aList[i]) >= 1 and isString(aList[i][1])
			ac + aList[i][1]
		but isList(aList[i])
			ac + aList[i][:item]
		ok
	next
	return ac

func _TrJoin(ac)
	c = ""
	n = len(ac)
	for i = 1 to n
		c += ac[i] + ","
	next
	return c

func _TrFirstLine(c)
	n = StzFindFirst(char(10), c)
	if n = 0  return c  ok
	return substr(c, 1, n - 1)

func _TrFilesOf(cDir)
	aTwo = _TourFilesUnder(cDir, "")
	return aTwo[1]
