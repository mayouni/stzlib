# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #36.

load "../../../stzBase.ring"


Nx = Nx("{@Property(Cube)}")
? Nx.Match(1)   #--> TRUE
? Nx.Match(8)   #--> TRUE
? Nx.Match(27)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()
