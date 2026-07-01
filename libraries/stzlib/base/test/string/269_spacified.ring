load "../../stzBase.ring"
load "../_narrated.ring"

# Spacified() is the non-mutating form of SpacifyChars (space between chars);
# SpacifiedUsing(sep) uses a custom separator. Archive block #269.

Scenario("Non-mutating spacing of chars")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	Then("Spacified() spaces the chars", o1.Spacified(), "9 9 9 9 9 9 9 9 9 9 9")
	Then("SpacifiedUsing('_') uses underscores", o1.SpacifiedUsing("_"), "9_9_9_9_9_9_9_9_9_9_9")
EndScenario()

Summary()
