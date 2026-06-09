# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #315.
#ERR Error (R14) : Calling Method without definition: deepboundedby

load "../../stzBase.ring"

pr()

#                   ...4.6...v...4.v.v..1.v..
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                   ...^.^...0...^.6.8..^.3..

? @@( o1.FindBoundedByZZ([ "[", "]" ]) )
#--> [ [ 5, 9 ], [ 15, 15 ], [ 22, 22 ] ]

? @@( o1.BoundedBy([ "[", "]" ]) ) + NL
#--> [ " [===", "=", "=" ]

#--

? @@( o1.DeepFindBoundedByZZ([ "[", "]" ]) )
#--> [ [ 7, 9 ], [ 15, 15 ], [ 22, 22 ], [ 5, 17 ] ]

? @@( o1.DeepBoundedBy([ "[", "]" ]) )
#--> [ "===", "=", "=", " [===]---[=] " ]

StopProfiler()

pf()
# Executed in 0.04 second(s) in Ring 1.22
