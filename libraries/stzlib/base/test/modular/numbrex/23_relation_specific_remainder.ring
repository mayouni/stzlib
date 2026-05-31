# Narrative
# --------
# RELATION: SPECIFIC REMAINDER
#
# Extracted from stznumbrextest.ring, block #23.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Relation(Mod:3=1)}")
? Nx.Match(10)  #--> TRUE (10 % 3 = 1)
? Nx.Match(7)   #--> TRUE (7 % 3 = 1)
? Nx.Match(9)   #--> FALSE (9 % 3 = 0)

pf()
