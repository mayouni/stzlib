load "../../stzBase.ring"
load "../_narrated.ring"

# The bare o prefix also reads as octal. Archive block #849.

Scenario("o without the 0")
	Then("octal form",
		Q("o01234567").RepresentsNumberInOctalForm(), TRUE)
EndScenario()

Summary()
