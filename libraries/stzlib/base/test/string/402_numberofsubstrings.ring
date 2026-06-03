# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #402.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("123456")
? o1.NumberOfSubStrings()
#--> 21

? @@( o1.SubStrings() )
#--> [
#	"1", "12", "123", "1234", "12345", "123456", "2",
#	"23", "234", "2345", "23456", "3", "34", "345",
#	"3456", "4", "45", "456", "5", "56", "6"
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.19
