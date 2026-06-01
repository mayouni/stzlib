# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #414.

load "../../../stzBase.ring"


o1 = new stzString("AB12CD345")
? @@( o1.SplitToPartsOfNChars(2) ) # Same as SplitToPartsOfExactlyNChars(2)
#--> [ "AB", "12", "CD", "34" ]

? @@( o1.SplitToPartsOfNCharsXT(2) )
#--> [ "AB", "12", "CD", "34", "5" ]

pf()
# Executed in 0.04 second(s).
