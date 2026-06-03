# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #810.

load "../../stzBase.ring"


o1 = new stzString("extrasection")
o1.RemoveRange(1, 5)
? o1.Content()
#--> section

pf()
# Executed in 0.01 second(s).
