load "../../stzBase.ring"
load "../_narrated.ring"

# ... while :BoundedByIB (Including Bounds) removes the bounds too.
# Archive block #888.

Scenario("Heart and its slashes")
	o1 = new stzString("__/\/\__/♥\__")
	o1.RemoveXT("♥", :BoundedByIB = ["/", "\"])
	Then("all three gone", o1.Content(), "__/\/\____")
EndScenario()

Summary()
