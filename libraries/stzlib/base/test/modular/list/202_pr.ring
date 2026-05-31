# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #202.

load "../../../stzBase.ring"


o1 = new stzString("123456789")

? o1.SectionXT(5, 3) # Same as Section(3, 5)
#--> 534

? o1.SectionXT(5, -3)
#--> 567

pf()
# Executed in 0.01 second(s) in Ring 1.21
