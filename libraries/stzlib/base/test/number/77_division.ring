# Narrative
# --------
# A stzNumber object responds to Ring's arithmetic operators, here the
# division operator, returning the computed scalar result.
#
# Building a stzNumber around 12500 and writing o1 / 500 yields 25.
# The key Softanza idiom shown is non-mutation: arithmetic operators
# compute and return a new value but leave the wrapped number untouched,
# so o1.Content() still reports the original 12500 afterwards. Operators
# are read-only views; mutation requires an explicit setter.
#
#
# Repositioned from test/list (this is a stzNumber test, so it belongs under test/number).
# Extracted from stzlisttest.ring, block #413.

load "../../stzBase.ring"

pr()

o1 = new stzNumber(12500)

? o1 / 500
#--> 25

# Note that the / operator does not change the o1 content:

? o1.Content()
#--> 12500

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.21
