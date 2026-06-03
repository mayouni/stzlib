# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #251.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC*EF")
# NOTE: QStringObject() removed -- Qt purged from Softanza
# Use engine-based replacement instead:
o1.ReplaceAt(4, "D")
? o1.Content()
#--> "ABCDEF"

pf()
# Executed in 0.01 second(s)
