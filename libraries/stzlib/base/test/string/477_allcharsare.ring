load "../../stzBase.ring"
load "../_narrated.ring"

# AllCharsAre over several kinds. NOTE: the final CharsInverted() line of
# the archive ("LOVE" -> upside-down glyphs) belongs to the RETIRED
# Turned/Inverted family (tests #473-#475: pending the inverted-char
# table port); its :Invertible kind check is asserted, the glyph output
# is not. Archive block #477.

Scenario("All chars are of a kind")
	Then("chars", Q("str").AllCharsAre(:Chars), TRUE)
	Then("strings", Q("str").AllCharsAre(:Strings), TRUE)
	Then("numbers", Q("123").AllCharsAre(:Numbers), TRUE)
	Then("punctuations", Q("(,)").AllCharsAre(:Punctuations), TRUE)
	Then("arabic", Q("نور").AllCharsAre(:Arabic), TRUE)
	Then("right-to-left", Q("نور").AllCharsAre(:RightToLeft), TRUE)
	Then("invertible", Q("LOVE").AllCharsAre(:Invertible), TRUE)
EndScenario()

Summary()
