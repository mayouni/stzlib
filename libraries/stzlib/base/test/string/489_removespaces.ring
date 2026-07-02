load "../../stzBase.ring"
load "../_narrated.ring"

# A two-step chain and its QH history (RemoveSpaces + Uppercase are both
# history-aware). Archive block #489.

Scenario("Cleaning and shouting hello")
	Then("the chain result",
		Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content(), "HELLO")
	Then("the captured steps",
		ListEq( QH("h e l l o").RemoveSpacesQ().UppercaseQ().History(),
			[ "h e l l o", "hello", "HELLO" ] ), TRUE)
	DontKeepHistory()
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
