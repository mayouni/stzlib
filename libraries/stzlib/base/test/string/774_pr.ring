# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #774.

load "../../stzBase.ring"


o1 = new stzString("___VAR---")
o1.ReplaceLeadingChar("_", :With = "*")
? o1.Content()
#--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChar("-", :With = "*")
? o1.Content()
#--> ___VAR*

pf()
# Executed in 0.02 second(s).
