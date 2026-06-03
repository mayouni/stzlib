# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #352.

load "../../stzBase.ring"


o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindBoundedBy([ "{", "}" ]) ) + NL
#--> [ 23, 33 ]

? @@( o1.FindBoundedByZZ([ "{", "}" ]) ) + NL
#--> [ [ 23, 25 ], [ 33, 35 ] ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.18
