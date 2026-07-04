load "../../stzBase.ring"
load "../_narrated.ring"

# RepresentsRealNumber. Archive block #832.

Scenario("A plain decimal real")
	Then("yes", Q("12500543.12").RepresentsRealNumber(), TRUE)
EndScenario()

Summary()
