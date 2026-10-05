load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfNumbers -- the defects the documentation waves found (doc/DEFECTS.md), one scenario per family.
# Every expectation is written from the MEANING of the method, never copied from what it answered.
# Random picks are asserted by their law (membership, side, coverage over many draws), not by one draw.

Scenario("Absolute and Negate edit the list; Absoluted and Negated return a copy")
	o1 = new stzListOfNumbers([ 3, -2, 0, -7, 5 ])
	Then("Absoluted answers every number made positive", @@(o1.Absoluted()), "[ 3, 2, 0, 7, 5 ]")
	Then("Absoluted leaves the list alone", @@(o1.Content()), "[ 3, -2, 0, -7, 5 ]")
	Then("Negated answers every positive number made negative", @@(o1.Negated()), "[ -3, -2, 0, -7, -5 ]")
	Then("Negated leaves the list alone", @@(o1.Content()), "[ 3, -2, 0, -7, 5 ]")
	o1.Absolute()
	Then("Absolute changes the list itself", @@(o1.Content()), "[ 3, 2, 0, 7, 5 ]")
	o1.Negate()
	Then("Negate changes the list itself", @@(o1.Content()), "[ -3, -2, 0, -7, -5 ]")
EndScenario()

Scenario("Cumulate starts at the second number")
	o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
	Then("Cumulated answers the running sums", @@(o1.Cumulated()), "[ 1, 3, 6, 10, 15 ]")
	Then("Cumulated leaves the list alone", @@(o1.Content()), "[ 1, 2, 3, 4, 5 ]")
	o1.Cumulate()
	Then("Cumulate changes the list itself", @@(o1.Content()), "[ 1, 3, 6, 10, 15 ]")
	Then("two numbers add up", @@(StzListOfNumbersQ([ 4, 6 ]).Cumulated()), "[ 4, 10 ]")
	Then("one number stays", @@(StzListOfNumbersQ([ 4 ]).Cumulated()), "[ 4 ]")
EndScenario()

Scenario("MeanByCoefficient is the weighted mean")
	o1 = new stzListOfNumbers([ 16, 18, 20, 17 ])
	Then("coefficients 4 2 2 1 give 157 / 9 = 17.4444", floor(o1.MeanByCoefficient([ 4, 2, 2, 1 ]) * 10000), 174444)
	Then("equal coefficients give the plain mean", o1.MeanByCoefficient([ 1, 1, 1, 1 ]), o1.Mean())
	bRaised = 0
	try
		o1.MeanByCoefficient([ 1, 2 ])
	catch
		bRaised = 1
	done
	Then("one coefficient per number is required", bRaised, 1)
EndScenario()

Scenario("OnlyUnicodes keeps the numbers that are code points")
	o1 = new stzListOfNumbers([ 65, -1, 1.5, 1114111, 1114112, 0 ])
	Then("whole numbers 0 to 1114111 only", @@(o1.OnlyUnicodes()), "[ 65, 1114111, 0 ]")
EndScenario()

Scenario("The smallest and largest numbers, with positions, name the number's OWN position")
	o1 = new stzListOfNumbers([ 50, 10, 40, 10, 30, 20 ])
	Then("Bottom3AndTheirPositions pairs each number with where it sits (repeats give a pair each)",
		@@(o1.Bottom3AndTheirPositions()), "[ [ 10, 2 ], [ 10, 4 ], [ 20, 6 ], [ 30, 5 ] ]")
	Then("Top3AndTheirPositions pairs each number with where it sits",
		@@(o1.Top3AndTheirPositions()), "[ [ 30, 5 ], [ 40, 3 ], [ 50, 1 ] ]")
	Then("the Numbers spelling is the same", @@(o1.Top3NumbersAndTheirPositions()), @@(o1.Top3AndTheirPositions()))
	Then("Bottom3NumbersAndTheirPositions too", @@(o1.Bottom3NumbersAndTheirPositions()), @@(o1.Bottom3AndTheirPositions()))
	Then("on an ascending list without repeats it was always right, and still is",
		@@(StzListOfNumbersQ([ 1, 2, 3, 4, 5 ]).Top3AndTheirPositions()), "[ [ 3, 3 ], [ 4, 4 ], [ 5, 5 ] ]")
	Then("a descending list is no longer paired by index",
		@@(StzListOfNumbersQ([ 9, 7, 5, 3 ]).Bottom3AndTheirPositions()), "[ [ 3, 4 ], [ 5, 3 ], [ 7, 2 ] ]")
	Then("MinZ names the smallest number and its position", @@(o1.MinZ()), "[ 10, 2 ]")
	Then("MaxZ names the largest number and its position", @@(o1.MaxZ()), "[ 50, 1 ]")
	Then("MinZ of a descending list is its LAST number", @@(StzListOfNumbersQ([ 9, 7, 5 ]).MinZ()), "[ 5, 3 ]")
	Then("all the other widths are the same shape (5, 7, 10)",
		len(StzListOfNumbersQ([ 8, 7, 6, 5, 4, 3, 2, 1, 0, 9 ]).Bottom10AndTheirPositions()), 10)
	Then("Top5NumbersAndTheirPositions ends at the maximum with its position",
		@@(StzListOfNumbersQ([ 8, 7, 6, 5, 4, 3, 2, 1, 0, 9 ]).Top5NumbersAndTheirPositions()[5]), "[ 9, 10 ]")
EndScenario()

Scenario("Bottom10 and its family answer fewer numbers instead of raising")
	o1 = new stzListOfNumbers([ 4, 2, 4, 9 ])
	Then("Bottom10 of three distinct values answers those three", @@(o1.Bottom10()), "[ 2, 4, 9 ]")
	Then("Bottom5Numbers too", @@(o1.Bottom5Numbers()), "[ 2, 4, 9 ]")
	Then("FindBottom10 answers every position of those values", @@(o1.FindBottom10()), "[ 1, 2, 3, 4 ]")
	Then("Bottom3 still answers three", @@(o1.Bottom3()), "[ 2, 4, 9 ]")
	Then("Bottom2 answers two", @@(o1.NLowestNumbers(2)), "[ 2, 4 ]")
	Then("Top10 already did the same", @@(o1.Top10()), "[ 2, 4, 9 ]")
EndScenario()

Scenario("Neighbors compares n with the MAXIMUM, not with the count")
	o1 = new stzListOfNumbers([ 4, 7, 10, 3, 6, 9 ])
	Then("8 lies between 7 and 9", @@(o1.Neighbors(8)), "[ 7, 9 ]")
	Then("5 lies between 4 and 6", @@(o1.Neighbors(5)), "[ 4, 6 ]")
	Then("a number of the list has the numbers either side of it", @@(o1.Neighbors(6)), "[ 4, 7 ]")
	Then("below the smallest only the smallest", @@(o1.Neighbors(1)), "[ 3 ]")
	Then("above the largest only the largest", @@(o1.Neighbors(50)), "[ 10 ]")
	Then("the smallest has one neighbour", @@(o1.Neighbors(3)), "[ 4 ]")
	Then("the largest has one neighbour", @@(o1.Neighbors(10)), "[ 9 ]")
	Then("an n above the count but inside the range (the old failure) gets a pair",
		@@(StzListOfNumbersQ([ 100, 200, 300 ]).Neighbors(150)), "[ 100, 200 ]")
	Then("repeats count once", @@(StzListOfNumbersQ([ 1, 1, 5, 5, 9 ]).Neighbors(5)), "[ 1, 9 ]")
	Then("a misspelt alias is the same", @@(o1.NighborsOf(8)), "[ 7, 9 ]")
	Then("NearestNighborsTo too", @@(o1.NearestNighborsTo(8)), "[ 7, 9 ]")
EndScenario()

Scenario("Closest passes n to Nearest")
	o1 = new stzListOfNumbers([ 10, 20, 35 ])
	Then("Closest(22) is 20", o1.Closest(22), 20)
	Then("Closest agrees with ClosestTo", o1.Closest(33), o1.ClosestTo(33))
EndScenario()

Scenario("ContainsADividableNumberBy and DividableNumbersBy test each number against n")
	o1 = new stzListOfNumbers([ 4, 9, 12, 15, 7 ])
	Then("the numbers 3 divides", @@(o1.DividableNumbersBy(3)), "[ 9, 12, 15 ]")
	Then("the numbers 4 divides", @@(o1.DividableNumbersBy(4)), "[ 4, 12 ]")
	Then("not just the even numbers", @@(o1.DividableNumbersBy(5)), "[ 15 ]")
	Then("ContainsADividableNumberBy(7) is TRUE: 7 itself", o1.ContainsADividableNumberBy(7), 1)
	Then("ContainsADividableNumberBy(11) is FALSE although the product could be a multiple of anything",
		o1.ContainsADividableNumberBy(11), 0)
	Then("a negative number is tested as it is, and does not raise",
		StzListOfNumbersQ([ -9, 4 ]).ContainsADividableNumberBy(3), 1)
	Then("zero divides nothing", @@(o1.DividableNumbersBy(0)), "[ ]")
EndScenario()

Scenario("AreGreaterThen and AreSmallerThen are strict")
	o1 = new stzListOfNumbers([ 5, 6, 7 ])
	Then("every number is above 4", o1.AreGreaterThen(4), 1)
	Then("5 is not above 5", o1.AreGreaterThen(5), 0)
	Then("every number is below 8", o1.AreSmallerThen(8), 1)
	Then("7 is not below 7", o1.AreSmallerThen(7), 0)
EndScenario()

Scenario("SortByInDescending sorts by an expression, largest first")
	o1 = new stzListOfNumbers([ -5, 1, -3, 4 ])
	Then("SortedByInDescending on the absolute value", @@(o1.SortedByInDescending("abs(@number)")), "[ -5, 4, -3, 1 ]")
	Then("SortedByDown is the same", @@(o1.SortedByDown("abs(@number)")), "[ -5, 4, -3, 1 ]")
	Then("the list is left alone by the passive form", @@(o1.Content()), "[ -5, 1, -3, 4 ]")
	o1.SortByInDescending("abs(@number)")
	Then("the active form changes the list", @@(o1.Content()), "[ -5, 4, -3, 1 ]")
	o2 = new stzListOfNumbers([ -5, 1, -3, 4 ])
	o2.SortByDown("abs(@number)")
	Then("SortByDown too", @@(o2.Content()), "[ -5, 4, -3, 1 ]")
EndScenario()

Scenario("MultiplyEachWithW and DivideEachWithW keep the numbers that fail the condition")
	o1 = new stzListOfNumbers([ 10, 20, 30, 40 ])
	Then("EachMultipliedWithW multiplies from position 2 and keeps the first number",
		@@(o1.EachMultipliedWithW(2, "@i > 1")), "[ 10, 40, 60, 80 ]")
	Then("the list is left alone", @@(o1.Content()), "[ 10, 20, 30, 40 ]")
	Then("EachDividedWithW divides from position 3 and keeps the others",
		@@(o1.EachDividedWithW(10, "@i > 2")), "[ 10, 20, 3, 4 ]")
	o1.MultiplyEachWithW(3, "@i > 3")
	Then("MultiplyEachWithW changes the list and keeps all four numbers", @@(o1.Content()), "[ 10, 20, 30, 120 ]")
	o1.DivideEachWithW(10, "@i > 3")
	Then("DivideEachWithW undoes it", @@(o1.Content()), "[ 10, 20, 30, 12 ]")
EndScenario()

Scenario("NumbersGreaterThan no longer needs n to be in the list")
	o1 = new stzListOfNumbers([ 3, 9, 5, 12 ])
	Then("above 4 although 4 is absent", @@(o1.NumbersGreaterThan(4)), "[ 9, 5, 12 ]")
	Then("with positions", @@(o1.NumbersGreaterThanZ(4)), "[ [ 9, 2 ], [ 5, 3 ], [ 12, 4 ] ]")
	Then("below 6 with positions", @@(o1.NumbersSmallerThanZ(6)), "[ [ 3, 1 ], [ 5, 3 ] ]")
	Then("the aliases point at the same method", @@(o1.NumbersLargerThan(4)), "[ 9, 5, 12 ]")
EndScenario()

Scenario("The random picks draw from the list, not from the numbers that happen to fit a position")
	# a list of numbers all far above its size: the old pick needed one strictly between 1 and the size
	o1 = new stzListOfNumbers([ 100, 200, 300, 400, 500 ])
	aSeen = []
	bAllInList = 1
	for i = 1 to 200
		n = o1.ARandomNumber()
		if find(o1.Content(), n) = 0
			bAllInList = 0
		ok
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("ARandomNumber always answers a number of the list", bAllInList, 1)
	Then("and over 200 draws every number of the list showed up", len(aSeen), 5)
	Then("ANumber, AnyRandomNumber and AnyNumber are the same pick", find(o1.Content(), o1.ANumber()) > 0 and find(o1.Content(), o1.AnyRandomNumber()) > 0 and find(o1.Content(), o1.AnyNumber()) > 0, 1)
	aZ = o1.ARandomNumberZ()
	Then("the Z form names the number and its position", o1.Content()[aZ[2]], aZ[1])
	Then("a list of one number answers it", StzListOfNumbersQ([ 7 ]).ARandomNumber(), 7)
	bRaised = 0
	try
		StzListOfNumbersQ([]).ARandomNumber()
	catch
		bRaised = 1
	done
	Then("an empty list raises", bRaised, 1)

	aNs = o1.NRandomNumbers(4)
	bOk = len(aNs) = 4
	for i = 1 to 4
		if find(o1.Content(), aNs[i]) = 0
			bOk = 0
		ok
	next
	Then("NRandomNumbers(4) answers four numbers of the list", bOk, 1)
	aNz = o1.NRandomNumbersZ(3)
	bOk = len(aNz) = 3
	for i = 1 to 3
		if o1.Content()[aNz[i][2]] != aNz[i][1]
			bOk = 0
		ok
	next
	Then("NRandomNumbersZ(3) answers three [ number, position ] pairs that agree", bOk, 1)
EndScenario()

Scenario("The random picks by comparison answer only numbers on the right side")
	o1 = new stzListOfNumbers([ 10, 20, 30, 40, 50 ])
	bBelow = 1
	bAbove = 1
	aBelow = []
	aAbove = []
	for i = 1 to 150
		n = o1.ANumberLessThan(30)
		if n >= 30
			bBelow = 0
		ok
		if find(aBelow, n) = 0
			aBelow + n
		ok
		n = o1.ANumberGreaterThan(30)
		if n <= 30
			bAbove = 0
		ok
		if find(aAbove, n) = 0
			aAbove + n
		ok
	next
	Then("ANumberLessThan(30) is always below 30", bBelow, 1)
	Then("and both 10 and 20 appear", len(aBelow), 2)
	Then("ANumberGreaterThan(30) is always above 30 (was R14)", bAbove, 1)
	Then("and both 40 and 50 appear", len(aAbove), 2)
	aZ = o1.ANumberGreaterThanZ(30)
	Then("the Z form carries the position IN THE LIST", o1.Content()[aZ[2]], aZ[1])
	aZ = o1.ANumberLessThanZ(30)
	Then("and so does ANumberLessThanZ", o1.Content()[aZ[2]], aZ[1])
	bRaised = 0
	try
		o1.ANumberLessThan(5)
	catch
		bRaised = 1
	done
	Then("with no number below 5 it raises, rather than answer a wrong one", bRaised, 1)
EndScenario()

Scenario("NNumbers* answer n numbers of the right side (repeats allowed)")
	o1 = new stzListOfNumbers([ 10, 20, 30, 40, 50 ])
	aLess = o1.NNumbersLessThan(6, 30)
	bOk = len(aLess) = 6
	for i = 1 to len(aLess)
		if aLess[i] >= 30
			bOk = 0
		ok
	next
	Then("NNumbersLessThan(6, 30): six numbers, all below 30 (was R14)", bOk, 1)
	aGt = o1.NNumbersGreaterThan(5, 30)
	bOk = len(aGt) = 5
	for i = 1 to len(aGt)
		if aGt[i] <= 30
			bOk = 0
		ok
	next
	Then("NNumbersGreaterThan(5, 30): five numbers, all above 30 (was R14)", bOk, 1)
	aOt = o1.NNumbersOtherThan(8, 30)
	bOk = len(aOt) = 8
	for i = 1 to len(aOt)
		if aOt[i] = 30
			bOk = 0
		ok
	next
	Then("NNumbersOtherThan(8, 30): eight numbers, none is 30 (was R19)", bOk, 1)
	Then("the alias NRandomNumbersGreaterThan is the greater-than one, not the less-than one",
		SmallestOf(o1.NRandomNumbersGreaterThan(5, 30)) > 30, 1)
	aZ = o1.NNumbersGreaterThanZ(4, 30)
	bOk = len(aZ) = 4
	for i = 1 to len(aZ)
		if o1.Content()[aZ[i][2]] != aZ[i][1] or aZ[i][1] <= 30
			bOk = 0
		ok
	next
	Then("NNumbersGreaterThanZ names positions in the list", bOk, 1)
	aZ = o1.NNumbersLessThanZ(4, 30)
	bOk = len(aZ) = 4
	for i = 1 to len(aZ)
		if o1.Content()[aZ[i][2]] != aZ[i][1] or aZ[i][1] >= 30
			bOk = 0
		ok
	next
	Then("NNumbersLessThanZ names positions in the list", bOk, 1)
	Then("NNumbersOtherThanMany leaves out several", SmallestOf(o1.NNumbersOtherThanMany(10, [ 10, 20 ])) >= 30, 1)
EndScenario()

Scenario("AnyNumberAfter and AnyNumberAfterPosition come AFTER, and reach every number after")
	o1 = new stzListOfNumbers([ 100, 200, 300, 400, 500 ])
	aSeen = []
	bAfter = 1
	for i = 1 to 200
		n = o1.AnyNumberAfter(200)
		if n <= 200
			bAfter = 0
		ok
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("AnyNumberAfter(200) is always above 200 in position", bAfter, 1)
	Then("and all of 300, 400 and 500 show up (it answered 500 only)", len(aSeen), 3)
	aSeen = []
	bAfter = 1
	for i = 1 to 200
		n = o1.AnyNumberAfterPosition(2)
		if find(aSeen, n) = 0
			aSeen + n
		ok
		if n <= 200
			bAfter = 0
		ok
	next
	Then("AnyNumberAfterPosition(2) is never at or before position 2 (it could answer the 1st)", bAfter, 1)
	Then("and reaches positions 3, 4 and 5", len(aSeen), 3)
	Then("AnyNumberAfterPosition(4) is the 5th", o1.AnyNumberAfterPosition(4), 500)
	aZ = o1.AnyNumberAfterZ(200)
	Then("AnyNumberAfterZ names the position", o1.Content()[aZ[2]], aZ[1])
	Then("and it is after the 2nd", aZ[2] > 2, 1)
	aZ = o1.AnyNumberAfterPositionZ(3)
	Then("AnyNumberAfterPositionZ(3) is the 4th or the 5th", aZ[2] > 3, 1)
	aSeen = []
	for i = 1 to 200
		n = o1.AnyNumberBeforePosition(3)
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("AnyNumberBeforePosition(3) reaches the 1st and the 2nd", len(aSeen), 2)
	Then("AnyNumberBeforePositionZ(2) is a pair", @@(o1.AnyNumberBeforePositionZ(2)), "[ 100, 1 ]")
EndScenario()

Scenario("AnyNumberBeforeOrAfter answers a NUMBER of the other side")
	o1 = new stzListOfNumbers([ 100, 200, 300, 400, 500 ])
	aSeen = []
	for i = 1 to 300
		n = o1.AnyNumberBeforeOrAfter(300)
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("around 300 it reaches 100 200 400 and 500, never 300", len(aSeen), 4)
	Then("300 is never answered", find(aSeen, 300), 0)
	Then("at the first number it can only go after", o1.AnyNumberBeforeOrAfter(100) > 100, 1)
	Then("at the last number it can only go before", o1.AnyNumberBeforeOrAfter(500) < 500, 1)
	aZ = o1.AnyNumberBeforeOrAfterZ(300)
	Then("the Z form names the position", o1.Content()[aZ[2]], aZ[1])
	bRaised = 0
	try
		o1.AnyNumberBeforeOrAfter(999)
	catch
		bRaised = 1
	done
	Then("an absent n raises", bRaised, 1)
EndScenario()

Scenario("Numbers from outside a position or a section")
	o1 = new stzListOfNumbers([ 100, 200, 300, 400, 500 ])
	aSeen = []
	for i = 1 to 300
		n = o1.AnyNumberOutsidePosition(3)
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("AnyNumberOutsidePosition(3) reaches the four other numbers", len(aSeen), 4)
	Then("and never the 3rd", find(aSeen, 300), 0)
	aSeen = []
	for i = 1 to 300
		n = o1.AnyNumberNotBetweenPositions(2, 4)
		if find(aSeen, n) = 0
			aSeen + n
		ok
	next
	Then("AnyNumberNotBetweenPositions(2, 4) reaches the 1st and the 5th only", len(aSeen), 2)
	Then("100 and 500", find(aSeen, 100) > 0 and find(aSeen, 500) > 0, 1)
	aZ = o1.AnyNumberOutsidePositionZ(1)
	Then("the Z form is a pair outside position 1", aZ[2] != 1 and o1.Content()[aZ[2]] = aZ[1], 1)
	aZ = o1.AnyNumberNotBetweenPositionsZ(2, 5)
	Then("NotBetweenPositionsZ(2, 5) is the first number", @@(aZ), "[ 100, 1 ]")
	Then("NItemsOutsidePositionZ answers the pairs outside a position",
		@@(o1.NItemsOutsidePositionZ(2)), "[ [ 100, 1 ], [ 300, 3 ], [ 400, 4 ], [ 500, 5 ] ]")
	Then("or outside several", @@(o1.NItemsOutsidePositionZ([ 1, 5 ])), "[ [ 200, 2 ], [ 300, 3 ], [ 400, 4 ] ]")
EndScenario()

Scenario("SomeNumbers* call the right constructor and answer numbers of the right side")
	o1 = new stzListOfNumbers([ 10, 20, 30, 40, 50 ])
	bOk = 1
	for i = 1 to 40
		a = o1.SomeNumbersLessThan(0, 30)
		for j = 1 to len(a)
			if a[j] >= 30
				bOk = 0
			ok
		next
		a = o1.SomeNumbersGreaterThan(0, 30)
		for j = 1 to len(a)
			if a[j] <= 30
				bOk = 0
			ok
		next
		a = o1.SomeNumbersBetween(10, 50)
		for j = 1 to len(a)
			if a[j] <= 10 or a[j] >= 50
				bOk = 0
			ok
		next
		a = o1.SomeNumbersNotBetween(20, 40)
		for j = 1 to len(a)
			if a[j] > 20 and a[j] < 40
				bOk = 0
			ok
		next
		a = o1.SomeNumbersOtherThan(10, 50)
		for j = 1 to len(a)
			if a[j] = 10 or a[j] = 50
				bOk = 0
			ok
		next
	next
	Then("SomeNumbersLessThan/GreaterThan/Between/NotBetween/OtherThan never answer a number of the wrong side (were R3)", bOk, 1)
	Then("SomeNumbersLessThan answers at least one when some are below", len(o1.SomeNumbersLessThan(0, 30)) >= 1, 1)
	Then("and an empty list when none is", @@(o1.SomeNumbersLessThan(0, 5)), "[ ]")
	Then("SomeNumbersOtherThan reads BOTH numbers: leaving out all but 30 gives only 30",
		@@(o1.SomeNumbersOtherThanMany([ 10, 20, 40, 50 ])), @@(o1.SomeNumbersOtherThanMany([ 10, 20, 40, 50 ])))
	aSeen = []
	for i = 1 to 100
		a = o1.SomeNumbersOtherThanMany([ 10, 20, 40, 50 ])
		for j = 1 to len(a)
			if find(aSeen, a[j]) = 0
				aSeen + a[j]
			ok
		next
	next
	Then("and 30 is the only number it can answer", @@(aSeen), "[ 30 ]")
	aZ = o1.SomeNumbersGreaterThanZ(0, 30)
	bOk = 1
	for j = 1 to len(aZ)
		if o1.Content()[aZ[j][2]] != aZ[j][1] or aZ[j][1] <= 30
			bOk = 0
		ok
	next
	Then("the Z form names positions in the list", bOk, 1)
EndScenario()

Scenario("Walker reverse-engineers the list into a stzWalker that reproduces it")
	o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
	oW = o1.Walker()
	Then("a constant step gives the list back", @@(oW.Walkables()), "[ 1, 2, 3, 4, 5 ]")
	Then("its step is 1", @@(oW.Steps()), "[ 1 ]")
	Then("it starts at the first number and ends at the last", "" + oW.StartNumber() + " " + oW.EndNumber(), "1 5")
	o2 = new stzListOfNumbers([ 1, 2, 5, 6, 9, 10 ])
	Then("a repeating pattern of steps reproduces the list", @@(o2.Walker().Walkables()), "[ 1, 2, 5, 6, 9, 10 ]")
	o3 = new stzListOfNumbers([ 4, 8, 2, 3, 7, 1, 2 ])
	Then("a pattern with a negative step reproduces the list too", @@(o3.Walker().Walkables()), "[ 4, 8, 2, 3, 7, 1, 2 ]")
	oW2 = new stzWalker(10, 1, [ -3 ])
	Then("a walker with no fixed count stops on the end", @@(oW2.Walkables()), "[ 10, 7, 4, 1 ]")
	oW3 = new stzWalker(1, 100, [ 2 ])
	Then("or goes no further than the end", len(oW3.Walkables()), 50)
	bRaised = 0
	try
		o4 = new stzWalker(1, 5, [ ])
	catch
		bRaised = 1
	done
	Then("a walker without steps is refused", bRaised, 1)
	bRaised = 0
	try
		o5 = new stzListOfNumbers([ 7 ])
		o5.Walker()
	catch
		bRaised = 1
	done
	Then("one number has no steps to walk", bRaised, 1)
EndScenario()

Summary()

func SmallestOf(aNumbers)
	nMin = aNumbers[1]
	for i = 2 to len(aNumbers)
		if aNumbers[i] < nMin
			nMin = aNumbers[i]
		ok
	next
	return nMin
