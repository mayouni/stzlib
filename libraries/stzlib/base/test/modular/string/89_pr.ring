# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #89.

load "../../../stzBase.ring"


#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSections("aa", "aa"))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

pf()
# Executed in 0.08 second(s)
