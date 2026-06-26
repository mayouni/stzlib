load "../../stzBase.ring"
load "../_narrated.ring"

# Reverse() -- reverse the string in place. Archive block #233 ran it on the
# ~1.9M-char UnicodeData() as a perf demo; UnicodeData() is empty in this
# checkout, so Reverse is verified here on a small string plus the
# reverse-twice-is-identity invariant.

Scenario("Reversing a string")
	Given('"Ring"')
	o1 = new stzString("Ring")
	o1.Reverse()
	Then("'Ring' reversed is 'gniR'", o1.Content(), "gniR")
	o1.Reverse()
	Then("reversing again restores the original", o1.Content(), "Ring")
EndScenario()

Summary()
