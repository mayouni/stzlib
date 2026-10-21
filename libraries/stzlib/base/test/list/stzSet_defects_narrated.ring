load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzSet subsets (DEFECTS.md, stzSet, fixed on fix/st): Subsets, SubSetsOfNElements and
# NumberOfSubsets were only a TODO comment, so the first two answered an empty text and the third
# answered 0. One cause, three rows.
#
# THE DEFINITION, written down and checked here against expectations typed by hand or computed apart:
#   - Subsets() is the POWER SET: the empty set and the set itself are in it. A set of n items has 2^n.
#   - ORDER: by size (0 items first), and within one size in the order of the POSITIONS of the items:
#     [1,2] before [1,3] before [2,3]. Each subset keeps the order of the set. The empty set answers [[]].
#   - SubSetsOfNElements(n): the subsets of exactly n items in the same order; 0 gives [[]], more than
#     the size gives [], a negative, fractional or non-number size raises a message.
#   - NumberOfSubsets() is 2^size computed WITHOUT listing; exact (a power of 2 is held exactly) up to
#     1023 items, a message beyond.
#   - LISTING IS CAPPED at 65536 subsets (a set of 16 items): more would fill the memory of the machine.
#     Subsets raises beyond 16 items; SubSetsOfNElements raises when the answer would pass 65536.
#   - the subsets hold the items themselves, unchanged: numbers, texts, nested lists.
# The class could always be built; stzSetError was the missing piece: the guards of init, Update and
# UnionWith called it and raised R3 instead of their message. It is defined now in stzSet.ring, and the
# first scenario proves each guard.
#
# Accented and Hebrew texts are built from char codes and never printed.

cE1 = char(195) + char(169)                # a small e acute
cHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
cAcc = "caf" + cE1

Scenario("A stzSet can be built, and its guards raise their own message")
	oS = new stzSet([ 3, 1, 3, 2, 1 ])
	Then("the repeats are dropped, first kept", Same(@@(oS.Content()), "[ 3, 1, 2 ]"), 1)
	cErr = ""
	try  oBad = new stzSet(5)  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't create the stzSet object")
	Then("a value that is not a list raises the class's own message, not R3", bHas, 1)
	bHasR3 = HasText(cErr, "stzseterror")
	Then("and the message does not name the missing function", bHasR3, 0)
	cErr = ""
	try  oS.Update([ 1, 1, 2 ])  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't update the set")
	Then("Update with a repeated item raises its message", bHas, 1)
	Then("the set is unchanged after the refused update", Same(@@(oS.Content()), "[ 3, 1, 2 ]"), 1)
	cErr = ""
	try  oS.UnionWith([ 5, 5 ])  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't compute the union")
	Then("UnionWith a repeated item raises its message", bHas, 1)
	cErr = ""
	try  oS.UpdateWith([ 7, 8 ])  catch  cErr = cCatchError  done
	Then("Update with a proper set raises nothing", cErr, "")
	Then("and replaces the content", Same(@@(oS.Content()), "[ 7, 8 ]"), 1)
EndScenario()

Scenario("The subsets of a 4-item set, against a power set written by hand")
	oS = new stzSet([ 1, 2, 3, 4 ])
	cWant = "[ [ ], [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ], " +
	        "[ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ], [ 1, 2, 3, 4 ] ]"
	aSubs = oS.Subsets()
	Then("Subsets is the hand-written power set, in size then position order", Same(@@(aSubs), cWant), 1)
	cWrong = "[ [ ], [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 1, 3 ], [ 1, 2 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ], " +
	         "[ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ], [ 1, 2, 3, 4 ] ]"
	Then("a power set with [1,3] before [1,2] is NOT the answer", Same(@@(aSubs), cWrong), 0)
	Then("the empty set is the first subset", len(aSubs[1]), 0)
	Then("the set itself is the last subset", Same(@@(aSubs[16]), "[ 1, 2, 3, 4 ]"), 1)
	Then("there are 16 of them", len(aSubs), 16)
	Then("NumberOfSubsets says 16 too", oS.NumberOfSubsets(), 16)
	Then("NumberOfSubsets does not say 15 (the set itself would be missing)", oS.NumberOfSubsets() = 15, 0)
	Then("asking for the subsets leaves the set as it was", Same(@@(oS.Content()), "[ 1, 2, 3, 4 ]"), 1)
	aSubs[2] + 99
	Then("editing a returned subset does not edit the set", Same(@@(oS.Content()), "[ 1, 2, 3, 4 ]"), 1)
	Then("nor the next answer", Same(@@(oS.Subsets()[2]), "[ 1 ]"), 1)
EndScenario()

Scenario("Subsets of exactly n items")
	oS = new stzSet([ 1, 2, 3, 4 ])
	Then("n = 2 gives the six pairs in position order",
		Same(@@(oS.SubSetsOfNElements(2)), "[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]"), 1)
	Then("n = 3 gives the four triples",
		Same(@@(oS.SubSetsOfNElements(3)), "[ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ]"), 1)
	Then("n = 1 gives the singletons", Same(@@(oS.SubSetsOfNElements(1)), "[ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]"), 1)
	Then("n = 0 gives only the empty set", Same(@@(oS.SubSetsOfNElements(0)), "[ [ ] ]"), 1)
	Then("n = the size gives only the set itself", Same(@@(oS.SubSetsOfNElements(4)), "[ [ 1, 2, 3, 4 ] ]"), 1)
	Then("n above the size gives nothing", Same(@@(oS.SubSetsOfNElements(5)), "[ ]"), 1)
	Then("n = 2 does not give the four triples",
		Same(@@(oS.SubSetsOfNElements(2)), "[ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ]"), 0)
	cErr = ""
	try  oS.SubSetsOfNElements(-1)  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't list the subsets of a given size")
	Then("a negative size raises a message", bHas, 1)
	cErr = ""
	try  oS.SubSetsOfNElements(1.5)  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't list the subsets of a given size")
	Then("a fractional size raises a message", bHas, 1)
	cErr = ""
	try  oS.SubSetsOfNElements("two")  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't list the subsets of a given size")
	Then("a text size raises a message", bHas, 1)
	cErr = ""
	try  oS.SubSetsOfNElements(2)  catch  cErr = cCatchError  done
	Then("a good size raises nothing", cErr, "")
EndScenario()

Scenario("Counts against independent figures, sizes 0 to 10")
	nBadTotal = 0
	nBadList = 0
	nBadK = 0
	nBadUnique = 0
	nBadSorted = 0
	nBadSize = 0
	for nSz = 0 to 10
		aItems = []
		for nI = 1 to nSz
			aItems + nI
		next
		oS = new stzSet(aItems)
		aS = oS.Subsets()
		nTwo = pow(2, nSz)                        # the builtin, independent of the class
		if oS.NumberOfSubsets() != nTwo  nBadTotal++  ok
		if len(aS) != nTwo  nBadList++  ok
		aRow = PascalRow(nSz)                     # the binomials, built by addition
		nSum = 0
		for nK = 0 to nSz
			aK = oS.SubSetsOfNElements(nK)
			nSum += len(aK)
			if len(aK) != aRow[nK + 1]  nBadK++  ok
			for nJ = 1 to len(aK)
				if len(aK[nJ]) != nK  nBadSize++  ok
			next
		next
		if nSum != nTwo  nBadK++  ok
		# every subset is distinct, and ascending (the items are 1..n in order)
		aSeen = []
		for nJ = 1 to len(aS)
			aSeen + @@(aS[nJ])
			for nI = 2 to len(aS[nJ])
				if aS[nJ][nI] <= aS[nJ][nI - 1]  nBadSorted++  ok
			next
		next
		oSeen = new stzSet(aSeen)
		if oSeen.NumberOfElements() != nTwo  nBadUnique++  ok
		# the sizes never go down along Subsets
		for nJ = 2 to len(aS)
			if len(aS[nJ]) < len(aS[nJ - 1])  nBadSize++  ok
		next
	next
	Then("NumberOfSubsets equals 2^n for n = 0..10", nBadTotal, 0)
	Then("the length of Subsets equals 2^n for n = 0..10", nBadList, 0)
	Then("each SubSetsOfNElements length equals its binomial, and they add up to 2^n", nBadK, 0)
	Then("every listed subset has the size asked, and the sizes never go down", nBadSize, 0)
	Then("no subset is listed twice", nBadUnique, 0)
	Then("every subset keeps the order of the set", nBadSorted, 0)
	Then("the check itself can fail: 2^4 is not 15", pow(2, 4) = 15, 0)
	Then("and the binomial row of 4 is 1 4 6 4 1", Same(@@(PascalRow(4)), "[ 1, 4, 6, 4, 1 ]"), 1)
EndScenario()

Scenario("Items of every kind come back unchanged")
	oT = new stzSet([ cHeb, cAcc, "x" ])
	aT = oT.Subsets()
	Then("three texts give 8 subsets", len(aT), 8)
	bSame = ( aT[2][1] = cHeb and aT[3][1] = cAcc and aT[4][1] = "x" )
	Then("the singletons hold the texts themselves, Hebrew and accented included", bSame, 1)
	bSame = ( aT[5][1] = cHeb and aT[5][2] = cAcc and aT[6][2] = "x" and aT[7][1] = cAcc and aT[7][2] = "x" )
	Then("the pairs keep set order", bSame, 1)
	Then("the last subset has the three", len(aT[8]), 3)
	bSame = ( aT[8][1] = cHeb and aT[8][2] = cAcc and aT[8][3] = "x" )
	Then("in set order", bSame, 1)
	bSwapped = ( aT[5][1] = cAcc )
	Then("a pair is not in a swapped order", bSwapped, 0)

	oC = new stzSet([ "a", "A" ])
	Then("case counts: a and A are two elements, so 4 subsets", len(oC.Subsets()), 4)
	bKept = ( strcmp(oC.Subsets()[3][1], "A") = 0 )
	Then("and the second singleton keeps its capital", bKept, 1)

	oN = new stzSet([ [ 1, 2 ], [ 3 ] ])
	Then("nested lists as items give 4 subsets", len(oN.Subsets()), 4)
	Then("they are the lists themselves",
		Same(@@(oN.Subsets()), "[ [ ], [ [ 1, 2 ] ], [ [ 3 ] ], [ [ 1, 2 ], [ 3 ] ] ]"), 1)
	Then("a pair of nested lists is not flattened",
		Same(@@(oN.SubSetsOfNElements(2)), "[ [ 1, 2, 3 ] ]"), 0)

	oM = new stzSet([ 1, "one", 2.5, [ 7 ] ])
	Then("mixed kinds give 16 subsets", len(oM.Subsets()), 16)
	Then("the mixed pairs are in position order",
		Same(@@(oM.SubSetsOfNElements(2)),
		     '[ [ 1, "one" ], [ 1, 2.50 ], [ 1, [ 7 ] ], [ "one", 2.50 ], [ "one", [ 7 ] ], [ 2.50, [ 7 ] ] ]'), 1)
EndScenario()

Scenario("Empty, one item, and repeats given to the constructor")
	oE = new stzSet([])
	Then("the empty set has one subset: the empty set", Same(@@(oE.Subsets()), "[ [ ] ]"), 1)
	Then("NumberOfSubsets says 1", oE.NumberOfSubsets(), 1)
	Then("size 0 of the empty set is [ [ ] ]", Same(@@(oE.SubSetsOfNElements(0)), "[ [ ] ]"), 1)
	Then("size 1 of the empty set is nothing", Same(@@(oE.SubSetsOfNElements(1)), "[ ]"), 1)
	Then("and not zero subsets overall", oE.NumberOfSubsets() = 0, 0)
	o1 = new stzSet([ "z" ])
	Then("one item gives the empty set and the singleton", Same(@@(o1.Subsets()), '[ [ ], [ "z" ] ]'), 1)
	Then("NumberOfSubsets says 2", o1.NumberOfSubsets(), 2)
	oD = new stzSet([ 1, 2, 1, 2, 2 ])
	Then("repeats given to the constructor are dropped first: 4 subsets", len(oD.Subsets()), 4)
	Then("and they are those of [ 1, 2 ]", Same(@@(oD.Subsets()), "[ [ ], [ 1 ], [ 2 ], [ 1, 2 ] ]"), 1)
	Then("not 32, which five items would give", len(oD.Subsets()) = 32, 0)
EndScenario()

Scenario("The size limit and the counting that does not list")
	aSixteen = []
	for nI = 1 to 16
		aSixteen + nI
	next
	o16 = new stzSet(aSixteen)
	cErr = ""
	try  aBig = o16.Subsets()  catch  cErr = cCatchError  done
	Then("16 items are listed without complaint", cErr, "")
	Then("65536 subsets", len(aBig), 65536)
	Then("the last is the set itself", len(aBig[65536]), 16)
	aBig = []
	aSeventeen = aSixteen
	aSeventeen + 17
	o17 = new stzSet(aSeventeen)
	cErr = ""
	try  o17.Subsets()  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't list the subsets")
	Then("17 items are refused with a message", bHas, 1)
	Then("but NumberOfSubsets answers 131072 without listing", o17.NumberOfSubsets(), 131072)
	Then("131072 is 2^17, not 2^16", o17.NumberOfSubsets() = 65536, 0)
	cErr = ""
	try  aK8 = o17.SubSetsOfNElements(8)  catch  cErr = cCatchError  done
	Then("size 8 of 17 items is allowed (24310 subsets)", cErr, "")
	Then("and has the binomial length", len(aK8), 24310)
	Then("first of them", Same(@@(aK8[1]), "[ 1, 2, 3, 4, 5, 6, 7, 8 ]"), 1)
	Then("last of them", Same(@@(aK8[24310]), "[ 10, 11, 12, 13, 14, 15, 16, 17 ]"), 1)
	aK8 = []
	cErr = ""
	try  aK16 = o17.SubSetsOfNElements(16)  catch  cErr = cCatchError  done
	Then("size 16 of 17 items gives 17 subsets", len(aK16), 17)
	Then("the first leaves out the last item", Same(@@(aK16[1]), "[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]"), 1)
	aTwenty = aSeventeen
	aTwenty + 18
	aTwenty + 19
	aTwenty + 20
	o20 = new stzSet(aTwenty)
	cErr = ""
	try  o20.SubSetsOfNElements(10)  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't list the subsets")
	Then("size 10 of 20 items (184756) is refused", bHas, 1)
	Then("NumberOfSubsets of 20 items is 1048576", o20.NumberOfSubsets(), 1048576)
	aHuge = []
	for nI = 1 to 40
		aHuge + nI
	next
	oH = new stzSet(aHuge)
	Then("NumberOfSubsets of 40 items is 2^40, exactly", oH.NumberOfSubsets(), 1099511627776)
	Then("and not that plus one", oH.NumberOfSubsets() = 1099511627777, 0)
	aMax = []
	for nI = 1 to 1023
		aMax + nI
	next
	oMax = new stzSet(aMax)
	Then("1023 items count as 2^1023", oMax.NumberOfSubsets() = pow(2, 1023), 1)
	aMax + 1024
	oOver = new stzSet(aMax)
	cErr = ""
	try  oOver.NumberOfSubsets()  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't count the subsets")
	Then("1024 items are refused with a message", bHas, 1)
EndScenario()

Scenario("Neighbours of the same shape: the 'many' forms")
	oS = new stzSet([ 1, 2, 3 ])
	Then("UnionWithMany adds the new elements of each set, in order",
		Same(@@(oS.UnionWithMany([ [ 3, 4 ], [ 5, 4 ] ])), "[ 1, 2, 3, 4, 5 ]"), 1)
	Then("and leaves the set alone", Same(@@(oS.Content()), "[ 1, 2, 3 ]"), 1)
	cErr = ""
	try  oS.UnionWithMany([ [ 4, 4 ] ])  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't compute the union with many sets")
	Then("a member with a repeat raises its message", bHas, 1)
	oS.UnifyWithMany([ [ 3, 4 ], [ 6 ] ])
	Then("UnifyWithMany changes the set in place", Same(@@(oS.Content()), "[ 1, 2, 3, 4, 6 ]"), 1)
	Then("IntersectionWithMany keeps what every list holds, in set order",
		Same(@@(oS.IntersectionWithMany([ [ 6, 4, 9 ], [ 4, 4, 1, 6 ] ])), "[ 4, 6 ]"), 1)
	Then("not what only one holds", Same(@@(oS.IntersectionWithMany([ [ 6, 4, 9 ], [ 4, 4, 1, 6 ] ])), "[ 1, 4, 6, 9 ]"), 0)
	Then("an empty list of lists gives the set", Same(@@(oS.IntersectionWithMany([])), "[ 1, 2, 3, 4, 6 ]"), 1)
	Then("a list with no common element gives nothing", Same(@@(oS.IntersectionWithMany([ [ 1 ], [ 2 ] ])), "[ ]"), 1)
	cErr = ""
	try  oS.IntersectionWithMany(5)  catch  cErr = cCatchError  done
	bHas = HasText(cErr, "Can't compute the intersection with many lists")
	Then("a value that is not a list of lists raises its message", bHas, 1)
	Then("AddElement of a new list element adds it", Same(@@(oS.AddElementQ([ 8 ]).Content()), "[ 1, 2, 3, 4, 6, [ 8 ] ]"), 1)
EndScenario()

Summary()

func Same(pcA, pcB)
	return strcmp(pcA, pcB) = 0

func HasText(pcHay, pcNeedle)
	_aPos_ = StzFind(pcNeedle, pcHay)
	return len(_aPos_) > 0

func PascalRow(pnN)
	_aRow_ = [ 1 ]
	for _r_ = 1 to pnN
		_aNext_ = [ 1 ]
		for _c_ = 2 to _r_
			_aNext_ + (_aRow_[_c_ - 1] + _aRow_[_c_])
		next
		_aNext_ + 1
		_aRow_ = _aNext_
	next
	return _aRow_
