# Narrative
# --------
# The (-) operator is NON-mutating, so a bare subtraction statement is a no-op.
#
# `o1 - 4:6` computes a new list and discards it -- Softanza's stzList (-)
# never alters the receiver -- so Content() still returns the original 1..7.
# Even captured it would not be [ 1, 2, 3, 7 ]: a raw range RHS is removed as a
# SINGLE item (the sublist [4,5,6], absent here), not as a position span. To
# drop positions 4..6 use RemoveSection(4, 6); for element-wise removal use
# These(4:6). (Same semantics as blocks #72 and #148.)
#
# Extracted from stzlisttest.ring, block #261.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:7)
o1 - 4:6

? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
