load "../../stzBase.ring"
load "../_narrated.ring"

# Lexicographic < and > on stzString. (There is deliberately NO =
# operator -- the original warns it clashes with stzExtCode's SQL
# DSL -- so the equality lines assert via IsEqualTo, case-sensitive.)
# Archive block #897.

Scenario("Ordering names")
	Then("sam before samira", Q("sam") < "samira", TRUE)
	Then("samira after ira", Q("samira") > "ira", TRUE)
	Then("qam is not sam", Q("qam").IsEqualTo("sam"), FALSE)
	Then("QAM is not qam (case-sensitive)",
		Q("QAM").IsEqualTo("qam"), FALSE)
EndScenario()

Summary()
