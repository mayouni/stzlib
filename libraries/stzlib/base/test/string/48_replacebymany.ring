load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByMany(sub, [r1,r2,r3]) replaces each occurrence of sub by cycling
# through the replacements (1st->r1, 2nd->r2, 3rd->r3, wrapping). Archive #48.

Scenario("Replacing occurrences by cycling replacements")
	Given('"ring php ruby ring python ring"')
	o1 = new stzString("ring php ruby ring python ring")
	o1.ReplaceByMany("ring", [ "X", "XX", "XXX" ])
	Then("each 'ring' gets the next replacement", o1.Content(), "X php ruby XX python XXX")
EndScenario()

Summary()
