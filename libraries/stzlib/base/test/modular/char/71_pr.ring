# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #71.

load "../../../stzBase.ring"


? Unicode("ُ") #--> 1615

o1 = new stzChar("ُ")

? o1.IsArabic7arakah() #--> TRUE

? o1.Name() #--> ARABIC DAMMA
? o1.NameIs("ARABIC DAMMA") #--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.23
