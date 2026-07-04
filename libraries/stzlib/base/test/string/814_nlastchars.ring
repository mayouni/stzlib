load "../../stzBase.ring"
load "../_narrated.ring"

# NLastChars feeding IsMadeOfSome. Archive block #814.

Scenario("The two trailing dammas")
	o1 = new stzString("مَنْصُورِيَّاتُُ")
	Then("made of chars from the candidate set",
		o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ]), TRUE)
EndScenario()

Summary()
