# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #724.

load "../../../stzBase.ring"


o1 = new stzString("LIFE")

? o1.Inverted()
#--> EFIL

? o1.CharsInverted() + NL
#--> ⅂IℲƎ

? o1.Turned()
#--> ƎℲI⅂

? o1.CharsTurned()
#--> ⅂IℲƎ

pf()
# Executed in 0.09 second(s).
