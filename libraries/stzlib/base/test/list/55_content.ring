# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #55.
#ERR Error (R14) : Calling Method without definition: replacebymany

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, :♥, 3, 4, :♥, :♥ ])
anPos = o1.Find(:♥)
#--> [ 2, 5, 6 ]

o1.ReplaceByMany(:♥, [2, 5, 6])
? o1.Content()

#--> [ 1, 2, 3, 4, 5, 6 ]

pf()
# Executed in 0.04 second(s)
