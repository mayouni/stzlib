load "../../stzBase.ring"
load "../_narrated.ring"

# * with a list distributes the string over its items.
# Archive block #785.

Scenario("A times 1 2 3")
	Then("A1A2A3", Q("A") * [ "1", "2", "3" ], "A1A2A3")
EndScenario()

Summary()
