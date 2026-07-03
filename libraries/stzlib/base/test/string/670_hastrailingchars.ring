load "../../stzBase.ring"
load "../_narrated.ring"

# The trailing-run reading toolkit. Archive block #670.

Scenario("Trailing zeros of a number-in-string")
	o1 = new stzString("12.4560000")
	Then("there is a trailing run", o1.HasTrailingChars(), TRUE)
	Then("of four chars", o1.HowManyTrailingChar(), 4)
	Then("the char is 0", o1.TrailingChar(), "0")
	Then("... confirmed", o1.TrailingCharIs("0"), TRUE)
EndScenario()

Summary()
