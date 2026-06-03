# Narrative
# --------
# NEW FEATURES: FIND METHODS
#
# Extracted from stznumbrextest.ring, block #43.

load "../../stzBase.ring"


pr()

# Get Next Matching Number

Nx = Nx("{@Property(Prime) & @Digit2}")
? Nx.MatchingNumberAfter(10)  #--> 11 (first 2-digit prime >= 10)

pf()
