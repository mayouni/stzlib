# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #9.

load "../../../stzBase.ring"


? @@( StzNullObjectQ() )
#--> @noname

? @@([ StzNullObjectQ() ])
#--> [ @noname ]

? @@([ 1:3, StzNullObjectQ(), "a":"b", StzFalseObjectQ() ])
#!--> [ [ 1, 2, 3 ], @noname, [ "a", "b" ], @noname ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20
