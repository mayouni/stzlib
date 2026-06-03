# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #800.

load "../../stzBase.ring"

pr()

o1 = new stzString("سلام لأهل مصر الكرام")
o1.RemoveNLeftChars(7)
? o1.Content()
o#--> سلام لأهل مصر

pf()
# Executed in 0.01 second(s).
