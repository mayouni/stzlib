load "../../stzBase.ring"
load "../_narrated.ring"

# InsertBefore / InsertAfter read their args flexibly: when only the
# SECOND one is found in the content, it is the anchor (the first is
# the inserted text). Archive block #912.

Scenario("Greeting a dear friend")
	o1 = new stzString("Hello dear!")
	o1.InsertBefore("my ", "dear")
	Then("my before dear", o1.Content(), "Hello my dear!")
	o1.InsertAfter(" friend", "dear")
	Then("friend after dear", o1.Content(), "Hello my dear friend!")
EndScenario()

Summary()
