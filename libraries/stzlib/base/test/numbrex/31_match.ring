# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #31.

load "../../stzBase.ring"

pr()

Nx = Nx("{@Digit(1-9)6}")
? Nx.Match(123456) #--> TRUE

pf()
