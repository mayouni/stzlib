# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #368.

load "../../stzBase.ring"

pr()

o1 = new stzString(" <<<<word>>> and ~~~~word~~~~~ ")

? @@( o1.BoundsOf( "word") )
#--> [ "<<<<", ">>>", "~~~~", "~~~~~" ]

? @@( o1.BoundsOfXT( "word", [ 3, 2 ] ) )
#--> [ "<<<", ">>", "~~~", "~~" ]

? @@( o1.BoundsOfXT( "word", 8 ) )
#--> [ "<<<<", ">>>", "~~~~", "~~~~~" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.17
