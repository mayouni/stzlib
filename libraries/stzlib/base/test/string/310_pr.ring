load "../../stzBase.ring"
load "../_narrated.ring"

# InsertAfterPositions([positions], str) inserts str after each given char
# position -- the after-flavored twin of block #309 (the archive block shows
# the call with its expected content in a comment). Archive block #310.

Scenario("Inserting after positions")
	Given('"123456789"')
	o1 = new stzString("123456789")
	o1.InsertAfterPositions([3, 6], "_")
	Then("underscores land after positions 3 and 6", o1.Content(), "123_456_789")
EndScenario()

Summary()
