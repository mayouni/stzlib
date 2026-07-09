# Narrative
# --------
# The * operator on a stzList repeats its content N times in one step.
#
# Softanza overloads arithmetic operators on stzList so a list can be
# scaled like a number: o1 * 3 takes the single-element list [0] and
# returns [0, 0, 0]. The key idiom shown here is dual-purpose mutation:
# the expression both returns the new content (usable inline with ?)
# and updates the underlying object in place, so a following o1.Show()
# reflects the same repeated content without a separate assignment.
#
# Extracted from stzlisttest.ring, block #146.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The * operator on a stzList repeats its content N times in one step.")

	# Changes the object and returns its content IN THE SAME TIME:

	o1 = new stzList([0])
	Then("repeat_operator example 1", @@( o1 * 3 ), @@( [ 0, 0, 0 ] ))

	Then("repeat_operator example 2", @@( o1.Content() ), @@( [ 0 ] ))
EndScenario()

Summary()
