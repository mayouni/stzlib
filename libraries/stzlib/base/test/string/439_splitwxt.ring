# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #439.
#ERR Error (R14) : Calling Method without definition: splitwxt

load "../../stzBase.ring"

pr()

o1 = new stzString("RingRingRing")

? o1.SplitWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitAtWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitWXT(:At = "Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

pf()
# Executed in 0.41 second(s) in Ring 1.21
