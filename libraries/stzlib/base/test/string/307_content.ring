load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyTheseSubStrings when the tokens tile the WHOLE string: single
# separators appear between tokens and the edge whitespace is trimmed.
# Archive block #307.

Scenario("Spacifying a fully-tiled name string")
	Given('"MahmoudBertAhmedMansourIlirGalMajdi"')
	o1 = new stzString("MahmoudBertAhmedMansourIlirGalMajdi")
	o1.SpacifyTheseSubStrings([
		"Mahmoud", "Bert", "Ahmed", "Mansour", "Ilir", "Gal", "Majdi" ])
	Then("the names separate with single spaces, no edge spaces",
		o1.Content(), "Mahmoud Bert Ahmed Mansour Ilir Gal Majdi")
EndScenario()

Summary()
