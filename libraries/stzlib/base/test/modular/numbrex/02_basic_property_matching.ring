# Narrative
# --------
# BASIC PROPERTY MATCHING
#
# Extracted from stznumbrextest.ring, block #2.

load "../../../stzBase.ring"


pr()

Nx = new stzNumbrex("{@Property(Prime)}")
? Nx.Match(17)  #--> TRUE
? Nx.Match(18)  #--> FALSE

pf()
