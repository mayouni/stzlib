# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #809.

load "../../../stzBase.ring"


o1 = new stzString("extrasection")
o1.RemoveSectionQ(6, :LastChar)
? o1.Content()
#--> extra

pf()
# Executed in 0.01 second(s).
