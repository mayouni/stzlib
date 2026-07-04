load "../../stzBase.ring"
load "../_narrated.ring"

# VizFindCS: one caret at each match start, case dial honored.
# Archive block #953.

Scenario("Three spellings of stz")
	o1 = new stzString("..STZ..StZ..stz")
	Then("all three marked",
		o1.vizFindCS("stz", FALSE),
		"..STZ..StZ..stz" + NL + "--^----^----^--")
EndScenario()

Summary()
