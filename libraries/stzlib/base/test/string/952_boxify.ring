load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfChars: Boxify renders the cell strip; BoxDash uses dashed
# lines. (The archive's lone rounded corner on Boxify was a one-char
# garble; the box is rectangular, like its own BoxDash.)
# Archive block #952.

Scenario("A char list in cells, twice")
	o1 = new stzListOfChars( @Chars("..STZ..StZ..stz") )
	Then("solid cells",
		o1.Boxify(),
		"┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐" + NL +
		"│ . │ . │ S │ T │ Z │ . │ . │ S │ t │ Z │ . │ . │ s │ t │ z │" + NL +
		"└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘")
	Then("dashed cells",
		o1.BoxDash(),
		"┌╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┐" + NL +
		"┊ . ┊ . ┊ S ┊ T ┊ Z ┊ . ┊ . ┊ S ┊ t ┊ Z ┊ . ┊ . ┊ s ┊ t ┊ z ┊" + NL +
		"└╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┘")
EndScenario()

Summary()
shutdown($_zst_fail)
