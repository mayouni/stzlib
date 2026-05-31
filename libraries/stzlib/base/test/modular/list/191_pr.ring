# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #191.

load "../../../stzBase.ring"


o1 = new stzList( 10:12 + "str1" + "str2" + [ "+", "-" ] + o1 )

? @@( o1.NumbersAndStrings() )
#--> [ 10, 11, 12, "str1", "str2" ]

? @@( o1.NumbersAndStringsZ() )
#--> [ [ 10, 1 ], [ 11, 2 ], [ 12, 3 ], [ "str1", 4 ], [ "str2", 5 ] ]

pf()
# Executed in 0.04 second(s)
