# Narrative
# --------
# Two ways to render a stzList on the console: full vs elided.
#
# Show() prints every item of the list, here the full 1..18 range.
# ShowShort() is the compact variant: it keeps the first three and
# last three items and collapses the middle into a literal "..."
# marker, so a long list stays glanceable. The ellipsis is the
# bare three-dot string "..." (no surrounding spaces).
#
# Extracted from stzlisttest.ring, block #122.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Two ways to render a stzList on the console: full vs elided.")

	o1 = new stzList(1:18)

	Then("showshort example 1", @@( o1.Content() ), @@( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 ] ))

	o1.ShowShort()
EndScenario()

Summary()
