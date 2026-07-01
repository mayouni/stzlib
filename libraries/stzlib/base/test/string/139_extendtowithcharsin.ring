load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendToWithCharsIn(n, chars) grows the string to length n by cycling through
# the given chars (a range "1":"3" is the 3-element list ["1","2","3"]).
# Archive block #139.

Scenario("Extending a string by cycling chars")
	Given('"123"')
	o1 = new stzString("123")
	o1.ExtendToWithCharsIn( 8, "1":"3" )
	Then("it grows to length 8 by cycling 1,2,3", o1.Content(), "12312312")
EndScenario()

Summary()
