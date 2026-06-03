# Narrative
# --------
# pr()
#
# Extracted from stzextinctest.ring, block #4.

load "../../stzBase.ring"

pr()

bPositive = FALSE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([ -1 ])  # Only 1 value
? @@( v([ :x, :y, :z ]) )  #--> [ -1, 2, 3 ]  (replaces only :x; keeps :y/:z from vl())

pf()
# Executed in almost 0 second(s) in Ring 1.23
