load "../../stzBase.ring"
load "../_narrated.ring"

# SubstringsBoundedBy with a single-char bound -- the non-overlapping
# token scan that powers constraint strings. Archive block #864.

Scenario("Reading the constraint numbers")
	o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
	Then("three bounded pieces",
		ListEq( o1.SubstringsBoundedBy("@"),
			[ "32", "CharsAnd", "8" ] ), TRUE)
	o2 = new stzString("MustHave32CharsAnd8Spaces")
	Then("no bounds, no pieces",
		len( o2.SubstringsBoundedBy("@") ), 0)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
