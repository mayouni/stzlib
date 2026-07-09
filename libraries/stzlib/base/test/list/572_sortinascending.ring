# Narrative
# --------
# SortInAscending() orders a mixed list in place: numbers rise first in
# numeric order (3, 4, 5, 7), then strings follow in alphabetical order
# ("cairo", "tunis"). The numbers-before-strings grouping is Softanza's
# stable ordering for heterogeneous lists.
#
# Extracted from stzlisttest.ring, block #572 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("SortInAscending orders a mixed list, numbers before strings")
	o1 = new stzList([ 5, 4, "tunis", 3, 7, "cairo" ])
	o1.SortInAscending()
	Then("numbers rise first, then strings alphabetically",
		@@( o1.Content() ), @@([ 3, 4, 5, 7, "cairo", "tunis" ]))
EndScenario()

Summary()
