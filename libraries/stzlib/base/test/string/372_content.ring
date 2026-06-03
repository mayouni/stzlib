# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #372.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC456DE")
o1.RemoveSection(4, 6)
? o1.Content()
#--> "ABCDE"

pf()
# Executed in 0.01 second(s) in Ring 1.21
