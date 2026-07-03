load "../../stzBase.ring"
load "../_narrated.ring"

# The rich Section() anchor vocabulary: positional, named, auto-ordered,
# symbolic (:FirstChar/:LastChar/:EndOfString/:EndOfLine), substring
# anchors (:From finds the FIRST occurrence, :To the LAST), the mirror
# symbol :@, and :NthToLast. Archive block #523.

Scenario("Sections by numbers and symbols")
	Then("positional", Q("SOFTANZA").Section(1, 4), "SOFT")
	Then("named", Q("SOFTANZA").Section(:From = 1, :To = 4), "SOFT")
	Then("auto-ordered", Q("SOFTANZA").Section(4, 1), "SOFT")
	Then("whole string via symbols",
		Q("SOFTANZA").Section(:From = :LastChar, :To = :FirstChar), "SOFTANZA")
EndScenario()

Scenario("Sections by substring anchors")
	Then("from F to the last A", Q("SOFTANZA").Section(:From = "F", :To = "A"), "FTANZA")
	Then("from A to the end",
		Q("SOFTANZA").Section( :From = "A", :To = :EndOfString ), "ANZA")
	Then("from By to the end of its line",
		Q("Programming By Heart!
     This is Softanza motto.").
		Section( :From = "By", :To = :EndOfLine), "By Heart!")
EndScenario()

Scenario("The mirror symbol and NthToLast")
	Then("4 mirrored is a single char", Q("SOFTANZA").Section(4, :@), "T")
	Then("the 3rd-to-last mirrored", Q("SOFTANZA").Section(:NthToLast = 3, :@), "A")
	Then("both mirrored is everything", Q("SOFTANZA").Section(:@, :@), "SOFTANZA")
EndScenario()

Summary()
