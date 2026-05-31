# Narrative
# --------
# FACTOR COUNT
#
# Extracted from stznumbrextest.ring, block #12.

load "../../../stzBase.ring"


pr()

Nx4 = Nx("{@Factor4}")
? Nx4.Match(6)   #--> TRUE (factors: 1,2,3,6)
? Nx4.Match(8)   #--> TRUE (factors: 1,2,4,8)
? Nx4.Match(12)  #--> FALSE (factors: 1,2,3,4,6,12 = 6 factors)

pf()
