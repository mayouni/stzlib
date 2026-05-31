# Narrative
# --------
# NEGATION: NOT EVEN (ODD)
#
# Extracted from stznumbrextest.ring, block #21.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@!Property(Even)}")
? Nx.Match(7)  #--> TRUE (odd)
? Nx.Match(8)  #--> FALSE (is even)
pf()
