load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy: the content START positions of the bounded regions.
# Archive block #550.

Scenario("Two bounded words")
	o1 = new stzString("txt <<ring>> txt <<php>>")
	Then("the content starts",
		ListEq( o1.FindAnyBoundedBy([ "<<",">>" ]), [7, 20] ), TRUE)
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
