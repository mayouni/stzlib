# Narrative
# --------
# Drops a contiguous slice of a list by position range with RemoveSection().
#
# RemoveSection(nFrom, nTo) deletes every element whose 1-based position
# falls within the inclusive range [nFrom, nTo], then re-knits the head and
# tail so the survivors close ranks. Here positions 3 through 8 (values
# 3..8) are excised from [1..10], leaving the front pair [1, 2] joined to
# the back pair [9, 10]. The operation mutates the stzList in place, and
# Content() reads back the reduced list.
#
# Extracted from stzlisttest.ring, block #178.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Drops a contiguous slice of a list by position range with RemoveSection().")

	o1 = new stzList([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
	o1.RemoveSection(3, 8)
	Then("removesection example 1", @@( o1.Content() ), @@( [ 1, 2, 9, 10 ] ))
EndScenario()

Summary()
