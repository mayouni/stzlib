# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #539.

load "../../stzBase.ring"

pr()

o1 = new stzString("How many words in <<many many words>>? So many!")

? @@( o1.FindPositions(:Of = "many") ) + NL
#--> [ 5, 21, 26, 43 ]

? @@( o1.FindAsSections(:Of = "many") ) + NL
#--> [ [ 5, 8 ], [ 21, 24 ], [ 26, 29 ], [ 43, 46 ] ]

#--

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? @@( o1.AnySubstringsBoundedBy([ "<<", :and = ">>" ]) )
#--> [ "word", "noword", "word" ]

? @@( o1.FindSubStringsBoundedBy([ "<<", :and = ">>" ]) ) + NL
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByAsSections([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 46 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
