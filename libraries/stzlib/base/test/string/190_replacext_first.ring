load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(:First, sub, :With = new) replaces the FIRST occurrence. Was a no-op
# until ReplaceFirst's byte/codepoint slicing was repaired (it corrupted
# multibyte content like hearts). Archive block #190.

Scenario("Replacing the first occurrence")
	Given('"_♥♥\__/♥\__/♥\_"')
	o1 = new stzString("_♥♥\__/♥\__/♥\_")
	o1.ReplaceXT(:First, "♥", :With = "/")
	Then("the first heart becomes a slash", o1.Content(), "_/♥\__/♥\__/♥\_")
EndScenario()

Summary()
