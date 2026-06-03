# Narrative
# --------
# RELATION: DIVISIBLE BY 10
#
# Extracted from stznumbrextest.ring, block #24.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Relation(Mod:5=0) & @Property(Even)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(20)  #--> TRUE
? Nx.Match(15)  #--> FALSE (not even)

pf()
