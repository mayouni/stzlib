load "../../stzBase.ring"
load "../_narrated.ring"

# FindPrevious(sub, :StartingAt = p) -- the nearest occurrence of `sub` BEFORE
# position p. Archive block #225.

Scenario("Finding the previous occurrence before a position")
	Given('"___<<<ring>>>___<<<softanza>>>___"')
	o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
	Then("the '<<<' before position 11 is at 4", o1.FindPrevious("<<<", :StartingAt = 11), 4)
EndScenario()

Summary()
