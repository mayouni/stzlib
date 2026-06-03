# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #38.

load "../../stzBase.ring"

pr()

Nx = Nx("{@Property(Deficient)}")
? Nx.Match(8)   #--> TRUE (1+2+4 = 7 < 8)
? Nx.Match(10)  #--> TRUE (1+2+5 = 8 < 10)
? Nx.Match(6)   #--> FALSE (perfect)
pf()
