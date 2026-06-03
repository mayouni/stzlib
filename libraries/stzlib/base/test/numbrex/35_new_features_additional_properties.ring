# Narrative
# --------
# NEW FEATURES: ADDITIONAL PROPERTIES
#
# Extracted from stznumbrextest.ring, block #35.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Triangular)}")
? Nx.Match(1)   #--> TRUE
? Nx.Match(3)   #--> TRUE
? Nx.Match(6)   #--> TRUE
? Nx.Match(10)  #--> TRUE
? Nx.Match(11)  #--> FALSE

pf()
