# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #23.

load "../../stzBase.ring"

pr()

? ARandomNumberBetweenAnd( :Between = 1, :And = 5 ) # bounds INCLUDED; strict: ARandomNumberStrictlyBetweenAnd()
#--> 2
#--> 4
#--> 3
#--> 4
#--> 3

pf()
