load "../../stzBase.ring"
load "../_narrated.ring"

# Softanza's emptiness rules: the empty string is uncountable,
# unfindable, uncontainable, irreplaceable and irremovable.
# Archive block #612.

Scenario("Emptiness is uncountable and unfindable")
	Then("counting it in empty", Q("").Count(''), 0)
	Then("counting it in text", Q("text").Count(''), 0)
	Then("finding it in empty", ListEq( Q("").Find(''), [ ] ), TRUE)
	Then("finding it in text", ListEq( Q("text").Find(''), [ ] ), TRUE)
EndScenario()

Scenario("Emptiness is uncontainable")
	Then("empty contains nothing", Q("").Contains(''), FALSE)
	Then("... not even text", Q("").Contains('text'), FALSE)
	Then("text does not contain it", Q("text").Contains(''), FALSE)
EndScenario()

Scenario("Emptiness is irreplaceable and irremovable")
	Then("replace on empty", Q("").ReplaceQ('', '').Content(), "")
	Then("replace any on empty", Q("").ReplaceQ('any', '').Content(), "")
	Then("replace it by any on empty", Q("").ReplaceQ('', 'any').Content(), "")
	Then("replace it in text", Q("text").ReplaceQ('', "").Content(), "text")
	Then("... by X", Q("text").ReplaceQ('', "X").Content(), "text")
	Then("remove it from empty", Q("").RemoveQ('').Content(), "")
	Then("remove text from empty", Q("").RemoveQ('text').Content(), "")
	Then("remove it from text", Q("text").RemoveQ('').Content(), "text")
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
