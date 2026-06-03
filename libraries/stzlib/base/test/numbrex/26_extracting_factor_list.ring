# Narrative
# --------
# EXTRACTING FACTOR LIST
#
# Extracted from stznumbrextest.ring, block #26.

load "../../stzBase.ring"


pr()

Nx = Nx("{@Factor+}")
? Nx.Match(42) #--> TRUE
? @@( Nx.Factors() )
#--> [ 1, 2, 3, 6, 7, 14, 21, 42 ]

pf()
