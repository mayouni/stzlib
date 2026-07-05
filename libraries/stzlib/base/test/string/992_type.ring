load "../../stzBase.ring"
load "../_narrated.ring"

# QQ wraps by inferred type. Archive block #992.

Scenario("A plain string wraps as stzString")
	Then("stzstring", QQ("normal text").StzType(), "stzstring")
EndScenario()

Summary()
