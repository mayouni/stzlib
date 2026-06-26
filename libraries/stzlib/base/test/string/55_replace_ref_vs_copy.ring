load "../../stzBase.ring"
load "../_narrated.ring"

# Replace by reference vs by copy: Replace() mutates the object in place, while
# Copy().ReplaceQ() works on a fresh copy and leaves the original intact.
# Archive block #55.

Scenario("Replacing in place")
	Given('"R I N G"')
	o1 = new stzString("R I N G")
	o1.Replace(" ", "-")
	Then("Replace() mutates the object", o1.Content(), "R-I-N-G")
EndScenario()

Scenario("Replacing on a copy")
	Given('"R I N G"')
	o2 = new stzString("R I N G")
	Then("Copy().ReplaceQ() returns the changed copy", o2.Copy().ReplaceQ(" ", "-").Content(), "R-I-N-G")
	Then("the original is unchanged", o2.Content(), "R I N G")
EndScenario()

Summary()
