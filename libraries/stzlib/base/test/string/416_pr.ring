# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #416.

load "../../stzBase.ring"


o1 = new stzString("*#!ABC$^..")
? o1.NumberOfSubStrings()
#--> 55

? @@( o1.SubStringsWXT(' Q(@SubString).IsMadeOfLetters() ') )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

pf()
# Executed in 0.58 second(s) in Ring 1.22
# Executed in 0.99 second(s) in Ring 1.19
