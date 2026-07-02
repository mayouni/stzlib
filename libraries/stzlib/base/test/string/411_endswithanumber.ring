load "../../stzBase.ring"
load "../_narrated.ring"

# EndsWithNumberN matches the unsigned suffix too, while TrailingNumber
# still reports the sign. Archive block #411.

Scenario("The unsigned suffix also matches")
	Given('"Amount: +132.45"')
	o1 = new stzString("Amount: +132.45")
	Then("it ends with a number", o1.EndsWithANumber(), TRUE)
	Then("the unsigned check passes", o1.EndsWithNumberN("132.45"), TRUE)
	Then("the trailing number keeps the plus", o1.TrailingNumber(), "+132.45")
EndScenario()

Summary()
