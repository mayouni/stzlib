load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:String, :With = s) -- append s. Archive block #140.

Scenario("Extending a string by appending text")
	o1 = new stzString("ABC")
	o1.ExtendXT( :String, :With = "DE" )
	Then("'DE' is appended", o1.Content(), "ABCDE")
EndScenario()

Summary()
