load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyByManyXT -- like ReplaceManyByMany but the replacement list CYCLES
# when shorter than the search list (ring->♥, softanza->♥♥, kandaji->♥, zai->♥♥).
# Archive block #16.

Scenario("ReplaceManyByManyXT cycles a shorter replacement list")
	Given('"ring qt softanza pyhton kandaji csharp zai" with 4 words and 2 replacements')
	Then("the 2 replacements cycle across the 4 words", ManyByManyXT(),
		"♥ qt ♥♥ pyhton ♥ csharp ♥♥")
EndScenario()

Summary()

func ManyByManyXT
	o = new stzString("ring qt softanza pyhton kandaji csharp zai")
	o.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])
	return o.Content()
