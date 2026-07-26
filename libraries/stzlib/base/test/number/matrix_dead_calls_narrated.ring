load "../../stzBase.ring"
load "../_narrated.ring"

# THE DEAD-CALL AUDIT ON stzMatrix.
#
# Two symptoms were reported -- an R14 on IsByManyNamedParam breaking seven tests,
# and an R3 on updateColumn breaking one. Auditing the whole file found NINE
# defects, and the two reported ones were the least interesting.
#
# The audit is worth stating because the first pass MISSED half of it. Diffing
# `This.X(` against every `def X` on the class chain -- the recipe that found
# fifteen dead calls in stzNumber -- catches only calls on SELF. stzMatrix's worst
# breakage was in calls on an object VARIABLE (`_oList_.IsByManyNamedParam()`) and
# in ARITY (methods called with the wrong number of arguments, which Ring accepts
# at parse time and raises on at run time). Three passes were needed:
#
#   1. This.X()      against the chain          ->  1 dead call
#   2. var.X()       against THAT variable's chain -> 10 dead calls
#   3. This.X(a, b)  against the def's arity    ->  5 wrong-arity calls
#
# What follows pins the repairs. Every expected value here was already written
# down in the matrix tests -- these methods had been failing against their own
# documentation, which is the strongest evidence a fix is right rather than merely
# different.

Scenario("asking the wrong class: the named-param vocabulary lives on one class")
	# `_oList_ = new stzList(pBy)` then `_oList_.IsByManyNamedParam()`. That
	# predicate is on stzListNamedParams; stzList exposes only a handful of the
	# vocabulary as convenience methods. R14, and it took the whole
	# ReplaceElementsAt / ReplaceSection family with it.
	oM = new stzMatrix([ [1,2,3], [4,5,6], [7,8,9] ])
	oM.ReplaceElementsAt([ [1,3], [2,2], [3,1] ], :By = 0)
	Then("ReplaceElementsAt, single value", @@(oM.Content()),
	     "[ [ 1, 2, 0 ], [ 4, 0, 6 ], [ 0, 8, 9 ] ]")

	oM2 = new stzMatrix([ [1,2,3], [4,5,6], [7,8,9] ])
	oM2.ReplaceElementsAt([ [1,3], [2,2], [3,1] ], :By = [ 10, 20, 30 ])
	Then("...and by many", @@(oM2.Content()),
	     "[ [ 1, 2, 10 ], [ 4, 20, 6 ], [ 30, 8, 9 ] ]")

	oM3 = new stzMatrix([ [14,20,16], [14,20,16], [17,23,19] ])
	oM3.ReplaceSection([1,1], [2,2], :By = 0)
	Then("ReplaceSection", @@(oM3.Content()),
	     "[ [ 0, 0, 16 ], [ 0, 0, 16 ], [ 17, 23, 19 ] ]")
EndScenario()

Scenario("a function that never existed, reached through eval()")
	# MultiplyCols BUILT A STRING OF RING CODE and eval()'d it, calling
	# updateColumn() -- which exists nowhere in this library or in Ring. Every call
	# raised R3. It goes one column at a time through the engine now, which is what
	# the method's own From..To branch already did.
	oM = new stzMatrix([ [1,0,3], [4,0,6], [7,0,9] ])
	oM.MultiplyCols([1, 3], :By = 2)
	Then("columns 1 and 3 doubled, column 2 untouched", @@(oM.Content()),
	     "[ [ 2, 0, 6 ], [ 8, 0, 12 ], [ 14, 0, 18 ] ]")
EndScenario()

Scenario("`func` where `def` was meant, which is not a method at all")
	# FindCol was spelled `func FindCol(paCol)` inside the class body. Inside a
	# class, `func` does not define a method -- so FindCol was unreachable and
	# FindCols, its only caller, raised R14. It was the ONE `func` among 95
	# definitions; FindRow, FindRows and FindCols all use `def`.
	oM = new stzMatrix([ [88,85,88], [70,88,70], [99,65,99] ])
	Then("FindCol", @@(oM.FindCol([ 88, 70, 99 ])), "[ 1, 3 ]")

	oM2 = new stzMatrix([ [88,85,88,1], [70,88,70,1], [99,65,99,1] ])
	Then("...and FindCols, which could not work without it",
	     @@(oM2.FindCols([ [1,1,1], [88,70,99] ])), "[ 1, 3, 4 ]")
EndScenario()

Scenario("arity: arguments dropped, and arguments in the wrong order")
	# ReplaceElementInSectionByMany(pnElm, ...) called
	# FindThisElementInSection(panStart, panEnd) -- DROPPING pnElm into a method
	# that takes three arguments. Its sibling one method above had the call right.
	oM = new stzMatrix([ [1,2,1], [4,1,6], [1,8,9] ])
	oM.ReplaceElementInSectionByMany(1, [1,1], [3,3], [ 70, 80, 90 ])
	Then("each occurrence of 1 takes the next replacement", @@(oM.Content()),
	     "[ [ 70, 2, 80 ], [ 4, 90, 6 ], [ 1, 8, 9 ] ]")

	oX = new stzMatrix([ [1,2,1], [4,1,6], [1,8,9] ])
	oX.ReplaceElementInSectionByManyXT(1, [1,1], [3,3], [ 70, 80 ])
	Then("...and the XT form CYCLES the replacements", @@(oX.Content()),
	     "[ [ 70, 2, 80 ], [ 4, 70, 6 ], [ 80, 8, 9 ] ]")

	# FindInSection's list branch called FindElementsInSection, which takes only
	# the section bounds and returns the POSITIONS in it (test 45 documents that).
	# The method it wanted was FindTheseElementsInSection.
	oF = new stzMatrix([ [1,2,3], [4,5,6], [7,8,9] ])
	Then("FindInSection with one element", @@(oF.FindInSection(5, [1,1], [3,3])),
	     "[ [ 2, 2 ] ]")
	Then("...and with several", @@(oF.FindInSection([1,5,9], [1,1], [3,3])),
	     "[ [ 1, 1 ], [ 2, 2 ], [ 3, 3 ] ]")
EndScenario()

Scenario("AddXT, which was broken in four independent ways at once")
	# It asked stzList for predicates that live on stzListNamedParams; it passed
	# (value, index) into AddInCol(index, value); it called AddInDiagonal with two
	# arguments where it takes one; and IsInDiagonal / IsInDiagonal1 /
	# IsInDiagonal2 existed NOWHERE in the library. No input could succeed.
	aB = [ [1,2,3], [4,5,6], [7,8,9] ]

	o1 = new stzMatrix(aB)  o1.AddXT(10, :InCol = 2)
	Then(":InCol reaches column 2 -- not column 10, as the swapped order did",
	     @@(o1.Content()), "[ [ 1, 12, 3 ], [ 4, 15, 6 ], [ 7, 18, 9 ] ]")

	o2 = new stzMatrix(aB)  o2.AddXT(10, :InRow = 1)
	Then(":InRow", @@(o2.Content()), "[ [ 11, 12, 13 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")

	o3 = new stzMatrix(aB)  o3.AddXT(10, :InCols = [1,3])
	Then(":InCols", @@(o3.Content()), "[ [ 11, 2, 13 ], [ 14, 5, 16 ], [ 17, 8, 19 ] ]")

	o4 = new stzMatrix(aB)  o4.AddXT(10, :InRows = [1,3])
	Then(":InRows", @@(o4.Content()), "[ [ 11, 12, 13 ], [ 4, 5, 6 ], [ 17, 18, 19 ] ]")

	# The diagonal forms are BARE MARKERS, not named pairs, because
	# AddInDiagonal(pnValue) takes no position -- a diagonal is fixed by the
	# matrix, so there is nothing for [:InDiagonal, x] to carry. Nothing in the
	# library anchored the old pair spelling; the arity is what settles it.
	o5 = new stzMatrix(aB)  o5.AddXT(10, :InDiagonal)
	Then(":InDiagonal hits (1,1) (2,2) (3,3)", @@(o5.Content()),
	     "[ [ 11, 2, 3 ], [ 4, 15, 6 ], [ 7, 8, 19 ] ]")

	o6 = new stzMatrix(aB)  o6.AddXT(10, :InDiagonal2)
	Then(":InDiagonal2 hits (1,3) (2,2) (3,1)", @@(o6.Content()),
	     "[ [ 1, 2, 13 ], [ 4, 15, 6 ], [ 17, 8, 9 ] ]")
EndScenario()

Scenario("a method whose body named three variables it did not have")
	# AddInRows was a copy of AddInCols that was never finished being renamed:
	# every reference said `paColumns`, which is not its parameter, and the
	# fallback loop read `panRows` and `_nRow_`, which do not exist either -- while
	# adding the value TWICE per cell. It could not run on any input, and no test
	# ever called it.
	aB = [ [1,2,3], [4,5,6], [7,8,9] ]

	oRow = new stzMatrix(aB)  oRow.AddInRows([1,3], 100)
	Then("rows 1 and 3", @@(oRow.Content()),
	     "[ [ 101, 102, 103 ], [ 4, 5, 6 ], [ 107, 108, 109 ] ]")

	oF = new stzMatrix(aB)  oF.AddInRows([ :From = 1, :To = 2 ], 100)
	Then("...and the From..To form", @@(oF.Content()),
	     "[ [ 101, 102, 103 ], [ 104, 105, 106 ], [ 7, 8, 9 ] ]")

	oC = new stzMatrix(aB)  oC.AddInCols([1,3], 100)
	Then("the template it was copied from, still correct", @@(oC.Content()),
	     "[ [ 101, 2, 103 ], [ 104, 5, 106 ], [ 107, 8, 109 ] ]")
EndScenario()

Scenario("two aliases the tests documented and nothing defined")
	# test 01 has always called AddToCol and AddToRow, and always recorded the
	# matrices they produce. Neither existed. They join AddCV / AddVC / AddRV /
	# AddVR, which alias the same pair.
	aB = [ [11,12,13], [14,15,16], [17,18,19] ]

	oT = new stzMatrix(aB)  oT.AddToCol(2, 5)
	Then("AddToCol", @@(oT.Content()),
	     "[ [ 11, 17, 13 ], [ 14, 20, 16 ], [ 17, 23, 19 ] ]")

	oI = new stzMatrix(aB)  oI.AddInCol(2, 5)
	Then("...is exactly AddInCol", @@(oT.Content()), @@(oI.Content()))

	oRow = new stzMatrix(aB)  oRow.AddToRow(1, 3)
	oJ = new stzMatrix(aB)  oJ.AddInRow(1, 3)
	Then("AddToRow is exactly AddInRow", @@(oRow.Content()), @@(oJ.Content()))
EndScenario()

Summary()
