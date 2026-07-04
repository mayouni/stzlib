load "../../stzBase.ring"
load "../_narrated.ring"

# The full viz-find tour: plain carets, numbers, sections ('--'),
# and the boxed + sectioned + numbered ensemble. (The archive's
# comment-art spacing on the section numbers is loose -- ends are
# right-aligned to the end column, which makes 15/18 touch.)
# Archive block #972.

Scenario("Viz-finding a recurring substring")
	o1 = new stzString("fjringljringdjringg")
	Then("three positions",
		ListEq( o1.Find("ring"), [ 3, 9, 15 ] ), TRUE)
	Then("carets",
		o1.vizFind("ring"),
		"fjringljringdjringg" + NL + "--^-----^-----^----")
	Then("numbered",
		o1.vizFindXT("ring", [ :Numbered = TRUE ]),
		"fjringljringdjringg" + NL + "--^-----^-----^----" + NL +
		"  3     9     15   ")
	Then("as sections",
		ListEq( o1.FindAsSections("ring"),
			[ [3, 6], [9, 12], [15, 18] ] ), TRUE)
	Then("sectioned rail",
		o1.vizFindZZ("ring"),
		"fjringljringdjringg" + NL + "  '--'  '--'  '--' ")
	Then("sectioned + numbered",
		o1.vizFindXT("ring", [ :Sectioned = TRUE, :Numbered = TRUE ]),
		"fjringljringdjringg" + NL + "  '--'  '--'  '--' " + NL +
		"  3  6  9 12  1518 ")
	Then("the boxed ensemble",
		o1.vizFindXT("ring", [ :Boxed = TRUE, :Rounded = TRUE,
			:Sectioned = TRUE, :Numbered = TRUE ]),
		"╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮" + NL +
		"│ f │ j │ r │ i │ n │ g │ l │ j │ r │ i │ n │ g │ d │ j │ r │ i │ n │ g │ g │" + NL +
		"╰───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───╯" + NL +
		"          '-----------'           '-----------'           '-----------'      " + NL +
		"          3           6           9          12           15         18")
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
