load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceByMany distributes over the carets. Archive block #957.

Scenario("Three carets, three letters")
	o1 = new stzString("----^----------^----------^-----")
	Then("the canvas", o1.Content(), "----^----------^----------^-----")
	o1.ReplaceByMany("^", [ "A", "B", "C" ])
	Then("lettered", o1.Content(), "----A----------B----------C-----")
EndScenario()

Summary()
