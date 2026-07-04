load "../../stzBase.ring"
load "../_narrated.ring"

# Chars, bytes, unicode codepoints and bytecodes of "s(36-in-circle)m" --
# one ASCII char, one 3-byte CJK sign, one ASCII char. (The archive's
# SizeInBytes/SizeInBytesPerChar numbers were stale copy-garble; the
# real sizes are 1+3+1 = 5.) Archive block #719.

Scenario("One string, four readings")
	o1 = new stzString("s㊱m")
	Then("three chars",
		ListEq( o1.Chars(), [ "s", "㊱", "m" ] ), TRUE)
	Then("three codepoints",
		ListEq( o1.Unicodes(), [ 115, 12977, 109 ] ), TRUE)
	Then("zipped per char",
		ListEq( o1.UnicodesPerChar(),
			[ [ "s", 115 ], [ "㊱", 12977 ], [ "m", 109 ] ] ), TRUE)
	Then("five bytes in all", o1.SizeInBytes(), 5)
	Then("1 + 3 + 1 per char",
		ListEq( o1.NumberOfBytesPerChar(),
			[ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ] ), TRUE)
	Then("... so five byte-items", len( o1.Bytes() ), 5)
	Then("the signed bytecodes",
		ListEq( o1.Bytecodes(), [ 115, -29, -118, -79, 109 ] ), TRUE)
	Then("zipped per char",
		ListEq( o1.BytecodesPerChar(),
			[ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ] ), TRUE)
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
