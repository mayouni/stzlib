load "../../stzBase.ring"
load "../_narrated.ring"

# Counting and locating occurrences with the named spellings, plus the
# two faces of Sections() (of a substring -> spans; of spans -> their
# substrings) and the bounded-occurrences counter. Archive block #529.

Scenario("Counting many")
	o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")
	Then("five occurrences", o1.NumberOfOccurrence(:OfSubString = "many"), 5)
	Then("their positions",
		ListEq( o1.Positions(:of = "many"), [5, 12, 33, 40, 54] ), TRUE)
	Then("their sections",
		ListEq( o1.Sections(:Of = "many"),
			[ [5, 8], [12, 15], [33, 36], [40, 43], [54, 57] ] ), TRUE)
	Then("sections of spans give the substrings",
		ListEq( o1.Sections([ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ] ]),
			[ "many", "many", "many" ] ), TRUE)
	Then("three of them are << >>-bounded",
		o1.NumberOfOccurrenceXT(
			:OfSubString = "many",
			:BoundedBy = [ "<<", :and = ">>" ]), 3)
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
