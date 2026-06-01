# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #276.

load "../../../stzBase.ring"


o1 = new stzString("99999999999")
o1.SpacifyXT( :Using = " ", :Step = 3, :Going = :Backward )
? o1.Content()
#--> 99 999 999 999

pf()
# Executed in 0.03 second(s).
