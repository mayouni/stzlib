# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #855.

load "../../stzBase.ring"


o1 = new stzString("saस्तेb")
? o1.NumberOfChars()
#--> 7

? @@( o1.Unicodes() )
#--> [ 115, 97, 2360, 2381, 2340, 2375, 98 ]

? @@( o1.UnicodesXT() )
#--> [ [ 115, "s" ], [ 97, "a" ], [ 2360, "स" ], [ 2381, "्" ], [ 2340, "त" ], [ 2375, "े" ], [ 98, "b" ] ]

? @@( o1.CharsAndTheirUnicodes() )
#--> [ [ "s", 115 ], [ "a", 97 ], [ "स", 2360 ], [ "्", 2381 ], [ "त", 2340 ], [ "े", 2375 ], [ "b", 98 ] ]

pf()
# Executed in 0.03 second(s).
