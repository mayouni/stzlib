load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByMany(sub, list) and the Replace(sub, :By=list) / Replace(sub,
# :ByMany=list) shorthands all cycle the replacements (multibyte-safe). Archive #56.

Scenario("Replace-by-many and its named shorthands")
	Given('"1♥34♥♥"')
	o1 = new stzString("1♥34♥♥")
	o1.ReplaceByMany("♥", [ "2", "5", "6" ])
	Then("ReplaceByMany cycles 2,5,6", o1.Content(), "123456")

	o2 = new stzString("1♥34♥♥")
	o2.Replace("♥", :By = [ "2", "5", "6" ])
	Then("Replace(:By=list) agrees", o2.Content(), "123456")

	o3 = new stzString("1♥34♥♥")
	o3.Replace("♥", :ByMany = [ "2", "5", "6" ])
	Then("Replace(:ByMany=list) agrees", o3.Content(), "123456")
EndScenario()

Summary()
