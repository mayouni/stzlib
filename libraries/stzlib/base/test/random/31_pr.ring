# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #31.

load "../../stzBase.ring"


? ARandomNumberLessThan(10)
#--> 2

? ARandomNumberIn(1:10) 
#--> 1

? @@( ARandomNumberInZ(1:10) ) + NL
#--> [ 2, 2 ]

? RandomNumberBetween(100, 150) + NL
#--> 149

? @@( NRandomNumbersBetween(3, 100, 110) ) + NL
#--> [ 101, 101, 101 ]

? @@( NRandomNumbersBetweenU(3, 100, 110) ) + NL
#--> [ 102, 109, 105 ]

? @@( NRandomNumbersBetweenZ(3, 100, 110) ) + NL
#--> [ [ 105, 6 ], [ 108, 9 ], [ 105, 6 ] ]

? @@( NRandomNumbersBetweenUZ(3, 100, 110) )
#--> [ [ 102, 3 ], [ 106, 7 ], [ 103, 4 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.20
