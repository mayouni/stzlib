load "../../stzBase.ring"
load "../_narrated.ring"

# Finding a substring INSIDE bounded regions: FindSubStringsBoundedBy /
# FindSubStringBoundedBy / FindXT(:BoundedBy) all return the substring's
# start positions; the AsSections twins return its spans; and the
# :BoundedByIB forms anchor at the opener and span the whole region
# including both bounds. Archive block #346.

Scenario("Bounded finds anchored at the substring")
	Given('"12♥♥♥67♥♥♥12♥♥♥67" (hearts at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("any substring bounded by 67..12",
		ListEq( o1.FindSubStringsBoundedBy([ "67", :And = "12" ]), [ 8 ] ), TRUE)
	Then("the hearts bounded by 67..12",
		ListEq( o1.FindSubStringBoundedBy("♥♥♥", [ "67", :And = "12" ]), [ 8 ] ), TRUE)
	Then("the FindXT spelling",
		ListEq( o1.FindXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]), [ 8 ] ), TRUE)
	Then("its section",
		ListEq( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]), [ [8, 10] ] ), TRUE)
	Then("the IB section spans bounds too",
		ListEq( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "67", :And = "12" ]), [ [6, 12] ] ), TRUE)
	Then("the reversed bounds find both hearts",
		ListEq( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "12", :And = "67" ]),
			[ [3, 5], [13, 15] ] ), TRUE)
	Then("... and their IB spans",
		ListEq( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "12", "67" ]),
			[ [1, 7], [11, 17] ] ), TRUE)
EndScenario()

Scenario("Positions of the IB forms")
	Given('the same string')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("content positions",
		ListEq( o1.FindXT( "♥♥♥", :BoundedBy = ["12", :And = "67" ]), [ 3, 13 ] ), TRUE)
	Then("IB positions anchor at the openers",
		ListEq( o1.FindXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]), [ 1, 11 ] ), TRUE)
	Then("IB sections",
		ListEq( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]),
			[ [1, 7], [11, 17] ] ), TRUE)
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
