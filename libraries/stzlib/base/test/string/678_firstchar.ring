# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #678.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
? o1.FirstChar() #--> A
? o1.LastChar()  #--> C

pf()
# Executed in 0.01 second(s).
