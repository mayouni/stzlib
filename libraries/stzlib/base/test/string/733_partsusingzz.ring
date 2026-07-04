load "../../stzBase.ring"
load "../_narrated.ring"

# PartsUsingZZ over a bilingual sentence, partitioned by CharCase --
# each part zipped with its section. Archive block #733.

Scenario("Case runs of a bilingual sentence")
	o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
	Then("fifteen zipped parts",
		ListEq( o1.PartsUsingZZ( 'StzCharQ(This[@i]).CharCase()' ),
		[
			[ "H", [ 1, 1 ] ],
			[ "anine", [ 2, 6 ] ],
			[ " حنين ", [ 7, 12 ] ],
			[ "is", [ 13, 14 ] ],
			[ " ", [ 15, 15 ] ],
			[ "a", [ 16, 16 ] ],
			[ " ", [ 17, 17 ] ],
			[ "nice", [ 18, 21 ] ],
			[ " جميلة وعمرها 7 ", [ 22, 37 ] ],
			[ "years", [ 38, 42 ] ],
			[ "-", [ 43, 43 ] ],
			[ "old", [ 44, 46 ] ],
			[ " سنوات ", [ 47, 53 ] ],
			[ "girl", [ 54, 57 ] ],
			[ "!", [ 58, 58 ] ]
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
