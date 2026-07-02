load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSubStringsBoundedByIB drops each bounded run together with its
# bounds: the two "]---[" segments vanish, leaving "Hello Ring!". MUTATING.
# Extracted from stzlisttest.ring, block #324.

Scenario("Removing bounded runs including their bounds")
	Given("'Hello ]---[Ring!]---['")
	o1 = new stzString('Hello ]---[Ring!]---[')
	o1.RemoveSubStringsBoundedByIB([ "]","[" ])
	Then("the bracketed dashes vanish", o1.Content(), "Hello Ring!")
EndScenario()

Summary()
