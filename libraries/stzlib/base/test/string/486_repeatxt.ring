load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatXTQ names the output container and returns the elevated object.
# Archive block #486.

Scenario("Choosing the repeat container")
	Then("a :String repeat elevates to stzString",
		Q("A").RepeatXTQ(:String, 3).StzType(), :stzString)
	Then("a :List repeat elevates to stzList",
		Q("A").RepeatXTQ(:List, 3).StzType(), :stzList)
EndScenario()

Summary()
