# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #23.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? ARandomNumber( :Between = 1, :And = 5 ) # To include bounds (1 and 5) use ...XT()
#--> 2
#--> 4
#--> 3
#--> 4
#--> 3

pf()
