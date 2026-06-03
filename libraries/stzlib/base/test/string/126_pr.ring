# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #126.

load "../../stzBase.ring"


o1 = new stzString("BEBE")

? o1.NumberOfSubStringsU()
#--> 7

? @@( o1.SubStringsU() )
#-< [ "B", "BE", "BEB", "BEBE", "E", "EB", "EBE" ]

pf()
# Executed in 0.01 second(s)
