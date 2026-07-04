load "../../stzBase.ring"
load "../_narrated.ring"

# ... and with sorted positions the ByMany pairing works.
# Archive block #925.

Scenario("Filling in the missing letters")
	o1 = new stzString("ab3de6gh9")
	o1.ReplaceCharsAtPositionsByMany([3, 6, 9], [ "c", "f", "i" ])
	Then("the alphabet restored", o1.Content(), "abcdefghi")
EndScenario()

Summary()
