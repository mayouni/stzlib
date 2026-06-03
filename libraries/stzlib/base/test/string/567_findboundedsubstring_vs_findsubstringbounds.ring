# Narrative
# --------
# FindBoundedSubString() VS FindSubStringBounds()
#
# Extracted from stzStringTest.ring, block #567.
#ERR Error (R14) : Calling Method without definition: findboundedsubstring

load "../../stzBase.ring"


pr()
#                             11               28           41
#                             v                v            v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubString("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringZZ("word") ) + NL
#--> [ [ 11, 14 ], [ 28, 31 ], [ 41, 44 ] ]

? @@( o1.FindSubStringBounds("word") ) + NL
#--> [ 9, 15, 26, 32, 39, 45 ]

? @@( o1.FindSubStringBoundsZZ("word") )
#--< [ [ 9, 10 ], [ 15, 16 ], [ 26, 27 ], [ 32, 33 ], [ 39, 40 ], [ 45, 46 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.19
