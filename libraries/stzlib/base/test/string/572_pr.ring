# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #572.

load "../../stzBase.ring"


o1 = new stzString("bla <<nonword>> bla")

? @@( o1.FindSubStringBoundsZZ("word") )
#--> [ [ 9, 9 ], [ 14, 15 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
