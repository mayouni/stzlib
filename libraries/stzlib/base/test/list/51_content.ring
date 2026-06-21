# Narrative
# --------
# ReplaceThisItemAt: same guarded behaviour as #50, shown with the bare
# positional 3-arg form.
#
# First call uses ReplaceThisItemAt(3, "♥", "★") -- no :With label, the third
# argument is the replacement -- and succeeds since position 3 holds "♥".
# The second call (on a fresh list) guards on "BLA" at position 2, which
# holds 2, so it is a no-op and the list stays unchanged.
#
# Extracted from stzlisttest.ring, block #51.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceThisItemAt(3, "♥", "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replace. Otherwise, nothing
# will happen. In fact:

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])
o1.ReplaceThisItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, "♥" ]

pf()
# Executed in 0.05 second(s)
