# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #270.

load "../../stzBase.ring"

pr()

o1 = new stzString("99999999999")
o1.SpacifyXT( "_", 3, :Backward )

? o1.Content()
#--> 99_999_999_999

pf()
# Executed in 0.01 second(s)
