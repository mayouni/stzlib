# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #271.
#ERR Error (R14) : Calling Method without definition: spacifyxt

load "../../stzBase.ring"

pr()

o1 = new stzString("99999999999")
o1.SpacifyXT( :Using = "_", :Step = 3, :Direction = :Backward )

? o1.Content()
#--> 99_999_999_999

pf()
# Executed in 0.02 second(s)
