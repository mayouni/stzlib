load "../../stzBase.ring"
load "../_narrated.ring"

# A fluent chain crossing object types (string -> chars list -> string),
# and its QH history capturing the value after EVERY step -- including
# the type changes. (The archive's QHH VTMS variant adds exec-time and
# byte-size columns, which are machine-dependent and not asserted.)
# Archive block #505.

Scenario("From LIFE to L-heart-F-E")
	Then("the chain result",
		Q("LIFE").
			LowercaseQ().
			SpacifyQ().
			CharsQ().
			RemoveSpacesQ().
			UppercaseQ().
			JoinQ().
			SpacifyQ().
			ReplaceQ("I", :With = AHeart()).
			Content(), "L ♥ F E")
	Then("the captured steps across types",
		ListEq( QH("LIFE").
			LowercaseQ().
			SpacifyQ().
			CharsQ().
			RemoveSpacesQ().
			UppercaseQ().
			JoinQ().
			SpacifyQ().
			ReplaceQ("I", :With = AHeart()).
			History(),
			[ "LIFE",
			  "life",
			  "l i f e",
			  [ "l", " ", "i", " ", "f", " ", "e" ],
			  [ "l", "i", "f", "e" ],
			  [ "L", "I", "F", "E" ],
			  "LIFE",
			  "L I F E",
			  "L ♥ F E" ] ), TRUE)
	DontKeepHistory()
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
