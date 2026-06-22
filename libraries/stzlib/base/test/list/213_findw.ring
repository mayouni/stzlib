# Narrative
# --------
# FindW: locate the positions in a list where a boolean predicate holds.
#
# W is Softanza's single conditional-search form -- now both performant
# (engine-backed, no eval) AND expressive. There are two ways to reach a
# neighbour inside the predicate, with a deliberate difference:
#
#   * RAW index math, This[@i + 1], scans EVERY position. At the last
#     position This[@i+1] is out of range and reads as non-numeric, so the
#     trailing index 9 is matched too -> [ 2, 6, 9 ]. You own the bounds.
#
#   * The CURSOR keyword @NextItem opts into safe "executable-section"
#     bounding: the scan is restricted to positions where @NextItem exists,
#     so the last position (no successor) is dropped -> [ 2, 6 ].
#
# Pick raw indices when you want every slot; pick @NextItem when you want
# neighbour semantics with the bounds handled for you. (For real Ring logic
# in the predicate, use the WF family instead.)
#
# Extracted from stzlisttest.ring, block #213.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? o1.FindW(' NOT isNumber(This[@i + 1]) ')        # raw indices: scans all positions
#--> [ 2, 6, 9 ]

? o1.FindW(' Q(@NextItem).IsNotANumber() ')       # cursor: bounded to where @NextItem exists
#--> [ 2, 6 ]

? StzListQ( o1.FindW(' Q(@NextItem).IsNotANumber() ') ).IsEqualTo([ 2, 6 ])
#--> TRUE

? StzListQ( o1.FindW(' NOT isNumber(This[@i + 1]) ') ).IsEqualTo([ 2, 6, 9 ])
#--> TRUE

pf()
# Executed in 0.14 second(s).
