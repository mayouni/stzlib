# Narrative
# --------
# Section(n1, n2) returns the contiguous run of items between two
# positions, inclusive of both endpoints.
#
# Here the list holds 1..10 and Section(3, 10) yields items at
# positions 3 through 10, i.e. [ 3, 4, 5, 6, 7, 8, 9, 10 ]. Both the
# lower and upper bound are kept, so the result length is
# (n2 - n1 + 1). This is the position-based counterpart to slicing:
# you name where to start and where to stop, and Softanza hands back
# everything in between as a fresh list. @@() is used only to render
# the result in readable bracketed form.
#
# Extracted from stzlisttest.ring, block #182.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Section(n1, n2) returns the contiguous run of items between two positions, inclusive of bo")

	o1 = new stzList(1:10)
	Then("section example 1", @@( o1.Section(3, 10) ), @@( [ 3, 4, 5, 6, 7, 8, 9, 10 ] ))
EndScenario()

Summary()
