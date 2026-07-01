load "../../stzBase.ring"
load "../_narrated.ring"

# HowManyST(sub, :StartingAt = n) counts the occurrences at or after the
# starting position -- on a stzString and, symmetrically, on a stzList of
# its chars. Archive block #320.

Scenario("Counting occurrences from a starting position")
	Given('"123456♥..♥♥" (hearts at 7, 10, 11)')
	o1 = new stzString("123456♥..♥♥")
	Then("3 hearts live at or after position 6",
		o1.HowManyST("♥", :StartingAt = 6), 3)
	o2 = new stzList( @Chars("123456♥..♥♥") )
	Then("the char-list counts the same",
		o2.HowManyST("♥", :StartingAt = 6), 3)
EndScenario()

Summary()
