# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #240.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")

? o1.FirstHalf()
#--> 1234
? o1.SecondHalf() + NL
#--> 56789

? o1.Halves() # Or Bisect()
#--> [ "1234", "56789" ]

? o1.FirstHalfXT()
#--> 12345
? o1.SecondHalfXT() + NL
#--> 6789

? o1.HalvesXT() # Or BisectXT()
#--> [ "12345", "6789" ]


pf()
# Executed in 0.02 second(s)
