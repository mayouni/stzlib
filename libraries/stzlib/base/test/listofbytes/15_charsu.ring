# Narrative
# --------
#
# Extracted from stzlistofbytestest.ring, block #15.

load "../../stzBase.ring"

pr()

o1 = new stzString("ssdsd")

? o1.CharsU()
#--> [ "s", "d" ]

? @@( o1.Unicodes() )
#--> [ 115, 115, 100, 115, 100 ]

? @@( o1.CharsAndUnicodes() ) # Same as o1.UnicodePerChar()
#--> [ [ "s", 115 ], [ "s", 115 ], [ "d", 100 ], [ "s", 115 ], [ "d", 100 ] ]

? @@( o1.CharsAndUnicodesU() )
#--> [ [ "s", 115 ], [ "d", 100 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.12 second(s) in Ring 1.17
