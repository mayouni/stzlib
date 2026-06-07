# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #90.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

#                       5 7  01    
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSectionsS("aa", "aa", :startingat = 2))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

pf()
