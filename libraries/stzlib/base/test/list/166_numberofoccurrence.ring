# Narrative
# --------
# Counts and locates how many times an exact item value appears in a list.
#
# The list holds many lookalike string items built from the characters
# '*', '4', '3' and the quoted token '"*"'. NumberOfOccurrence matches on
# the WHOLE item value, not a substring, so it counts only the items that
# are exactly the quoted-asterisk token '"*"' -- three of them. Find then
# returns the 1-based positions of every exact match, here [2, 14, 18].
# Together they show the count/locate pair built on strict item equality.
#
# Extracted from stzlisttest.ring, block #166.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Counts and locates how many times an exact item value appears in a list.")

	o1 = new stzList([
		"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
		"4", "4*", "4*3", "4*34", "*", "*3",
		"*34", '"*"', "3", "34", "4", '"*"'
	])

	Then("numberofoccurrence example 1", @@( o1.NumberOfOccurrence('"*"') ), @@( 3 ))

	Then("numberofoccurrence example 2", @@( o1.Find('"*"') ), @@( [2, 14, 18] ))
EndScenario()

Summary()
