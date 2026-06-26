load "../../stzBase.ring"
load "../_narrated.ring"

# NumberOfSubStrings() counts all contiguous substrings of a string (n*(n+1)/2
# for length n; 12 -> 78). SubStrings() returns them all. Archive block #125.

Scenario("Counting all the substrings of a word")
	Given('"RINGORIALAND" (12 chars)')
	o1 = new stzString("RINGORIALAND")
	Then("there are 12*13/2 = 78 substrings", o1.NumberOfSubStrings(), 78)
	Then("SubStrings() returns that many", len( o1.SubStrings() ), 78)
EndScenario()

Summary()
