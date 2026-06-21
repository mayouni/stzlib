# Narrative
# --------
# Picking several items at once by their positions with ItemsAtPositions().
#
# A stzList built from the range "A":"E" holds [ "A", "B", "C", "D", "E" ].
# ItemsAtPositions([2, 3]) returns the items sitting at positions 2 and 3,
# i.e. [ "B", "C" ], preserving the order in which the positions were asked.
# This is the multi-position read counterpart to a single Item(n) lookup:
# one call, a list of 1-based positions in, the matching items out.
#
# Extracted from stzlisttest.ring, block #89.

load "../../stzBase.ring"

pr()

o1 = new stzList("A" : "E")
? o1.ItemsAtPositions([2, 3])
#--> [ "B", "C" ]

pf()
#--> Executed in 0.03 second(s)
