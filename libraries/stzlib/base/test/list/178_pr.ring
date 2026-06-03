# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #178.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1.RemoveSection(3, 8)
? @@( o1.Content() )
#--> [ 1, 2, 9, 10 ]

pf()
