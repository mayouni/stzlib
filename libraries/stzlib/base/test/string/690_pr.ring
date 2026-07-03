load "../../stzBase.ring"
load "../_narrated.ring"

# Operators on stzString: [n] reads a char, [substring] finds its
# positions, [:First]/[:Last] are keywords. (The archive also compared
# with = -- the impl deliberately has no = operator, per its own
# warning about the stzExtCode conflict; asserted via Content().)
# Archive block #690.

Scenario("Square brackets, two readings")
	o1 = new stzString("SOFTANZA")
	Then("a number reads the char", o1[5], "A")
	Then("a substring finds its positions",
		ListEq( o1["A"], [ 5, 8 ] ), TRUE)
	Then("... of any length",
		ListEq( o1["NZA"], [ 6 ] ), TRUE)
	Then(":First and :Last as keywords",
		o1[:First] + o1[:Last], "SA")
	Then("compared through Content()",
		o1.Content() = StringUppercase("softanza"), TRUE)
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
