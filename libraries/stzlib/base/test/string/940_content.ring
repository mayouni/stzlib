load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyCharsUsing. Archive block #940.

Scenario("Tildes between the letters")
	o1 = new stzString("SOFTANZA")
	o1.SpacifyCharsUsing("~")
	Then("tilde-joined", o1.Content(), "S~O~F~T~A~N~Z~A")
EndScenario()

Summary()
