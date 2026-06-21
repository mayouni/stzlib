# Narrative
# --------
# ExtendToWithItemsIn() grows a list up to a target length, filling the
# new slots by cycling through a supplied pool of items.
#
# Starting from [1,2,3] and asking to extend to length 8 with the pool
# "A":"C" (i.e. ["A","B","C"]), Softanza appends items drawn cyclically
# from the pool until the list reaches 8 entries: "A","B","C" fills slots
# 4-6, then the pool wraps to give "A","B" for slots 7-8. The pool is
# reused as many times as needed, never stopping mid-target, so the final
# length is exactly the requested 8.
#
# Extracted from stzlisttest.ring, block #156.

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsIn( 8, "A":"C" )
o1.Show()
#--> [ 1, 2, 3, "A", "B", "C", "A", "B" ]

pf()
# Executed in 0.03 second(s)
