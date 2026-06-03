# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #415.

load "../../stzBase.ring"

pr()

? Q(12500) + 500
#--> 13000

? ( Q(12500) + Q(500) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 26000

pf()
# Executed in 0.14 second(s).
