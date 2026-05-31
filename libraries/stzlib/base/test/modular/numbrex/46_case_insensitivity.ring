# Narrative
# --------
# CASE INSENSITIVITY
#
# Extracted from stznumbrextest.ring, block #46.

load "../../../stzBase.ring"


pr()

# Case Insensitive Keywords

Nx = Nx("{@PROPERTY(PRIME)}")
? Nx.Match(17)  #--> TRUE

Nx = Nx("{@property(prime)}")
? Nx.Match(17)  #--> TRUE

Nx = Nx("{@Property(Prime)}")
? Nx.Match(17)  #--> TRUE

pf()
