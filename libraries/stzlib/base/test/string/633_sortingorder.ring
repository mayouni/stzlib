load "../../stzBase.ring"
load "../_narrated.ring"

# SortingOrder on already-sorted strings. Archive block #633.

Scenario("Detecting the order")
	Then("an ascending string is sorted",
		Q("AAABCDDEFGILNTVX").IsSorted(), TRUE)
	Then("... ascending", Q("AAABCDDEFGILNTVX").SortingOrder(), :Ascending)
	Then("a descending string is sorted",
		Q("XVTNLIGFEDDCBAAA").IsSorted(), TRUE)
	Then("... descending", Q("XVTNLIGFEDDCBAAA").SortingOrder(), :Descending)
EndScenario()

Summary()
