load "../../stzBase.ring"
load "../_narrated.ring"

# Scripts of a text: letters carry the script, spaces are Common;
# Script() gives the dominant one. Archive block #688.

Scenario("A French line's scripts")
	o1 = new stzText("père frère mère tête")
	Then("two scripts", o1.CountScripts(), 2)
	Then("latin + common (the spaces)",
		ListEq( o1.Scripts(), [ "latin", "common" ] ), TRUE)
	Then("dominant script", o1.Script(), "latin")
	Then("diacritics off", o1.DiacriticsRemoved(), "pere frere mere tete")
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
