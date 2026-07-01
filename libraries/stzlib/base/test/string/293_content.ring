load "../../stzBase.ring"
load "../_narrated.ring"

# Unspacify() = Trim + collapse each run of 2+ spaces to a single space
# (the original monolith: Trim + remove the duplicate-consecutive spaces).
# Inner single spaces survive; edges are trimmed. Archive block #293.

Scenario("Unspacifying a string")
	Given('" so ftan   za "')
	o1 = new stzString(" so ftan   za ")
	o1.Unspacify()
	Then("edges trimmed, the 3-space run collapsed", o1.Content(), "so ftan za")
EndScenario()

Summary()
