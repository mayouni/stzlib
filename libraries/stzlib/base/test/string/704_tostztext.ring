load "../../stzBase.ring"
load "../_narrated.ring"

# Scripts of a mixed-script string, via ToStzText(). The underscores
# read as Common since the UAX #24 fix (chunk 40) -- the archive
# predates it and listed only the three letter scripts.
# Archive block #704.

Scenario("Four scripts in one string")
	o1 = new stzString("__b和平س__a__و")
	Then("common + the three letter scripts",
		ListEq( o1.ToStzText().Scripts(),
			[ "common", "latin", "han", "arabic" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
