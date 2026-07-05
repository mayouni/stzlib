load "../../stzBase.ring"
load "../_narrated.ring"

# Is(:StzString) matches the object's own type.
# Extracted from stzObjectTest.ring, block #29.

Scenario("A string is a stzString")
	o1 = new stzString("hello")
	Then("yes", o1.Is(:StzString), TRUE)
EndScenario()

Summary()
