load "../../stzBase.ring"
load "../_narrated.ring"

# LETTER-flavored methods are case-blind: n and N are both the letter N.
# Archive block #701.

Scenario("Letters regardless of their case")
	o1 = new stzString("Adoption of the plan B")
	Then("contains the letters N and b",
		o1.ContainsTheLetters([ "N", "b" ]), TRUE)
EndScenario()

Summary()
