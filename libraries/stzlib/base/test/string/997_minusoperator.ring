load "../../stzBase.ring"
load "../_narrated.ring"

# Minus with a number trims the tail; with a Q()-wrapped operand the
# result stays chainable. Archive block #997.

Scenario("Four flavors of minus")
	Then("minus 3 trims the last three",
		Q("A**BC***DE***") - 3, "A**BC***DE")
	Then("minus a string removes it everywhere",
		Q("A**BC***DE***") - "*", "ABCDE")
	Then("a Q operand keeps it chainable",
		( Q("A**BC***DE***") - Q("*") ).StzType(), "stzstring")
	Then("... so the chain goes on",
		( Q("A**BC***DE***") - Q("*") ).Lowercased(), "abcde")
EndScenario()

Summary()
