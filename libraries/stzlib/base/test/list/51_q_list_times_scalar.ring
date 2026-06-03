# Narrative
# --------
# Q(list) * N repeats the wrapped list N times. With a singleton
# list this is the natural "give me a vector of zeros" idiom:
# Q([0]) * 3  ->  [ 0, 0, 0 ].
#
# Extracted from stzlisttest.ring, the operator-overload block.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q([0]) * 3
#--> [0, 0, 0]

pf()
