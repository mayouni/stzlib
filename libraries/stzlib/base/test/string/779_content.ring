load "../../stzBase.ring"
load "../_narrated.ring"

# The explicit-char run replace, chained on both ends.
# Archive block #779.

Scenario("Greeting Tunisia")
	o1 = new stzString("oooo Tunisia---")
	o1.ReplaceLeadingChar("o", :With = "Hi")
	Then("o-run becomes Hi", o1.Content(), "Hi Tunisia---")
	o1.ReplaceTrailingChar("-", :With = "!")
	Then("dash-run becomes !", o1.Content(), "Hi Tunisia!")
EndScenario()

Summary()
