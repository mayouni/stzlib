load "../../stzBase.ring"
load "../_narrated.ring"

# Left/Right vs Start/End on right-to-left text: for an RTL string the
# VISUAL right is the string START, so NRightCharsAsSubstring and
# RemoveFromRight mirror (per the original IsRightToLeft-aware impls);
# RemoveFromStart/End are the direction-neutral forms.
# Archive block #581.

Scenario("Left and right on LTR text")
	o1 = new stzString("let's say welcome to everyone!")
	o1.RemoveFromLeft("let's say ")
	Then("the lead is gone", o1.Content(), "welcome to everyone!")
EndScenario()

Scenario("Right means start on RTL text")
	o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
	Then("the right 4 chars open the text", o1.NRightCharsAsSubstring(4), "هذه ")
	o1.RemoveFromRight("هذه ")
	Then("removing from the right trims the start",
		o1.Content(), "الكلمات الّتي سوف تبقى")
EndScenario()

Scenario("Start and end are direction-neutral")
	o1 = new stzString("let's say welcome to everyone!")
	o1.RemoveFromStart("let's say ")
	Then("LTR", o1.Content(), "welcome to everyone!")
	o2 = new stzString("هذه الكلمات الّتي سوف تبقى")
	o2.RemoveFromStart("هذه ")
	Then("RTL, same code", o2.Content(), "الكلمات الّتي سوف تبقى")
EndScenario()

Summary()
