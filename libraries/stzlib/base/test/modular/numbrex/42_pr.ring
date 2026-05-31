# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #42.

load "../../../stzBase.ring"


Nx = Nx("{@Multiple(5)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(15)  #--> TRUE
? Nx.Match(12)  #--> FALSE

pf()
