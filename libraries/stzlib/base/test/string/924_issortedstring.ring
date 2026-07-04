load "../../stzBase.ring"
load "../_narrated.ring"

# The sortedness checkers know their types apart. Archive block #924.

Scenario("Strings are not lists, lists are not strings")
	Then("a list is not a sorted STRING", IsSortedString(1:5), FALSE)
	Then("a string is not a sorted LIST", IsSortedList("abc"), FALSE)
	Then("1:5 sorts ascending", IsSortedListInAscending(1:5), TRUE)
	Then("5:1 sorts descending", IsSortedListInDescending(5:1), TRUE)
	Then("abc sorts ascending", IsSortedStringInAscending("abc"), TRUE)
	Then("cba sorts descending", IsSortedStringInDescending("cba"), TRUE)
	Then("the method form too",
		StzStringQ("cba").IsSortedInDescending(), TRUE)
EndScenario()

Summary()
