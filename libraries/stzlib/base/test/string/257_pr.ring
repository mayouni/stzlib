load "../../stzBase.ring"
load "../_narrated.ring"

# @replace on an Arabic phrase. Archive block #257.

Scenario("Good morning becomes good light")
	Then("kheir -> nour",
		@replace("صباح الخير أصدقائي", "خير", "نور"),
		"صباح النور أصدقائي")
EndScenario()

Summary()
