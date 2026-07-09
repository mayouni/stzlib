# Narrative
# --------
# Builds a stzList from a character range and grows it with ExtendWith().
#
# The colon form stzList("A" : "C") asks Softanza to materialize the
# inclusive character range A through C, yielding [ "A", "B", "C" ].
# ExtendWith() then appends the items of another list ("D", "E") onto
# the tail in place, so the list becomes [ "A", "B", "C", "D", "E" ].
# This contrasts with AddItem (one element) -- ExtendWith splices a
# whole list, keeping the result a flat sequence rather than nesting.
#
# Extracted from stzlisttest.ring, block #151.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Builds a stzList from a character range and grows it with ExtendWith().")

	o1 = new stzList("A" : "C")
	o1.ExtendWith(["D", "E"])
	Then("extendwith example 1", @@( o1.Content() ), @@( [ "A", "B", "C", "D", "E" ] ))
EndScenario()

Summary()
