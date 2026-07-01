load "../../stzBase.ring"
load "../_narrated.ring"

# Unspacified() edge cases. Per the original monolith impl (Trim + collapse
# duplicate-consecutive spaces -- the authority, matching sibling block #293),
# all-space strings trim to "" and inner runs of 2+ spaces collapse to one.
# NOTE: the archive #--> of this block predates that impl (pure-trim era with
# an all-space quirk: "  " -> " ", "r  in  g " -> "r  in  g" "not removing
# spaces inside") and contradicts BOTH the archived impl and block #293's
# collapse of "   za" -> " za"; asserted at the original-impl behavior and
# logged in _AUDIT_DEFECTS.md. Archive block #295.

Scenario("Unspacified on all-space strings")
	Then('" " trims away', @@( Q(" ").Unspacified() ), '""')
	Then('"  " trims away', @@( Q("  ").Unspacified() ), '""')
	Then('"   " trims away', @@( Q("   ").Unspacified() ), '""')
EndScenario()

Scenario("Unspacified trims edges around content")
	Then('" ♥" -> "♥"', Q(" ♥").Unspacified(), "♥")
	Then('"♥ " -> "♥"', Q("♥ ").Unspacified(), "♥")
	Then('" ♥ " -> "♥"', Q(" ♥ ").Unspacified(), "♥")
EndScenario()

Scenario("Unspacified collapses inner runs to one space")
	Then('"r  in  g " -> "r in g"', Q("r  in  g ").Unspacified(), "r in g")
	Then('"    r  in  g " -> "r in g"', Q("    r  in  g ").Unspacified(), "r in g")
EndScenario()

Summary()
