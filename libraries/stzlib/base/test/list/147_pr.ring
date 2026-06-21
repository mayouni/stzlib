# Narrative
# --------
# Repeats a stzList in place using the arithmetic-style * operator.
#
# Softanza overloads * on stzList so that `o1 * 3` concatenates the
# list to itself the given number of times, mutating the object in
# place. Starting from [0, 1, 2], multiplying by 3 yields three
# back-to-back copies: [ 0, 1, 2, 0, 1, 2, 0, 1, 2 ]. This mirrors
# the familiar "string * n" idiom, extended to lists so collections
# can be tiled with a single, readable operator instead of a loop.
#
# Extracted from stzlisttest.ring, block #147.

load "../../stzBase.ring"

pr()

o1 = new stzList([0, 1, 2])
o1 * 3
o1.Show()
#--> [ 0, 1, 2, 0, 1, 2, 0, 1, 2 ]

pf()
# Executed in 0.03 second(s)
