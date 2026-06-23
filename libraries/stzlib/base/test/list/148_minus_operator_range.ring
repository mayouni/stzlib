# Narrative
# --------
# The (-) operator is NON-mutating: a bare subtraction statement changes
# nothing.
#
# Softanza's stzList (-) returns a NEW list and never alters the receiver, so
# `o1 - 3:5` produces a value that is immediately discarded -- o1 itself is
# untouched and Show() prints the original [ 1, 2, 3, 4, 5, 6, 7 ]. (Even if
# the result were captured it would not be [ 1, 2, 6, 7 ]: a raw range RHS is
# removed as a SINGLE item, not as a section. Use RemoveSection(3,5) to drop a
# span, or These(3:5) for element-wise removal -- see block #72.)
#
# Extracted from stzlisttest.ring, block #148.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:7)
o1 - 3:5
o1.Show()
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

pf()
# Executed in 0.03 second(s)
