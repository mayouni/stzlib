load "../../stzBase.ring"
load "../_narrated.ring"

# The whole boxing family: plain, rounded, rounded-dashed, per-char,
# per-char rounded, and the VizFind marker on the bottom rail.
# Archive block #751.

Scenario("Six ways to box RING")
	o1 = new stzString("RING")
	Then("the content", o1.Content(), "RING")
	Then("Boxed",
		o1.Boxed(),
		"┌──────┐" + NL + "│ RING │" + NL + "└──────┘")
	Then("BoxedRounded",
		o1.BoxedRounded(),
		"╭──────╮" + NL + "│ RING │" + NL + "╰──────╯")
	Then("BoxedRoundedDashed",
		o1.BoxedRoundedDashed(),
		"╭╌╌╌╌╌╌╮" + NL + "┊ RING ┊" + NL + "╰╌╌╌╌╌╌╯")
	Then("EachCharBoxed",
		o1.EachCharBoxed(),
		"┌───┬───┬───┬───┐" + NL +
		"│ R │ I │ N │ G │" + NL +
		"└───┴───┴───┴───┘")
	Then("EachCharBoxedRounded",
		o1.EachCharboxedRounded(),
		"╭───┬───┬───┬───╮" + NL +
		"│ R │ I │ N │ G │" + NL +
		"╰───┴───┴───┴───╯")
	Then("VizFindBoxedRounded marks the I below",
		o1.VizFindBoxedRounded("I"),
		"╭───┬───┬───┬───╮" + NL +
		"│ R │ I │ N │ G │" + NL +
		"╰───┴─•─┴───┴───╯")
EndScenario()

Summary()
