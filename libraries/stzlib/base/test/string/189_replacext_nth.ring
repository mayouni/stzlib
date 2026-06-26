load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(:Nth = n, sub, :With = new) -- replace only the n-th occurrence.
# Archive block #189. (The data uses backslashes; Ring keeps "\_" literal.)

Scenario("Replacing the n-th occurrence")
	Given('"_/♥\__/♥\__/♥♥__/♥\_" (the 4th heart lacks its slash)')
	o1 = new stzString("_/♥\__/♥\__/♥♥__/♥\_")
	o1.ReplaceXT(:Nth = 4, "♥", :With = "\")
	Then("the 4th heart gets its backslash", o1.Content(), "_/♥\__/♥\__/♥\__/♥\_")
EndScenario()

Summary()
