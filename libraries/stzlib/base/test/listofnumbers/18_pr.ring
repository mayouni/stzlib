# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #18.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q([1, "*", 2, "*", 3 ]) - "*"
#--> [ 1, 2, 3 ]

? ( Q([1,"*",  2, "*", 3 ]) - Q("*") ).Content()
# \_______________ _____________/
#                 V
#          A stzList object

#--> [ 1, 2, 3 ]

pf()
# Executed in 0.02 second(s)
