# Narrative
# --------
# Reversed: return the list in reverse order, without touching the original.
#
# The ..ed form is non-mutating (contrast Reverse(), which flips in place).
# Built from the integer range 1:3, so o1 holds [ 1, 2, 3 ] and Reversed()
# yields [ 3, 2, 1 ].
#
# Extracted from stzlisttest.ring, block #70.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:3)
? o1.Reversed()
#--> [ 3, 2, 1 ]

pf()
# Executed in 0.03 second(s)
