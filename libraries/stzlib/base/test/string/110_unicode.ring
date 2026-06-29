load "../../stzBase.ring"
load "../_narrated.ring"

# Unicode() / Unicodes() -- codepoint(s) of a string or a list of strings
# (multichar items nest). The hex forms carry the "U+" prefix, consistent with
# stzChar.HexUnicode() (block #109). Archive block #110.

Scenario("Codepoints of strings and lists of strings")
	Then("dotless-i is codepoint 305", Q("ı").Unicode(), 305)
	Then("dotless-j is codepoint 567", Q("ȷ").Unicode(), 567)
	Then("Unicodes('abc') is [97,98,99]", ListEq( Q("abc").Unicodes(), [ 97, 98, 99 ] ), TRUE)
	Then("Unicodes([a,b,c]) is [97,98,99]", ListEq( Q([ "a","b","c" ]).Unicodes(), [ 97, 98, 99 ] ), TRUE)
	Then("multichar items nest", ListEq( Q([ "a","bcd","e" ]).Unicodes(), [ 97, [ 98, 99, 100 ], 101 ] ), TRUE)
	Then("the global Unicodes('abc') agrees", ListEq( Unicodes("abc"), [ 97, 98, 99 ] ), TRUE)
	Then("HexUnicode carries the 'U+' prefix", Q("a").HexUnicode(), "U+0061")
	Then("HexUnicodes prefixes every char", ListEq( Q("abc").HexUnicodes(), [ "U+0061", "U+0062", "U+0063" ] ), TRUE)
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
