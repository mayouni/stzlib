# Narrative
# --------
# FindW with symmetric index math: This[@i-3] = This[@i+3].
#
# The predicate finds positions whose 3rd-previous item equals their
# 3rd-next item. In [ 0, 8, 0, 0, 1, 8, 0, 0 ] only position 4 qualifies
# (This[1]=0 equals This[7]=0). The engine evaluates the raw index math
# directly; out-of-range neighbours simply do not match, so the result is
# [ 4 ]. W is the single performant + expressive conditional form.
#
# Extracted from stzlisttest.ring, block #487.

load "../../stzBase.ring"

pr()

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? @@( o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') )
#--> [ 4 ]

pf()
# Executed in 0.23 second(s).
