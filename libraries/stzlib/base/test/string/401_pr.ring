# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #401.

load "../../stzBase.ring"


o1 = new stzString("*4*34")
? o1.NumberOfSubStrings()
#--> 15

? @@( o1.SubStrings() )
#--> [
#	"*", "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*",
#	"*3", "*34", "3", "34", "4"
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
