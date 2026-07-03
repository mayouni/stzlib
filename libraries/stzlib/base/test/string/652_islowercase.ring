load "../../stzBase.ring"
load "../_narrated.ring"

# IsLowercase / IsLowercaseOf. Archive block #652.

Scenario("date is lowercase")
	Then("in itself", Q("date").IsLowercase(), TRUE)
	Then("... and of DATE", Q("date").IsLowercaseOf("DATE"), TRUE)
EndScenario()

Summary()
