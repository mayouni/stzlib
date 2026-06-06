# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #138.

load "../../stzBase.ring"

pr()

o1 = new stzString("123")
o1.ExtendToWithCharsRepeated(8)
o1.Show()
#--> "12312312"

pf()
# Executed in 0.01 second(s) in Ring 1.21
