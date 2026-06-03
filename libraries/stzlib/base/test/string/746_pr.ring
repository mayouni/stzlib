# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #746.

load "../../stzBase.ring"


o1 = new stzString("SoftAnza Libraray")

? o1.CountCharsWXT('{ @Char = "a" }')
#--> 3

? o1.CountCharsWXT('{	Q(@Char).IsEqualToCS("a", :CS = FALSE) }')
#--> 4

pf()
# Executed in 0.30 second(s).
