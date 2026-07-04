load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSection. Archive block #789.

Scenario("Starring the middle third")
	o1 = new stzString("123456789")
	o1.ReplaceSection(4, 6, :With = "***")
	Then("stars in place", o1.Content(), "123***789")
EndScenario()

Summary()
