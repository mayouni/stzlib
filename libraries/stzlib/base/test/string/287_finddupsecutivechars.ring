# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #287.
#ERR Error (R14) : Calling Method without definition: finddupsecutivechars

load "../../stzBase.ring"

pr()

#                   1234567890123457890
o1 = new stzString("ABBBBbbbbCCcFFFaABCC")

? @@( o1.FindDupSecutiveChars() ) + NL
#--> [ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ]

? @@( o1.FindDupSecutiveCharsZZ() ) + NL
#--> [ [ 3, 5 ], [ 7, 9 ], [ 11, 11 ], [ 14, 15 ], [ 20, 20 ] ]

pf()
# Executed in 0.02 second(s).
