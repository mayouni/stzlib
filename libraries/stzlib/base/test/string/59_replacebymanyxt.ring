load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByManyXT(sub, :By = list) cycles the replacements and WRAPS when there
# are more occurrences than replacements. Archive block #59.

Scenario("Replace-by-many that wraps the replacement list")
	Given('"ring php ring ruby ring python ring"')
	o1 = new stzString("ring php ring ruby ring python ring")
	o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
	Then("the two replacements alternate across four occurrences",
		o1.Content(), "#1 php #2 ruby #1 python #2")
EndScenario()

Summary()
