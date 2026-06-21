# Narrative
# --------
# Inserting an element at a 1-based position with stzList.InsertAt().
#
# A stzList is built from [ "A", "C", "D" ], then InsertAt(2, "B")
# splices "B" in so it becomes the new second element, shifting "C"
# and "D" one slot to the right. Content() returns the whole list
# in its current order, confirming the insert landed at position 2
# rather than overwriting it. This is the object-oriented mirror of
# the equivalent free-function example shown just above in the
# source suite.
#
# Extracted from stzlisttest.ring, block #362.

load "../../stzBase.ring"

pr()

# Same example above in stzList

o1 = new stzList([ "A", "C", "D" ])
o1.InsertAt(2, "B")

? o1.Content()
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s).
