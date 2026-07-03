load "../../stzBase.ring"
load "../_narrated.ring"

# Cleansing semi-structured data: remove empty lines, lines to a list of
# strings, trim each, split each on the semicolon -- one fluent thought.
# Archive block #514.

Scenario("From messy text to a clean grid")
	o1 = new stzString("

	.;1;.;.;.
	1;2;3;4;5


	.;3;.;.;.
	.;4;.;.;.

	.;5;.;.;.  ")
	Then("the rows come out structured",
		ListEq( o1.RemoveEmptyLinesQ().
			LinesQRT(:stzListOfStrings).
			TrimQ().
			StringsSplitted(:Using = ";"),
			[ [ ".", "1", ".", ".", "." ],
			  [ "1", "2", "3", "4", "5" ],
			  [ ".", "3", ".", ".", "." ],
			  [ ".", "4", ".", ".", "." ],
			  [ ".", "5", ".", ".", "." ] ] ), TRUE)
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
