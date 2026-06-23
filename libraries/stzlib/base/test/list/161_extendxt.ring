# Narrative
# --------
# ExtendXT(:ToPosition, :WithItemsIn): grow to a target length, distributing a
# pool of items into the new slots.
#
# ExtendXT reaches the absolute target length (:ToPosition = 5) and fills the
# missing slots by drawing from the :WithItemsIn pool in order, cycling the
# pool if more slots are needed. From [ "A", "B", "C" ] the two new slots take
# "D" and "E", giving the flat [ "A", "B", "C", "D", "E" ]. Contrast :With =
# val (block #160), which repeats a single filler value into every new slot.
#
# Extracted from stzlisttest.ring, block #161.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :WithItemsIn = [ "D", "E" ])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.05 second(s)
