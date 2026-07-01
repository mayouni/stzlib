load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:ToPosition = n, :ByCharsRepeated) is the same as :With=:CharsRepeated:
# grow to length n by repeating the string's own chars. Archive block #143.

Scenario("Extending to a position, :ByCharsRepeated spelling")
	Given('"ABC"')
	o1 = new stzString("ABC")
	o1.ExtendXT( :ToPosition = 5, :ByCharsRepeated )
	Then("it grows to 'ABCAB'", o1.Content(), "ABCAB")
EndScenario()

Summary()
