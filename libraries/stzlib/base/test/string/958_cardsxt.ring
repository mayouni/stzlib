load "../../stzBase.ring"
load "../_narrated.ring"

# The playing-card helpers. Archive block #958.

Scenario("A deck of names and glyphs")
	aXT = CardsXT()
	Then("thirteen cards", len(aXT), 13)
	Then("ace first",
		ListEq( aXT[1], [ "ace", "🂡" ] ), TRUE)
	Then("king last",
		ListEq( aXT[13], [ "king", "🂮" ] ), TRUE)
	Then("the glyphs alone",
		ListEq( Cards(),
			[ "🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪",
			  "🂫", "🂭", "🂮" ] ), TRUE)
	Then("one by name", Card(:jack), "🂫")
	Then("a chosen few",
		ListEq( TheseCards([ :four, :nine, :king ]),
			[ "🂤", "🂩", "🂮" ] ), TRUE)
	Then("... with their names",
		ListEq( TheseCardsXT([ :four, :nine, :king ]),
			[ [ "four", "🂤" ], [ "nine", "🂩" ], [ "king", "🂮" ] ] ), TRUE)
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
