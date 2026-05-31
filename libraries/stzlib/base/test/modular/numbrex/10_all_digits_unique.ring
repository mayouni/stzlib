# Narrative
# --------
# ALL DIGITS UNIQUE
#
# Extracted from stznumbrextest.ring, block #10.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Digit(:unique)+}")
? Nx.Match(1234)    #--> TRUE
? Nx.Match(1223)    #--> FALSE
? Nx.Match(987654)  #--> TRUE

pf()
