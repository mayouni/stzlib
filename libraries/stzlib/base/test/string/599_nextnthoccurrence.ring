load "../../stzBase.ring"
load "../_narrated.ring"

# NextNthOccurrence counts occurrences from a position INCLUSIVELY (the
# settled ST convention). The archive #-->s (2 and 40) were off-by-one
# hand values -- the string's occurrences sit at 1, 17 and 39.
# Archive block #599.

Scenario("Nth occurrence from a position")
	o1 = new stzString("ring is not the ring you ware but the ring you program with")
	Then("the 1st from position 1",
		o1.NextNthOccurrence(1, :of = "ring", :startingat = 1), 1)
	Then("the 2nd from position 17",
		o1.NextNthOccurrence(2, :of = "ring", :startingat = 17), 39)
EndScenario()

Summary()
