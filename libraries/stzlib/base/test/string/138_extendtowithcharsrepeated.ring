load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendToWithCharsRepeated(n) -- pad up to length n by repeating the string's
# own chars. Archive block #138.

Scenario("Extending by repeating the string's own chars")
	o1 = new stzString("123")
	o1.ExtendToWithCharsRepeated(8)
	Then("'123' repeated up to width 8", o1.Content(), "12312312")
EndScenario()

Summary()
