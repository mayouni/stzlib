load "../../stzBase.ring"
load "../_narrated.ring"

# UpdateWith(new) replaces the object's content wholesale. Archive block #279.

Scenario("Updating the content in place")
	Given('"999999999999"')
	o1 = new stzString("999999999999")
	o1.UpdateWith("999 999 999.999")
	Then("the content becomes the new value", o1.Content(), "999 999 999.999")
EndScenario()

Summary()
