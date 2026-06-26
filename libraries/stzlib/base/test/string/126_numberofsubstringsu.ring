load "../../stzBase.ring"
load "../_narrated.ring"

# The U-variants return the UNIQUE substrings (deduplicated). "BEBE" has 7 unique
# substrings. Archive block #126.

Scenario("Unique substrings of a string")
	Given('"BEBE"')
	o1 = new stzString("BEBE")
	Then("there are 7 unique substrings", o1.NumberOfSubStringsU(), 7)
	Then("they are listed without duplicates",
		ListEq( o1.SubStringsU(), [ "B", "BE", "BEB", "BEBE", "E", "EB", "EBE" ] ), TRUE)
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
