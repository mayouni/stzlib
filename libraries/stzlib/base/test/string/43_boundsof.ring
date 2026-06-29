load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsOf gives the full bound runs around each occurrence; BoundsOfXT with
# :UpToNChars caps each side. Archive block #43.

Scenario("BoundsOf and its capped XT form")
	Given('"Hello <<<Ring>>>, the beautiful (((Ring)))!"')
	o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
	Then("BoundsOf returns the full bound runs per occurrence",
		ListEq( o1.BoundsOf("Ring"), [ [ "<<<", ">>>" ], [ "(((", ")))" ] ] ), TRUE)
	Then("BoundsOfXT(:UpToNChars=2) caps each side to 2 chars",
		ListEq( o1.BoundsOfXT("Ring", :UpToNChars = 2), [ [ "<<", ">>" ], [ "((", "))" ] ] ), TRUE)
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
