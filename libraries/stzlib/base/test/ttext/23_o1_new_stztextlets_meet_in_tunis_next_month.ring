# Narrative
# --------
# o1 = new stzText("Let's meet in Tunis next month!")
#
# Extracted from stzTtexttest.ring, block #23.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

o1.ReplaceWord("Tunis", :With = "Cairo")
? o1.Content()

pf()
