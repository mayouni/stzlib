load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyByManyXT(olds, :By = news) -- like ReplaceManyByMany but the
# replacement list CYCLES when shorter than the search list. Here 2 replacements
# cover 3 search words: ring->♥, softanza->♥♥, kandaji wraps back to ♥. Archive
# block #17. (Companion to block #16, which shows the 4-word / 2-replacement case.)
#
# The archive block also demo'd FindAnyBoundedBy after pf() -- that code is
# unreachable (pf() halts) and the method has a separate logged defect (returns
# substrings instead of positions); see _AUDIT_DEFECTS.md and block #124.

Scenario("ReplaceManyByManyXT recycles a shorter replacement list over more words")
	Given('"ring qt softanza pyhton kandaji csharp ring" with 3 search words and 2 replacements')
	Then("the 2 replacements cycle, so kandaji wraps back to the first", ManyByManyXT(),
		"♥ qt ♥♥ pyhton ♥ csharp ♥")
EndScenario()

Summary()

func ManyByManyXT
	o = new stzString("ring qt softanza pyhton kandaji csharp ring")
	o.ReplaceManyByManyXT([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥" ])
	return o.Content()
