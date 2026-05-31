# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #414.

load "../../../stzBase.ring"


? Q(12500) / 500
#--> 25

? ( Q(12500) / Q(500) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 50

pf()
# vExecuted in 0.05 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.21
