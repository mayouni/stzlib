load "../../stzBase.ring"
load "../_narrated.ring"

# Singular vs plural: RemoveLeadingChar() / RemoveTrailingChar() remove exactly
# ONE end char; RemoveAnyLeadingChar() / RemoveLeadingChars() remove the whole
# run. Archive block #34. (The impl documents this distinction at ~4458.)
#
# NOTE: the archive #--> showed "Ring" for the SINGULAR calls, but that is what
# the PLURAL forms give; the singular forms peel one char. Asserted per impl,
# and the plural shortcut is shown alongside for contrast.

Scenario("Removing one end char vs the whole run")
	Given('"---Ring"')
	o1 = new stzString("---Ring")
	o1.RemoveLeadingChar()
	Then("RemoveLeadingChar() peels one leading char", o1.Content(), "--Ring")

	Given('"Ring---"')
	o2 = new stzString("Ring---")
	o2.RemoveTrailingChar()
	Then("RemoveTrailingChar() peels one trailing char", o2.Content(), "Ring--")

	Given('a fresh "---Ring"')
	o3 = new stzString("---Ring")
	o3.RemoveLeadingChars()
	Then("RemoveLeadingChars() (plural) peels the whole run", o3.Content(), "Ring")
EndScenario()

Summary()
