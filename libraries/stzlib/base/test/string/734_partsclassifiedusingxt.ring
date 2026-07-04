load "../../stzBase.ring"
load "../_narrated.ring"

# PartsClassifiedUsingXT groups the parts by their partitioner value.
# Archive block #734.

Scenario("Classifying a sentence by script")
	o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
	Then("three classes, in first-seen order",
		ListEq( o1.PartsClassifiedUsingXT( 'StzCharQ(@char).Script()' ),
		[
			[ "latin", [ "Hanine", "is", "a", "nice", "years", "old", "girl" ] ],
			[ "common", [ " ", " ", " ", " ", " ", " ", " 7 ", "-", " ", " ", "!" ] ],
			[ "arabic", [ "حنين", "جميلة", "وعمرها", "سنوات" ] ]
		] ), TRUE)
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
