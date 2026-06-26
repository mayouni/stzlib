load "../../stzBase.ring"
load "../_narrated.ring"

# Low-level case-sensitive list helpers (@-prefixed globals) and the stzList
# ContainsCS surface. Archive block #165.

Scenario("Case-sensitive membership in a list of strings")
	aL = [ "hi!", "--♥♥♥--♥♥♥--" ]
	Then("@ListContainsCS finds 'hi!'", @ListContainsCS(aL, "hi!", TRUE), TRUE)
	Then("@FindNthSTCS locates it at position 1", @FindNthSTCS(aL, 1, "hi!", :StartingAt = 1, TRUE), 1)
	Then("Q(list).ContainsCS('hi!') is TRUE", Q(aL).ContainsCS("hi!", 1), TRUE)
EndScenario()

Summary()
