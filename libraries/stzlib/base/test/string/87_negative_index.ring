load "../../stzBase.ring"
load "../_narrated.ring"

# Negative indexing via Q([...])[-n] -- counts from the end. Archive block #87.

Scenario("Indexing a list from the end")
	Then("[-3] of [A,B,C,D,E] is the 3rd-from-last", Q(["A", "B", "C", "D", "E"])[-3], "C")
EndScenario()

Summary()
