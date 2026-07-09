# Narrative
# --------
# Demonstrates stzList.EachContains() -- a whole-list predicate that
# returns TRUE only when EVERY item of the list "contains" the probe.
#
# For a string item, "contains" means the substring test: "ee♥ee"
# contains "♥". For a sublist item, it means membership: ["ee","♥","ee"]
# contains the element "♥". So a list mixing strings and sublists still
# answers TRUE as long as each item passes its own containment check.
# The probe here is the heart glyph; the codepoint-aware engine matches it
# correctly inside multibyte strings. The final case fails because the
# number 0 cannot contain "♥", so EachContains() short-circuits to FALSE.
#
# Extracted from stzlisttest.ring, block #113.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Demonstrates stzList.EachContains() -- a whole-list predicate that returns TRUE only when")

	o1 = new stzList([ "ee♥ee", "b♥bbb", "ccc♥", "♥♥" ])
	Then("eachcontains example 1", @@( o1.EachContains("♥") ), @@( TRUE ))

	o1 = new stzList([ ["ee","♥","ee"], ["♥", "bb"], "ccc♥", "♥♥" ])
	Then("eachcontains example 2", @@( o1.EachContains("♥") ), @@( TRUE ))

	o1 = new stzList([ "a♥a" ])
	Then("eachcontains example 3", @@( o1.EachContains("♥") ), @@( TRUE ))

	o1 = new stzList([ 0, "a♥a" ])
	Then("eachcontains example 4", @@( o1.EachContains("♥") ), @@( FALSE ))
EndScenario()

Summary()
