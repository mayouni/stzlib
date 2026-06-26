load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAt(pos, old, new) -- replace the occurrence of `old` that starts at
# position `pos` with `new`. Archive block #53.

Scenario("Replacing a substring at a known position")
	Given('"123ruby89"')
	o1 = new stzString("123ruby89")
	o1.ReplaceAt(4, "ruby", "ring")
	Then("'ruby' at position 4 becomes 'ring'", o1.Content(), "123ring89")
EndScenario()

Summary()
