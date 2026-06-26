load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSections(listOfRanges) -- delete the given a:b ranges (codepoint-aware,
# so it handles the multibyte hearts correctly). Archive block #64.

Scenario("Removing several codepoint ranges")
	Given('"1♥♥456♥♥901♥♥4" (hearts at 2:3, 7:8, 12:13)')
	o1 = new stzString("1♥♥456♥♥901♥♥4")
	o1.RemoveSections([ 2:3, 7:8, 12:13 ])
	Then("the three heart pairs are gone", o1.Content(), "14569014")
EndScenario()

Summary()
