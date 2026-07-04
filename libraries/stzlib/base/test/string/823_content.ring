load "../../stzBase.ring"
load "../_narrated.ring"

# InsertBefore / InsertAfter with a substring ANCHOR: the insertion
# lands at the anchor's first occurrence. Archive block #823.

Scenario("Two roads to the same sentence")
	o1 = new stzString("Ring language")
	o1.InsertBefore("language", "programming ")
	Then("inserted before the anchor",
		o1.Content(), "Ring programming language")
	o2 = new stzString("Ring language")
	o2.InsertAfter("Ring", " programming")
	Then("inserted after the anchor",
		o2.Content(), "Ring programming language")
EndScenario()

Summary()
