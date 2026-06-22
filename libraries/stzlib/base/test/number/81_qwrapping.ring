# Narrative
# --------
# Q() lifts a raw number into a Softanza stzNumber so arithmetic operators
# work directly on the boxed value.
#
# Q(15) - 7 yields a plain 8: subtracting a Ring number from a boxed one
# returns the scalar result. ( Q(15) - Q(7) ) * 2 first reduces the boxed
# subtraction to 8, then the * 2 operator multiplies through to 16. The
# point is that Q()-wrapped numbers behave transparently under +, -, and *
# without any explicit unwrap, letting expressions read like ordinary math.
#
#
# Repositioned from test/list (this is a stzNumber test, so it belongs under test/number).
# Extracted from stzlisttest.ring, block #417.

load "../../stzBase.ring"

pr()

? Q(15) - 7
#--> 8

? ( Q(15) - Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 16

pf()
# Executed in 0.09 second(s).
