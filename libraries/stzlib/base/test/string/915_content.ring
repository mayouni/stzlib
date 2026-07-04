load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceOccurrences: chosen occurrence numbers, matching
# replacements, all in named-param dress. Archive block #915.

Scenario("Only the 2nd and 3rd dots blocks")
	o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
	o1.ReplaceOccurrences([ 2, :and = 3 ], :of = "[...]", :by = [ "ONE", :and = "TWO" ])
	Then("first block untouched",
		o1.Content(), "--[...]---ONE---TWO---[~~~]--[~~~]--")
EndScenario()

Summary()
