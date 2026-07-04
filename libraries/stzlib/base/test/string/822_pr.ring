load "../../stzBase.ring"
load "../_narrated.ring"

# Find feeding InsertBeforePositions. Archive block #822.

Scenario("Underscoring every in")
	o1 = new stzString("Ring programming language")
	anPos = o1.Find("in")
	Then("two ins",
		ListEq( anPos, [ 2, 14 ] ), TRUE)
	o1.InsertBeforePositions(anPos, "_")
	Then("both marked", o1.Content(), "R_ing programm_ing language")
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
