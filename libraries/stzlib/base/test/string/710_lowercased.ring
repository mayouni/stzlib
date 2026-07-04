load "../../stzBase.ring"
load "../_narrated.ring"

# The three case transforms. (Foldcased is a TODO in the archive.)
# Archive block #710.

Scenario("tunis in three cases")
	Then("lowercased", Q("tunis").Lowercased(), "tunis")
	Then("uppercased", Q("tunis").Uppercased(), "TUNIS")
	Then("titlecased", Q("tunis").Titlecased(), "Tunis")
EndScenario()

Summary()
