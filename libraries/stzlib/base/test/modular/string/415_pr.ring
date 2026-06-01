# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #415.

load "../../../stzBase.ring"


o1 = new stzString("ABC")
? @@( o1.SubStrings() )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

pf()
# Executed in 0.02 second(s).
