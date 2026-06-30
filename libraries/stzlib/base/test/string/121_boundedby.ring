load "../../stzBase.ring"
load "../_narrated.ring"

# A single repeated bound pairs its occurrences OVERLAPPINGLY, so every gap is
# kept: BoundedBy("aa") on "aa***aa**aa***aa" returns the three consecutive gaps.
# Archive block #121.

Scenario("Substrings bounded by a repeated marker keep the middle gaps")
	Given('"aa***aa**aa***aa"')
	o1 = new stzString("aa***aa**aa***aa")
	Then("BoundedBy('aa') keeps all three gaps",
		ListEq( o1.BoundedBy("aa"), [ "***", "**", "***" ] ), TRUE)
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
