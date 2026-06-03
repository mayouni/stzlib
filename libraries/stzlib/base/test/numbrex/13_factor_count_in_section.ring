# Narrative
# --------
# FACTOR COUNT IN Section
#
# Extracted from stznumbrextest.ring, block #13.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Factor2-5}")
? Nx.Match(6)   #--> TRUE (4 factors)
? Nx.Match(12)  #--> FALSE (6 factors)
? Nx.Match(4)   #--> TRUE (3 factors)

pf()
