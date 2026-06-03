# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #556.

load "../../stzBase.ring"


o1 = new stzString("12*A*33*A*")
? o1.FindAll("*")
#--> [3, 5, 8, 10]

? o1.FindNth(3, "*") + NL
#--> 8

? o1.FindFirst("*") + NL
#--> 3

? o1.FindLast("*") + NL
#--> 10

? @@( o1.FindAsSections("*") )
#--> [ [ 3, 3 ], [ 5, 5 ], [ 8, 8 ], [ 10, 10 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.20
