# Narrative
# --------
# FLOOR-2 SUGAR -- the readable boolean NARRATIVE, rebuilt THIN. The old
# stzChainOfTruth eval()'d user strings per step; this rebuild is eval-free:
# every predicate word resolves through the ONE lexicon to a DESCRIPTOR, and
# the chain folds once through the deterministic @is<X> dispatch (the same
# substrate as constraints + modality). Deterministic -> CERTAIN; accountable
# -> Why() narrates the verdict.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("A truth narrative folds descriptor atoms to one verdict")
	Then("all-true AND chain holds",
		TruthOf("ring").IsA(:Lowercase).AndIsA(:Latin).AndContaining("g").Holds(), TRUE)
	Then("...and Why narrates it",
		Why(), 'yes: "ring" is lowercase and is latin and containing "g"')
	Then("a failing atom breaks the AND",
		TruthOf("ring").IsA(:Uppercase).Holds(), FALSE)
	Then("...", Why(), 'no: "ring" is not (is uppercase)')
EndScenario()

Scenario("Numbers narrate too")
	Then("positive AND even", TruthOf(42).IsA(:Positive).AndIsA(:Even).Holds(), TRUE)
	Then("positive AND odd fails", TruthOf(42).IsA(:Positive).AndIsA(:Odd).Holds(), FALSE)
EndScenario()

Scenario("OR and NOT compose (left-to-right reading)")
	Then("uppercase word satisfies the OR",
		TruthOf("RING").IsA(:Lowercase).OrIsA(:Uppercase).Holds(), TRUE)
	Then("mixed case satisfies NEITHER side",
		TruthOf("Ring").IsA(:Lowercase).OrIsA(:Uppercase).Holds(), FALSE)
	Then("AND-NOT negates the next atom",
		TruthOf("ring").IsA(:Lowercase).AndIsNotA(:Uppercase).Holds(), TRUE)
EndScenario()

Scenario("Lists narrate by type + membership")
	Then("a list of numbers containing 2",
		TruthOf([ 1, 2, 3 ]).IsA(:ListOfNumbers).AndContaining(2).Holds(), TRUE)
EndScenario()

Scenario("Verdicts are CERTAIN in the evidential register")
	TruthOf("ring").IsA(:Lowercase).Holds()
	Then("a deterministic narrative answers certainly", Certainty(), 1)
	Then("...", Evidentially(), "certainly")
EndScenario()

Summary()
