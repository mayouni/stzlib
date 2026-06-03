# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #152.

load "../../stzBase.ring"

pr()

o1 = new stzString("softanza")
? o1.Section(4, 6)
#--> "tan"

? o1.Section(6, 4)
#--> "tan"

pf()
# Executed in 0.03 second(s)
