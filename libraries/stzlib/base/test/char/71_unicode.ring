# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #71.
#ERR Error (R14) : Calling Method without definition: isarabic7arakah

load "../../stzBase.ring"

pr()

? Unicode("ُ") #--> 1615

o1 = new stzChar("ُ")

? o1.IsArabic7arakah() #--> TRUE

? o1.Name() #--> ARABIC DAMMA
? o1.NameIs("ARABIC DAMMA") #--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.23
