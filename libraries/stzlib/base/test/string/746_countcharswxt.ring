# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #746.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

o1 = new stzString("SoftAnza Libraray")

? o1.CountCharsWXT('{ @Char = "a" }')
#--> 3

? o1.CountCharsWXT('{	Q(@Char).IsEqualToCS("a", :CS = FALSE) }')
#--> 4

pf()
# Executed in 0.30 second(s).
