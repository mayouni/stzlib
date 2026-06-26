load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendWith(s) -- append s to the string. Archive block #135. (The archive's
# Show() #--> rendered the result as a list of chars; the actual content is the
# string "ABCDE".)

Scenario("Extending a string with more characters")
	Given('"ABC"')
	o1 = new stzString("ABC")
	o1.ExtendWith("DE")
	Then("the content is now ABCDE", o1.Content(), "ABCDE")
EndScenario()

Summary()
