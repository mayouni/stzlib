load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveRange. Archive block #810.

Scenario("Keeping just the section")
	o1 = new stzString("extrasection")
	o1.RemoveRange(1, 5)
	Then("range removed", o1.Content(), "section")
EndScenario()

Summary()
