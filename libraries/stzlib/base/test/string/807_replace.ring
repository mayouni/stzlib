# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #807.

load "../../stzBase.ring"

pr()

o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceQ("xo", "ng").Content()
#--> Ring Ring Ring

pf()
# Executed in 0.01 second(s).
