load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceOccurrencesByMany(occurrences, sub, :By = news) -- replace the Nth, Mth,
# ... occurrence of `sub` (by occurrence INDEX, not char position) with the
# matching replacement. Archive block #62.

Scenario("Replacing the 1st, 3rd and 5th occurrences")
	Given('"ring php ring ruby ring python ring csharp ring" (5 rings)')
	o1 = new stzString("ring php ring ruby ring python ring csharp ring")
	o1.ReplaceOccurrencesByMany([ 1, 3, 5], "ring", :By = [ "#1", "#3", "#5" ])
	Then("occurrences 1/3/5 change; 2 and 4 stay 'ring'",
		o1.Content(), "#1 php ring ruby #3 python ring csharp #5")
EndScenario()

Summary()
