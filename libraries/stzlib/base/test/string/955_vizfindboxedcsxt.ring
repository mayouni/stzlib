load "../../stzBase.ring"
load "../_narrated.ring"

# VizFindBoxedCSXT: the cell strip with a bullet under each match
# START. Archive block #955.

Scenario("Four bulleted matches")
	o1 = new stzString("..STZ..StZ..stz...STZ")
	Then("bullets at 3, 8, 13 and 19",
		o1.VizFindBoxedCSXT("STZ", :CS = FALSE, [ :Numbered = TRUE ]),
		"┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐" + NL +
		"│ . │ . │ S │ T │ Z │ . │ . │ S │ t │ Z │ . │ . │ s │ t │ z │ . │ . │ . │ S │ T │ Z │" + NL +
		"└───┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴───┴─•─┴───┴───┘")
EndScenario()

Summary()
shutdown($_zst_fail)
