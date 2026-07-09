# Narrative
# --------
# ReplaceAnyItemAt: single-position, unguarded replace.
#
# Overwrite position 3 with "★" regardless of its current value. The other
# "♥" (at position 5) is untouched -- this is position-addressed, not
# value-addressed. The :With label reads as "replace any item at 3 with ★".
#
# Extracted from stzlisttest.ring, block #49.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceAnyItemAt(3, :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.05 second(s) before
