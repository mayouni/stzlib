load "../../stzBase.ring"
load "../_narrated.ring"

# The perf narration: Ring's += over a million Arabic strings takes
# ~45s; Softanza's Concatenate() does it in seconds. Asserted here
# functionally (exact result length); the timing story lives in the
# archive. Archive block #976.

Scenario("Concatenating a million Arabic strings")
	acList = []
	for i = 1 to 1000000
		acList + "السّلام عليكم ورحمة الله"
	next
	cRes = Concatenate(acList)
	Then("a million joined copies",
		StzLen(cRes), 1000000 * StzLen("السّلام عليكم ورحمة الله"))
EndScenario()

Summary()
