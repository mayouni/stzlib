# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #64.

load "../../stzBase.ring"

pr()

o1 = new stzString("1♥♥456♥♥901♥♥4")
o1.RemoveSections([ 2:3, 7:8, 12:13 ])
? o1.Content()
#--> 14569014

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17
