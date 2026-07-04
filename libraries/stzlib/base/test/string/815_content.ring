load "../../stzBase.ring"
load "../_narrated.ring"

# CompressUsingBinary keeps the chars whose mask bit is 1.
# Archive block #815.

Scenario("Masking ABCDEFGH")
	o1 = new stzString("ABCDEFGH")
	o1.CompressUsingBinary("10011011")
	Then("the 1-bits survive", o1.Content(), "ADEGH")
EndScenario()

Summary()
