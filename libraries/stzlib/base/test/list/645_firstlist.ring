# Narrative
# --------
# FirstList / FindFirstList: locate the first SUBLIST inside a mixed list.
#
# In a list whose items are a mix of scalars and sublists, FirstList
# returns the first item that is itself a list, and FindFirstList returns
# its position. Here the range 1:3 (stored as the sublist [ 1, 2, 3 ]) is
# the first list-valued item, sitting at position 3.
#
# Extracted from stzlisttest.ring, block #645.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1:3, "C", "D", 4:5 ])
? o1.FirstList()
#--> [ 1, 2, 3 ]

? o1.FindFirstList()
#--> 3

pf()
# Executed in almost 0 second(s)
