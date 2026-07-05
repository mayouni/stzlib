load "../../stzBase.ring"
load "../_narrated.ring"

# Objects start unnamed (@noname); SetVarName names one afterward, or
# the :name = value form names it at birth. Named objects become
# findable inside a list, grouped by name.
# Extracted from stznamedvarstest.ring, block #13.

Scenario("Naming objects and making them findable")
	oGreeting = new stzString("Hi!")
	Then("born nameless", oGreeting.VarName(), "@noname")
	oGreeting.SetVarName(:oGreeting)
	Then("named afterward", oGreeting.VarName(), "ogreeting")
	oHello = new stzString(:oHello = "Hello Ring!")
	Then("named at birth", oHello.VarName(), "ohello")
	o1 = new stzList([ "one", oGreeting, 12, oGreeting, Q("two"), oHello, 10 , Q(10) ])
	Then("the object positions",
		ListEq( o1.FindObjects(), [ 2, 4, 5, 6, 8 ] ), TRUE)
	Then("grouped by name",
		ListEq( o1.ObjectsZ(),
			[ [ "ogreeting", [ 2, 4 ] ], [ "@noname", [ 5, 8 ] ], [ "ohello", [ 6 ] ] ] ), TRUE)
	Then("find one by name",
		ListEq( o1.FindObject(:oGreeting), [ 2, 4 ] ), TRUE)
	Then("find the other",
		ListEq( o1.FindObject(:oHello), [ 6 ] ), TRUE)
	Then("the named ones",
		ListEq( o1.FindNamedObjects(), [ 2, 4, 6 ] ), TRUE)
	Then("the unnamed ones",
		ListEq( o1.FindUnnamedObjects(), [ 5, 8 ] ), TRUE)
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
