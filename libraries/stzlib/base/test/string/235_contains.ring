load "../../stzBase.ring"
load "../_narrated.ring"

# Contains() -- codepoint-aware substring test (works on multibyte bullets).
# The Softanza counterpart of Ring's byte-oriented substr (block #234). Archive #235.

Scenario("Containment of an empty string vs a bullet")
	Given('"•••••••••" (nine bullets)')
	o1 = new stzString("•••••••••")
	Then("it does not contain the empty string", o1.Contains(""), FALSE)
	Then("it does contain a bullet", o1.Contains("•"), TRUE)
EndScenario()

Summary()
