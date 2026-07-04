load "../../stzBase.ring"
load "../_narrated.ring"

# The explicit-char forms: replace the run ONLY when it is made of
# the given char. Archive block #774.

Scenario("Naming the run char")
	o1 = new stzString("___VAR---")
	o1.ReplaceLeadingChar("_", :With = "*")
	Then("underscores collapsed", o1.Content(), "*VAR---")
	o2 = new stzString("___VAR---")
	o2.ReplaceTrailingChar("-", :With = "*")
	Then("dashes collapsed", o2.Content(), "___VAR*")
EndScenario()

Summary()
