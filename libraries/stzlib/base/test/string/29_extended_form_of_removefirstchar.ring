load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirstChar() peels ONE char at a time; RemoveFirstCharXT() (the eXTended
# form) peels the whole leading run in one shot. RemoveLeadingChars() is the
# same shortcut. Archive block #29.

Scenario("Peeling leading chars one-by-one, then all at once")
	Given('"-------Ring" (7 leading dashes)')
	o1 = new stzString("-------Ring")
	o1.RemoveFirstChar()
	Then("one peeled -> 6 dashes", o1.Content(), "------Ring")
	o1.RemoveFirstChar()
	Then("two peeled -> 5 dashes", o1.Content(), "-----Ring")
	o1.RemoveFirstChar()
	Then("three peeled -> 4 dashes", o1.Content(), "----Ring")
	o1.RemoveFirstCharXT()
	Then("the XT form peels the rest in one shot", o1.Content(), "Ring")

	Given('a fresh "-------Ring"')
	o2 = new stzString("-------Ring")
	o2.RemoveLeadingChars()
	Then("RemoveLeadingChars() does it directly", o2.Content(), "Ring")
EndScenario()

Summary()
