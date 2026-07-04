load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOf: full coverage AND every token used. IsMadeOfSome allows
# unused candidates. Archive block #816.

Scenario("Compositions of aabbcaacccbb")
	o1 = new stzString("aabbcaacccbb")
	Then("made of aa, bb and c",
		o1.IsMadeOf([ "aa", "bb", "c" ]), TRUE)
	Then("made of some of a, b, c, x",
		o1.IsMadeOfSome([ "a", "b", "c", "x" ]), TRUE)
EndScenario()

Summary()
