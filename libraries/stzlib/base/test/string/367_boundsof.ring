load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsOf(sub) returns the bounds around EACH occurrence as [open, close]
# pairs (the per-occurrence nested shape settled in block #42; this
# archive block displayed the single pair flattened). The XT / UpToNChars
# forms cap each side. Archive block #367.

Scenario("Bounds of a single occurrence, capped")
	Given('"<<<word>>>"')
	o1 = new stzString("<<<word>>>")
	# RULING (chunk 35): BoundsOf is FLAT per the original impl
	# (blocks #589-#591).
	Then("the full bound runs, flat",
		ListEq( o1.BoundsOf("word"), [ "<<<", ">>>" ] ), TRUE)
	Then("capped at 2 a side",
		ListEq( o1.BoundsOfXT("word", :UpToNChars = 2), [ [ "<<", ">>" ] ] ), TRUE)
	Then("capped per side",
		ListEq( o1.BoundsOfXT("word", [ 1, 2 ]), [ [ "<", ">>" ] ] ), TRUE)
	Then("the UpToNChars spelling",
		ListEq( o1.BoundsOfUpToNChars("word", 2), [ [ "<<", ">>" ] ] ) and
		ListEq( o1.BoundsOfUpToNChars("word", [ 1, 2 ]), [ [ "<", ">>" ] ] ), TRUE)
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
