# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #218.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

? Q([ "I ", "believe ", "in ","Ring!" ]).Reduce()
#--> I believe in Ring!

pf()
#--> Executed in 0.93
