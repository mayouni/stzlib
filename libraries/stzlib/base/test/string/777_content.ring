load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceEachLeadingChar, then removing the trailing run by replacing
# each of its chars with "". Archive block #777.

Scenario("Cheering then cleaning")
	o1 = new stzString("aaaaah Tunisia!---")
	o1.ReplaceEachLeadingChar(:With = "O")
	Then("five O's", o1.Content(), "OOOOOh Tunisia!---")
	o1.ReplaceEachTrailingChar(:With = "")
	Then("dashes vanished", o1.Content(), "OOOOOh Tunisia!")
EndScenario()

Summary()
