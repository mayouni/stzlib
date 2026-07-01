load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthW(n, condition) returns the position of the nth char matching a W-DSL
# condition. The @char form is engine-backed. Archive block #246.
# (The @substring predicate form is a separate deferred feature -- the W finder
# currently evaluates per-char only; see _AUDIT_DEFECTS.md.)

Scenario("Finding the nth char matching a W condition")
	Given('"•♥••••♥••" (hearts at 2 and 7)')
	o1 = new stzString("•♥••••♥••")
	Then("the 2nd char equal to '♥' is at position 7", o1.FindNthW(2, '@char = "♥"'), 7)
EndScenario()

Summary()
