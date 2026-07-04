load "../../stzBase.ring"
load "../_narrated.ring"

# NLastCharsRemoved, and CharsReversed on a section. (The archive's
# upside-down glyphs came from the retired Qt char-flip toy, like 715;
# CharsReversed reverses the ORDER.) Archive block #801.

Scenario("Trimming a tail, reversing a head")
	o1 = new stzString("ring language is nice language")
	Then("nine chars off the end",
		o1.NLastCharsRemoved(9), "ring language is nice")
	Then("the first word backwards",
		o1.SectionQ(1, 4).CharsReversed(), "gnir")
EndScenario()

Summary()
