# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #889.

load "../../stzBase.ring"


o1 = new stzString("__^^^__^^♥^^__")
o1.RemoveSubStringBoundedBy("♥", "^^")
? o1.Content()
#--> __^^^__^^^^__

pf()
# Executed in 0.03 second(s).
