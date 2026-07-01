load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthW(n, condition) returns the position of the nth char (or substring)
# matching a W-DSL condition. @char is engine-backed; @substring enumerates the
# substrings and filters via the list W-DSL. Archive block #246.

Scenario("Finding the nth char / substring matching a W condition")
	Given('"•♥••••♥••" (hearts at 2 and 7)')
	o1 = new stzString("•♥••••♥••")
	Then("the 2nd char equal to '♥' is at position 7", o1.FindNthW(2, '@char = "♥"'), 7)
	Then("the 2nd substring equal to '•♥•' starts at position 6",
		o1.FindNthW(2, '@substring = "•♥•"'), 6)
EndScenario()

Summary()
