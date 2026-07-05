load "../../stzBase.ring"
load "../_narrated.ring"

# Insert(sub, :BeforePosition = n) and InsertBefore(:Position = n,
# :SubString = sub) are two orders for the same edit; the short forms
# take bare positions. Extracted from stzlisttest.ring, block #361.

Scenario("Two orderings, one insertion")
	o1 = new stzString("ACD")
	o1.Insert("B", :BeforePosition = 2)
	Then("substring-first form", o1.Content(), "ABCD")
	o2 = new stzString("ACD")
	o2.InsertBefore( :Position = 2, :SubString = "B")
	Then("position-first form", o2.Content(), "ABCD")
	o2.Insert("B", 2)
	o2.InsertBefore(2, "B")
	Then("the short forms stack", o2.Content(), "ABBBCD")
EndScenario()

Summary()
