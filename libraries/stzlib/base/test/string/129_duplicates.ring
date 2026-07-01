load "../../stzBase.ring"
load "../_narrated.ring"

# Duplicates() returns every duplicated SUBSTRING (not just chars), deduped, in
# scan order -- so "RINGORIALAND" includes the multi-char "RI". Archive block #129.

Scenario("The duplicated substrings of a string")
	Given('"RINGORIALAND"')
	o1 = new stzString("RINGORIALAND")
	Then("Duplicates includes multi-char runs like 'RI'",
		ListEq( o1.Duplicates(), [ "R", "RI", "I", "N", "A" ] ), TRUE)
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
