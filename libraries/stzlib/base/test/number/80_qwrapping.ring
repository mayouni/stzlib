# Narrative
# --------
# How Q() lifts a plain Ring number into a Softanza stzNumber so that
# arithmetic operators (* here) dispatch through the object.
#
# Q(15) wraps 15 into a stzNumber; multiplying by a bare 7 yields 105.
# Nesting Q() on both operands -- ( Q(15) * Q(7) ) * 2 -- keeps the
# result an object-aware expression and evaluates to 210. The point is
# that Q() participation is sticky: once one operand is a stzNumber the
# whole expression stays in Softanza's numeric world, yet still prints
# as an ordinary scalar. The surrounding pr()/pf() pair brackets the
# block for the profiler; the trailing "STOPPED!" banner is pf()'s
# success marker, not an error.
#
#
# Repositioned from test/list (this is a stzNumber test, so it belongs under test/number).
# Extracted from stzlisttest.ring, block #416.

load "../../stzBase.ring"

pr()

? Q(15) * 7
#--> 105

? ( Q(15) * Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 210

pf()
# Executed in 0.11 second(s).
