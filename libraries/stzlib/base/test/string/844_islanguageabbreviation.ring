load "../../stzBase.ring"
load "../_narrated.ring"

# Language abbreviations: short (2) vs long (3). Archive block #844.

Scenario("ara is the long form")
	o1 = new stzString("ara")
	Then("a language abbreviation", o1.IsLanguageAbbreviation(), TRUE)
	Then("not the short form", o1.IsShortLanguageAbbreviation(), FALSE)
	Then("the long one", o1.IsLongLanguageAbbreviation(), TRUE)
	Then("says so itself", o1.LanguageAbbreviationForm(), :Long)
EndScenario()

Summary()
