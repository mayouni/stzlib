load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceWithMany(sub, list) cycles the replacements across each occurrence of sub
# (same family as ReplaceByMany). Archive block #80.

Scenario("Replacing a separator by cycling values")
	Given('"--Ring--Softanza--"')
	o1 = new stzString("--Ring--Softanza--")
	o1.ReplaceWithMany("--", [ "1", "2", "3" ])
	Then("the three '--' get 1, 2, 3", o1.Content(), "1Ring2Softanza3")
EndScenario()

Summary()
