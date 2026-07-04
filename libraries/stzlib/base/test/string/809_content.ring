load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSection with a keyword bound. Archive block #809.

Scenario("Keeping just the extra")
	o1 = new stzString("extrasection")
	o1.RemoveSectionQ(6, :LastChar)
	Then("section removed", o1.Content(), "extra")
EndScenario()

Summary()
