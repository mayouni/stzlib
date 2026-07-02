load "../../stzBase.ring"
load "../_narrated.ring"

# Multi-needle find: Find([subs]) lists ALL positions flat and sorted;
# TheseSubStringsZ groups each substring with its positions, and the ZZ
# form with its sections. Archive block #354.

Scenario("Finding many substrings at once")
	Given('"bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}"')
	o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}")
	Then("all positions, flat and sorted",
		ListEq( o1.Find([ "♥♥♥", "✤✤✤" ]), [ 6, 22, 35 ] ), TRUE)
	Then("each substring grouped with its positions",
		ListEq( o1.TheseSubStringsZ([ "♥♥♥", "✤✤✤" ]),
			[ [ "♥♥♥", [ 6, 22 ] ], [ "✤✤✤", [ 35 ] ] ] ), TRUE)
	Then("... and with its sections",
		ListEq( o1.TheseSubStringsZZ([ "♥♥♥", "✤✤✤" ]),
			[ [ "♥♥♥", [ [6, 8], [22, 24] ] ],
			  [ "✤✤✤", [ [35, 37] ] ] ] ), TRUE)
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
