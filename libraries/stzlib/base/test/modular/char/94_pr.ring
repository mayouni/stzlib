# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #94.

load "../../../stzBase.ring"


lower("Ⅺ")
o1 = new stzChar("Ⅺ")
? o1.lowercased() #--> ⅺ

o1 = new stzChar("ⅺ")
? o1.UPPERcased() #TODO // Ring upper() may be responsible for this!
 #--> should return Ⅺ but it returned nothing

pf()
# Executed in 0.01 second(s) in Ring 1.23
