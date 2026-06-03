# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #122.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("<<***>>**<<***>>")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 3, 5 ], [ 12, 14 ] ]

pf()
# Executed in 0.07 second(s)
