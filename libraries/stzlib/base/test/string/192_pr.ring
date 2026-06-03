# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #192.

load "../../stzBase.ring"


o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~") # Or :AtPosition
? o1.Content()
#--> ~~/♥\~~

pf()
#-- Executed in 0.01 second(s)
