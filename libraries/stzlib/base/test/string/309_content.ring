load "../../stzBase.ring"
load "../_narrated.ring"

# InsertBefore([positions], str) -- alias InsertBeforePositions -- inserts
# str before each of the given char positions. Archive block #309.

Scenario("Inserting before positions")
	Given('"123456789"')
	o1 = new stzString("123456789")
	o1.InsertBefore([4, 7], "_")
	Then("underscores land before positions 4 and 7", o1.Content(), "123_456_789")
EndScenario()

Summary()
