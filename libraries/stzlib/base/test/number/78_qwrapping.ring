# Narrative
# --------
# How Q() lifts a raw value into a Softanza object so arithmetic stays "smart".
#
# Q() is the universal quick-wrapper: Q(12500) becomes a stzNumber, and any
# arithmetic touching it returns the same kind of object rather than a plain
# Ring number. So Q(12500) / 500 yields 25, and ( Q(12500) / Q(500) ) * 2
# yields 50 -- the result remains a stzNumber because Q() seeded the chain.
# This is the Softanza idiom: wrap once with Q() and the whole expression
# inherits the rich numeric behavior, keeping computations fluent and chainable.
#
#
# Repositioned from test/list (this is a stzNumber test, so it belongs under test/number).
# Extracted from stzlisttest.ring, block #414.

load "../../stzBase.ring"

pr()

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
