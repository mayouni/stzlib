# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #789.

load "../../../stzBase.ring"


o1 = new stzstring("123456789")
o1.ReplaceSection(4, 6, :with = "***")
? o1.Content()
#--> "123***789"

pf()
# Executed in 0.01 second(s).
