# Narrative
# --------
# pr()
#
# Extracted from stznumbrextest.ring, block #45.

load "../../stzBase.ring"


# Count matching numbers between two given numbers

Nx = Nx("{@Property(Prime) & @Digit2}")
? Nx.CountMatchingNumbersBetween(10, :And = 99)
#--> 21

pf()
