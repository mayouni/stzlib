load "../../stzBase.ring"
load "../_narrated.ring"

# The same with a same-string bound (the overlap walk). Archive block #562.

Scenario("Star-bounded words")
	o1 = new stzString("my **word** and your **word**")
	Then("their content starts",
		ListEq( o1.FindSubStringBoundedBy("word", [ "**", "**" ]), [6, 24] ), TRUE)
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
