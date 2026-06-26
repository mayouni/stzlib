load "../../stzBase.ring"
load "../_narrated.ring"

# FindNext / FindNthNext / FindPrevious / FindNthPrevious -- directional search
# from a start position, codepoint-aware. Extreme cases on a small string.
# Archive block #236.

Scenario("Directional search from a position")
	Given('"•••••••••" (nine bullets)')
	o1 = new stzString("•••••••••")
	Then("FindNext('') is 0", o1.FindNext("", :StartingAt = 1), 0)
	Then("FindNext('x') (absent) is 0", o1.FindNext("x", :StartingAt = 1), 0)
	Then("FindNext('•', from 5) is 6", o1.FindNext("•", :StartingAt = 5), 6)
	Then("FindNthNext(6, '•', from 3) is 9", o1.FindNthNext(6, "•", :StartingAt = 3), 9)
	Then("FindNthNext(5, '•', from 1) is 6", o1.FindNthNext(5, "•", :StartingAt = 1), 6)
	Then("FindPrevious('•', from 5) is 4", o1.FindPrevious("•", :StartingAt = 5), 4)
	Then("FindPrevious('•', from 2) is 1", o1.FindPrevious("•", :StartingAt = 2), 1)
	Then("FindNthPrevious(8, '•', from 9) is 1", o1.FindNthPrevious(8, "•", :StartingAt = 9), 1)
	Then("FindNthPrevious(3, '•', from 4) is 1", o1.FindNthPrevious(3, "•", :StartingAt = 4), 1)
EndScenario()

Summary()
