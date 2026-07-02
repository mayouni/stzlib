load "../../stzBase.ring"
load "../_narrated.ring"

# The full numbers surface on a price list: all occurrences, the unique
# set, the starts, the sections, and the Z / ZZ groupings (each unique
# number with its positions / sections). Archive block #429.

Scenario("Prices in a receipt")
	Given('"book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12"')
	o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")
	Then("all numbers",
		ListEq( o1.Numbers(), [ "12.34", "-56.30", "12.34", "77.12" ] ), TRUE)
	Then("the unique numbers",
		ListEq( o1.UniqueNumbers(), [ "12.34", "-56.30", "77.12" ] ), TRUE)
	Then("the starts", ListEq( o1.FindNumbers(), [ 7, 21, 39, 55 ] ), TRUE)
	Then("the sections",
		ListEq( o1.FindNumbersZZ(), [ [7, 11], [21, 26], [39, 43], [55, 59] ] ), TRUE)
	Then("the Z grouping",
		ListEq( o1.NumbersZ(),
			[ [ "12.34", [ 7, 39 ] ], [ "-56.30", [ 21 ] ], [ "77.12", [ 55 ] ] ] ), TRUE)
	Then("the ZZ grouping",
		ListEq( o1.NumbersZZ(),
			[ [ "12.34", [ [7, 11], [39, 43] ] ],
			  [ "-56.30", [ [21, 26] ] ],
			  [ "77.12", [ [55, 59] ] ] ] ), TRUE)
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
