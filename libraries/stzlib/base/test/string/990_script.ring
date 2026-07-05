load "../../stzBase.ring"
load "../_narrated.ring"

# Han script detection. Archive block #990.

Scenario("A Chinese hello")
	Then("han", StzTextQ("你好").Script(), "han")
EndScenario()

Summary()
