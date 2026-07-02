load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSection(n1, n2, :With = new) swaps a span for new content
# (multibyte-safe). Archive block #374.

Scenario("Replacing a section")
	Given('"123456789"')
	o1 = new stzString("123456789")
	o1.ReplaceSection(4, 6, :with = "♥♥♥")
	Then("the middle becomes hearts", o1.Content(), "123♥♥♥789")
EndScenario()

Summary()
