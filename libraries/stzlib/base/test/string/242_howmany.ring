# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #242.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

#                      4     0     6    1
o1 = new stzString("---***---***---***---")

? o1.HowMany("***")
#--> 3

? o1.Nth(3, "***")
#--> 16

? o1.FindLast("***")
#--> 16

pf()
# Executed in 0.01 second(s) in Ring 1.21
