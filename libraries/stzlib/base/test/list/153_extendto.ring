# Narrative
# --------
# ExtendTo() grows a list to a requested length, padding the new slots with 0.
#
# Starting from the range list [ 1, 2, 3 ] (built via the 1 : 3 shorthand),
# ExtendTo(5) stretches it to five items. The original elements are kept in
# place and the two added trailing slots are filled with the neutral filler
# value 0, yielding [ 1, 2, 3, 0, 0 ]. This is the Softanza idiom for
# resizing-up in place: you declare the target size and let the list backfill
# the gap, rather than appending elements one by one.
#
# Extracted from stzlisttest.ring, block #153.

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendTo(5)
o1.Show()
#--> [ 1, 2, 3, 0, 0 ]

pf()
# Executed in 0.03 second(s)
