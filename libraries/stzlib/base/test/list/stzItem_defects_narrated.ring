load "../../stzBase.ring"
load "../_narrated.ring"

# DEFECTS register, class stzItemCS: twenty methods that raised R14 (they forwarded to methods
# stzList does not have), plus the defects found while documenting them: the case flag given to
# init was never read by the plain methods, OccurrencesXT answered only the last requested
# position, and the two public names InstertedBeforeCS / InstertedAfterCS were typos.
#
# Rules this guard keeps: every positive has a negative sibling; every passive form (the *ed
# forms) is checked to leave the object and the caller's list UNCHANGED; expectations are written
# by hand from the meaning of the method, never copied from the output. Run from inside test/list.

Scenario("The case flag given to init is now read by the plain methods")
	aL = [ "a", "b", "A", "c", "a", "b", "b" ]
	oCs = new stzItemCS("a", aL, 1)
	oCi = new stzItemCS("a", aL, 0)
	oNm = TheItemInQ("a", aL)
	Then("flag 1: Positions compares with case", Same(oCs.Positions(), [ 1, 5 ]), 1)
	Then("flag 0: Positions ignores case", Same(oCi.Positions(), [ 1, 3, 5 ]), 1)
	Then("flag 0: NumberOfOccurrence counts three", oCi.NumberOfOccurrence(), 3)
	Then("flag 1: NumberOfOccurrence counts two", oCs.NumberOfOccurrence(), 2)
	Then("flag 0: LastPosition of a is the capital A closing a list", StzItemCSQ("a", [ "a", "b", "A" ], 0).LastPosition(), 3)
	Then("flag 1: the same list ends its a at 1", StzItemCSQ("a", [ "a", "b", "A" ], 1).LastPosition(), 1)
	Then("flag 0: NthPosition(2) reaches the capital A", oCi.NthPosition(2), 3)
	Then("flag 1: NthPosition(2) skips it", oCs.NthPosition(2), 5)
	Then("the named flag :CaseSensitive of TheItemInQ means with case", Same(oNm.Positions(), [ 1, 5 ]), 1)
	Then("the explicit CS form still overrides the stored flag", Same(oCs.PositionsCS(0), [ 1, 3, 5 ]), 1)
	Then("and the other way", Same(oCi.PositionsCS(1), [ 1, 5 ]), 1)
	Then("the stored flag is still readable", oCi.CaseSensitive(), 0)
EndScenario()

Scenario("OccurrencesXT answers one position per requested occurrence")
	aL = [ "a", "b", "A", "c", "a", "b", "b" ]
	o = new stzItemCS("a", aL, 1)
	Then("occurrences 1 and 2 are at 1 and 5", Same(o.OccurrencesXT([ 1, 2 ]), [ 1, 5 ]), 1)
	Then("the order requested is kept", Same(o.OccurrencesXT([ 2, 1 ]), [ 5, 1 ]), 1)
	Then("one occurrence gives one position", Same(o.OccurrencesXT([ 2 ]), [ 5 ]), 1)
	Then("an occurrence that does not exist is left out, not answered as 0", Same(o.OccurrencesXT([ 1, 3 ]), [ 1 ]), 1)
	Then("with case ignored the third occurrence exists", Same(o.OccurrencesCSXT([ 1, 2, 3 ], 0), [ 1, 3, 5 ]), 1)
	bRaised = 0
	try
		o.OccurrencesXT([ "x" ])
	catch
		bRaised = 1
	done
	Then("a list that is not made of numbers is refused", bRaised, 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
EndScenario()

Scenario("Sections: the positions of the item as runs of consecutive positions")
	aL = [ "x", "a", "a", "a", "y", "a" ]
	o = new stzItemCS("a", aL, 1)
	Then("a run of three and a lone one", Same(o.Sections(), [ [ 2, 4 ], [ 6, 6 ] ]), 1)
	Then("PositionsAsSections is the same call", Same(o.PositionsAsSections(), [ [ 2, 4 ], [ 6, 6 ] ]), 1)
	Then("Positions, for contrast, lists every one", Same(o.Positions(), [ 2, 3, 4, 6 ]), 1)
	oB = new stzItemCS("b", [ "a", "b", "A", "c", "a", "b", "b" ], 1)
	Then("two runs: a lone one and a pair", Same(oB.Sections(), [ [ 2, 2 ], [ 6, 7 ] ]), 1)
	oA = new stzItemCS("a", [ "a", "b", "A", "c", "a" ], 1)
	Then("with case ignored the capital splits nothing: three lone ones", Same(oA.SectionsCS(0), [ [ 1, 1 ], [ 3, 3 ], [ 5, 5 ] ]), 1)
	Then("with case kept the capital is not the item", Same(oA.Sections(), [ [ 1, 1 ], [ 5, 5 ] ]), 1)
	Then("an absent item has no section", len(StzItemCSQ("z", aL, 1).Sections()), 0)
	Then("a number item", Same(StzItemCSQ(2, [ 2, 2, 5, 2 ], 1).Sections(), [ [ 1, 2 ], [ 4, 4 ] ]), 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
EndScenario()

Scenario("IsBoundedBy and IsBetween")
	aL = [ "<", "a", ">", "x", "a", "y" ]
	o = new stzItemCS("a", aL, 1)
	Then("bounded by the pair right around the first occurrence", o.IsBoundedBy([ "<", ">" ]), 1)
	Then("bounded by the pair right around the second occurrence", o.IsBoundedBy([ "x", "y" ]), 1)
	Then("a pair that never surrounds it", o.IsBoundedBy([ "<", "y" ]), 0)
	Then("the pair in the wrong order", o.IsBoundedBy([ ">", "<" ]), 0)
	Then("between: the opener before and the closer after, right next to it", o.IsBetween("<", ">"), 1)
	Then("between does not need them to touch: < ... a ... y", o.IsBetween("<", "y"), 1)
	Then("whereas bounded does", o.IsBoundedBy([ "<", "y" ]), 0)
	Then("between: the closer must come after", o.IsBetween(">", "<"), 0)
	Then("between: a bound that is not in the list", o.IsBetween("<", "q"), 0)
	oS = new stzItemCS("<", aL, 1)
	Then("an item at the start has no left neighbour", oS.IsBoundedBy([ "x", ">" ]), 0)
	Then("an item at the start is not between anything before it", oS.IsBetween("x", ">"), 0)
	oE = new stzItemCS("y", aL, 1)
	Then("an item at the end has no right neighbour", oE.IsBoundedBy([ "a", "z" ]), 0)
	oC = new stzItemCS("a", [ "<", "A", ">" ], 0)
	Then("case ignored (flag 0): A counts as a", oC.IsBoundedBy([ "<", ">" ]), 1)
	Then("case ignored, explicit CS form", StzItemCSQ("a", [ "<", "A", ">" ], 1).IsBoundedByCS([ "<", ">" ], 0), 1)
	Then("case kept: A is not a", StzItemCSQ("a", [ "<", "A", ">" ], 1).IsBoundedBy([ "<", ">" ]), 0)
	Then("between with case ignored, explicit CS form", StzItemCSQ("a", [ "<", "A", ">" ], 1).IsBetweenCS("<", ">", 0), 1)
	Then("between with case kept", StzItemCSQ("a", [ "<", "A", ">" ], 1).IsBetween("<", ">"), 0)
	oN = new stzItemCS(5, [ 4, 5, 6 ], 1)
	Then("numbers: bounded by 4 and 6", oN.IsBoundedBy([ 4, 6 ]), 1)
	Then("numbers: not by 4 and 7", oN.IsBoundedBy([ 4, 7 ]), 0)
	bRaised = 0
	try
		o.IsBoundedBy("x")
	catch
		bRaised = 1
	done
	Then("bounds that are not a pair are refused", bRaised, 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
EndScenario()

Scenario("BoundedBy: the list with the bounds put around each occurrence")
	aL = [ "a", "b", "c", "b" ]
	o = new stzItemCS("b", aL, 1)
	Then("brackets around both b", Same(o.BoundedBy([ "[", "]" ]), [ "a", "[", "b", "]", "c", "[", "b", "]" ]), 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
	Then("the object still answers the same positions", Same(o.Positions(), [ 2, 4 ]), 1)
	oS = new stzItemCS("a", [ "a", "b" ], 1)
	Then("an item at the start", Same(oS.BoundedBy([ "(", ")" ]), [ "(", "a", ")", "b" ]), 1)
	oE = new stzItemCS("b", [ "a", "b" ], 1)
	Then("an item at the end", Same(oE.BoundedBy([ "(", ")" ]), [ "a", "(", "b", ")" ]), 1)
	Then("an absent item leaves a copy of the list", Same(StzItemCSQ("z", aL, 1).BoundedBy([ "(", ")" ]), aL), 1)
	Then("with case ignored", Same(StzItemCSQ("a", [ "a", "A" ], 1).BoundedByCS([ "(", ")" ], 0), [ "(", "a", ")", "(", "A", ")" ]), 1)
	Then("with case kept the capital is left alone", Same(StzItemCSQ("a", [ "a", "A" ], 1).BoundedBy([ "(", ")" ]), [ "(", "a", ")", "A" ]), 1)
	bRaised = 0
	try
		o.BoundedBy("x")
	catch
		bRaised = 1
	done
	Then("bounds that are not a pair are refused", bRaised, 1)
EndScenario()

Scenario("ReplacedWith and Removed return a copy and leave the list alone")
	aL = [ "a", "b", "A", "c", "a", "b", "b" ]
	o = new stzItemCS("a", aL, 1)
	Then("ReplacedWith replaces the occurrences with case", Same(o.ReplacedWith("Z"), [ "Z", "b", "A", "c", "Z", "b", "b" ]), 1)
	Then("Replaced is the same call", Same(o.Replaced("Z"), [ "Z", "b", "A", "c", "Z", "b", "b" ]), 1)
	Then("ReplacedBy is the same call", Same(o.ReplacedBy("Z"), [ "Z", "b", "A", "c", "Z", "b", "b" ]), 1)
	Then("with case ignored the capital goes too", Same(o.ReplacedWithCS("Z", 0), [ "Z", "b", "Z", "c", "Z", "b", "b" ]), 1)
	Then("ReplacedCS is the same call as ReplacedWithCS", Same(o.ReplacedCS("Z", 0), [ "Z", "b", "Z", "c", "Z", "b", "b" ]), 1)
	Then("Removed drops the occurrences with case", Same(o.Removed(), [ "b", "A", "c", "b", "b" ]), 1)
	Then("with case ignored the capital goes too", Same(o.RemovedCS(0), [ "b", "c", "b", "b" ]), 1)
	Then("the object's list is unchanged", Same(o.List(), aL), 1)
	Then("the caller's list is unchanged", Same(aL, [ "a", "b", "A", "c", "a", "b", "b" ]), 1)
	Then("the item is unchanged", o.Item(), "a")
	Then("the object still counts two", o.NumberOfOccurrence(), 2)
	oAbs = new stzItemCS("z", aL, 1)
	Then("an absent item: ReplacedWith is a copy of the list", Same(oAbs.ReplacedWith("Q"), aL), 1)
	Then("an absent item: Removed is a copy of the list", Same(oAbs.Removed(), aL), 1)
	oN = new stzItemCS(2, [ 1, 2, 3, 2, 5 ], 1)
	Then("numbers: replaced by 9", Same(oN.ReplacedWith(9), [ 1, 9, 3, 9, 5 ]), 1)
	Then("numbers: removed", Same(oN.Removed(), [ 1, 3, 5 ]), 1)
	Then("numbers: the text '2' is not the number 2", Same(StzItemCSQ("2", [ 1, 2, "2" ], 1).Removed(), [ 1, 2 ]), 1)
	oLi = new stzItemCS([ 1, 2 ], [ [ 1, 2 ], "x", [ 1, 2 ], [ 3 ] ], 1)
	Then("a list item: removed", Same(oLi.Removed(), [ "x", [ 3 ] ]), 1)
	Then("a list item: replaced", Same(oLi.ReplacedWith("q"), [ "q", "x", "q", [ 3 ] ]), 1)
	oS = new stzItemCS("שלום", [ "שלום", "عالم", "😀", "שלום" ], 1)
	Then("Hebrew, Arabic and emoji: removed", Same(oS.Removed(), [ "عالم", "😀" ]), 1)
	Then("an emoji item replaced", Same(StzItemCSQ("😀", [ "😀", "x", "😀" ], 1).ReplacedWith("-"), [ "-", "x", "-" ]), 1)
EndScenario()

Scenario("Uppercased and Lowercased put the item in the other case, inside the list")
	aL = [ "ab", "Ab", "AB", "ab" ]
	o = new stzItemCS("ab", aL, 1)
	Then("Uppercased: only the exact occurrences", Same(o.Uppercased(), [ "AB", "Ab", "AB", "AB" ]), 1)
	Then("UppercasedCS(0): every case of it", Same(o.UppercasedCS(0), [ "AB", "AB", "AB", "AB" ]), 1)
	oA = new stzItemCS("Ab", aL, 1)
	Then("Lowercased: only the exact occurrences", Same(oA.Lowercased(), [ "ab", "ab", "AB", "ab" ]), 1)
	Then("LowercasedCS(0): every case of it", Same(oA.LowercasedCS(0), [ "ab", "ab", "ab", "ab" ]), 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
	Then("the caller's list is unchanged", Same(aL, [ "ab", "Ab", "AB", "ab" ]), 1)
	oG = new stzItemCS("ω", [ "ω", "α", "ω" ], 1)
	Then("Greek: omega becomes capital omega, alpha is left", Same(oG.Uppercased(), [ "Ω", "α", "Ω" ]), 1)
	oH = new stzItemCS("שלום", [ "שלום", "x" ], 1)
	Then("Hebrew has no case: the list is a copy", Same(oH.Uppercased(), [ "שלום", "x" ]), 1)
	oN = new stzItemCS(5, [ 5, "a" ], 1)
	Then("a number has no case: the list is a copy, the text beside it is left alone", Same(oN.Uppercased(), [ 5, "a" ]), 1)
	Then("an absent item: a copy", Same(StzItemCSQ("z", [ "a" ], 1).Uppercased(), [ "a" ]), 1)
	Then("the whole list is NOT upper-cased, only the item", Same(StzItemCSQ("a", [ "a", "b" ], 1).Uppercased(), [ "A", "b" ]), 1)
EndScenario()

Scenario("InsertedBefore and InsertedAfter put a new item around each occurrence")
	aL = [ "a", "b", "a", "c" ]
	o = new stzItemCS("a", aL, 1)
	Then("InsertedBefore: before each a", Same(o.InsertedBefore("X"), [ "X", "a", "b", "X", "a", "c" ]), 1)
	Then("InsertedAfter: after each a", Same(o.InsertedAfter("X"), [ "a", "X", "b", "a", "X", "c" ]), 1)
	Then("InsertedBAt is the same call as InsertedBefore", Same(o.InsertedBAt("X"), [ "X", "a", "b", "X", "a", "c" ]), 1)
	Then("InsertedBeforeItem is the same", Same(o.InsertedBeforeItem("X"), [ "X", "a", "b", "X", "a", "c" ]), 1)
	Then("InsertedAfterItem is the same", Same(o.InsertedAfterItem("X"), [ "a", "X", "b", "a", "X", "c" ]), 1)
	Then("the object's list is unchanged", Same(o.List(), aL), 1)
	Then("the caller's list is unchanged", Same(aL, [ "a", "b", "a", "c" ]), 1)
	oEnd = new stzItemCS("c", aL, 1)
	Then("an item at the end: inserted after it, at the very end", Same(oEnd.InsertedAfter("X"), [ "a", "b", "a", "c", "X" ]), 1)
	Then("an item at the end: inserted before it", Same(oEnd.InsertedBefore("X"), [ "a", "b", "a", "X", "c" ]), 1)
	Then("an item at the start: inserted before it, at the very start", Same(o.InsertedBefore("X")[1], "X"), 1)
	Then("an absent item: a copy of the list", Same(StzItemCSQ("z", aL, 1).InsertedBefore("X"), aL), 1)
	oCi = new stzItemCS("a", [ "a", "A" ], 1)
	Then("the correctly spelled InsertedBeforeCS, case ignored", Same(oCi.InsertedBeforeCS("X", 0), [ "X", "a", "X", "A" ]), 1)
	Then("the correctly spelled InsertedBeforeCS, case kept", Same(oCi.InsertedBeforeCS("X", 1), [ "X", "a", "A" ]), 1)
	Then("the correctly spelled InsertedAfterCS, case ignored", Same(oCi.InsertedAfterCS("X", 0), [ "a", "X", "A", "X" ]), 1)
	Then("the correctly spelled InsertedAfterCS, case kept", Same(oCi.InsertedAfterCS("X", 1), [ "a", "X", "A" ]), 1)
	Then("the old misspelling InstertedBeforeCS still works", Same(oCi.InstertedBeforeCS("X", 0), [ "X", "a", "X", "A" ]), 1)
	Then("the old misspelling InstertedAfterCS still works", Same(oCi.InstertedAfterCS("X", 0), [ "a", "X", "A", "X" ]), 1)
	Then("InsertedAtCS is the same call as InsertedBeforeCS", Same(oCi.InsertedAtCS("X", 0), [ "X", "a", "X", "A" ]), 1)
	oF = new stzItemCS("a", [ "A", "a" ], 0)
	Then("the flag 0 given to init reaches InsertedBefore", Same(oF.InsertedBefore("X"), [ "X", "A", "X", "a" ]), 1)
	Then("the flag 1 given to init reaches InsertedBefore", Same(StzItemCSQ("a", [ "A", "a" ], 1).InsertedBefore("X"), [ "A", "X", "a" ]), 1)
	oN = new stzItemCS(2, [ 1, 2, 3 ], 1)
	Then("numbers: before", Same(oN.InsertedBefore(0), [ 1, 0, 2, 3 ]), 1)
	Then("numbers: after", Same(oN.InsertedAfter(0), [ 1, 2, 0, 3 ]), 1)
	Then("a list inserted as one item", Same(oN.InsertedBefore([ 7, 8 ]), [ 1, [ 7, 8 ], 2, 3 ]), 1)
	Then("the new item may equal the followed item", Same(StzItemCSQ("a", [ "a", "b" ], 1).InsertedBefore("a"), [ "a", "a", "b" ]), 1)
EndScenario()

Scenario("InsertedBeforeItems and InsertedAfterItems put several items in order")
	aL = [ "a", "b", "a" ]
	o = new stzItemCS("a", aL, 1)
	Then("before each a, in the order given", Same(o.InsertedBeforeItems([ "X", "Y" ]), [ "X", "Y", "a", "b", "X", "Y", "a" ]), 1)
	Then("after each a, in the order given", Same(o.InsertedAfterItems([ "X", "Y" ]), [ "a", "X", "Y", "b", "a", "X", "Y" ]), 1)
	Then("InsertedBeforeManyItems is the same call", Same(o.InsertedBeforeManyItems([ "X", "Y" ]), [ "X", "Y", "a", "b", "X", "Y", "a" ]), 1)
	Then("InsertedAfterManyItems is the same call", Same(o.InsertedAfterManyItems([ "X", "Y" ]), [ "a", "X", "Y", "b", "a", "X", "Y" ]), 1)
	Then("one item in a list is the same as the single-item form", Same(o.InsertedBeforeItems([ "X" ]), o.InsertedBeforeItem("X")), 1)
	Then("one item in a list is the same as the single-item form, after", Same(o.InsertedAfterItems([ "X" ]), o.InsertedAfterItem("X")), 1)
	Then("an empty list inserts nothing", Same(o.InsertedBeforeItems([]), aL), 1)
	Then("the new items may include the followed item", Same(StzItemCSQ("a", [ "a", "b" ], 1).InsertedAfterItems([ "a", "a" ]), [ "a", "a", "a", "b" ]), 1)
	oCi = new stzItemCS("a", [ "a", "A" ], 1)
	Then("case ignored", Same(oCi.InsertedBeforeItemsCS([ "X", "Y" ], 0), [ "X", "Y", "a", "X", "Y", "A" ]), 1)
	Then("case kept", Same(oCi.InsertedBeforeItemsCS([ "X", "Y" ], 1), [ "X", "Y", "a", "A" ]), 1)
	Then("InsertedAfterItemsCS, case ignored", Same(oCi.InsertedAfterItemsCS([ "X", "Y" ], 0), [ "a", "X", "Y", "A", "X", "Y" ]), 1)
	Then("InsertedBeforeItemCS, case ignored", Same(oCi.InsertedBeforeItemCS("X", 0), [ "X", "a", "X", "A" ]), 1)
	Then("InsertedAfterItemCS, case ignored", Same(oCi.InsertedAfterItemCS("X", 0), [ "a", "X", "A", "X" ]), 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
	Then("the caller's list is unchanged", Same(aL, [ "a", "b", "a" ]), 1)
	bRaised = 0
	try
		o.InsertedBeforeItems("X")
	catch
		bRaised = 1
	done
	Then("a text where a list of items is expected is refused", bRaised, 1)
EndScenario()

Scenario("InsertedBeforePosition(s) and InsertedAfterPosition(s) put the followed item at positions")
	aL = [ "x", "y", "z" ]
	o = new stzItemCS("a", aL, 1)
	Then("before position 3", Same(o.InsertedBeforePosition(3), [ "x", "y", "a", "z" ]), 1)
	Then("before position 1", Same(o.InsertedBeforePosition(1), [ "a", "x", "y", "z" ]), 1)
	Then("after position 1", Same(o.InsertedAfterPosition(1), [ "x", "a", "y", "z" ]), 1)
	Then("after position 3, the last: appended", Same(o.InsertedAfterPosition(3), [ "x", "y", "z", "a" ]), 1)
	Then("InsertedAtPosition is the same call as InsertedBeforePosition", Same(o.InsertedAtPosition(3), [ "x", "y", "a", "z" ]), 1)
	Then("position 0 changes nothing", Same(o.InsertedBeforePosition(0), aL), 1)
	Then("a position far beyond the list changes nothing", Same(o.InsertedBeforePosition(9), aL), 1)
	Then("after a position far beyond the list changes nothing", Same(o.InsertedAfterPosition(9), aL), 1)
	Then("the position just past the end is appended to by the Before form", Same(o.InsertedBeforePosition(4), [ "x", "y", "z", "a" ]), 1)
	Then("the position just past the end is not a position for the After form", Same(o.InsertedAfterPosition(4), aL), 1)
	Then("two past the end no longer kills the process (stzList raises R14 there)", Same(o.InsertedBeforePosition(5), aL), 1)
	Then("a text where a position is expected changes nothing", Same(o.InsertedBeforePosition("x"), aL), 1)
	Then("before positions 1 and 3", Same(o.InsertedBeforePositions([ 1, 3 ]), [ "a", "x", "y", "a", "z" ]), 1)
	Then("after positions 1 and 3, the last one included", Same(o.InsertedAfterPositions([ 1, 3 ]), [ "x", "a", "y", "z", "a" ]), 1)
	Then("the order the positions are given in does not matter", Same(o.InsertedBeforePositions([ 3, 1 ]), [ "a", "x", "y", "a", "z" ]), 1)
	Then("InsertedAtPositions is the same call", Same(o.InsertedAtPositions([ 1, 3 ]), [ "a", "x", "y", "a", "z" ]), 1)
	Then("InsertedBeforeManyPositions is the same call", Same(o.InsertedBeforeManyPositions([ 1, 3 ]), [ "a", "x", "y", "a", "z" ]), 1)
	Then("InsertedAfterManyPositions is the same call", Same(o.InsertedAfterManyPositions([ 1, 3 ]), [ "x", "a", "y", "z", "a" ]), 1)
	Then("an empty list of positions changes nothing", Same(o.InsertedBeforePositions([]), aL), 1)
	Then("the After form really inserts AFTER (it used to be the Before form)",
		Same(o.InsertedAfterPosition(2), [ "x", "y", "a", "z" ]), 1)
	Then("the Before form at the same position differs", Same(o.InsertedBeforePosition(2), [ "x", "a", "y", "z" ]), 1)
	Then("the object's list is unchanged", Same(o.List(), aL), 1)
	Then("the caller's list is unchanged", Same(aL, [ "x", "y", "z" ]), 1)
	Then("a number item", Same(StzItemCSQ(7, [ 1, 2 ], 1).InsertedBeforePosition(2), [ 1, 7, 2 ]), 1)
EndScenario()

Scenario("InsertedBeforeW and InsertedAfterW put the followed item around the items that meet a condition")
	aL = [ "a", "b", "a", "c" ]
	o = new stzItemCS("X", aL, 1)
	Then("before each a", Same(o.InsertedBeforeW('{ @item = "a" }'), [ "X", "a", "b", "X", "a", "c" ]), 1)
	Then("after each a (it used to insert BEFORE)", Same(o.InsertedAfterW('{ @item = "a" }'), [ "a", "X", "b", "a", "X", "c" ]), 1)
	Then("InsertedAtW is the same call as InsertedBeforeW", Same(o.InsertedAtW('{ @item = "a" }'), [ "X", "a", "b", "X", "a", "c" ]), 1)
	Then("a condition nothing meets changes nothing", Same(o.InsertedBeforeW('{ @item = "zz" }'), aL), 1)
	Then("the list is unchanged", Same(o.List(), aL), 1)
EndScenario()

Scenario("Passive forms never touch the object (a sweep over every *ed form)")
	aL = [ "a", "b", "a", "c" ]
	o = new stzItemCS("a", aL, 1)
	o.Sections()
	o.BoundedBy([ "<", ">" ])
	o.ReplacedWith("Z")
	o.Removed()
	o.Uppercased()
	o.Lowercased()
	o.InsertedBefore("X")
	o.InsertedAfter("X")
	o.InsertedBeforeItems([ "X", "Y" ])
	o.InsertedAfterItems([ "X", "Y" ])
	o.InsertedBeforePosition(2)
	o.InsertedAfterPositions([ 1, 2 ])
	Then("after twelve passive calls the list is as given", Same(o.List(), [ "a", "b", "a", "c" ]), 1)
	Then("the item is as given", o.Item(), "a")
	Then("the flag is as given", o.CaseSensitive(), 1)
	Then("the object still finds its positions", Same(o.Positions(), [ 1, 3 ]), 1)
EndScenario()

Scenario("Known limits that stay documented rather than fixed")
	bRaised = 0
	cMsg = ""
	try
		ItemQ("a")
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("ItemQ still raises: it builds the class stzSItem, which does not exist", bRaised, 1)
	Then("and says which class is missing", StzFindFirst("stzsitem", lower(cMsg)) > 0, 1)
	bRaised = 0
	cMsg = ""
	try
		StzItemQ("an", "banana").Positions()
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("a stzItem (an item in a TEXT) still cannot answer a list method", bRaised, 1)
	Then("it says the list must be a list", StzFindFirst("must be a list", cMsg) > 0, 1)
	Then("but its accessors work", StzItemQ("an", "banana").Item(), "an")
EndScenario()

Summary()

func Same(aA, aB)
	if @@(aA) = @@(aB)
		return 1
	ok
	? "    SAME? left:  " + @@(aA)
	? "          right: " + @@(aB)
	return 0
