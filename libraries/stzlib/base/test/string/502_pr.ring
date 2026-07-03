load "../../stzBase.ring"
load "../_narrated.ring"

# The S() stringifier and the N() numberifier shorthands.
# Archive block #502.

Scenario("Casting shorthands")
	Then("S stringifies a range", S(1:3), "[ 1, 2, 3 ]")
	Then("N numberifies a signed string", N("-12500"), -12500)
EndScenario()

Summary()
