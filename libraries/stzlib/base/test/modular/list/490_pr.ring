# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #490.

load "../../../stzBase.ring"


o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindNthNextOccurrence( 2, :Of = 120, :StartingAt = 1 ) #--> 6
#--> 6

pf()
# Executed in almost 0 second(s).
