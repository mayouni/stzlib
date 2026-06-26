load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendTo(n) -- pad the string on the right with spaces until it is n chars
# long. Archive block #85.

Scenario("Padding a string to a fixed width")
	Given('"ABC"')
	o1 = new stzString("ABC")
	o1.ExtendTo(5)
	Then("it is padded to width 5 with spaces", o1.Content(), "ABC  ")
EndScenario()

Summary()
