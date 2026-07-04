load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAllChars(:With = c) stars out every char -- codepoint-aware
# (the Arabic letters count once each). Archive block #739.

Scenario("Starring a whole sentence")
	o1 = new stzString("Use these two letters: س and ص.")
	o1.ReplaceAllChars( :With = "*" )
	Then("as many stars as chars",
		o1.Content(), "*******************************")
EndScenario()

Summary()
