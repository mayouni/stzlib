load "../../stzBase.ring"
load "../_narrated.ring"

# BetweenIB(a, b) -- the section between positions a and b (inclusive bounds);
# equivalent to Section(a, b) here. Archive block #185.

Scenario("The section between two positions")
	Given('"<<♥♥♥>>--<<stars>>--<<♥♥♥>>"')
	o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")
	Then("BetweenIB(3, 5) is the heart run", o1.BetweenIB(3, 5), "♥♥♥")
	Then("Section(3, 5) gives the same", o1.Section(3, 5), "♥♥♥")
EndScenario()

Summary()
