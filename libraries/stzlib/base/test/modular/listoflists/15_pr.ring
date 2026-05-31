# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #15.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, 4, "|", 2, 3, 4, 5, "|", 2, 3, 4, 5 ])
#		      \_____/       \_____/          \_____/
#			 2             6                11

? o1.FindSubList([ 2, 3, 4 ])
#--> [ 2, 6, 11 ]

pf()
# Executed in 0.04 second(s).
