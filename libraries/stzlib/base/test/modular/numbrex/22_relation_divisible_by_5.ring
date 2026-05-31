# Narrative
# --------
# RELATION: DIVISIBLE BY 5
#
# Extracted from stznumbrextest.ring, block #22.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Relation(Mod:5=0)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(25)  #--> TRUE
? Nx.Match(13)  #--> FALSE

pf()
