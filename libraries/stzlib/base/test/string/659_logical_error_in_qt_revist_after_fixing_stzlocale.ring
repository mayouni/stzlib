load "../../stzBase.ring"
load "../_narrated.ring"

# Locale-aware lowercase, and the round-trip check the archive itself
# flags as a known limitation (der fluss != der fluß without full
# SpecialCasing -- see the engine backlog). Archive block #659.

Scenario("German lowercase round-trip")
	Then("DER FLUSS lowers to der fluss",
		Q("DER FLUSS").LowercasedInLocale("de-DE"), "der fluss")
	Then("the eszett round-trip stays FALSE (documented limitation)",
		Q("der fluß").IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE"), FALSE)
EndScenario()

Summary()
