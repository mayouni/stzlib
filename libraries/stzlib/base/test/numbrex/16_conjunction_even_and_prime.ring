# Narrative
# --------
# CONJUNCTION: EVEN AND PRIME
#
# Extracted from stznumbrextest.ring, block #16.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Property(Even) & @Property(Prime)}")
? Nx.Match(2)  #--> TRUE (only even prime)
? Nx.Match(4)  #--> FALSE (even but not prime)
? Nx.Match(3)  #--> FALSE (prime but not even)

pf()
