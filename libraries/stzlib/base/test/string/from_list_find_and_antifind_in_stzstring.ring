# Narrative
# --------
# Find and AntiFind in stzString
#
# Extracted from stzlisttest.ring, block #35.
#ERR Error (R14) : Calling Method without definition: antifind

load "../../stzBase.ring"


pr()

o1 = new stzString("12♥45♥67♥9")

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

? @@( o1.AntiFindZZ("♥") )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

pf()
