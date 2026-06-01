# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #53.

load "../../../stzBase.ring"


o1 = new stzString("123ruby89")
o1.ReplaceAt(4, "ruby", "ring")
? o1.Content()
#--> 123ring89

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18
