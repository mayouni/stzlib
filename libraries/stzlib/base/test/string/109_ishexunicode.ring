load "../../stzBase.ring"
load "../_narrated.ring"

# The hex-unicode round trip: IsHexUnicode tests a "U+XXXX" literal; HexUnicode /
# UnicodeToHexUnicode go codepoint -> "U+XXXX"; HexUnicodeToUnicode goes back.
# Archive block #109.

Scenario("Hex-unicode recognition and codepoint -> hex")
	Then("'U+0649' is a hex-unicode literal", Q("U+0649").IsHexUnicode(), TRUE)
	Then("a stzChar's HexUnicode is 'U+06A2'", StzCharQ("ڢ").HexUnicode(), "U+06A2")
	Then("UnicodeToHexUnicode(1698) is 'U+06A2'", UnicodeToHexUnicode(1698), "U+06A2")
	Then("HexUnicodeToUnicode('U+06A2') reverses to 1698", HexUnicodeToUnicode("U+06A2"), 1698)
	Then("the round trip QQ('U+0649') is the right char", StzCharQ("U+0649").Content(), "ى")
EndScenario()

Summary()
