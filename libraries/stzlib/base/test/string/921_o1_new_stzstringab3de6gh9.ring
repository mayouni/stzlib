load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharsAtPositionsByMany REJECTS unsorted positions with a
# raise (the pairing needs ascending order). Archive block #921.

Scenario("Unsorted positions refused")
	o1 = new stzString("ab3de6gh9")
	bRaised = FALSE
	try
		o1.ReplaceCharsAtPositionsByMany([3, 12, 9], [ "c", "f", "i" ])
	catch
		bRaised = TRUE
	done
	Then("the call raises", bRaised, TRUE)
	Then("content untouched", o1.Content(), "ab3de6gh9")
EndScenario()

Summary()
