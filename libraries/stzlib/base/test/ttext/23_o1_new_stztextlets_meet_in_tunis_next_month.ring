# Narrative
# --------
# o1 = new stzText("Let's meet in Tunis next month!")
#
# Extracted from stzTtexttest.ring, block #23.

load "../../stzBase.ring"

o1.ReplaceWord("Tunis", :With = "Cairo")
? o1.Content()
