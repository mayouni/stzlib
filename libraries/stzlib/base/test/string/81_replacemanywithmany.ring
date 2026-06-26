load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyWithMany(olds, news) -- positional many-to-many replacement (the
# twin of ReplaceManyByMany). Each old maps to the new at the same index.
# Archive block #81.

Scenario("Mapping several separators to several replacements")
	Given('"--Ring__Softanza.." with three separators')
	o1 = new stzString("--Ring__Softanza..")
	o1.ReplaceManyWithMany([ "--", "__", ".." ], [ "1", "2", "3" ])
	Then("-- / __ / .. become 1 / 2 / 3", o1.Content(), "1Ring2Softanza3")
EndScenario()

Summary()
