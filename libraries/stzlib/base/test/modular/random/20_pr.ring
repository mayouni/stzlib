# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #20.

load "../../../stzBase.ring"



? Some( NumbersIn( -5 : 5 ) )
#--> [ -1, -4, -5, 3 ]

? Few( NumbersIn( -5 : 5 ) )
#--> [ 0, -4 ]

? All( EvenNumbersIn( -5 : 5 ) )
#--> [ -4, -2, 0, 2, 4 ]

? Half( OddNumbersIn( -5 : 5 ) )
#--> [ -5, 1, 3 ]

? Most( PositiveNumbersIn( -5 : 5 ) )
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
