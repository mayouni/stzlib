# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #344.

load "../../stzBase.ring"

#                      4 6      3 5
o1 = new stzString("*<<***>>**<<***>>*")

? o1.FindAnyBoundedBy([ "<<", ">>" ])
#--> [4, 13]

? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

? "--"

? o1.FindAnyBoundedByIB([ "<<", ">>" ])
#--> [2, 11]

? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.17
