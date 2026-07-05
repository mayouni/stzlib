load "../../stzBase.ring"
load "../_narrated.ring"

# SizeInBytes is the real content byte length ("Softanza" -> 8). The
# 64/32 variants report Ring's list-structure accounting, which is
# version-dependent (the archive's 624/624/400 were a stale snapshot).
# Archive block #06.

Scenario("The bytes of a word")
	o1 = new stzString("Softanza")
	Then("eight content bytes", o1.SizeInBytes(), 8)
	Then("the 64-bit struct size is reported", o1.SizeInBytes64() > 0, TRUE)
	Then("... and the 32-bit one", o1.SizeInBytes32() > 0, TRUE)
EndScenario()

Summary()
