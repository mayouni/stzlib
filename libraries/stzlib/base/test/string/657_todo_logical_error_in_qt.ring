load "../../stzBase.ring"
load "../_narrated.ring"

# The German sharp s: lowercase, and it uppercases to "SS" (Unicode
# SpecialCasing -- now honored by StzUpper). NOTE: Ring's builtin
# upper() is byte-based and leaves the multibyte ss unchanged (the
# archive's "DER FLUSS" for it came from the old Qt era); Softanza's
# Uppercased() does it right. Archive block #657.

Scenario("Eszett up and down")
	Then("it is lowercase", Q("ß").CharCase(), :Lowercase)
	Then("it uppercases to SS", Q("ß").Uppercased(), "SS")
	Then("a whole river, Softanza-cased",
		Q("der fluß").Uppercased(), "DER FLUSS")
	Then("SS lowercases to ss (no locale round-trip)",
		Q("SS").Lowercased(), "ss")
	Then("... also under the german locale",
		Q("SS").LowercasedInLocale("ge-GE"), "ss")
EndScenario()

Summary()
