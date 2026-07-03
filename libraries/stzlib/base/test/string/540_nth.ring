load "../../stzBase.ring"
load "../_narrated.ring"

# Nth(n, sub): the position of the n-th occurrence; NthAsSection its
# span. Archive block #540.

Scenario("The second word")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	Then("its position", o1.Nth(2, "word"), 30)
	Then("its section", ListEq( o1.NthAsSection(2, "word"), [ 30, 33 ] ), TRUE)
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
