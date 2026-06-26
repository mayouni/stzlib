load "../../stzBase.ring"
load "../_narrated.ring"

# Splitting a string into halves. On odd length, FirstHalf rounds down and the
# XT forms round up. Halves returns both. Archive block #240.

Scenario("Halving an odd-length string")
	Given('"123456789"')
	o1 = new stzString("123456789")
	Then("FirstHalf rounds down", o1.FirstHalf(), "1234")
	Then("SecondHalf is the rest", o1.SecondHalf(), "56789")
	Then("Halves returns both", ListEq( o1.Halves(), [ "1234", "56789" ] ), TRUE)
	Then("FirstHalfXT rounds up", o1.FirstHalfXT(), "12345")
	Then("SecondHalfXT is the rest", o1.SecondHalfXT(), "6789")
	Then("HalvesXT returns both", ListEq( o1.HalvesXT(), [ "12345", "6789" ] ), TRUE)
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
