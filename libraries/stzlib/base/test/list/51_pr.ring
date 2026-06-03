# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #51.

load "../../stzBase.ring"


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
