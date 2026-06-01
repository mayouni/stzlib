# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #565.

load "../../../stzBase.ring"


o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

? @@( o1.FindSubStringBoundedBy("word", [ "<<", ">>" ]) )
#--> [ 11 ]

? @@( o1.FindSubStringBoundedByZZ("word", [ "<<", ">>" ]) ) + NL
#--> [ [ 11, 14 ] ]

#--

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByZZ([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 49 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
