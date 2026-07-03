load "../../stzBase.ring"
load "../_narrated.ring"

# The previous-nth marquer: string, position, and Z forms.
# Archive block #616.

Scenario("Third marquer back from 50")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("the marquer", o1.PreviousNthMarquer(3, :StartingAt = 50), "#1")
	Then("its position", o1.FindPreviousNthMarquer(3, :StartingAt = 50), 12)
	Then("the Z pair",
		ListEq( o1.PreviousNthMarquerZ(3, :StartingAt = 50), [ "#1", 12 ] ), TRUE)
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
