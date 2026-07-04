load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSectionsByMany REJECTS unsorted / overlapping sections with
# a raise, per the archive. Archive block #920.

Scenario("Overlapping sections refused")
	o1 = new stzString("...456...012...678..")
	bRaised = FALSE
	try
		o1.ReplaceSectionsByMany([ [ 4, 6 ], [ 10, 20 ], [ 16, 18 ] ],
			[ "A", "BB", "CCC" ])
	catch
		bRaised = TRUE
	done
	Then("the call raises", bRaised, TRUE)
	Then("and the content is untouched",
		o1.Content(), "...456...012...678..")
EndScenario()

Summary()
