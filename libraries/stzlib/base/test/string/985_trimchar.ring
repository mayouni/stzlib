load "../../stzBase.ring"
load "../_narrated.ring"

# TrimChar strips a NAMED char from both ends in one call.
# (Repositioned from test/list block #68.) Archive block #985.

Scenario("Hearts off both sides at once")
	o1 = new stzString("♥♥♥123♥♥♥")
	o1.TrimChar("♥")
	Then("bare digits", o1.Content(), "123")
EndScenario()

Summary()
