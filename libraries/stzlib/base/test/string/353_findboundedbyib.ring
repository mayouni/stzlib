# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #353.

load "../../stzBase.ring"

pr()

o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindBoundedByIB([ "{", "}" ]) ) + NL
#--> [ 22, 32 ]

? @@( o1.BoundedByIBZ([ "{", "}" ]) ) + NL
#--> [ [ "{min}", 22 ], [ "{max}", 32 ] ]

? @@( o1.BoundedByIBZZ([ "{", "}" ]) )
#--> [ [ "{min}", [ 22, 26 ] ], [ "{max}", [ 32, 36 ] ] ]

StopProfiler()

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.24 second(s) in Ring 1.18
