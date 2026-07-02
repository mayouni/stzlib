load "../../stzBase.ring"
load "../_narrated.ring"

# Trailing-number detection keeps the sign and the decimal point:
# "Amount: -132.45" trails "-132.45". Archive block #409.

Scenario("A negative decimal closes the string")
	Given('"Amount: -132.45"')
	o1 = new stzString("Amount: -132.45")
	Then("it ends with a number", o1.EndsWithANumber(), TRUE)
	Then("the explicit check", o1.EndsWithThisNumber("-132.45"), TRUE)
	Then("the trailing number", o1.TrailingNumber(), "-132.45")
EndScenario()

Summary()
