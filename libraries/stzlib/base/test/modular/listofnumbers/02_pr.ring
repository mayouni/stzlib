# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #2.

load "../../../stzBase.ring"


o1 = new stzNumbers([ 8, 12, 14, 18, 20, 24 ])
? @@( o1.DiffWith(12) )
#--> [ -4, 0, 2, 6, 8, 12 ]

pf()
