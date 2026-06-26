load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:ToPosition = n, :WithCharsIn = [chars]) -- pad up to position n,
# cycling through the given chars. Archive block #145.
#
# NOTE: the archive #--> "ABCDED" (6 chars) was a typo -- :ToPosition = 5 yields
# 5 chars (consistent with blocks #141/#144), so "ABC" + "DE" = "ABCDE".

Scenario("Extending to a position cycling through given chars")
	o1 = new stzString("ABC")
	o1.ExtendXT( :ToPosition = 5, :WithCharsIn = [ "D", "E" ])
	Then("padded to position 5 with D,E", o1.Content(), "ABCDE")
EndScenario()

Summary()
