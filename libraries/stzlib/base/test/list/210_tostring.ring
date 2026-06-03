# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #210.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 7 ])

? @@( o1.ToString() ) + NL
#-->
# "1
#  2
#  3
#  *
#  5
#  6
#  *
#  7"

? @@( o1.Stringified() ) + NL
#--> [ "1", "2", "3", "*", "5", "6", "*", "7" ]

? o1.ToCode()
#--> [ 1, 2, 3, "*", 5, 6, "*", 7 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.7
