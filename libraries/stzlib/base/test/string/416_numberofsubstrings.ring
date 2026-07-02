load "../../stzBase.ring"
load "../_narrated.ring"

# Filtering the 55 windows of a noisy string down to the letter-made ones
# with the WF (anonymous-function) form -- IsMadeOfLetters is beyond the
# engine W-DSL. Archive block #416.

Scenario("Letter-made substrings via WF")
	Given('"*#!ABC$^.."')
	o1 = new stzString("*#!ABC$^..")
	Then("all windows", o1.NumberOfSubStrings(), 55)
	Then("the letter-made ones",
		ListEq( o1.SubStringsWF( func s { return Q(s).IsMadeOfLetters() } ),
			[ "A", "AB", "ABC", "B", "BC", "C" ] ), TRUE)
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
