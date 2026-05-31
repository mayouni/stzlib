# Narrative
# --------
# DIGITS WITHIN Section
#
# Extracted from stznumbrextest.ring, block #8.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Digit(1-5)+}")
? Nx.Match(1234)  #--> TRUE
? Nx.Match(1256)  #--> FALSE
? Nx.Match(543)   #--> TRUE
pf()
