# Narrative
# --------
# MOVING AND SWAPPING
#
# Extracted from stzlisttest.ring, block #365.

load "../../stzBase.ring"


pr()

o1 = new stzList([ "C", "B", "A" ])
o1.Move( :From = 3, :To = 1 )
? o1.Content() #--> [ "A", "C", "B" ]

o1.Swap( :Items = 2, :AndItem = 3 )
? o1.Content() #--> [ "A", "B", "C" ]

pf()
# Executed in 0.06 second(s).
