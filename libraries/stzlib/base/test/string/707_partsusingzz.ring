load "../../stzBase.ring"
load "../_narrated.ring"

# PartsUsingZZ zips each part with its section. Archive block #707.

Scenario("Script runs, with their whereabouts")
	o1 = new stzString("__b和平س__a_ووو")
	Then("eight zipped parts",
		ListEq( o1.PartsUsingZZ(' StzCharQ(This[@i]).Script() '),
			[
				[ "__", [ 1, 2 ] ], [ "b", [ 3, 3 ] ],
				[ "和平", [ 4, 5 ] ], [ "س", [ 6, 6 ] ],
				[ "__", [ 7, 8 ] ], [ "a", [ 9, 9 ] ],
				[ "_", [ 10, 10 ] ], [ "ووو", [ 11, 13 ] ]
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
