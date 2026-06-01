# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #275.

load "../../../stzBase.ring"


o1 = new stzString("99999999999")

o1.SpacifyXT( " ", 3, :Backward )
? o1.Content() + NL
#--> 99 999 999 999

pf()
# Executed in 0.01 second(s).
