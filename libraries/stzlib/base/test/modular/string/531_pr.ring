# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #531.

load "../../../stzBase.ring"


o1 = new stzString("what a <<nice>>> day!")

? o1.Section(3, 3)
#--> "a"

? o1.Section(10, 13)
#--> "nice"

? o1.Section(13, 10)
#--> "nice"

pf()
# Executed in 0.01 second(s) in Ring 1.22
