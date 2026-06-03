# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #127.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("BEbe")

? o1.NumberOfSubStringsCS(TRUE)
#--> 10

? @@( o1.SubStringsCS(TRUE) )
#--> [ "B", "BE", "BEb", "BEbe", "E", "Eb", "Ebe", "b", "be", "e" ]

? o1.NumberOfSubStringsCS(FALSE)
#--> 7

? @@( o1.SubStringsCS(FALSE) )
#--> [ "b", "be", "beb", "bebe", "e", "eb", "ebe" ]

pf()
# Executed in 0.01 second(s)
