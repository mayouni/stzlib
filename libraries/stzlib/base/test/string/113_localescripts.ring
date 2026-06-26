load "../../stzBase.ring"
load "../_narrated.ring"

# LocaleScripts() and UnicodeScripts() are the two script registries. Archive
# block #113 (the source carries a #TODO to unify the two).
#
# NOTE: the archive #--> said 141 locale scripts; the registry has since grown to
# 143. Asserted at the current counts (a regression guard); the unification TODO
# is unrelated.

Scenario("The two script registries are populated")
	Then("LocaleScripts() has 143 entries", len( LocaleScripts() ), 143)
	Then("UnicodeScripts() has 157 entries", len( UnicodeScripts() ), 157)
EndScenario()

Summary()
