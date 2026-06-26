load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyByMany(olds, :By = news) -- positional 1:1 replacement of each old
# substring by its corresponding new one (companion to blocks #15/#16). Here the
# trailing "ring" maps to the first replacement again. Archive block #60.

Scenario("Each search word maps to its own replacement")
	Given('"ring qt softanza pyhton kandaji csharp ring"')
	o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")
	o1.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])
	Then("ring/softanza/kandaji -> the heart marks", o1.Content(), "♥ qt ♥♥ pyhton ♥♥♥ csharp ♥")
EndScenario()

Summary()
