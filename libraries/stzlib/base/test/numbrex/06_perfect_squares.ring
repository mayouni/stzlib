# Narrative
# --------
# PERFECT SQUARES
#
# Extracted from stznumbrextest.ring, block #6.

load "../../stzBase.ring"


pr()

oSquare = Nx("{@Property(Square)}")
? oSquare.Match(16)  #--> TRUE
? oSquare.Match(25)  #--> TRUE
? oSquare.Match(26)  #--> FALSE

pf()
