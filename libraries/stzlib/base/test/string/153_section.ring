load "../../stzBase.ring"
load "../_narrated.ring"

# Section(a, b) on a list -- the list counterpart of block #152, also
# bound-order independent. Archive block #153.

Scenario("A list section is bound-order independent")
	Given('new stzList([ "s","o","f","t","a","n","z","a" ])')
	o1 = new stzList([ "s", "o", "f", "t", "a", "n", "z", "a" ])
	Then("Section(4, 6) is [t,a,n]", ListEq( o1.Section(4, 6), [ "t", "a", "n" ] ), TRUE)
	Then("Section(6, 4) auto-orders to the same", ListEq( o1.Section(6, 4), [ "t", "a", "n" ] ), TRUE)
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
