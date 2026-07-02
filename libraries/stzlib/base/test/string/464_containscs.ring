load "../../stzBase.ring"
load "../_narrated.ring"

# The method form of the block-#463 checks. Archive block #464.

Scenario("ContainsCS on a condition string")
	o1 = new stzString(" Q(@char).IsNumberInString() ")
	Then("it contains @char", o1.ContainsCS("@char", FALSE), TRUE)
	Then("... but not @substring", o1.ContainsCS("@substring", FALSE), FALSE)
EndScenario()

Summary()
