# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #908.

load "../../stzBase.ring"


o1 = new stzlist([ "R", "I", "N", "G" ])
? o1.FindMany([ "R", "I", "N", "G" ])
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in almost 0 second(s).
