# Narrative
# --------
# EXACT DIGIT COUNT
#
# Extracted from stznumbrextest.ring, block #7.

load "../../../stzBase.ring"


pr()

Nx3 = Nx("{@Digit3}")
? Nx3.Match(123)    #--> TRUE
? Nx3.Match(1234)   #--> FALSE
? Nx3.Match(12)     #--> FALSE

pf()
