load "../../stzBase.ring"
load "../_narrated.ring"

# The singular char removers: RemoveFirstChar (unconditional),
# RemoveThisFirstCharCS (only if the first char equals c, case-dialed),
# RemoveNthChar(:Last), and RemoveThisNthChar(n, c) -- remove the char AT
# position n only if it equals c. Archive block #371.

Scenario("Peeling chars off a string, conditionally")
	Given('"_ABC_DE_"')
	o1 = new stzString("_ABC_DE_")
	o1.RemoveFirstChar()
	Then("the leading underscore goes", o1.Content(), "ABC_DE_")
	o1.RemoveThisFirstCharCS("a", :CS = FALSE)
	Then("the case-insensitive A goes too", o1.Content(), "BC_DE_")
	o1.RemoveNthChar(:Last)
	Then("the last char goes", o1.Content(), "BC_DE")
	o1.RemoveThisNthChar(3, "_")
	Then("position 3 goes because it IS an underscore", o1.Content(), "BCDE")
EndScenario()

Summary()
