load "../../stzBase.ring"
load "../_narrated.ring"

# "What You Think Is What You Write": the Are() checker reads like the
# sentence you'd say about the data. Archive block #451.

Scenario("Natural-language checks")
	Then("chars of 12309 are numbers",
		Q("12309").CharsQ().NumbrifiedQ().Are(:Numbers), TRUE)
	Then("chars of 248 are even positive numbers",
		Q("248").CharsQ().NumberifiedQ().Are([ :Even, :Positive, :Numbers ]), TRUE)
	Then("these are punctuation chars",
		Q([ ",", ":", ";" ]).Are([ :Punctuation, :Chars ]), TRUE)
EndScenario()

Summary()
