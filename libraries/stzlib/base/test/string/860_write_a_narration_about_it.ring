load "../../stzBase.ring"
load "../_narrated.ring"

# SizeInBytes is the real byte length (the archive's 624 was Ring
# 64-bit struct accounting -- that breakdown now lives in
# SizeInBytesXT, whose exact numbers track the Ring version, so only
# its shape is pinned here). Archive block #860.

Scenario("The koala's memory story")
	o1 = new stzString("🐨")
	Then("four content bytes", o1.SizeInBytes(), 4)
	aXT = o1.SizeInBytesXT()
	Then("the struct breakdown has four rows", len(aXT), 4)
	Then("headed by the list-structure row",
		aXT[1][1], "RING_64BIT_LIST_STRUCTURE_SIZE")
EndScenario()

Summary()
