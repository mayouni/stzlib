# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #461.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "E", "a", "c", "V", "E" ])
? o1.FindMany([ "a", "c" ]) #--> [1, 3, 5]

? o1 - These([ "a", "c" ]) # Same as: o1.RemoveItemsAtPositions([ 1, 3, 5 ])
#--> [ "E", "V", "E" ]

pf()
# Executed in almost 0 second(s).
