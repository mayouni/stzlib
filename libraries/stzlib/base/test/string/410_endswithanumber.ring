load "../../stzBase.ring"
load "../_narrated.ring"

# Same with a "+" sign: EndsWithNumberN is the arity-safe spelling of
# EndsWithThisNumber (the bare EndsWithNumber() is the 0-arg predicate,
# per the archive's own error note). Archive block #410.

Scenario("A plus-signed decimal closes the string")
	Given('"Amount: +132.45"')
	o1 = new stzString("Amount: +132.45")
	Then("it ends with a number", o1.EndsWithANumber(), TRUE)
	Then("the N-suffixed check", o1.EndsWithNumberN("+132.45"), TRUE)
	Then("the trailing number keeps the plus", o1.TrailingNumber(), "+132.45")
EndScenario()

Summary()
