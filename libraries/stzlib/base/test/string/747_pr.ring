# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #747.

load "../../stzBase.ring"


o1 = new stzString("SoftAnza Libraray")
? o1.FindCharsWXT('{ StzCharQ(@Char).Lowercased() = "a" }')
#--> [ 5, 8, 14, 16 ]

pf()
# Executed in 0.19 second(s).
