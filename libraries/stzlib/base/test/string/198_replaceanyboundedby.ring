load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAnyBoundedBy / ...IB -- replace the content bounded by a pair (IB also
# replaces the bounds). Archive block #198.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the non-IB ReplaceAnyBoundedBy with
# a repeated bound ("/" .. "/") pairs the slashes consecutively, so the " and "
# between the two regions is also consumed -- "bla bla /.../ and /---/!" becomes
# "bla bla /bla/bla/bla/!" instead of "bla bla /bla/ and /bla/!". The IB form
# works and is asserted.

Scenario("Replacing bounded content, including bounds")
	Given('"bla bla /.../ and /---/!"')
	o1 = new stzString("bla bla /.../ and /---/!")
	o1.ReplaceAnyBoundedByIB([ "/", "/" ], "bla")
	Then("IB replaces each /../  region wholesale", o1.Content(), "bla bla bla and bla!")

	# Non-IB form mis-pairs the repeated "/" bound:
	o2 = new stzString("bla bla /.../ and /---/!")
	o2.ReplaceAnyBoundedBy([ "/", "/" ], "bla")
	? "  NOTE  ReplaceAnyBoundedBy -> " + o2.Content() + "  (want '...bla/ and /bla...' -- deferred)"
EndScenario()

Summary()
