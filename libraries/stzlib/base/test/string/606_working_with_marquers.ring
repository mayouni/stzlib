load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsMarquers needs a digit after #; Marquers lists them in order.
# Archive block #606.

Scenario("Detecting marquers")
	Then("a lone # is not one", StzStringQ("My name is #.").ContainsMarquers(), FALSE)
	Then("#0 is", StzStringQ("My name is #0.").ContainsMarquers(), TRUE)
	Then("#1 is", StzStringQ("My name is #1.").ContainsMarquers(), TRUE)
	Then("#01 is", StzStringQ("My name is #01.").ContainsMarquers(), TRUE)
	Then("all three, in order",
		ListEq( Q("bla #0 bla bla #1 bla #2 blabla").Marquers(),
			[ "#0", "#1", "#2" ] ), TRUE)
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
