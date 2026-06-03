# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #702.
#ERR Error (R14) : Calling Method without definition: findsubstringbetween

load "../../stzBase.ring"

pr()

o1 = new stzString("opsus amcKLMbmi findus")

? o1.FindSubStringBetween("KLM", "amc", "bmi") # Or simply FindBetween()
#--> 10

pf()
# Executed in 0.01 second(s).
