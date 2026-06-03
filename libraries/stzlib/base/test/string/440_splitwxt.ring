# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #440.
#ERR Error (R14) : Calling Method without definition: splitwxt

load "../../stzBase.ring"

pr()

o1 = new stzString("RingRingRing")

? @@( o1.SplitWXT(:At = " @position % 4 = 0 ") )
#--> [ "Rin", "Rin", "Rin" ]

? @@( o1.SplitWXT(:After = " @position % 4 = 0 ") )
#--> [ "Ring", "Ring", "Ring" ]

pf()
# Executed in 0.19 second(s) in Ring 1.21
