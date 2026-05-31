# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #44.

load "../../../stzBase.ring"


# Get matching numbers in between two numbers

Nx = Nx("{@Property(Perfect)}")
aResults = Nx.MatchingNumbersBetween(1, :And = 100)
? @@(aResults)  #--> [6, 28]

pf()
