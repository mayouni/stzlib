load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifySubStrings(listOfSubs) -- surround each named substring with spaces, in
# place (so run-together words get separated). Archive block #133.

Scenario("Spacing out chosen substrings")
	Given('"Ringprogramminglanguageispowerful!"')
	o1 = new stzString("Ringprogramminglanguageispowerful!")
	o1.SpacifySubStrings([ "programming", "is" ])
	Then("the named substrings are spaced apart", o1.Content(), "Ring programming language is powerful!")
EndScenario()

Summary()
