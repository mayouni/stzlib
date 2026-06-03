# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #824.

load "../../stzBase.ring"


o1 = new stzString("Hi Dan! You are Dan, but your work is never done! 😉")
o1.ReplaceNthOccurrence(2, "Dan", "hardworker")

? o1.Content()
#--> Hi Dan! You are hardworker, but your work is never done! 😉

pf()
# Executed in 0.01 second(s).
