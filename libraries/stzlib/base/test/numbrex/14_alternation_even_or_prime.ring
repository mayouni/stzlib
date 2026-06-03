# Narrative
# --------
# ALTERNATION: EVEN OR PRIME
#
# Extracted from stznumbrextest.ring, block #14.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Even) | @Property(Prime)}")
? Nx.Match(2)  #--> TRUE (both even and prime)
? Nx.Match(4)  #--> TRUE (even)
? Nx.Match(7)  #--> TRUE (prime)
? Nx.Match(9)  #--> FALSE (neither)

pf()
