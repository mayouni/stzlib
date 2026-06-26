load "../../stzBase.ring"
load "../_narrated.ring"

# Unicode() / Unicodes() -- codepoint(s) of a string or a list of strings
# (multichar items nest). Archive block #110.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the HEX forms are inconsistent with
# stzChar -- stzString.HexUnicode("a") returns "0061" WITHOUT the "U+" prefix
# (stzChar's HexUnicode includes it, block #109), and HexUnicodes wraps each
# single-char item in a list. Those are left as un-asserted NOTEs.

Scenario("Codepoints of strings and lists of strings")
	Then("dotless-i is codepoint 305", Q("ı").Unicode(), 305)
	Then("dotless-j is codepoint 567", Q("ȷ").Unicode(), 567)
	Then("Unicodes('abc') is [97,98,99]", ListEq( Q("abc").Unicodes(), [ 97, 98, 99 ] ), TRUE)
	Then("Unicodes([a,b,c]) is [97,98,99]", ListEq( Q([ "a","b","c" ]).Unicodes(), [ 97, 98, 99 ] ), TRUE)
	Then("multichar items nest", ListEq( Q([ "a","bcd","e" ]).Unicodes(), [ 97, [ 98, 99, 100 ], 101 ] ), TRUE)
	Then("the global Unicodes('abc') agrees", ListEq( Unicodes("abc"), [ 97, 98, 99 ] ), TRUE)
	# Hex forms drop the "U+" prefix and over-nest -- inconsistent with stzChar:
	? "  NOTE  Q('a').HexUnicode() -> " + @@(Q("a").HexUnicode()) + "  (should be 'U+0061' -- deferred)"
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
