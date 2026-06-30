load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByMany(sub, :By = list) cycles the replacements (multibyte-safe).
# Archive block #58.

Scenario("Replace-by-many with the :By named param")
	Given('"ring php ruby ring python ring"')
	o1 = new stzString("ring php ruby ring python ring")
	o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
	Then("each 'ring' gets the next heart-run", o1.Content(), "♥ php ruby ♥♥ python ♥♥♥")
EndScenario()

Summary()
