# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #231.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ExtractNumbers() is broken three
# ways on "Math: 18, Geo: 16, :Physics: 17.80": it splits "17.80" into 17 and 80
# (decimal not handled -- though Numbers() handles decimals, blocks 228/230), it
# returns NUMBERS not strings ([18,16,17,80]), and it does NOT mutate the string
# (Content() is unchanged, but Extract should REMOVE the numbers leaving
# "Math: , Geo: , :Physics: "). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
? @@( o1.ExtractNumbers() )
#--> expected [ "18", "16", "17.80" ] (currently [ 18, 16, 17, 80 ])

? o1.Content()
#--> expected "Math: , Geo: , :Physics: " (currently unchanged)

pf()
