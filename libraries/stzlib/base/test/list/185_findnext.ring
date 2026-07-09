# Narrative
# --------
# Locating items in a list: FindNext, Find, and FindFirst.
#
# FindNext(value, :StartingAt = pos) returns the position of the next
# occurrence of the value at or after the given start index. Here 14
# first appears at position 1, and scanning from position 1 the next
# match is reported at position 3. Find(14) returns every position the
# value occupies ([ 1, 3, 4 ]), and FindFirst(4) returns 0 because 4
# is absent. Together they cover the single-step, all-positions, and
# first-only flavours of search.
#
# Extracted from stzlisttest.ring, block #185.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Locating items in a list: FindNext, Find, and FindFirst.")

	o1 = new stzList([ 14, 10, 14, 14, 20 ])

	//? o1.Section(0, :Last)

	Then("findnext example 1", @@( o1.FindNext(14, :StartingAt = 1) ), @@( 3 ))
	# Executed in 0.06 second(s)

	Then("findnext example 2", @@( o1.Find(14) ), @@( [ 1, 3, 4 ] ))

	Then("findnext example 3", @@( o1.FindFirst(4) ), @@( 0 ))
EndScenario()

Summary()
