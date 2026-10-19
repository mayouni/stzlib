load "../../stzBase.ring"
load "../_narrated.ring"

# stzGraphComparison (end of base/graph/stzGraph.ring) -- the three register rows, run on small graphs whose
# answers were worked out by hand BEFORE the code was run.
#
#   base    a -> b -> c                      no cycle
#   cyc     base + c -> a                    closes a cycle through all three nodes
#   cyc2    base + c -> b                    closes a cycle b -> c -> b
#   acy     base + node d + c -> d           stays acyclic
#   rem     base minus node c                stays acyclic
#
# What each row was: Content had an empty body and answered the empty text; WithCycles and WithoutCycles
# tested the cycle field, which holds the text TRUE or FALSE, against the numbers 1 and 0, so both always
# answered the empty list. Two siblings had the same shape: Recommend never gave its acyclic bonus (a cyclic
# variation could win) and ByMetric raised "Invalid numeric string" on any text column. Run from inside
# this folder. ASCII only on the console.

oBase = BuildBase()
oCyc  = BuildCyc()
oCyc2 = BuildCyc2()
oAcy  = BuildAcy()
oRem  = BuildRem()

oMix = new stzGraphComparison(oBase, [ [ "cyc", oCyc ], [ "acy", oAcy ], [ "cyc2", oCyc2 ], [ "rem", oRem ] ])

Scenario("The variations really are what the header says")
	Then("the base has no cycle", oBase.HasCyclicDependencies(), 0)
	Then("cyc has a cycle", oCyc.HasCyclicDependencies(), 1)
	Then("cyc2 has a cycle", oCyc2.HasCyclicDependencies(), 1)
	Then("acy has no cycle", oAcy.HasCyclicDependencies(), 0)
	Then("rem has no cycle", oRem.HasCyclicDependencies(), 0)
EndScenario()

Scenario("Content answers what Data answers")
	aData = oMix.Data()
	aContent = oMix.Content()
	Then("Content is a list, not the empty text", isList(aContent), 1)
	Then("Content holds the three keys", len(aContent), 3)
	Then("Content counts the four variations", aContent[:count], 4)
	Then("Content names the baseline", aContent[:baseline], "base")
	Then("Content holds the four rows", len(aContent[:comparisons]), 4)
	Then("Content and Data print the same", @@(aContent), @@(aData))
	Then("Content is NOT the empty text", isString(aContent), 0)
EndScenario()

Scenario("The rows keep the cycle field as text (nothing else changed)")
	aRows = oMix.Comparisons()
	Then("cyc holds the text TRUE", aRows[1][:hasCycles], "TRUE")
	Then("acy holds the text FALSE", aRows[2][:hasCycles], "FALSE")
	Then("the field is a string, not a number", isString(aRows[1][:hasCycles]), 1)
EndScenario()

Scenario("WithCycles names the variations whose graph has a cycle")
	acWith = oMix.WithCycles()
	Then("two variations hold a cycle", len(acWith), 2)
	Then("cyc is named", HasName(acWith, "cyc"), 1)
	Then("cyc2 is named", HasName(acWith, "cyc2"), 1)
	Then("acy is NOT named", HasName(acWith, "acy"), 0)
	Then("rem is NOT named", HasName(acWith, "rem"), 0)
	Then("the order of the comparison is kept", acWith[1] + " " + acWith[2], "cyc cyc2")
EndScenario()

Scenario("WithoutCycles names the variations that stay acyclic")
	acWithout = oMix.WithoutCycles()
	Then("two variations stay acyclic", len(acWithout), 2)
	Then("acy is named", HasName(acWithout, "acy"), 1)
	Then("rem is named", HasName(acWithout, "rem"), 1)
	Then("cyc is NOT named", HasName(acWithout, "cyc"), 0)
	Then("cyc2 is NOT named", HasName(acWithout, "cyc2"), 0)
	Then("the order of the comparison is kept", acWithout[1] + " " + acWithout[2], "acy rem")
EndScenario()

Scenario("The two lists partition the variation names")
	acA = oMix.WithCycles()
	acB = oMix.WithoutCycles()
	Then("together they hold every variation", len(acA) + len(acB), oMix.Data()[:count])
	Then("no name is in both", CountShared(acA, acB), 0)
	acAll = []
	nLenA = len(acA)
	for i = 1 to nLenA
		acAll + acA[i]
	next
	nLenB = len(acB)
	for i = 1 to nLenB
		acAll + acB[i]
	next
	Then("every row name is in the union", CountShared(acAll, ColumnNames(oMix)), 4)
EndScenario()

Scenario("All acyclic: no variation has a cycle")
	oAllAcy = new stzGraphComparison(oBase, [ [ "acy", oAcy ], [ "rem", oRem ] ])
	Then("WithCycles is empty", len(oAllAcy.WithCycles()), 0)
	Then("WithoutCycles holds both", len(oAllAcy.WithoutCycles()), 2)
	Then("WithCycles is still a list", isList(oAllAcy.WithCycles()), 1)
EndScenario()

Scenario("All cyclic: no variation is acyclic")
	oAllCyc = new stzGraphComparison(oBase, [ [ "cyc", oCyc ], [ "cyc2", oCyc2 ] ])
	Then("WithoutCycles is empty", len(oAllCyc.WithoutCycles()), 0)
	Then("WithCycles holds both", len(oAllCyc.WithCycles()), 2)
	Then("WithoutCycles is still a list", isList(oAllCyc.WithoutCycles()), 1)
EndScenario()

Scenario("A cyclic baseline: the flag is the state of the variation, not a change")
	oBaseCyc = BuildCyc()
	oBreak = oBaseCyc.Copy()
	oBreak { RemoveThisEdge("c", "a") }
	oKeep = oBaseCyc.Copy()
	oKeep { AddNode("z") }
	oBC = new stzGraphComparison(oBaseCyc, [ [ "break", oBreak ], [ "keep", oKeep ] ])
	Then("the variation that breaks the cycle is acyclic", oBC.WithoutCycles()[1], "break")
	Then("the variation that keeps it is cyclic", oBC.WithCycles()[1], "keep")
	Then("each list holds one name", len(oBC.WithCycles()) + len(oBC.WithoutCycles()), 2)
	Then("break is NOT in WithCycles", HasName(oBC.WithCycles(), "break"), 0)
EndScenario()

Scenario("Variations given as a plain list are named V1, V2")
	oPlain = new stzGraphComparison(oBase, [ oCyc, oAcy ])
	Then("V1 is the cyclic one", oPlain.WithCycles()[1], "V1")
	Then("V2 is the acyclic one", oPlain.WithoutCycles()[1], "V2")
EndScenario()

Scenario("The flag test accepts what a row may hold")
	Then("the text TRUE", oMix._RowHasCycle([ :hasCycles = "TRUE" ]), 1)
	Then("the text true", oMix._RowHasCycle([ :hasCycles = "true" ]), 1)
	Then("the number 1", oMix._RowHasCycle([ :hasCycles = 1 ]), 1)
	Then("the text 1", oMix._RowHasCycle([ :hasCycles = "1" ]), 1)
	Then("the text FALSE is not a cycle", oMix._RowHasCycle([ :hasCycles = "FALSE" ]), 0)
	Then("the text false is not a cycle", oMix._RowHasCycle([ :hasCycles = "false" ]), 0)
	Then("the number 0 is not a cycle", oMix._RowHasCycle([ :hasCycles = 0 ]), 0)
	Then("the empty text is not a cycle", oMix._RowHasCycle([ :hasCycles = "" ]), 0)
EndScenario()

Scenario("Recommend gives the acyclic bonus (a cyclic variation can no longer win)")
	# cyc scores 8: bottlenecks reduced 5 + denser 3. acy scores 2 (more nodes added than removed), plus the
	# 10 of the acyclic bonus = 12. Before the fix the bonus was never given and cyc won with 8 against 2.
	oRec = new stzGraphComparison(oBase, [ [ "cyc", oCyc ], [ "acy", oAcy ] ])
	aRec = oRec.Recommend()
	Then("the acyclic variation wins", aRec[:recommended], "acy")
	Then("the cyclic variation does NOT win", aRec[:recommended] = "cyc", 0)
	Then("the answer carries a reason", len(aRec[:reason]) > 0, 1)
	oRec2 = new stzGraphComparison(oBase, [ [ "acy", oAcy ], [ "cyc", oCyc ] ])
	Then("the order of the variations does not matter", oRec2.Recommend()[:recommended], "acy")
	aMix = oMix.Recommend()
	Then("with four variations the winner is acyclic", HasName(oMix.WithoutCycles(), aMix[:recommended]), 1)
EndScenario()

Scenario("ByMetric sorts numbers by value, highest first")
	Then("nodes added", @@(oMix.ByMetric(:nodesAdded)), @@([ "acy", "cyc", "cyc2", "rem" ]))
	Then("nodes removed", oMix.ByMetric(:nodesRemoved)[1], "rem")
	Then("edges added puts the one with no edge added last", oMix.ByMetric(:edgesAdded)[4], "rem")
	Then("an unknown metric is refused", RaisesFor(oMix, :nope), 1)
	Then("a known metric is not refused", RaisesFor(oMix, :edgesAdded), 0)
EndScenario()

Scenario("ByMetric on a text column no longer raises (it sorted nothing before)")
	acCyc = oMix.ByMetric(:hasCycles)
	Then("the four names come back", len(acCyc), 4)
	Then("the cyclic variations come first (TRUE sorts above FALSE)", HasName([ acCyc[1], acCyc[2] ], "cyc"), 1)
	Then("the second cyclic one is next", HasName([ acCyc[1], acCyc[2] ], "cyc2"), 1)
	Then("an acyclic one is last", HasName([ acCyc[1], acCyc[2] ], acCyc[4]), 0)
	acDen = oMix.ByMetric(:densityChange)
	Then("the density column answers four names too", len(acDen), 4)
	acBot = oMix.ByMetric(:bottleneckChange)
	Then("the bottleneck column answers four names too", len(acBot), 4)
	Then("increased sorts below reduced in the byte order", acBot[4], "acy")
EndScenario()

Scenario("The other methods of the class answer on the same comparison")
	Then("Comparisons holds the four rows", len(oMix.Comparisons()), 4)
	Then("the first row is cyc", oMix.Comparisons()[1][:name], "cyc")
	cSummary = oMix.Summary()
	anP1 = StzFind("Baseline: base", cSummary)
	anP2 = StzFind("rem:", cSummary)
	anP3 = StzFind("Variations compared: 4", cSummary)
	Then("Summary starts with the baseline", anP1[1], 1)
	Then("Summary names every variation", len(anP2), 1)
	Then("Summary counts the variations", len(anP3), 1)
	Then("Summary does not name a variation that is not there", len(StzFind("zzz:", cSummary)), 0)
	Then("MostImpactful is the first of the two-change variations", oMix.MostImpactful(), "acy")
	Then("LeastImpactful is the first of the one-change variations", oMix.LeastImpactful(), "cyc")
	oTable = oMix.ToStzTable()
	Then("ToStzTable answers a table", oTable.ClassName(), "stztable")
	Then("the table has one row per metric", oTable.NumberOfRows(), 7)
	Then("the table has the metric column and one per variation", oTable.NumberOfColumns(), 5)
	Then("AsTable is the same table", @@(oMix.AsTable().Content()), @@(oTable.Content()))
	Then("AsStzTable is the same table", @@(oMix.AsStzTable().Content()), @@(oTable.Content()))
EndScenario()

Scenario("Building with no variation is refused")
	Then("an empty list of variations raises", RaisesBuild(oBase), 1)
EndScenario()

Summary()

# helpers at the END: top-level code after a func definition would join that function

func HasName(acList, cName)
	nLenH = len(acList)
	for i = 1 to nLenH
		if acList[i] = cName
			return 1
		ok
	next
	return 0

func CountShared(acL1, acL2)
	nShared = 0
	nLenS = len(acL1)
	for i = 1 to nLenS
		if HasName(acL2, acL1[i]) = 1
			nShared++
		ok
	next
	return nShared

func ColumnNames(oCmp)
	acNames = []
	aRowsC = oCmp.Comparisons()
	nLenC = len(aRowsC)
	for i = 1 to nLenC
		acNames + aRowsC[i][:name]
	next
	return acNames

func RaisesFor(oCmp, cMetric)
	nRaised = 0
	try
		oCmp.ByMetric(cMetric)
	catch
		nRaised = 1
	done
	return nRaised

func RaisesBuild(oBaseG)
	nRaised = 0
	try
		oBad = new stzGraphComparison(oBaseG, [])
	catch
		nRaised = 1
	done
	return nRaised

func BuildBase()
	oGb = new stzGraph("base")
	oGb {
		AddNode("a") AddNode("b") AddNode("c")
		Connect("a", "b") Connect("b", "c")
	}
	return oGb

func BuildCyc()
	oGb0 = BuildBase()
	oGv = oGb0.Copy()
	oGv { Connect("c", "a") }
	return oGv

func BuildCyc2()
	oGb0 = BuildBase()
	oGv = oGb0.Copy()
	oGv { Connect("c", "b") }
	return oGv

func BuildAcy()
	oGb0 = BuildBase()
	oGv = oGb0.Copy()
	oGv { AddNode("d") Connect("c", "d") }
	return oGv

func BuildRem()
	oGb0 = BuildBase()
	oGv = oGb0.Copy()
	oGv { RemoveNode("c") }
	return oGv
