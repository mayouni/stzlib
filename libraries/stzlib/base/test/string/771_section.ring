# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #771.
#ERR Error (R41) : Invalid numeric string

load "../../stzBase.ring"

pr()

o1 = new stzString("eeebxeTuniseee")

? o1.Section(:FirstChar, :LastChar)
#--> eeebxeTuniseee

? o1.Section( 7, 4 )
#--> Texb

pf()
# Executed in 0.01 second(s).
