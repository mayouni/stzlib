# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #1.

load "../../stzBase.ring"


o1 = new stzNumbers([ 8, 12, 14, 18, 20, 24 ])
? @@( o1.Diffs() )
#--> [ 4, 2, 4, 2, 4 ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
