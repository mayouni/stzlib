# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #568.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

#                           9      16        26     33    39     46
#                           v------v         v------v     v------v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubString("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringIB("word") ) + NL
#--> [ 9, 26, 39 ]

? @@( o1.FindBoundedSubStringIBZZ("word") )
#--> [ [ 9, 16 ], [ 26, 33 ], [ 39, 46 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
