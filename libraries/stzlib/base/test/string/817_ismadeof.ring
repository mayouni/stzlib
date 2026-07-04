load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOf requires every listed token to be USED -- an unused extra
# letter turns it FALSE; IsMadeOfSome does not mind.
# Archive block #817.

Scenario("The letters of Salsabil")
	o1 = new stzString("سلسبيل")
	Then("its four letters", o1.IsMadeOf([ "ب", "ل", "س", "ي" ]), TRUE)
	Then("an unused fifth spoils IsMadeOf",
		o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ]), FALSE)
	Then("... but not IsMadeOfSome",
		o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ]), TRUE)
EndScenario()

Summary()
