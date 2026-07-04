load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSectionsByMany refuses a bare-string replacements arg with a
# raise, per the archive. Archive block #966.

Scenario("A string is not a replacements list")
	o1 = new stzString("123---789---")
	bRaised = FALSE
	try
		o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], "^")
	catch
		bRaised = TRUE
	done
	Then("the call raises", bRaised, TRUE)
	Then("content untouched", o1.Content(), "123---789---")
EndScenario()

Summary()
