# Narrative
# --------
# Walks the family of in-place removal methods on a stzList, each
# stripping one item from a running list seeded with "_" separators.
#
# The point is the spread of removal idioms Softanza offers: by edge
# (RemoveFirstItem), by the Nth occurrence of a value (RemoveThisNthItem,
# RemoveNth), by first occurrence of a value (RemoveFirst), the same with
# a case-insensitivity dial (RemoveThisFirstItemCS with :CS = FALSE so
# "b" matches "B"), and by symbolic position. Note the comment on
# RemoveNthItem(:Last): :Last only works because CheckParams() is TRUE;
# otherwise prefer RemoveLastItem() or RemoveNthItem(NumberOfItems()).
# Content() reports the mutated list after each step.
#
# Extracted from stzlisttest.ring, block #328.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "A", "B", "C", "_", "D", "E", "_" ])

o1.RemoveFirstItem()
? @@( o1.Content() )
#--> [ "A", "B", "C", "_", "D", "E", "_" ]

o1.RemoveThisNthItem(1, "A")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E", "_" ]

o1.RemoveNth(2, "_")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E" ]

o1.RemoveFirst("_")
? @@( o1.Content() )
#--> [ "B", "C", "D", "E" ]

o1.RemoveThisFirstItemCS("b", :CS = FALSE)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last) # CheckParams() should be TRUE, otherwise :Last raises an error
			# You can use o1.RemoveNthItem(o1.NumberOfItems()) or
			# o1.RemoveLastItem() instead
? @@( o1.Content() )
#--> [ "C", "D" ]

pf()
# Executed in 0.02 second(s)
