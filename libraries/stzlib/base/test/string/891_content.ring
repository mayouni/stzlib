load "../../stzBase.ring"
load "../_narrated.ring"

# :BoundedByIB with a single-string bound. Archive block #891.

Scenario("Heart and its carets")
	o1 = new stzString("__/\/\__^^♥^^__")
	o1.RemoveXT("♥", :BoundedByIB = "^^")
	Then("all gone", o1.Content(), "__/\/\____")
EndScenario()

Summary()
