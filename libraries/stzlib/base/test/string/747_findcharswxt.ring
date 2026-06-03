# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #747.
#ERR Error (R14) : Calling Method without definition: findcharswxt

load "../../stzBase.ring"

pr()

o1 = new stzString("SoftAnza Libraray")
? o1.FindCharsWXT('{ StzCharQ(@Char).Lowercased() = "a" }')
#--> [ 5, 8, 14, 16 ]

pf()
# Executed in 0.19 second(s).
