load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthPreviousMarquer and the nearest-previous Z pair.
# Archive block #617.

Scenario("First marquer back from 50")
	CheckparamsOff()
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("its position", o1.FindNthPreviousMarquer(1, 50), 44)
	Then("the Z pair",
		ListEq( o1.PreviousMarquerZ(50), [ "#3", 44 ] ), TRUE)
	CheckParamsOn()
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
