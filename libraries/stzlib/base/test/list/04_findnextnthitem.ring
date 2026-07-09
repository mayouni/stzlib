# Narrative
# --------
# Find the n-th item forward / backward from a position -- by POSITION or
# by VALUE.
#
# FindNextNthItem returns the POSITION of the n-th item after the start
# (NextNthItem returns the item there); FindPreviousNthItem / PreviousNthItem
# are the backward mirror, counting back from the start. So from position 4,
# the 3rd next is position 7 ("A7"); from position 7, the 4th previous is
# position 4 ("A4").
#
# Extracted from stzlisttest.ring, block #4.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Find the n-th item forward / backward from a position -- by POSITION or by VALUE.")

	o1 = new stzList([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])

	Then("findnextnthitem example 1", @@( o1.FindNextNthItem(3, :StartingAt = 4) ), @@( 7 ))

	Then("findnextnthitem example 2", @@( o1.NextNthItem(3, :StartingAt = 4) ), @@( "A7" ))

	#--

	Then("findnextnthitem example 3", @@( o1.FindPreviousNthItem(4, :StartingAt = 7) ), @@( 4 ))

	Then("findnextnthitem example 4", @@( o1.PreviousNthItem(4, :StartingAt = 7) ), @@( "A4" ))
EndScenario()

Summary()
