# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #122.

load "../../stzBase.ring"


o1 = new stzString("<<***>>**<<***>>")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 3, 5 ], [ 12, 14 ] ]

pf()
# Executed in 0.07 second(s)
