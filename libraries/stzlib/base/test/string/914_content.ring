load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByMany with the :And tail distributes the replacements over
# the occurrences. Archive block #914.

Scenario("Three stars, three words")
	o1 = new stzString("--*--*--*--")
	o1.ReplaceByMany("*", [ "ONE", "TWO", :And = "THREE" ])
	Then("one word per star", o1.Content(), "--ONE--TWO--THREE--")
EndScenario()

Summary()
