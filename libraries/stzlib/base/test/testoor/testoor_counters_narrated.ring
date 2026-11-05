load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P3.4 -- NODE COUNTERS. How many times did a tour reach each node of its program? The
# counts are the numerator of graph coverage: a tour (or a hook acting for it) says it reached a
# node, and at the end the counts are printed as `[testoor node ID N]` lines, which the verdict
# reads into the tour's nodes record.
#
# THE QUESTION THE DESIGN HAD TO ANSWER FIRST, and the reason this guard measures: the first idea
# was Ring's per-line trace hook, which costs 11.5 us an event on Ring 1.27. A counter called
# directly must beat that, or counting is a tax nobody pays. It does, by a factor of fifty: an
# empty Ring function call is 0.05 us on Ring++, an engine call that takes and returns numbers
# 0.15 us. The same measurement found that an engine call that RETURNS A STRING cost 10.8 us, as much
# as the hook, because every bridge call built a fresh arena on the page allocator; the arena is now
# reused, and this guard pins both figures. (`ringvm_settrace`, the hook itself, does not exist on
# Ring++: it is not re-measured here, and says so.)
#
# Every positive has its sibling: an id that holds a space is refused and counts nowhere; a slot
# nobody registered is ignored; a count past the longest a node line carries saturates; the same
# script gives the same transcript on the core and on the Ring reference.

? "TESTOOR P3.4 -- node counters"
nCnStart = clock()
cCnGolden = currentdir() + "/../../testoor/golden"
bCnCore = $bStzTestoorCore

#============================================================================
Scenario("A node is registered once, counted by slot or by id, and reported as the lines a tour prints")
	nCnSec = clock()
	TestoorCore("auto")
	TestoorReset()
	Given("two nodes registered, one of them twice")
	nA = TestoorNodeSlot("sc1.Total")
	nB = TestoorNodeSlot("sc1.Rate")
	Then("a slot is a number from one, in the order of registration", nB - nA, 1)
	Then("registering a node again answers the slot it has", TestoorNodeSlot("sc1.Total"), nA)
	Given("hits by slot, by id, and by a number of hits")
	TestoorNodeHit(nA)
	TestoorNodeHit(nA)
	TestoorNodeHitN(nB, 5)
	TestoorNode("sc1.Total")
	TestoorNodeN("sc1.Rate", 2)
	Then("the hits add: Total three, Rate seven", "" + TestoorNodeCount("sc1.Total") + "/" + TestoorNodeCount("sc1.Rate"), "3/7")
	Then("a node nobody reached has no hits", TestoorNodeCount("sc1.Never"), 0)
	Then("the report is the node lines, in registration order",
	     TestoorNodesLines(), "[testoor node sc1.Total 3]" + char(10) + "[testoor node sc1.Rate 7]")
	Given("ids a node line could not carry, and a slot nobody registered")
	Then("an id with a space is refused: slot 0", TestoorNodeSlot("sc1 Total"), 0)
	Then("so is an empty one", TestoorNodeSlot(""), 0)
	Then("so is one with a tab in it", TestoorNodeSlot("sc1" + char(9) + "x"), 0)
	Then("a refused id counts nowhere", TestoorNode("sc1 Total"), 0)
	Then("a slot nobody registered is ignored, not counted somewhere else", TestoorNodeHit(9999) + TestoorNodeHit(0), 0)
	Then("and none of that added a line", TestoorNodesLines(), "[testoor node sc1.Total 3]" + char(10) + "[testoor node sc1.Rate 7]")
	Given("a count far past the longest a node line carries")
	Then("it saturates at fifteen nines", TestoorNodeHitN(nB, 1000000000000000000), 999999999999999)
	When("the counts are reset")
	TestoorNodesReset()
	Then("every count is zero", TestoorNodeCount("sc1.Total") + TestoorNodeCount("sc1.Rate"), 0)
	Then("nothing was reached, so the report is empty", TestoorNodesLines(), "")
	Then("and a slot cached before the reset still counts", TestoorNodeHit(nA), 1)
	Then("TestoorNodesReport prints the lines and says how many", TestoorNodesReport(), 1)
	TestoorReset()
	Then("TestoorReset zeroes the counts too: a tour's world includes them", TestoorNodeCount("sc1.Total"), 0)
EndScenario()
? "        [section took " + ((clock() - nCnSec) / clockspersecond()) + "s]"

if NOT bCnCore
	? ""
	? "SKIPPED by name, because stz_testoor is not loaded on this virtual machine:"
	? "  the core against the reference, the report read by the verdict, and the cost of a hit"
else

#============================================================================
Scenario("The core and the reference count the same: one script, two implementations, one transcript")
	nCnSec = clock()
	Given("the script walked on the Ring reference, then on the core")
	TestoorCore("ring")
	cCnRef = _CnScript()
	TestoorCore("engine")
	cCnEng = _CnScript()
	Then("the core holds the counts in the engine", _TestoorNodesDecide(), 1)
	Then("the two transcripts are the same bytes", cCnEng, cCnRef)
	Then("and say what the script did",
	     cCnEng, "gap=1|same=1|bad=0,0,0|A=5,B=6,C=1,none=0|lines=[testoor node cn.A 5]" + char(10) + "[testoor node cn.B 6]" + char(10) + "[testoor node cn.C 1]|ignored=0,0|big=999999999999999|negative=5|after=|again=1|")
EndScenario()
? "        [section took " + ((clock() - nCnSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("What the counters print is what the verdict reads: node evidence from a tour that counted")
	nCnSec = clock()
	TestoorCore("engine")
	TestoorReset()
	Given("a tour that reached Total three times and Add twice, and a node the graph does not own")
	nT = TestoorNodeSlot("stzTax.Total")
	for i = 1 to 3
		TestoorNodeHit(nT)
	next
	TestoorNodeN("stzMoney.Add", 2)
	TestoorNode("ghost.Node")
	cLines = TestoorNodesLines()
	Then("the report holds the three nodes, in registration order",
	     cLines, "[testoor node stzTax.Total 3]" + char(10) + "[testoor node stzMoney.Add 2]" + char(10) + "[testoor node ghost.Node 1]")
	When("the tour's output, with those lines, is judged against the program's graph")
	cOut = "250" + char(9) + "[testoor stop counted]" + char(10) + "500" + char(9) + "[testoor ok it counted]" + char(10)
	acL = str2list(cLines)
	for i = 1 to len(acL)
		cOut += "" + (750 + (i - 1) * 250) + char(9) + acL[i] + char(10)
	next
	cReq = '{"record":{"file":"fixtures/cnt.py","readable":1,"why":"","dialect":"protocol","lines":40,"asserts":1,"stops":[{"title":"(the tour)","line":1,"claims":[]}],"routes":[]},' +
	       '"output":' + _TourJsonStr(cOut) + ',"meta":{"exit":0,"hung":0,"stderr":"","wall_ms":1000,"seed":5,"unreadable":0,"face":{"ignore":"","endings":[]}},' +
	       '"graph":' + TestoorGoldenRead(cCnGolden + "/protocol2/judge/15_nodes_named_observed/graph.json") + "}"
	cTour = StzEngineTestoorVerdict(cReq)
	Then("the tour's nodes are the counts, in the graph's order, and the graph's own spelling",
	     StzFindFirst('"nodes":[{"id":"stzTax.Total","evidence":"observed","hits":3},{"id":"stzMoney.Add","evidence":"observed","hits":2}]', cTour) > 0, TRUE)
	Then("the node the graph does not own is not listed", StzFindFirst("ghost", cTour), 0)
	Then("and the tour is kept", StzFindFirst('"state":"kept"', cTour) > 0, TRUE)
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nCnSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("THE COST: a counter called directly beats the 11.5 us the Ring trace hook costs")
	nCnSec = clock()
	TestoorCore("engine")
	TestoorReset()
	nN = 100000
	nSlot = TestoorNodeSlot("cost.Slot")
	nT0 = clock()
	for i = 1 to nN
		_CnEmpty()
	next
	nEmptyUs = (clock() - nT0) / clockspersecond() / nN * 1000000
	nT0 = clock()
	for i = 1 to nN
		TestoorNodeHit(nSlot)
	next
	nSlotUs = (clock() - nT0) / clockspersecond() / nN * 1000000
	nT0 = clock()
	for i = 1 to nN
		TestoorNode("cost.Id")
	next
	nIdUs = (clock() - nT0) / clockspersecond() / nN * 1000000
	nT0 = clock()
	for i = 1 to nN
		x = StzEngineTestoorWorld("mode", "", 0, 0)
	next
	nStrUs = (clock() - nT0) / clockspersecond() / nN * 1000000
	? "        per event, over " + nN + " events each:"
	? "          an empty Ring function call     " + nEmptyUs + " us"
	? "          TestoorNodeHit(slot)            " + nSlotUs + " us"
	? "          TestoorNode(id)                 " + nIdUs + " us"
	? "          an engine call returning text   " + nStrUs + " us   (10.81 us before the arena was reused)"
	Given("a hundred thousand events counted by slot, and as many by id")
	Then("every hit was counted", TestoorNodeCount("cost.Slot") + TestoorNodeCount("cost.Id"), 2 * nN)
	Then("a hit by slot costs less than the 11.5 us the trace hook costs", nSlotUs < 11.5, TRUE)
	Then("a hit by id costs less than that too", nIdUs < 11.5, TRUE)
	Then("an engine call that returns text no longer pays a page allocation: under five us", nStrUs < 5, TRUE)
	Then("and a hit by slot is within a few Ring calls of an empty one", nSlotUs < nEmptyUs + 5, TRUE)
	bHook = 1
	try
		ringvm_settrace("")
	catch
		bHook = 0
	done
	if NOT bHook
		? "        NOT RE-MEASURED, by name: ringvm_settrace does not exist on this virtual machine (R3); the 11.5 us is Ring 1.27's"
	ok
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nCnSec) / clockspersecond()) + "s]"

ok

? ""
? "[P3.4 took " + ((clock() - nCnStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _CnEmpty()
	return

# ONE script on whichever implementation is chosen, as text. Slots are compared by gap, not by value:
# an implementation that has registered other ids before is not wrong for numbering them from there.
func _CnScript()
	TestoorNodesReset()
	_c_ = ""
	_s1_ = TestoorNodeSlot("cn.A")
	_s2_ = TestoorNodeSlot("cn.B")
	_c_ += "gap=" + (_s2_ - _s1_) + "|"
	_c_ += "same=" + (TestoorNodeSlot("cn.A") = _s1_) + "|"
	_c_ += "bad=" + TestoorNodeSlot("cn A") + "," + TestoorNodeSlot("") + "," + TestoorNodeSlot("cn" + char(9) + "x") + "|"
	TestoorNodeHit(_s1_)
	TestoorNodeHit(_s1_)
	TestoorNodeHit(_s1_)
	TestoorNodeHitN(_s2_, 5)
	TestoorNode("cn.C")
	TestoorNodeN("cn.A", 2)
	TestoorNode("cn.B")
	_c_ += "A=" + TestoorNodeCount("cn.A") + ",B=" + TestoorNodeCount("cn.B") + ",C=" + TestoorNodeCount("cn.C") + ",none=" + TestoorNodeCount("cn.nope") + "|"
	_c_ += "lines=" + TestoorNodesLines() + "|"
	_c_ += "ignored=" + TestoorNodeHit(9999) + "," + TestoorNodeHit(0) + "|"
	_c_ += "big=" + TestoorNodeHitN(_s2_, 1000000000000000000) + "|"
	_c_ += "negative=" + TestoorNodeHitN(_s1_, -5) + "|"
	TestoorNodesReset()
	_c_ += "after=" + TestoorNodesLines() + "|"
	_c_ += "again=" + TestoorNodeHit(_s1_) + "|"
	TestoorNodesReset()
	return _c_
