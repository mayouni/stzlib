# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #37.

load "../../stzBase.ring"

pr()

Nx = Nx("{@Property(Abundant)}")
? Nx.Match(12)  #--> TRUE (1+2+3+4+6 = 16 > 12)
? Nx.Match(18)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()
