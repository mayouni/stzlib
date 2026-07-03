load "../../stzBase.ring"
load "../_narrated.ring"

# SortMarquersIn* rewrites the marquer slots with the sorted values.
# Archive block #629.

Scenario("Sorting the candidates")
	o1 = new stzString("The first candidate is #3, the second is #1, while the third is #2!")
	o1.SortMarquersInAscending()
	Then("ascending",
		o1.Content(), "The first candidate is #1, the second is #2, while the third is #3!")
	o1.SortMarquersInDescending()
	Then("then descending",
		o1.Content(), "The first candidate is #3, the second is #2, while the third is #1!")
EndScenario()

Summary()
