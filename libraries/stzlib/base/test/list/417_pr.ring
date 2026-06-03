# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #417.

load "../../stzBase.ring"


? Q(15) - 7
#--> 8

? ( Q(15) - Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 16

pf()
# Executed in 0.09 second(s).
