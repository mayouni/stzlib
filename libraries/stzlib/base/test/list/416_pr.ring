# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #416.

load "../../stzBase.ring"


? Q(15) * 7
#--> 105

? ( Q(15) * Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 210

pf()
# Executed in 0.11 second(s).
