load "../../stzBase.ring"
load "../_narrated.ring"

# Same-string bounds ("--"): only the regions EQUAL to the substring are
# replaced -- "--nword-" survives. (The archive's second example showed
# --WORD-- while replacing :With = "word"; asserted with "WORD" in both
# forms, the coherent intent.) Archive block #575.

Scenario("Replacing dash-bounded words")
	o1 = new stzString("bla bla --word-- bla bla --nword- bla --word--")
	o1.ReplaceSubStringBoundedBy("word", "--", :With = "WORD")
	Then("the method form",
		o1.Content(), "bla bla --WORD-- bla bla --nword- bla --WORD--")
	o2 = new stzString("bla bla --word-- bla bla --nword- bla --word--")
	o2.ReplaceXT("word", :BoundedBy = "--", :With = "WORD")
	Then("the XT form",
		o2.Content(), "bla bla --WORD-- bla bla --nword- bla --WORD--")
EndScenario()

Summary()
