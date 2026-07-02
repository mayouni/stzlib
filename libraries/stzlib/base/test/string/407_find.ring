load "../../stzBase.ring"
load "../_narrated.ring"

# Finding decimal prices: positions, sections, and the sorted multi-needle
# FindManyAsSections. Archive block #407.

Scenario("Finding prices in a receipt")
	Given('"book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12"')
	o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")
	Then("the positions of 12.34", ListEq( o1.Find("12.34"), [ 7, 39 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindAsSections("12.34"), [ [7, 11], [39, 43] ] ), TRUE)
	Then("all three prices' sections, sorted",
		ListEq( o1.FindManyAsSections([ "12.34", "-56.30", "77.12" ]),
			[ [7, 11], [21, 26], [39, 43], [55, 59] ] ), TRUE)
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
