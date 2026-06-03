# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #25.

load "../../stzBase.ring"


? SomeXT( NumbersIn( -5 : 5 ), 20/100 )
#--> [ -5, 0, 4 ]

? FewXT( NumbersIn( -5 : 5 ), 5/100 )
#--> [ 2 ]

? MostXT( PositiveNumbersIn( -5 : 5 ), 90/100 )
#--> [ 3, 4, 5, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
