# Narrative
# --------
# NEGATION: NOT PERFECT
#
# Extracted from stznumbrextest.ring, block #20.

load "../../stzBase.ring"


pr()

Nx = Nx("{@!Property(Perfect)}")
? Nx.Match(10)  #--> TRUE (not perfect)
? Nx.Match(28)  #--> FALSE (is perfect)

pf()
