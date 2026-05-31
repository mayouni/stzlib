# Narrative
# --------
# Dynamic rule management
#
# Extracted from stzadverbtest.ring, block #6.

load "../../../stzBase.ring"


pr()

AddAdverbRule("^legal$", "legally", "exact", 2, "domain")
? Adverb("legal") #--> legally

AddAdverbRule("ment$", "mentally", "suffix", 4, "morphology")
? Adverb("payment") #--> paymentally

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.14 second(s) in Ring 1.22
