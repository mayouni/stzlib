load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyByMany(olds, :By = news) -- positional 1:1 replacement of each old
# substring by the corresponding new one. Archive block #15.

Scenario("ReplaceManyByMany maps each word to its replacement")
	Given('"ring qt softanza pyhton kandaji csharp ring kandaji"')
	Then("ring/softanza/kandaji -> the heart marks", ManyByMany(),
		"♥ qt ♥♥ pyhton ♥♥♥ csharp ♥ ♥♥♥")
EndScenario()

Summary()

func ManyByMany
	o = new stzString("ring qt softanza pyhton kandaji csharp ring kandaji")
	o.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])
	return o.Content()
