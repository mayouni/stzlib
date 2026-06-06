# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #780.

load "../../stzBase.ring"

pr()

o1 = new stzString("aaaaah Tunisia---")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oh Tunisia---

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Oh Tunisia!

pf()
# Executed in 0.02 second(s).
