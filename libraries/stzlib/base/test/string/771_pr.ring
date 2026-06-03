# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #771.

load "../../stzBase.ring"


o1 = new stzString("eeebxeTuniseee")

? o1.Section(:FirstChar, :LastChar)
#--> eeebxeTuniseee

? o1.Section( 7, 4 )
#--> Texb

pf()
# Executed in 0.01 second(s).
