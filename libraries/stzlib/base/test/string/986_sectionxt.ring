load "../../stzBase.ring"
load "../_narrated.ring"

# SectionXT with inverted bounds reads BACKWARDS -- the ORIGINAL
# SectionCSXT reverses when n1 > n2 (the chunk-44 ruling from block
# #771; this file\'s earlier list-side header claimed order-tolerant
# "345", contradicting the monolith). A negative second argument is
# a forward length. Archive block #986.

Scenario("Backwards and by length")
	o1 = new stzString("123456789")
	Then("5 to 3 reads backwards", o1.SectionXT(5, 3), "543")
	Then("5 with length 3 reads forward", o1.SectionXT(5, -3), "567")
EndScenario()

Summary()
