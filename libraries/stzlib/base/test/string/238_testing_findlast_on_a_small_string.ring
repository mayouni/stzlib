load "../../stzBase.ring"
load "../_narrated.ring"

# FindLast on a small string (codepoint-aware over multibyte chars). Archive #238.

Scenario("Finding the last occurrence")
	Given('"•♥••••♥••" (hearts at 2 and 7)')
	o1 = new stzString("•♥••••♥••")
	Then("FindLast('♥') is 7", o1.FindLast("♥"), 7)
	Then("FindLast('_') (absent) is 0", o1.FindLast("_"), 0)
EndScenario()

Summary()
