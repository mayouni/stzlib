load "../../stzBase.ring"
load "../_narrated.ring"

# HowMany / Nth / FindLast for a repeated substring. Archive block #242.

Scenario("Counting and locating a repeated substring")
	Given('"---***---***---***---" (three "***")')
	o1 = new stzString("---***---***---***---")
	Then("HowMany('***') is 3", o1.HowMany("***"), 3)
	Then("the 3rd '***' starts at 16", o1.Nth(3, "***"), 16)
	Then("FindLast('***') is also 16", o1.FindLast("***"), 16)
EndScenario()

Summary()
