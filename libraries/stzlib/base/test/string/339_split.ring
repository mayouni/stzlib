load "../../stzBase.ring"
load "../_narrated.ring"

# Same chain as block #338, with the condition spelled using the This.
# prefix ('This.NumberOfItems() > 2') -- both spellings are accepted.
# Archive block #339.

Scenario("Conditional fluent chain, This-prefixed condition")
	Given('"**aa***aa**aa***"')
	o1 = new stzString("**aa***aa**aa***")
	Then("the middle parts survive the IfQ gate",
		ListEq( o1.SplitQ("aa").IfQ('This.NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content(),
			[ "***", "**" ] ), TRUE)
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
