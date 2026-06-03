# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #40.

load "../../stzBase.ring"

pr()

Nx = Nx("{@Part(Fractional)}")
? Nx.Match(5)     #--> FALSE
? Nx.Match(5.7)   #--> TRUE

pf()
