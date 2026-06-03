# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #573.

load "../../stzBase.ring"

pr()

#                                14    20                        46    52
#                                v     v                         v     v
o1 = new stzString("bla word bla <<word>> bla bla <<noword>> bla <<word>> word _word_")

? @@( o1.FindSubStringBoundsZZ("word") ) + NL
#--> [ 14, 20, 46, 52 ]

? @@( o1.FindTheseSubStringBounds("word", [ "<<", ">>" ]) ) + NL
# [ 14, 20, 46, 52 ]

? @@( o1.FindTheseSubStringBoundsZZ("word", [ "<<", ">>" ]) ) + NL
#--> [ [ 14, 15 ], [ 20, 21 ], [ 46, 47 ], [ 52, 53 ] ]

o1.RemoveTheseSubStringBounds("word", [ "<<", ">>" ])

? o1.Content()
# #--> bla word bla word bla bla <<noword>> bla word word _word_

pf()
# Executed in 0.10 second(s) in Ring 1.22
