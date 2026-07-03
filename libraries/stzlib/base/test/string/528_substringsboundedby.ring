load "../../stzBase.ring"
load "../_narrated.ring"

# SubstringsBoundedBy with the inline [ open, :And = close ] spelling,
# and its U (unique) variant. Archive block #528.

Scenario("Bounded words, all and unique")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	Then("every bounded substring",
		ListEq( o1.SubstringsBoundedBy([ "<<", :and = ">>" ]),
			[ "word", "noword", "word" ] ), TRUE)
	Then("the unique set",
		ListEq( o1.SubStringsBoundedByU([ "<<", :and = ">>" ]),
			[ "word", "noword" ] ), TRUE)
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
