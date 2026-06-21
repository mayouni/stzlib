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

pr()

o1 = new stzList([ "ee♥ee", "b♥bbb", "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ ["ee","♥","ee"], ["♥", "bb"], "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ "a♥a" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ 0, "a♥a" ])
? o1.EachContains("♥")
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.19
