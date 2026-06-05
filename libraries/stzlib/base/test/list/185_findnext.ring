# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #185.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

//? o1.Section(0, :Last)
#--> Error message: Array Access (Index out of range) !

? o1.FindNext(14, :StartingAt = 1)
#--> 3
# Executed in 0.06 second(s)

? @@( o1.Find(14) )
#--> [ 1, 3, 4 ]

? o1.FindFirst(4)
#--> 0

pf()
# Executed in 0.04 second(s)
