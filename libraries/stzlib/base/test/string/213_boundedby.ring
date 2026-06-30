load "../../stzBase.ring"
load "../_narrated.ring"

# A single repeated bound "&" keeps the in-between gaps (overlapping pairing),
# and BoundedByIB widens the single bound to ["&","&"] and includes the bounds.
# Archive block #213.

Scenario("Substrings bounded by a single & marker")
	Given('"...&^^^&...&vvv&...&..."')
	o1 = new stzString("...&^^^&...&vvv&...&...")
	Then("BoundedBy keeps all the gaps",
		ListEq( o1.BoundedBy("&"), [ "^^^", "...", "vvv", "..." ] ), TRUE)
	Then("BoundedByIB includes the bounds",
		ListEq( o1.BoundedByIB("&"), [ "&^^^&", "&...&", "&vvv&", "&...&" ] ), TRUE)
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
