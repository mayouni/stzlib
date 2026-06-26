load "../../stzBase.ring"
load "../_narrated.ring"

# Unicode() -- the codepoint of a single-char string. Archive block #105.

Scenario("The codepoint of a character")
	Then("'I' is codepoint 73", Q("I").Unicode(), 73)
EndScenario()

Summary()
