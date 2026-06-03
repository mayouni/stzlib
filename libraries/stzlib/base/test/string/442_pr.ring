# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #442.

load "../../stzBase.ring"


o1 = new stzString("RingRingRing")

? o1.SplitAtCharsWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitWXT(:AtChars = "Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

pf()
# Executed in 0.31 second(s) in Ring 1.21
