load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy on a flat string. Archive block #699.

Scenario("Reading the bracketed codes")
	o1 = new stzString("amd[bmi]kmc[ddi]kc")
	Then("two codes",
		ListEq( o1.SubStringsBoundedBy([ "[", "]" ]),
			[ "bmi", "ddi" ] ), TRUE)
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
