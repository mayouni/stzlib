load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT(sep, step, direction) inserts sep every `step` chars, counting from
# the given direction. :Backward groups from the right. Archive block #270.

Scenario("Grouping digits from the right")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	o1.SpacifyXT( "_", 3, :Backward )
	Then("underscores group every 3 digits from the right", o1.Content(), "99_999_999_999")
EndScenario()

Summary()
