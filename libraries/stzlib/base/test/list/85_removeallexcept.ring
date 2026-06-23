# Narrative
# --------
# RemoveAllExcept with a SET of keepers (the list-argument form).
#
# Pass a list [ "♥","★","🌞" ] and every item not in that set is dropped --
# the numbers go, leaving the three symbols in original order. The multibyte
# emoji "🌞" is matched whole (codepoint-correct, never byte-split).
#
# Extracted from stzlisttest.ring, block #85.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 1, 2, 2, "★", 3, "🌞" ])
o1.RemoveAllExcept([ "♥", "★", "🌞" ]) # Or RemoveItemsOtherThan()

? @@( o1.Content() )
#--> [ "♥", "★", "🌞" ]

pf()
# Executed in 0.04 second(s)
