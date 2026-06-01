# Narrative
# --------
#
# Extracted from stznamedvarstest.ring, block #2.

load "../../../stzBase.ring"

pr()

for i = 1 to 3
	Vr([ :x, :y, :z ]) '=' Vl([ i, 2*i, 3*i ])
next

? @@( v([ :x, :y, :z ]) )
#--> [ 3, 6, 9 ]

? @@( VarVal([ :x, :y, :z ]) ) # Or VrVl()
#--> [ [ "x", 3 ], [ "y", 6 ], [ "z", 9 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.20
