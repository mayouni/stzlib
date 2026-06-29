load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(:Last, sub, :With = new) replaces the LAST occurrence. Was a no-op
# (and ReplaceLast wrongly hit the FIRST match) until its byte/codepoint slicing
# was repaired for multibyte content. Archive block #191.

Scenario("Replacing the last occurrence")
	Given('"_/♥\__/♥\__/♥♥_"')
	o1 = new stzString("_/♥\__/♥\__/♥♥_")
	o1.ReplaceXT(:Last, "♥", :With = "\")
	Then("the last heart becomes a backslash", o1.Content(), "_/♥\__/♥\__/♥\_")
EndScenario()

Summary()
