load "../../stzBase.ring"
load "../_narrated.ring"

# The XT forms add a numbers rail; :CS can ride in the options list.
# Archive block #954.

Scenario("Numbered carets, two spellings of the call")
	o1 = new stzString("..STZ..StZ..stz")
	cExp = "..STZ..StZ..stz" + NL +
	       "--^----^----^--" + NL +
	       "  3    8    13 "
	Then("VizFindXT with :CS in the options",
		o1.VizFindXT("stz", [ :Numbered = TRUE, :CS = FALSE ]), cExp)
	Then("VizFindCSXT with the dial as its own param",
		o1.VizFindCSXT("stz", :CS = FALSE, [ :Numbered = TRUE ]), cExp)
	Then("... and the uppercase needle finds the same",
		o1.VizFindCSXT("STZ", :CS = FALSE, [ :Numbered = TRUE ]), cExp)
EndScenario()

Summary()
