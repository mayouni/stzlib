# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #341.

load "../../../stzBase.ring"

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@( o1.FindSubStringsBoundedByZZ(["aa", "aa"]) )
#--> [ [ 5, 7 ], [ 10, 11 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
