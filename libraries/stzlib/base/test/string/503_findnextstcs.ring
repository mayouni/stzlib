load "../../stzBase.ring"
load "../_narrated.ring"

# FindNextSTCS: the next occurrence starting at a position, with the
# case dial. Archive block #503.

Scenario("Case-insensitive next find")
	o1 = new stzString("123456789RING")
	Then("ring matches RING at 10", o1.FindNextSTCS("ring", 5, FALSE), 10)
EndScenario()

Summary()
