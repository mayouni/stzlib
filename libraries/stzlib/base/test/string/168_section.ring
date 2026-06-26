load "../../stzBase.ring"
load "../_narrated.ring"

# Section(:From = a, :To = b) -- the span delimited by the first 'a' and the next
# 'b' (inclusive). Works on the string and on its char-list. Archive block #168.

Scenario("A section delimited by chars")
	Then("Section(:From='F', :To='A') of SOFTANZA is 'FTA'",
		Q("SOFTANZA").Section(:From = "F", :To = "A"), "FTA")
	Then("the same on a char-list",
		ListEq( Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A"), [ "F", "T", "A" ] ), TRUE)
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
