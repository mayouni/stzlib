load "../../stzBase.ring"
load "../_narrated.ring"

# A full pipeline: SubStringsBoundedByIBZZ pairs each bound-inclusive
# substring with its span; a stzHashList splits them into keys (substrings)
# and values (spans); the unspaced keys are filtered with the list W-DSL;
# and the surviving spans are unspaced in the host string.
# Archive block #302.

Scenario("Bounded substrings piped through a hash list and W filter")
	Given('"r  in  g language is like a r  ing at your fingertips!"')
	o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")
	acSubStrXT = o1.SubStringsBoundedByIBZZ([ "r","g" ])
	Then("each r..g region pairs with its span",
		ListEq( acSubStrXT,
			[ [ "r  in  g", [1,8] ], [ "r  ing", [29,34] ], [ "r fing", [42,47] ] ] ), TRUE)
	oHashList = QRT(acSubStrXT, :stzHashList)
	acWithoutSpaces = oHashList.KeysQRT(:stzListOfStrings).WithoutSapces()
	Then("the keys, unspaced (misspelled WithoutSapces accepted)",
		ListEq( acWithoutSpaces, [ "ring", "ring", "rfing" ] ), TRUE)
	aSectionsPos = Q(acWithoutSpaces).FindW('This[@i] = "ring"')
	Then("the W filter keeps the two real rings",
		ListEq( aSectionsPos, [ 1, 2 ] ), TRUE)
	aSections = oHashList.ValuesQ().ItemsAtPositions(aSectionsPos)
	Then("their spans come back from the hash-list values",
		ListEq( aSections, [ [ 1, 8 ], [ 29, 34 ] ] ), TRUE)
	o1.RemoveSpacesInSections(aSections)
	Then("only those regions are unspaced",
		o1.Content(), "ring language is like a ring at your fingertips!")
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
