load "../../stzBase.ring"
load "../_narrated.ring"

# Chars and codepoints of a Devanagari-laced string: UnicodesXT gives
# [code, char] pairs; CharsAndTheirUnicodes gives [char, code].
# Archive block #855.

Scenario("Seven chars, two scripts")
	o1 = new stzString("saस्तेb")
	Then("seven chars", o1.NumberOfChars(), 7)
	Then("their codepoints",
		ListEq( o1.Unicodes(),
			[ 115, 97, 2360, 2381, 2340, 2375, 98 ] ), TRUE)
	Then("codepoint-first pairs",
		ListEq( o1.UnicodesXT(),
			[ [ 115, "s" ], [ 97, "a" ], [ 2360, "स" ], [ 2381, "्" ],
			  [ 2340, "त" ], [ 2375, "े" ], [ 98, "b" ] ] ), TRUE)
	Then("char-first pairs",
		ListEq( o1.CharsAndTheirUnicodes(),
			[ [ "s", 115 ], [ "a", 97 ], [ "स", 2360 ], [ "्", 2381 ],
			  [ "त", 2340 ], [ "े", 2375 ], [ "b", 98 ] ] ), TRUE)
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
