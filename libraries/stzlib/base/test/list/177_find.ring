# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #177.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

? @@( o1.Find(14) )
#--> [ 1, 3, 4 ]

? o1.FindFirst(14)
#--> 1

? o1.FindLast(14)
#--> 4

? o1.FindNext(14, :StartingAt = 2)
#--> 3

pf()
# Executed in 0.05 second(s)
