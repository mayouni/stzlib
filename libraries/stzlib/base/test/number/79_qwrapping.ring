# Narrative
# --------
# Shows how Q() lifts a raw number into a Softanza stzNumber object
# that carries operator overloading into the surrounding expression.
#
# Q(12500) + 500 yields a plain 13000: only one operand is wrapped,
# so the addition resolves to ordinary numeric arithmetic. In the
# second expression ( Q(12500) + Q(500) ) * 2, the inner sum is a
# stzNumber (because Q(500) keeps the result an object), and that
# object's overloaded * operator multiplies it by 2, giving 26000.
# The idiom: wrap with Q() once and the object-ness propagates
# through the chained operations.
#
#
# Repositioned from test/list (this is a stzNumber test, so it belongs under test/number).
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
