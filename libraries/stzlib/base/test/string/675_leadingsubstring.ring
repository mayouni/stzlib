# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #675.

load "../../stzBase.ring"

pr()

o1 = new stzString("00012.456")

? o1.LeadingSubString()
#--> "000"

? @@( o1.LeadingSubStringZZ() )
#--> [ "000", [ 1, 3 ] ]

o1.RemoveLeadingSubString()
? o1.Content()
# 12.456

pf()
# Executed in 0.02 second(s).
