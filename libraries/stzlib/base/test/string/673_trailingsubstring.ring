# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #673.

load "../../stzBase.ring"

pr()

o1 = new stzString("12.4560000")

? o1.TrailingSubString()
#--> "0000"

? @@( o1.TrailingSubStringZZ() )
#--> [ "0000", [ 7, 10 ] ]

o1.RemoveTrailingSubString()
? o1.Content()
# 12.456

pf()
# Executed in 0.01 second(s).
