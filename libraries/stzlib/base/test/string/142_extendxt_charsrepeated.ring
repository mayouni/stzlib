load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:ToPosition = n, :With = :CharsRepeated) grows the string to length n
# by repeating its own chars from the start. Archive block #142.

Scenario("Extending to a position with repeated chars")
	Given('"ABC"')
	o1 = new stzString("ABC")
	o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
	Then("it grows to 'ABCAB'", o1.Content(), "ABCAB")
EndScenario()

Summary()
