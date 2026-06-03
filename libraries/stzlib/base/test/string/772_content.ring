# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #772.
#ERR Error (R14) : Calling Method without definition: replaceleadingchars

load "../../stzBase.ring"

pr()

o1 = new stzString("___VAR---")
o1.ReplaceLeadingChars(:With = "*")
? o1.Content()
#--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChars(:With = "*")
? o1.Content()
#--> ___VAR*

o1 = new stzString("___VAR---")
o1.ReplaceLeadingAndTrailingChars(:With = "*")
? o1.Content()
#--> *VAR*

pf()
# Executed in 0.02 second(s).
