load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNCharsLeft / RemoveNCharsRight. Archive block #898.

Scenario("Trimming the digits off both ends")
	o1 = new stzString("123SOFTANZA12345")
	o1.RemoveNCharsLeft(3)
	Then("head gone", o1.Content(), "SOFTANZA12345")
	o1.RemoveNCharsRight(5)
	Then("tail gone", o1.Content(), "SOFTANZA")
EndScenario()

Summary()
