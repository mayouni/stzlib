load "../../stzBase.ring"
load "../_narrated.ring"

# vizFind and its numbered XT form on a periodic string.
# Archive block #971.

Scenario("Four rings")
	o1 = new stzString("ringringringring")
	Then("carets every four",
		o1.vizFind("ring"),
		"ringringringring" + NL + "^---^---^---^---")
	Then("with the numbers rail",
		o1.vizFindXT("ring", [ :Numbered = TRUE ]),
		"ringringringring" + NL + "^---^---^---^---" + NL + "1   5   9   13  ")
EndScenario()

Summary()
