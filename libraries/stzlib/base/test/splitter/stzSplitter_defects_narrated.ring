load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzSplitter defects fixed on fix/gscl (DEFECTS.md, stzSplitter):
# SplitAroundSection raised R14 (AntiSectionZZ exists nowhere) and SplitAround of a
# pair raised R19; SplitAtPositions raised R2 for [ 1, N ] and made empty reversed
# sections for adjacent positions; SplitAroundPosition raised R21 for the last
# position and answered flat numbers for the first one or one out of range.
#
# DECIDED: a position outside 1..N RAISES a clear StzRaise ("Out of range!"), in
# every SplitAt/SplitAround method touched here. A splitter answers sections for
# a host of N positions, so a position outside it is a caller error; clamping
# would hand back sections the caller never asked for.

Scenario("SplitAroundSection and SplitAround of a pair answer")
	o = new stzSplitter(10)
	Then("2 to 5 on 10 positions", @@(o.SplitAroundSection(2, 5)), "[ [ 1, 1 ], [ 6, 10 ] ]")
	Then("the ends may come reversed", @@(o.SplitAroundSection(5, 2)), "[ [ 1, 1 ], [ 6, 10 ] ]")
	Then("a section starting at 1 leaves the right side only", @@(o.SplitAroundSection(1, 4)), "[ [ 5, 10 ] ]")
	Then("the whole range leaves nothing", @@(o.SplitAroundSection(1, 10)), "[ ]")
	Then("SplitAround([ 2, 5 ]) takes the pair as a section", @@(o.SplitAround([ 2, 5 ])), "[ [ 1, 1 ], [ 6, 10 ] ]")
	Then("SplitAround of three positions", @@(o.SplitAround([ 3, 6, 8 ])), "[ [ 1, 2 ], [ 4, 5 ], [ 7, 7 ], [ 9, 10 ] ]")
	Then("SplitAroundSectionIB runs", len(o.SplitAroundSectionIB(2, 5)), 2)
EndScenario()

Scenario("SplitAtPositions at the edges and with neighbours")
	o = new stzSplitter(10)
	Then("[ 1, 10 ] leaves the middle", @@(o.SplitAtPositions([ 1, 10 ])), "[ [ 2, 9 ] ]")
	Then("[ 3, 6 ] as before", @@(o.SplitAtPositions([ 3, 6 ])), "[ [ 1, 2 ], [ 4, 5 ], [ 7, 10 ] ]")
	Then("in any order", @@(o.SplitAtPositions([ 6, 3 ])), "[ [ 1, 2 ], [ 4, 5 ], [ 7, 10 ] ]")
	Then("adjacent positions make no empty section", @@(o.SplitAtPositions([ 4, 5 ])), "[ [ 1, 3 ], [ 6, 10 ] ]")
	Then("a repeated position counts once", @@(o.SplitAtPositions([ 4, 4 ])), "[ [ 1, 3 ], [ 5, 10 ] ]")
	Then("no position leaves the whole range", @@(o.SplitAtPositions([])), "[ [ 1, 10 ] ]")
	Then("SplitAroundPositions answers the same", @@(o.SplitAroundPositions([ 1, 10 ])), "[ [ 2, 9 ] ]")
EndScenario()

Scenario("One position, first, last or middle, gives a list of sections")
	o = new stzSplitter(10)
	Then("SplitAroundPosition(10) no longer raises R21", @@(o.SplitAroundPosition(10)), "[ [ 1, 9 ] ]")
	Then("SplitAroundPosition(1) is a list of sections", @@(o.SplitAroundPosition(1)), "[ [ 2, 10 ] ]")
	Then("SplitAroundPosition(4)", @@(o.SplitAroundPosition(4)), "[ [ 1, 3 ], [ 5, 10 ] ]")
	Then("SplitAtPosition(10)", @@(o.SplitAtPosition(10)), "[ [ 1, 9 ] ]")
	o1 = new stzSplitter(1)
	Then("on one position, cutting it leaves nothing", @@(o1.SplitAtPosition(1)), "[ ]")
EndScenario()

Scenario("Overlapping sections are merged")
	o = new stzSplitter(12)
	Then("[ 2, 8 ] and [ 3, 4 ] leave 1 and 9 to 12",
		@@(o.SplitAroundSections([ [ 2, 8 ], [ 3, 4 ] ])), "[ [ 1, 1 ], [ 9, 12 ] ]")
	Then("sorted first, as before",
		@@(o.SplitAroundSections([ [ 8, 9 ], [ 2, 3 ] ])), "[ [ 1, 1 ], [ 4, 7 ], [ 10, 12 ] ]")
EndScenario()

Scenario("A position outside 1..N raises a clear error")
	o = new stzSplitter(10)
	cMsg = "Out of range! The position 11 is outside 1..10." + char(10)
	Then("SplitAtPosition(11)", Raises(o, "o.SplitAtPosition(11)"), cMsg)
	Then("SplitAroundPosition(11)", Raises(o, "o.SplitAroundPosition(11)"), cMsg)
	Then("SplitAround(11)", Raises(o, "o.SplitAround(11)"), cMsg)
	Then("SplitAtPositions([ 3, 11 ])", Raises(o, "o.SplitAtPositions([ 3, 11 ])"), cMsg)
	Then("SplitAroundSection(5, 11)", Raises(o, "o.SplitAroundSection(5, 11)"), cMsg)
	Then("SplitAround([ 0, 3 ]) names the 0",
		Raises(o, "o.SplitAround([ 0, 3 ])"), "Out of range! The position 0 is outside 1..10." + char(10))
	Then("SplitAroundSections([ [ 8, 12 ] ])", Raises(o, "o.SplitAroundSections([ [ 8, 12 ] ])") != "", 1)
EndScenario()

Summary()

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
