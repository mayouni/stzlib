# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #26.

load "../../stzBase.ring"


o1 = new stzString("12.58000")
o1.RemoveThisCharFromRightXT("0") # Or RemoveAnyOccurrenceOfCharFromRight("0")
? o1.Content()
#--> 12.58

pf()
# Executed in 0.01 second(s).
