# Narrative
# --------
# Detecting and locating duplicate values in a stzList.
#
# Given a list with several repeated entries, four complementary
# views are offered: NumberOfDuplicates() counts how many distinct
# values appear more than once; FindDuplicates() returns the
# positions of the later (duplicate) occurrences; Duplicates()
# returns the duplicated values themselves; and DuplicatesZ() pairs
# each duplicated value with the list of positions where its repeats
# occur. Note that values like "4" are kept as strings, matching the
# original list element type rather than being coerced to numbers.
#
# Extracted from stzlisttest.ring, block #167.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Detecting and locating duplicate values in a stzList.")

	o1 = new stzList([
		"*", "*4", "*4*", "*4*3", "*4*34",
		"4", "4*", "4*3", "4*34", "*", "*3",
		"*34", "3", "34", "4"
	])

	Then("numberofduplicates example 1", @@( o1.NumberOfDuplicates() ), @@( 2 ))

	Then("numberofduplicates example 2", @@( o1.FindDuplicates() ), @@( [ 10, 15 ] ))

	Then("numberofduplicates example 3", @@( o1.Duplicates() ), @@( [ "*", "4" ] ))

	Then("numberofduplicates example 4", @@( o1.DuplicatesZ() ), @@( [ [ "*", [ 10 ] ], [ "4", [ 15 ] ] ] ))
EndScenario()

Summary()
