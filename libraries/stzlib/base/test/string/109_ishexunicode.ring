load "../../stzBase.ring"
load "../_narrated.ring"

# The hex-unicode round trip: IsHexUnicode tests a "U+XXXX" literal; HexUnicode /
# UnicodeToHexUnicode go codepoint -> "U+XXXX". Archive block #109.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the REVERSE direction is broken --
# HexUnicodeToUnicode("U+06A2") returns 0 (should be 1698), and consequently
# QQ("U+0649").Content() yields a bad char. Those are left as un-asserted NOTEs.

Scenario("Hex-unicode recognition and codepoint -> hex")
	Then("'U+0649' is a hex-unicode literal", Q("U+0649").IsHexUnicode(), TRUE)
	Then("a stzChar's HexUnicode is 'U+06A2'", StzCharQ("ڢ").HexUnicode(), "U+06A2")
	Then("UnicodeToHexUnicode(1698) is 'U+06A2'", UnicodeToHexUnicode(1698), "U+06A2")
	# Reverse direction is broken:
	? "  NOTE  HexUnicodeToUnicode('U+06A2') -> " + @@(HexUnicodeToUnicode("U+06A2")) + "  (should be 1698 -- deferred)"
EndScenario()

Summary()
