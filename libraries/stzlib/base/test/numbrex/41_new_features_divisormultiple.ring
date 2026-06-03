# Narrative
# --------
# NEW FEATURES: DIVISOR/MULTIPLE
#
# Extracted from stznumbrextest.ring, block #41.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Divisor(3)}")
? Nx.Match(9)   #--> TRUE
? Nx.Match(15)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()
