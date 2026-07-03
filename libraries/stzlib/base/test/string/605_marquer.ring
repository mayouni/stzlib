load "../../stzBase.ring"
load "../_narrated.ring"

# The marquer SYMBOL, the IsMarquer check, and Marquers() returning the
# "#N" strings (the archive showed the bare digits -- the sibling blocks
# #606-#608 pin the #-prefixed shape). Archive block #605.

Scenario("What a marquer is")
	Then("the symbol", Q("...").Marquer(), "#")
	Then("#12500 is one", Q("#12500").IsMarquer(), TRUE)
	Then("... and lists itself",
		ListEq( Q("#12500").Marquers(), [ "#12500" ] ), TRUE)
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
