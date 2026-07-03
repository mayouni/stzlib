load "../../stzBase.ring"
load "../_narrated.ring"

# Sit with a CONDITIONAL harvest: :CharsBeforeW takes the maximal run of
# chars satisfying the W predicate ("is a number" lowers to the engine's
# isDigit in char context). Archive block #538 (was a #TODO -- now live).

Scenario("Harvesting the digits before nice")
	o1 = new stzString("what a 123nice>>> day!")
	Then("the digit run and 3 chars after",
		ListEq( o1.Sit(
			:OnSection  = o1.FindFirstAsSection("nice"),
			:AndHarvest = [ :CharsBeforeW = 'Q(@char).IsANumber()', :NCharsAfter = 3 ]
		), [ "123", ">>>" ] ), TRUE)
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
