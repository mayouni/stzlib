# Narrative
# --------
# NEGATION: NOT PRIME
#
# Extracted from stznumbrextest.ring, block #19.

load "../../stzBase.ring"


pr()

Nx = Nx("{@!Property(Prime)}")
? Nx.Match(4)  #--> TRUE (composite)
? Nx.Match(9)  #--> TRUE (composite)
? Nx.Match(7)  #--> FALSE (is prime)

pf()
