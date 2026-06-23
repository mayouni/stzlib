# Narrative
# --------
# Removing a value from a stzList deletes every occurrence of it, not just the first.
#
# The list [ 10, 1, 2, 3, 10 ] has 10 at both ends. A single call to
# Remove(10) strips both, leaving [ 1, 2, 3 ]. Softanza's Remove(value)
# is value-based and global: it targets the item by identity wherever it
# appears, in contrast to position-based removal. Content() then yields
# the surviving items in their original order.
#
# Extracted from stzlisttest.ring, block #511.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 10, 1, 2, 3, 10 ])

o1.Remove(10)
? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s).
