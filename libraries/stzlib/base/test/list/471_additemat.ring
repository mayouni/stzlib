# Narrative
# --------
# Inserting an item beyond the current end of a stzList, and reading
# back the whole underlying list with Content().
#
# Starting from [ 1 .. 5 ], AddItemAt(8, 9) asks to place the value 9
# at position 8. Positions 6 and 7 do not yet exist, so Softanza grows
# the list and pads the gap with empty-string slots ("") rather than a
# special NULL marker -- Ring lists have no real null, so the empty
# string is the canonical filler. Content() then returns the raw,
# unwrapped list including those padding cells, giving
# [ 1, 2, 3, 4, 5, "", "", 9 ].
#
# Extracted from stzlisttest.ring, block #471.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:5)
o1.AddItemAt(8, 9)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, "", "", 9 ]

pf()
# Executed in almost 0 second(s).
