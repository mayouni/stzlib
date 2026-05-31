# Narrative
# --------
# PERFECT NUMBERS
#
# Extracted from stznumbrextest.ring, block #3.

load "../../../stzBase.ring"


pr()

oPerfect = Nx("{@Property(Perfect)}")
? oPerfect.Match(6)   #--> TRUE
? oPerfect.Match(28)  #--> TRUE
? oPerfect.Match(12)  #--> FALSE

pf()
