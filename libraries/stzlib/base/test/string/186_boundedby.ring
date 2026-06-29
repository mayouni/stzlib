load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedBy([open, close]) -- the substrings enclosed by the bounds, plus the
# U (unique) and IB (include-bounds) variants. Archive #186.

Scenario("Extracting substrings bounded by << >>")
	Given('"<<♥♥♥>>--<<stars>>--<<♥♥♥>>"')
	o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")
	Then("BoundedBy gives the three enclosed substrings",
		ListEq( o1.BoundedBy([ "<<", ">>" ]), [ "♥♥♥", "stars", "♥♥♥" ] ), TRUE)
	Then("BoundedByU keeps only the unique ones",
		ListEq( o1.BoundedByU([ "<<", ">>" ]), [ "♥♥♥", "stars" ] ), TRUE)
	Then("BoundedByIB includes the bounds",
		ListEq( o1.BoundedByIB([ "<<", ">>" ]), [ "<<♥♥♥>>", "<<stars>>", "<<♥♥♥>>" ] ), TRUE)
	Then("BoundedByIBU is unique AND includes the bounds",
		ListEq( o1.BoundedByIBU([ "<<", ">>" ]), [ "<<♥♥♥>>", "<<stars>>" ] ), TRUE)
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
