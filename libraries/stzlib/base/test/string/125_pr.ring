# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #125.

load "../../stzBase.ring"


o1 = new stzString("RINGORIALAND")

? o1.NumberOfSubStrings()
#--> 78

? @@S( o1.SubStrings() ) # S --> short : to show just a part of the long list
#--> [ "R", "RI", "RIN", ..., "N", "ND", "D" ]

pf()
#--> Executed in 0.01 second(s)
