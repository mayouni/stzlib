load "../../stzBase.ring"
load "../_narrated.ring"

# IsAFunction: the content names a DEFINED function; IsAClass: a defined
# class. Archive block #471.

Scenario("Recognizing defined names")
	Then("stzLen is a function", Q("stzLen").IsAFunction(), TRUE)
	Then("stzChar is a class", Q("stzChar").IsAClass(), TRUE)
EndScenario()

Summary()
