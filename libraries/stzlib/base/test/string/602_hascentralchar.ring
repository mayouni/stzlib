load "../../stzBase.ring"
load "../_narrated.ring"

# Central-char accessors on an odd-length string. Archive block #602.

Scenario("The center of RINGO")
	Then("it has one", Q("RINGO").HasCentralChar(), TRUE)
	Then("it is N", Q("RINGO").CentralChar(), "N")
	Then("at position 3", Q("RINGO").PositionOfCentralChar(), 3)
	Then("the named check", Q("RINGO").HasThisCentralChar("N"), TRUE)
EndScenario()

Summary()
