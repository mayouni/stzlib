# Narrative
# --------
# ReplaceTheseItemsAtPositionsByMany: replace the listed items, found at the
# given positions, distributing a small palette across the matches.
#
# At positions 1,3,4,6 the items [ "ring", "softanza" ] are replaced; the
# two replacements [ "♥", "♥♥" ] are spread across the four matched slots --
# the earlier matches take ♥ and the later ones ♥♥ -- giving
# [ "♥", "ruby", "♥", "♥♥", "php", "♥♥" ]. (The XT form, block #45, cycles
# the palette per match instead.)
#
# Extracted from stzlisttest.ring, block #43.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceTheseItemsAtPositionsByMany([ 1, 3, 4, 6 ], [ "ring", "softanza" ] , [ "♥", "♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "ruby", "♥", "♥♥", "php", "♥♥" ]

pf()
# Executed in almost 0 second(s)
