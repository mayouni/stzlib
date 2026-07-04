load "../../stzBase.ring"
load "../_narrated.ring"

# List appends stay fast whatever the content -- asserted
# functionally; the timing story lives in the archive.
# Archive block #977.

Scenario("A million appends, latin and arabic")
	acList = []
	for i = 1 to 1000000
		acList + "any text"
	next
	Then("a million latin items", len(acList), 1000000)
	acList2 = []
	for i = 1 to 1000000
		acList2 + "السّلام عليكم ورحمة الله"
	next
	Then("a million arabic items", len(acList2), 1000000)
EndScenario()

Summary()
