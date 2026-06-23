# Narrative
# --------
# ExtendToWithItemsRepeated() grows a list up to a target position by
# cycling the list's own items.
#
# Starting from [ 1, 2, 3 ], ExtendToWithItemsRepeated(8) extends the
# list TO position 8 (a final length of 8), filling the new slots by
# repeating the existing items in order: 1, 2, 3, 1, 2, 3, 1, 2.
# Note the "ExtendTo" semantics here are absolute (extend up to the
# given position), consistent with ExtendToWithItemsIn in block 156 --
# not a relative "extend BY 8" growth.
#
# Extracted from stzlisttest.ring, block #155.

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsRepeated(8)
o1.Show()
# Modernized: ExtendToWithItemsRepeated(8) extends the list TO position 8
# by cycling its own items (consistent with ExtendToWithItemsIn in 156).
# The old extracted output below assumed an "extend BY 8" semantics.
#--> [ 1, 2, 3, 1, 2, 3, 1, 2 ]

pf()
# Executed in 0.03 second(s)
