# Narrative
# --------
# ReplaceThisItemAt: value-GUARDED single-position replace, and the no-op
# case when the guard fails.
#
# First call: at position 3 the item IS "♥", so it becomes "★". Second call:
# at position 2 the guard says "BLA" but the item is actually 2, so the
# guard fails and nothing changes -- "This...At" demands BOTH the position
# and the stated value to match. Contrast the unguarded "Any" form (#49).
#
# Extracted from stzlisttest.ring, block #50.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceThisItemAt(3, "♥", :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replaced. Otherwise, nothing
# will happen. In fact:

o1.ReplaceThisItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

pf()
# Executed in 0.05 second(s)
