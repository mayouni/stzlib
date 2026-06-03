# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #365.

load "../../stzBase.ring"


o1 = new stzString("...ONE...TWO...ONE")
? @@( o1.FindSubstringsWXT('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ 4, 10, 16 ]

? @@( o1.FindSubstringsWXTZZ('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]

pf()
# Executed in 1.28 second(s) in Ring 1.21
# Executed in 3.91 second(s) in Ring 1.18
