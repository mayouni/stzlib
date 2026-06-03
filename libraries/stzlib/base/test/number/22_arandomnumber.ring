# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #22.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? ARandomNumber( :Between = 5, :And = 10 )
#--> 5
#--> 7
#--> 9
#--> 8
#--> 7

pf()
