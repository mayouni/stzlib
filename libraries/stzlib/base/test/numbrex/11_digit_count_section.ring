# Narrative
# --------
# DIGIT COUNT Section
#
# Extracted from stznumbrextest.ring, block #11.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Digit2-4}")
? Nx.Match(12)     #--> TRUE
? Nx.Match(1234)   #--> TRUE
? Nx.Match(1)      #--> FALSE
? Nx.Match(12345)  #--> FALSE

pf()
