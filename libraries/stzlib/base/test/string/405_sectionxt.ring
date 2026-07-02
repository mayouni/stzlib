load "../../stzBase.ring"
load "../_narrated.ring"

# SectionXT resolves negative indexes from the end (the strict Section
# raises on them -- the archive shows that raise commented out).
# Archive block #405.

Scenario("The lenient section with a negative end")
	Given('"123456789"')
	o1 = new stzString("123456789")
	Then("-3 counts from the end", o1.SectionXT(3, -3), "34567")
EndScenario()

Summary()
