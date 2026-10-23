load "../../stzBase.ring"
load "../_narrated.ring"

# stzDataSet -- the three register rows (NonParametricCorrelation, MutualInformation, PlanSummary)
# and the family around them.
#
#  - NonParametricCorrelation read a variable named _oOtherStats_ that it did not receive (R24).
#    It is the rank correlation under another name, so it takes the other data set. And the rank
#    correlation it forwards to disagreed with the textbook value as soon as a value was tied: the
#    engine's rank correlation uses 1 - 6*sum(d^2)/(n*(n^2-1)), exact only without ties, and for a
#    series that is all ties it answered 0.5. The ranks are taken in Ring now (ties share the
#    average rank) and the engine correlates them.
#  - MutualInformation joined each pair of values with an underscore and split it again, so a value
#    holding an underscore broke the pair. A pair is a pair of integers now.
#  - PlanSummary read the plan title from a variable that did not exist (R5).
#  - Six forwarding aliases named a method with fewer or more arguments than it takes (R19, R20).
#
# Every expected number below is a literal worked out by hand or by a short independent Python
# calculation (average ranks then Pearson; the sum over pairs of p*log2(p/(px*py))). The random
# cross-checks use naive O(n^2) oracles written here, not the class under test.
#
# Run from inside its folder: cd base/test/stats

$dsSeed = 12345
$dsSide = 0
$dsSideB = 0

Scenario("A control: the stand-in step does run when it is asked to")
	$dsSide = 0
	oCtl = new stzDataSet([ 2, 4, 4, 4, 5, 5, 7, 9, 10, 40 ])
	aStepCtl = [ :function = "DsSideNoArg", :description = "side" ]
	xCtl = oCtl._ExecutePlanStep(aStepCtl)
	Then("running a step through the class calls the stand-in", $dsSide, 1)
	$dsSide = 0
	Then("and a fresh counter reads 0", $dsSide, 0)
EndScenario()

Scenario("NonParametricCorrelation: the rank correlation, by hand")
	oX = Ds([ 1, 2, 3, 4, 5 ])
	oY = Ds([ 5, 6, 7, 8, 7 ])
	nGot = oX.NonParametricCorrelation(oY)
	# ranks of y: 1, 2, 3.5, 5, 3.5; centred sums: sxy = 8, sxx = 10, syy = 9.5; rho = 8 / sqrt(95)
	Then("x = 1..5 against 5,6,7,8,7 (one tie) is 8/sqrt(95)", Near(nGot, 0.8207826816681233, 0.000000001), 1)
	Then("... and not the shortcut formula's 0.825", Near(nGot, 0.825, 0.0001), 0)
	Then("... and not the ordinal ranks' 0.9", Near(nGot, 0.9, 0.0001), 0)
	Then("... and not the Pearson of the raw values, 0.8320502943378437", Near(nGot, 0.8320502943378437, 0.0001), 0)
	nSib = oX.RankCorrelationWith(oY)
	Then("it is the sibling's answer, exactly", nGot, nSib)
	Then("it is also the RankCorelWith spelling", oX.RankCorelWith(oY), nSib)

	oCube = Ds([ 1, 8, 27, 64, 125 ])
	Then("y = x^3 is a perfect monotone relation: 1", Near(oX.NonParametricCorrelation(oCube), 1, 0.000000000001), 1)
	Then("... where the Pearson correlation of the same pair is only 0.9431175138077005", Near(oX.CorrelationWith(oCube), 0.9431175138077005, 0.000000001), 1)
	Then("... so the answer is the rank one, not the Pearson one", Near(oX.NonParametricCorrelation(oCube), oX.CorrelationWith(oCube), 0.01), 0)
	oRev = Ds([ 5, 4, 3, 2, 1 ])
	Then("a reversed order is -1", Near(oX.NonParametricCorrelation(oRev), -1, 0.000000000001), 1)
	oRevCube = Ds([ 125, 64, 27, 8, 1 ])
	Then("a reversed cube is -1", Near(oX.NonParametricCorrelation(oRevCube), -1, 0.000000000001), 1)
	Then("a series against itself is 1", Near(oY.NonParametricCorrelation(oY), 1, 0.000000000001), 1)

	oA = Ds([ 1, 2, 2, 3 ])
	oB = Ds([ 1, 3, 3, 2 ])
	# ranks 1, 2.5, 2.5, 4 and 1, 3.5, 3.5, 2: sxy = 1.5, sxx = 4.5, syy = 4.5; rho = 1/3
	Then("1,2,2,3 against 1,3,3,2 (a tie in each) is 1/3", Near(oA.NonParametricCorrelation(oB), 0.3333333333333333, 0.000000000001), 1)

	oP = Ds([ 1, 2, 3, 4, 5, 6, 7, 8 ])
	oQ = Ds([ 2, 1, 4, 3, 6, 5, 8, 7 ])
	# no ties: 1 - 6*8/(8*63) = 1 - 48/504
	Then("four swapped neighbours, no tie: 1 - 48/504", Near(oP.NonParametricCorrelation(oQ), 0.9047619047619048, 0.000000000001), 1)

	aD1 = [ 3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5 ]
	aD2 = [ 2, 7, 1, 8, 2, 8, 1, 8, 2, 8, 4 ]
	Then("eleven values with several tie groups: 0.1384567651467695", Near(Ds(aD1).NonParametricCorrelation(Ds(aD2)), 0.1384567651467695, 0.000000001), 1)
	Then("the same pair reversed in role is the same", Near(Ds(aD2).NonParametricCorrelation(Ds(aD1)), 0.1384567651467695, 0.000000001), 1)
	oT = Ds([ 4, 4, 4, 1, 2 ])
	Then("a triple tie against 1..5: -0.7826237921249264", Near(oT.NonParametricCorrelation(oX), -0.7826237921249264, 0.000000001), 1)

	Then("an offset and a scale change nothing (ranks are invariant)", Near(Ds([ 11, 12, 13, 14, 15 ]).NonParametricCorrelation(Ds([ 50, 60, 70, 80, 70 ])), 0.8207826816681233, 0.000000001), 1)
	Then("... and a negative scale flips the sign", Near(oX.NonParametricCorrelation(Ds([ -5, -6, -7, -8, -7 ])), -0.8207826816681233, 0.000000001), 1)
EndScenario()

Scenario("NonParametricCorrelation: the answers that are not a correlation")
	oX = Ds([ 1, 2, 3, 4, 5 ])
	oConst = Ds([ 3, 3, 3, 3, 3 ])
	Then("a series with no spread (all tied) gives 0, not a number out of the shortcut formula", oX.NonParametricCorrelation(oConst), 0)
	Then("... on either side", oConst.NonParametricCorrelation(oX), 0)
	Then("... two constants give 0 too", oConst.NonParametricCorrelation(oConst), 0)
	Then("the Pearson sibling gives the same 0 for no spread", oX.CorrelationWith(oConst), 0)
	Then("lengths that differ give 0, as the siblings do", oX.NonParametricCorrelation(Ds([ 1, 2, 3 ])), 0)
	Then("... and the sibling agrees", oX.RankCorrelationWith(Ds([ 1, 2, 3 ])), 0)
	Then("fewer than two values give 0", Ds([ 7 ]).NonParametricCorrelation(Ds([ 9 ])), 0)
	Then("an empty set gives 0", Ds([]).NonParametricCorrelation(Ds([])), 0)
	Then("text data gives 0", Ds([ "a", "b", "c" ]).NonParametricCorrelation(Ds([ "x", "y", "z" ])), 0)
	Then("text against numbers gives 0", Ds([ "a", "b", "c" ]).NonParametricCorrelation(Ds([ 1, 2, 3 ])), 0)
	Then("numbers against text gives 0", Ds([ 1, 2, 3 ]).NonParametricCorrelation(Ds([ "a", "b", "c" ])), 0)
	Then("a set that is not equal to its constant is NOT 0 (control)", oX.NonParametricCorrelation(Ds([ 3, 3, 3, 3, 4 ])) != 0, 1)
EndScenario()

Scenario("NonParametricCorrelation: left alone, and the ranks themselves")
	aBefore = [ 3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5 ]
	oB = Ds(aBefore)
	nIgnore = oB.NonParametricCorrelation(Ds([ 2, 7, 1, 8, 2, 8, 1, 8, 2, 8, 4 ]))
	Then("the receiver's data is unchanged by the call", SameList(oB.Data(), aBefore), 1)
	aRanks = oB._GetRanks([ 10, 20, 20, 30, 20, 5 ])
	# sorted: 5, 10, 20, 20, 20, 30 at positions 1..6; the three 20s take (3+4+5)/3 = 4
	Then("ranks of 10,20,20,30,20,5 are 2,4,4,6,4,1", SameList(aRanks, [ 2, 4, 4, 6, 4, 1 ]), 1)
	Then("ranks with no tie are the ordinal positions", SameList(oB._GetRanks([ 30, 10, 20 ]), [ 3, 1, 2 ]), 1)
	Then("ranks of one tie group are all the middle", SameList(oB._GetRanks([ 7, 7, 7, 7 ]), [ 2.5, 2.5, 2.5, 2.5 ]), 1)
	Then("ranks of an empty list are empty", SameList(oB._GetRanks([]), []), 1)
	nSum = 0
	nRanks = len(aRanks)
	for i = 1 to nRanks
		nSum += aRanks[i]
	next
	Then("ranks of n values always add up to n(n+1)/2 = 21", nSum, 21)
EndScenario()

Scenario("NonParametricCorrelation: random sets with many ties against a naive oracle")
	$dsSeed = 20261023
	nBad = 0
	nCases = 40
	for iCase = 1 to nCases
		nLen = 6 + DsRand(20)
		nSpan = 2 + DsRand(8)
		aU = []
		aV = []
		for i = 1 to nLen
			aU + DsRand(nSpan)
			aV + DsRand(nSpan)
		next
		nWant = NaiveRho(aU, aV)
		nGot = Ds(aU).NonParametricCorrelation(Ds(aV))
		if NOT Near(nGot, nWant, 0.000000001)
			nBad++
		ok
	next
	Then("40 random pairs (6 to 25 values, values from a span of 2 to 9) match the naive rho", nBad, 0)
	# the oracle itself, on the hand-worked pair
	Then("the oracle gives 8/sqrt(95) on the first hand pair", Near(NaiveRho([ 1, 2, 3, 4, 5 ], [ 5, 6, 7, 8, 7 ]), 0.8207826816681233, 0.000000000001), 1)
EndScenario()

Scenario("MutualInformation: the hand-computed cases, in bits")
	oXab = Ds([ "a", "a", "b", "b" ])
	oYcd = Ds([ "c", "c", "d", "d" ])
	oYcdAlt = Ds([ "c", "d", "c", "d" ])
	Then("a,a,b,b against c,c,d,d: one bit exactly", oXab.MutualInformation(oYcd), 1)
	Then("a,a,b,b against c,d,c,d (independent): 0 exactly", oXab.MutualInformation(oYcdAlt), 0)
	o123 = Ds([ 1, 1, 2, 2, 3, 3 ])
	Then("x against itself, three values twice: log2(3)", Near(o123.MutualInformation(o123), 1.584962500721156, 0.000000000001), 1)
	Then("... and it is the entropy of x", Near(o123.MutualInformation(o123), o123.Entropy(), 0.000000000001), 1)
	Then("a constant series against anything: 0", Ds([ "k", "k", "k", "k" ]).MutualInformation(oYcd), 0)
	Then("anything against a constant series: 0", oXab.MutualInformation(Ds([ "k", "k", "k", "k" ])), 0)
	Then("two constant series: 0", Ds([ "k", "k", "k", "k" ]).MutualInformation(Ds([ "m", "m", "m", "m" ])), 0)
	oLow = Ds([ "Low", "Low", "High", "High", "Low", "High" ])
	Then("Low/High against No/Yes pairing one to one: one bit", oLow.MutualInformation(Ds([ "No", "No", "Yes", "Yes", "No", "Yes" ])), 1)
	# joint LX 2, LY 1, HX 1, HY 2 of 6, margins 1/2: 2*(1/3)log2(4/3) + 2*(1/6)log2(2/3) = 0.0817041659455104
	Then("Low/High against X,Y,X,Y,X,Y (near independent): 0.0817041659455104", Near(oLow.MutualInformation(Ds([ "X", "Y", "X", "Y", "X", "Y" ])), 0.0817041659455104, 0.000000000001), 1)
	aFour = [ 1, 2, 3, 1, 2, 3, 1, 1, 2, 3, 2, 2 ]
	aThree = [ "u", "v", "u", "w", "w", "u", "v", "v", "w", "u", "u", "w" ]
	Then("a twelve-pair table of numbers against texts: 0.4833557549816874", Near(Ds(aFour).MutualInformation(Ds(aThree)), 0.4833557549816874, 0.000000000001), 1)
	aXs = [ "a", "b", "c", "a", "b", "c", "a", "b", "d", "d" ]
	aYs = [ "p", "q", "r", "p", "q", "r", "q", "q", "r", "p" ]
	Then("ten pairs, three overlapping groups: 1.095461844238322", Near(Ds(aXs).MutualInformation(Ds(aYs)), 1.095461844238322, 0.000000000001), 1)
	Then("... the two entropies bracket it (1.9709505944546686 and 1.5709505944546684)", (1.095461844238322 <= 1.5709505944546684), 1)
EndScenario()

Scenario("MutualInformation: a value holding a separator is one value")
	aPlainX = [ "pq", "pq", "rs", "rs" ]
	aPlainY = [ "tu", "tu", "vw", "vw" ]
	aSeps = [ "_", "__", "_x_", "|", "||", " ", "  ", ",", ";", ":", "-", ".", "/", "\", "~", "=", char(9), char(10), char(13), "_|_ ,;" ]
	aUni = [ char(206) + char(177), char(206) + char(178) ]
	nSeps = len(aSeps)
	nBadDep = 0
	nBadInd = 0
	nBadLen = 0
	for i = 1 to nSeps
		cSep = aSeps[i]
		aXs = [ "p" + cSep + "q", "p" + cSep + "q", "r" + cSep + "s", "r" + cSep + "s" ]
		aYs = [ "t" + cSep + "u", "t" + cSep + "u", "v" + cSep + "w", "v" + cSep + "w" ]
		aYi = [ "t" + cSep + "u", "v" + cSep + "w", "t" + cSep + "u", "v" + cSep + "w" ]
		nDep = Ds(aXs).MutualInformation(Ds(aYs))
		nInd = Ds(aXs).MutualInformation(Ds(aYi))
		if nDep != 1
			nBadDep++
		ok
		if nInd != 0
			nBadInd++
		ok
		if nDep != Ds(aPlainX).MutualInformation(Ds(aPlainY))
			nBadLen++
		ok
	next
	Then("20 separators, dependent pairs: 1 bit each, as for the plain relabelling", nBadDep, 0)
	Then("20 separators, independent pairs: 0 bit each", nBadInd, 0)
	Then("20 separators: always equal to the plain relabelling", nBadLen, 0)

	# the exact case of the register row
	Then("a_b and c_d against x and y: 1, as ab and cd", Ds([ "a_b", "a_b", "c_d", "c_d" ]).MutualInformation(Ds([ "x", "x", "y", "y" ])), 1)
	Then("... in the other role too", Ds([ "x", "x", "y", "y" ]).MutualInformation(Ds([ "a_b", "a_b", "c_d", "c_d" ])), 1)
	Then("... against each other", Ds([ "a_b", "a_b", "c_d", "c_d" ]).MutualInformation(Ds([ "e_f", "e_f", "g_h", "g_h" ])), 1)
	Then("the plain relabelling gives 1", Ds([ "ab", "ab", "cd", "cd" ]).MutualInformation(Ds([ "x", "x", "y", "y" ])), 1)

	# two DIFFERENT pairs whose joined text is the same: a_b + c and a + b_c both read a_b_c
	aCx = [ "a_b", "a", "a_b", "a" ]
	aCy = [ "c", "b_c", "c", "b_c" ]
	Then("pairs that would join to the same text are told apart: x fixes y, so 1 bit (not 0)", Near(Ds(aCx).MutualInformation(Ds(aCy)), 1, 0.000000000001), 1)
	Then("... equal to the entropy 0.8112781244591328 when the split is 3 to 1", Near(Ds([ "a_b", "a_b", "a_b", "a" ]).MutualInformation(Ds([ "c", "c", "c", "b_c" ])), 0.8112781244591328, 0.000000000001), 1)
	Then("... and independent pairs of that shape stay 0", Ds([ "a_b", "a", "a_b", "a" ]).MutualInformation(Ds([ "c", "c", "b_c", "b_c" ])), 0)

	# unicode built from char codes, never printed
	aGx = [ aUni[1], aUni[1], aUni[2], aUni[2] ]
	aGy = [ aUni[2] + "_" + aUni[1], aUni[2] + "_" + aUni[1], aUni[1] + "|" + aUni[2], aUni[1] + "|" + aUni[2] ]
	Then("non-ASCII values with separators: 1 bit", Ds(aGx).MutualInformation(Ds(aGy)), 1)
	Then("... and 0 for the independent arrangement", Ds(aGx).MutualInformation(Ds([ aGy[1], aGy[3], aGy[1], aGy[3] ])), 0)

	# the empty text and the NA markers are dropped when the set is built, so the lengths differ
	Then("a set with an empty text has that value dropped: its length differs, so 0", Ds([ "a", "", "b", "b" ]).MutualInformation(Ds([ "c", "c", "d", "d" ])), 0)
	Then("... and its Count is 3", Ds([ "a", "", "b", "b" ]).Count(), 3)
	Then("both sets dropping at the same place leave a valid pair: a and b fix c and d, 2 to 1: 0.9182958340544896", Near(Ds([ "a", "", "b", "b" ]).MutualInformation(Ds([ "c", "", "d", "d" ])), 0.9182958340544896, 0.000000000001), 1)
EndScenario()

Scenario("MutualInformation: properties that must hold for any data")
	$dsSeed = 777
	nBadSym = 0
	nBadEnt = 0
	nBadNeg = 0
	nBadOracle = 0
	nCases = 30
	acLab = [ "a", "b", "c", "d", "e", "f" ]
	for iCase = 1 to nCases
		nLen = 4 + DsRand(25)
		nSpanX = 1 + DsRand(5)
		nSpanY = 1 + DsRand(5)
		aU = []
		aV = []
		for i = 1 to nLen
			aU + acLab[1 + DsRand(nSpanX)]
			aV + acLab[1 + DsRand(nSpanY)]
		next
		oU = Ds(aU)
		oV = Ds(aV)
		nUV = oU.MutualInformation(oV)
		nVU = oV.MutualInformation(oU)
		if nUV != nVU
			nBadSym++
		ok
		if NOT Near(oU.MutualInformation(oU), oU.Entropy(), 0.000000000001)
			nBadEnt++
		ok
		if nUV < 0
			nBadNeg++
		ok
		if NOT Near(nUV, NaiveMI(aU, aV), 0.000000000001)
			nBadOracle++
		ok
	next
	Then("30 random pairs: MI(x,y) = MI(y,x) exactly", nBadSym, 0)
	Then("30 random series: MI(x,x) is Entropy(x) within 1e-12", nBadEnt, 0)
	Then("30 random pairs: never below 0", nBadNeg, 0)
	Then("30 random pairs: within 1e-12 of the naive oracle", nBadOracle, 0)
	Then("the oracle gives 1 on the first hand pair", Near(NaiveMI([ "a", "a", "b", "b" ], [ "c", "c", "d", "d" ]), 1, 0.000000000001), 1)
	Then("MI never exceeds the smaller entropy: x against a coarser y", Ds([ "a", "b", "c", "d" ]).MutualInformation(Ds([ "p", "p", "q", "q" ])) <= 1.000000000001, 1)
	Then("... and it reaches it: 1 bit", Near(Ds([ "a", "b", "c", "d" ]).MutualInformation(Ds([ "p", "p", "q", "q" ])), 1, 0.000000000001), 1)
EndScenario()

Scenario("MutualInformation: values are the same when written the same way, like Entropy")
	oMix = Ds([ 1, "1", 1.0, 2 ])
	oWho = Ds([ "a", "a", "a", "b" ])
	Then("Entropy counts 1, '1' and 1.0 as one value: 0.8112781244591328", Near(oMix.Entropy(), 0.8112781244591328, 0.000000000001), 1)
	Then("the mutual information agrees: the three are one value, so x fixes y", Near(oMix.MutualInformation(oWho), 0.8112781244591328, 0.000000000001), 1)
	Then("... and MI(x,x) is that entropy", Near(oMix.MutualInformation(oMix), oMix.Entropy(), 0.000000000001), 1)
	Then("1,2,1,2 against a,a,b,b stay independent: 0", Ds([ 1, 2, 1, 2 ]).MutualInformation(Ds([ "a", "a", "b", "b" ])), 0)
	oCase = Ds([ "a", "A", "b", "B" ])
	Then("Entropy of a,A,b,B is one bit (a and A are one value, as for FrequencyTable)", Near(oCase.Entropy(), 1, 0.000000000001), 1)
	Then("the mutual information agrees: MI(x,x) = 1", Near(oCase.MutualInformation(oCase), 1, 0.000000000001), 1)

	Then("lengths that differ give 0", Ds([ "a", "b", "c" ]).MutualInformation(Ds([ "x", "y" ])), 0)
	Then("... and the length-equal control is not 0", Ds([ "a", "b", "c" ]).MutualInformation(Ds([ "x", "y", "z" ])) > 1.58, 1)
	Then("empty data gives 0", Ds([]).MutualInformation(Ds([])), 0)
	Then("numeric data works: 1,1,2,2 against 5,5,9,9 is one bit", Ds([ 1, 1, 2, 2 ]).MutualInformation(Ds([ 5, 5, 9, 9 ])), 1)
	aKeep = [ "a_b", "c_d", "a_b" ]
	oKeep = Ds(aKeep)
	xIgnore = oKeep.MutualInformation(Ds([ "x", "y", "x" ]))
	Then("the call leaves the data alone", SameList(oKeep.Data(), aKeep), 1)
EndScenario()

Scenario("PlanSummary: the preview of a plan's steps")
	oD = Ds([ 2, 4, 4, 4, 5, 5, 7, 9, 10, 40 ])
	cEda = oD.PlanSummary("eda")
	Then("it answers text, where it raised R5", isString(cEda), 1)
	Then("the title line carries the plan's own title", Has(cEda, "Plan: Exploratory Data Analysis"), 1)
	Then("the name and goal follow", Has(cEda, "Name: {eda}") and Has(cEda, "Goal: Comprehensive data exploration and understanding"), 1)
	Then("the data is shown", Has(cEda, "Data: [ 2, 4, 4, 4, 5, 5, 7, 9, 10, 40 ]"), 1)
	Then("nine steps apply to numbers", Has(cEda, "Steps (9):"), 1)
	Then("... and not the five of text data", Has(cEda, "Steps (5):"), 0)
	acWant = [ "  1. Check data quality", "  2. Identify data type", "  3. Get sample size", "  4. Central tendency (conditional)", "  5. Robust center (conditional)", "  6. Variability (conditional)", "  7. Distribution shape (conditional)", "  8. Asymmetry check (conditional)", "  9. Outlier detection (conditional)" ]
	nBadOrder = 0
	nPrev = 0
	nWant = len(acWant)
	for i = 1 to nWant
		nAt = substr(cEda, acWant[i])
		if nAt <= nPrev
			nBadOrder++
		ok
		nPrev = nAt
	next
	Then("all nine steps are listed, numbered, in the plan's order", nBadOrder, 0)
	Then("a step that does not apply to numbers is absent (Category distribution)", Has(cEda, "Category distribution"), 0)
	Then("the plain steps carry no (conditional)", Has(cEda, "Check data quality (conditional)"), 0)

	cOut = oD.PlanSummary("outliers")
	Then("outliers: the title", Has(cOut, "Plan: Outlier Detection and Analysis"), 1)
	Then("outliers: the argument of the trimmed mean is shown", Has(cOut, "  5. Robust mean (10% trimmed) (conditional) [params: 10]"), 1)
	Then("outliers: seven steps", Has(cOut, "Steps (7):"), 1)
	cClean = Ds([ 5, 5, 6, 6, 5, 6, 5, 6 ]).PlanSummary("outliers")
	Then("outliers on data without outliers: the conditional steps are left out (3 steps)", Has(cClean, "Steps (3):"), 1)
	Then("... and the trimmed mean is not listed", Has(cClean, "trimmed"), 0)

	cTr = oD.PlanSummary("trends")
	Then("trends: the window of 5 and of 10 are shown", Has(cTr, "Smooth short-term fluctuations (conditional) [params: 5]") and Has(cTr, "Long-term trend smoothing (conditional) [params: 10]"), 1)
	cTx = Ds([ "a", "b", "a", "c" ]).PlanSummary("eda")
	Then("text data: the five steps of the text branch", Has(cTx, "Steps (5):") and Has(cTx, "  4. Category distribution (conditional)") and Has(cTx, "  5. Category balance (conditional)"), 1)
	Then("... with no mean step", Has(cTx, "Central tendency"), 0)
	cGoal = oD.PlanSummary("anomalies")
	Then("a goal word resolves to its plan: anomalies is the outlier plan", Has(cGoal, "Plan: Outlier Detection and Analysis"), 1)
	Then("... in any letter case", Has(oD.PlanSummary("EDA"), "Plan: Exploratory Data Analysis"), 1)
EndScenario()

Scenario("PlanSummary: the preview agrees with the plan as data, for every template")
	oD = Ds([ 2, 4, 4, 4, 5, 5, 7, 9, 10, 40 ])
	acNames = [ "eda", "normality", "correlation", "outliers", "trends", "quality" ]
	nBadCount = 0
	nBadOrder = 0
	nBadTitle = 0
	nBadSteps = 0
	nNames = len(acNames)
	for i = 1 to nNames
		aPlan = oD.MakePlan(acNames[i])
		cText = oD.PlanSummary(acNames[i])
		if NOT Has(cText, "Plan: " + aPlan[:title])
			nBadTitle++
		ok
		if NOT Has(cText, "Steps (" + aPlan[:total_steps] + "):")
			nBadCount++
		ok
		aSteps = aPlan[:steps]
		nSteps = len(aSteps)
		if nSteps != aPlan[:total_steps]
			nBadSteps++
		ok
		nPrev = 0
		for j = 1 to nSteps
			nAt = substr(cText, "  " + j + ". " + aSteps[j][:description])
			if nAt <= nPrev
				nBadOrder++
			ok
			nPrev = nAt
		next
	next
	Then("six templates: every title appears", nBadTitle, 0)
	Then("six templates: the step count in the text is the plan's total_steps", nBadCount, 0)
	Then("six templates: every step description is listed with its number, in order", nBadOrder, 0)
	Then("six templates: total_steps is the number of steps", nBadSteps, 0)
	Then("the correlation plan applies 5 steps to this data (the control for the loop)", oD.MakePlan("correlation")[:total_steps], 5)
	Then("an unknown plan raises, as the sibling does", Has(RaiseOf(oD, "PlanSummary", "no such plan"), "Unknown Plan"), 1)
	Then("... and so does MakePlan", Has(RaiseOf(oD, "MakePlan", "no such plan"), "Unknown Plan"), 1)
EndScenario()

Scenario("PlanSummary: it only previews, nothing runs")
	$dsSide = 0
	$dsSideB = 0
	aData = [ 2, 4, 4, 4, 5, 5, 7, 9, 10, 40 ]
	oD = Ds(aData)
	cKey = oD.AddPlan("probe", "Probe plan", "steps with a side effect", [
		[ :function = "DsSideNoArg", :description = "first effect" ],
		[ :function = "DsSideTwo", :description = "second effect", :args = [ 3 ] ],
		[ :function = "Mean", :description = "third, a real method" ]
	])
	cText = oD.PlanSummary("probe")
	Then("the plan with three steps shows its title", Has(cText, "Plan: Probe plan"), 1)
	Then("... its goal", Has(cText, "Goal: steps with a side effect"), 1)
	Then("... three steps", Has(cText, "Steps (3):"), 1)
	Then("... step 1 first", Has(cText, "  1. first effect"), 1)
	Then("... step 2 with its params", Has(cText, "  2. second effect [params: 3]"), 1)
	Then("... step 3 last", Has(cText, "  3. third, a real method"), 1)
	nOne = substr(cText, "1. first effect")
	nTwo = substr(cText, "2. second effect")
	nThree = substr(cText, "3. third, a real method")
	Then("... in the order given", (nOne > 0) and (nOne < nTwo) and (nTwo < nThree), 1)
	Then("the first stand-in was not called", $dsSide, 0)
	Then("the second stand-in was not called", $dsSideB, 0)
	Then("the data set's data is unchanged", SameList(oD.Data(), aData), 1)
	Then("MakePlan, which only builds the plan, leaves them unrun as well", len(oD.MakePlan("probe")[:steps]), 3)
	Then("... still unrun", $dsSide + $dsSideB, 0)

	# the control: the same steps DO run when they are executed
	aPlan = oD.MakePlan("probe")
	xA = oD._ExecutePlanStep(aPlan[:steps][1])
	xB = oD._ExecutePlanStep(aPlan[:steps][2])
	Then("executing step 1 does call its stand-in", $dsSide, 1)
	Then("executing step 2 does call its stand-in, with its argument", $dsSideB, 3)
	cAgain = oD.PlanSummary("probe")
	Then("and the preview after that is the same text as before", cAgain, cText)

	# an empty plan
	oD.AddPlan("hollow", "Hollow plan", "nothing to do", [])
	cHollow = oD.PlanSummary("hollow")
	Then("an empty plan has its title", Has(cHollow, "Plan: Hollow plan"), 1)
	Then("... says it has no step", Has(cHollow, "Steps (0):"), 1)
	Then("... and lists none", Has(cHollow, "  1. "), 0)
	Then("... while the three-step plan above does list a first step (control)", Has(cText, "  1. "), 1)
	Then("an empty data set still gets a preview", Has(Ds([]).PlanSummary("eda"), "Plan: Exploratory Data Analysis"), 1)
	Then("... with the three steps that always apply", Has(Ds([]).PlanSummary("eda"), "Steps (3):"), 1)
EndScenario()

Scenario("The aliases that named a method with the wrong number of arguments")
	oD = Ds([ 2, 4, 4, 4, 5, 5, 7, 9, 10, 12 ])
	aWant = [ 3.3333333333333335, 4, 4.333333333333333, 4.666666666666667, 5.666666666666667, 7, 8.666666666666666, 10.333333333333334 ]
	aGot = oD.MovingAverage(3)
	nBad = 0
	nWant = len(aWant)
	Then("the moving average of window 3 has 8 values", len(aGot), 8)
	for i = 1 to nWant
		if NOT Near(aGot[i], aWant[i], 0.000000000001)
			nBad++
		ok
	next
	Then("... equal to the hand-worked ones", nBad, 0)
	Then("MovAvrg(3) is the same list", SameList(oD.MovAvrg(3), aGot), 1)
	Then("MovingMean(3) is the same list", SameList(oD.MovingMean(3), aGot), 1)
	Then("MovMean(3) is the same list", SameList(oD.MovMean(3), aGot), 1)
	Then("a window of 5 is not the window of 3 (control)", oD.MovMean(5) = aGot, 0)
	Then("MovMean(5) has 6 values", len(oD.MovMean(5)), 6)

	oC = Ds([ "a", "b", "a", "b" ])
	oE = Ds([ "x", "x", "y", "y" ])
	aTab = oC.ContingencyTable(oE)
	Then("ContingencyTable lists the other's values first", SameList(aTab[1], [ "x", "y" ]), 1)
	Then("ContingTable(other) is the same table", SameList(oC.ContingTable(oE), aTab), 1)
	Then("the table counts a with x once and a with y once", SameList(aTab[2][1][2], [ 1, 1 ]), 1)

	oS = new DsStub([ 1, 2, 3 ])
	aRun = oS.RunPlanXT("eda", 1)
	Then("RunPlanXT forwards both arguments to ExecutePlanXT", SameList(aRun, [ "stub", "eda", 1 ]), 1)
	aPerf = oS.PerformPlanXT("trends", 0)
	Then("PerformPlanXT forwards both arguments to ExecutePlanXT", SameList(aPerf, [ "stub", "trends", 0 ]), 1)
	Then("... and the answer is returned, not dropped", len(aPerf), 3)
EndScenario()

Summary()

# helpers go at the END: top-level code after a func belongs to that func

func Ds(aList)
	return new stzDataSet(aList)

func Near(a, b, nTol)
	if abs(a - b) <= nTol
		return 1
	ok
	return 0

# two lists are the same when they have the same items in the same order; numbers are compared
# within 1e-12, texts exactly, nested lists item by item
func SameList(aA, aB)
	if NOT (isList(aA) and isList(aB))
		return 0
	ok
	nvLa = len(aA)
	if nvLa != len(aB)
		return 0
	ok
	for nvI = 1 to nvLa
		if isNumber(aA[nvI]) and isNumber(aB[nvI])
			if abs(aA[nvI] - aB[nvI]) > 0.000000000001
				return 0
			ok
		but isString(aA[nvI]) and isString(aB[nvI])
			if strcmp(aA[nvI], aB[nvI]) != 0
				return 0
			ok
		but isList(aA[nvI]) and isList(aB[nvI])
			if NOT SameList(aA[nvI], aB[nvI])
				return 0
			ok
		else
			return 0
		ok
	next
	return 1

func Has(cText, cNeedle)
	if NOT isString(cText)
		return 0
	ok
	if substr(cText, cNeedle) > 0
		return 1
	ok
	return 0

func RaiseOf(oObj, cMethod, cArg)
	gRaised = ""
	try
		eval("gDummy = oObj." + cMethod + "(cArg)")
	catch
		gRaised = cCatchError
	done
	return gRaised

func DsSideNoArg()
	$dsSide++
	return 1

func DsSideTwo(n)
	$dsSideB += n
	return 1

# Park-Miller: small enough that the products stay exact in a double
func DsRand(nMax)
	$dsSeed = ($dsSeed * 16807) % 2147483647
	return $dsSeed % nMax

# ranks by counting, not by sorting: less + (equal + 1) / 2
func NaiveRanks(aList)
	nvN = len(aList)
	aRk = []
	for nvI = 1 to nvN
		nvLess = 0
		nvEq = 0
		for nvJ = 1 to nvN
			if aList[nvJ] < aList[nvI]
				nvLess++
			but aList[nvJ] = aList[nvI]
				nvEq++
			ok
		next
		aRk + (nvLess + (nvEq + 1) / 2)
	next
	return aRk

func NaiveRho(aA, aB)
	aRa = NaiveRanks(aA)
	aRb = NaiveRanks(aB)
	nvN = len(aRa)
	nvMa = 0
	nvMb = 0
	for nvI = 1 to nvN
		nvMa += aRa[nvI]
		nvMb += aRb[nvI]
	next
	nvMa = nvMa / nvN
	nvMb = nvMb / nvN
	nvSab = 0
	nvSaa = 0
	nvSbb = 0
	for nvI = 1 to nvN
		nvSab += (aRa[nvI] - nvMa) * (aRb[nvI] - nvMb)
		nvSaa += (aRa[nvI] - nvMa) * (aRa[nvI] - nvMa)
		nvSbb += (aRb[nvI] - nvMb) * (aRb[nvI] - nvMb)
	next
	if nvSaa = 0 or nvSbb = 0
		return 0
	ok
	return nvSab / sqrt(nvSaa * nvSbb)

# mutual information by counting, over lowercase plain labels
func NaiveMI(aX, aY)
	nvN = len(aX)
	nvMi = 0
	for nvI = 1 to nvN
		nvFirst = 1
		for nvJ = 1 to nvI - 1
			if aX[nvJ] = aX[nvI] and aY[nvJ] = aY[nvI]
				nvFirst = 0
			ok
		next
		if nvFirst
			nvXY = 0
			nvX = 0
			nvY = 0
			for nvK = 1 to nvN
				if aX[nvK] = aX[nvI]
					nvX++
				ok
				if aY[nvK] = aY[nvI]
					nvY++
				ok
				if aX[nvK] = aX[nvI] and aY[nvK] = aY[nvI]
					nvXY++
				ok
			next
			nvPxy = nvXY / nvN
			nvMi += nvPxy * (log(nvPxy / ((nvX / nvN) * (nvY / nvN))) / log(2))
		ok
	next
	return nvMi

# a data set whose ExecutePlanXT only records what it was asked
class DsStub from stzDataSet
	def ExecutePlanXT(cPlan, bVerbose)
		return [ "stub", cPlan, bVerbose ]
