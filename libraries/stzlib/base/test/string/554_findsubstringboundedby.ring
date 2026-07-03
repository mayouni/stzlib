load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringBoundedBy with a single-char bound and its FindXT
# :BoundedBy spellings (string or pair). Archive block #554.

Scenario("Hearts between stars")
	o1 = new stzString("12*♥*78*♥*")
	Then("the bounded hearts",
		ListEq( o1.FindSubStringBoundedBy("♥", "*"), [ 4, 9 ] ), TRUE)
	Then("the FindXT string spelling",
		ListEq( o1.FindXT("♥", :BoundedBy = "*" ), [ 4, 9 ] ), TRUE)
	Then("the FindXT pair spelling",
		ListEq( o1.FindXT("♥", :BoundedBy = [ "*", "*" ] ), [ 4, 9 ] ), TRUE)
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
