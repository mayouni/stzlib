# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #343.

load "../../../stzBase.ring"

#                      4 6  90  3 5
o1 = new stzString("*aa***aa**aa***aa*")

? o1.FindAnyBoundedBy([ "aa", "aa" ])
#--> [4, 9, 13]

? @@( o1.FindAnyBoundedByAsSections([ "aa", "aa" ]) )
#--> [ [ 4, 6 ], [ 9, 10 ], [ 13, 15 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.15 second(s) in ring 1.17

pf()
