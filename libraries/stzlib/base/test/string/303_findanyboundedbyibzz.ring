load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByIBZZ returns the bound-INCLUSIVE spans of the regions
# enclosed by [open, close]; SubStringsBoundedByIB gives those substrings,
# here piped through the (deliberately misspelled, still accepted)
# WithoutSapces(). Archive block #303.

Scenario("Bound-inclusive spans and their unspaced substrings")
	Given('"   r  in  g  is a rin  g  " (r..g regions at 4-11 and 19-24)')
	o1 = new stzString("   r  in  g  is a rin  g  ")
	Then("the IB spans include the bounds",
		ListEq( o1.FindAnyBoundedByIBZZ([ "r", "g" ]), [ [4,11], [19,24] ] ), TRUE)
	Then("the unspaced substrings both read 'ring'",
		ListEq( QRT( o1.SubStringsBoundedByIB([ "r","g" ]), :stzListOfStrings).WithoutSapces(),
			[ "ring", "ring" ] ), TRUE)
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
