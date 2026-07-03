load "../../stzBase.ring"
load "../_narrated.ring"

# Char sorting: the passive Sorted* forms, the checks, and the mutating
# Sort(). Archive block #632.

Scenario("Sorting a jumble of letters")
	o1 = new stzString("BCAADDEFAGTILNXV")
	Then("ascending copy", o1.SortedInAscending(), "AAABCDDEFGILNTVX")
	Then("not sorted yet", o1.IsSortedInAscending(), FALSE)
	Then("descending copy", o1.SortedInDescending(), "XVTNLIGFEDDCBAAA")
	Then("not descending either", o1.IsSortedInDescending(), FALSE)
	Then("so unsorted", o1.SortingOrder(), :Unsorted)
	o1.Sort()
	Then("Sort() mutates ascending", o1.Content(), "AAABCDDEFGILNTVX")
	Then("and the order says so", o1.SortingOrder(), :Ascending)
EndScenario()

Summary()
