# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #503.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789RING")
? o1.FindNextSTCS("ring", 5, FALSE)
#--> 10

pf()
# Executed in 0.01 second(s) in Ring 1.22
