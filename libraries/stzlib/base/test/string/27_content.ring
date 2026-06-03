# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #27.
#ERR Error (R14) : Calling Method without definition: removecharfromleft

load "../../stzBase.ring"

pr()

o1 = new stzString("00012.58")
o1.RemoveCharFromLeft("0")
? o1.Content()
#--> 0012.58

o1.RemoveCharFromLeftXT("0") # Or o1.RemoveAnyOccurrenceOfCharFromLeft("0")
? o1.Content()
#--> 12.58

pf()
# Executed in 0.01 second(s)
