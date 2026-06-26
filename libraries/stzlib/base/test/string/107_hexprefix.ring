load "../../stzBase.ring"
load "../_narrated.ring"

# HexPrefix() is the "0x" hex marker; RepresentsNumberInHexForm /
# ...InUnicodeHexForm test whether a string is a hex / U+ literal. Archive #107.
#
# NOTE: the archive #--> "Ox" was a typo (letter O); the impl correctly returns
# "0x" (zero).

Scenario("Recognising hex and U+ number literals")
	Then("HexPrefix() is '0x'", HexPrefix(), "0x")
	Then("'0x066E' is a hex number", Q( HexPrefix() + "066E").RepresentsNumberInHexForm(), TRUE)
	Then("'U+066E' is a unicode-hex number", Q("U+066E").RepresentsNumberInUnicodeHexForm(), TRUE)
EndScenario()

Summary()
