load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNLeftChars on an Arabic string removes the first 7 chars in
# STRING order ("salam la-" -- the archive expected the tail removed,
# the familiar RTL visual mixup). Archive block #800.

Scenario("Seven chars off the head of an Arabic greeting")
	o1 = new stzString("سلام لأهل مصر الكرام")
	o1.RemoveNLeftChars(7)
	Then("the head is gone, string-order",
		o1.Content(), "هل مصر الكرام")
EndScenario()

Summary()
