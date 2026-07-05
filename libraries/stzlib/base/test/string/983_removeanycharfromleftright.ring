load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAnyCharFromLeft / RemoveAnyCharFromRight: one-sided run trims
# of a NAMED char, codepoint-correct on the multibyte hearts.
# (Repositioned from test/list block #66.) Archive block #983.

Scenario("Hearts off each side in turn")
	o1 = new stzString("♥♥♥123♥♥♥")
	o1.RemoveAnyCharFromLeft("♥")
	Then("left run gone", o1.Content(), "123♥♥♥")
	o1.RemoveAnyCharFromRight("♥")
	Then("right run gone", o1.Content(), "123")
EndScenario()

Summary()
