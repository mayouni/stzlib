# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #91.

load "../../stzBase.ring"

pr()

o1 = new stzString("---♥♥...**---")

? o1.SubStringComesBetween("...", "♥♥", "**")
#--> TRUE

? o1.SubStringComesBetween("...", "**", "♥♥")
#--> TRUE

pf()
# Executed in 0.05 second(s)
