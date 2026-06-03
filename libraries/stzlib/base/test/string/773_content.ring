# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #773.
#ERR Error (R14) : Calling Method without definition: replaceeachleadingchar

load "../../stzBase.ring"

pr()

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingChar(:With = "*")
? o1.Content()
#--> ***VAR---

o1 = new stzString("___VAR---")
o1.ReplaceEachTrailingChar(:With = "*")
? o1.Content()
#--> ___VAR***

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingAndTrailingChar(:With = "*")
? o1.Content()
#--> ***VAR***

pf()
# Executed in 0.02 second(s).
