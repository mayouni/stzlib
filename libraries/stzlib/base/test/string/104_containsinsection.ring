load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsInSection(sub, n1, n2) checks whether sub appears within the section;
# ContainsInSections takes several sections. Archive block #104.

Scenario("Checking a substring within sections")
	Given('"123♥♥678♥♥1234♥♥789"')
	o1 = new stzString("123♥♥678♥♥1234♥♥789")
	Then("'♥' is inside section 3..10", o1.ContainsInSection("♥", 3, 10), TRUE)
	Then("'♥' is inside all three sections",
		o1.ContainsInSections("♥", [ [3,10], [8,12], [14,19] ]), TRUE)
EndScenario()

Summary()
