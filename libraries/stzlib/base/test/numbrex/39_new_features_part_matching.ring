# Narrative
# --------
# NEW FEATURES: PART MATCHING
#
# Extracted from stznumbrextest.ring, block #39.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Part(Integer)}")
? Nx.Match(5)     #--> TRUE
? Nx.Match(5.7)   #--> FALSE

pf()
