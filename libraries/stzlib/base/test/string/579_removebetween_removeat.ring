# Narrative
# --------
# RemoveBetween RemoveAt
#
# Extracted from stzStringTest.ring, block #579.

load "../../stzBase.ring"


pr()

# EXAMPLE 1
#                             11
o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.RemoveXT("word", :AtPosition = 11)
? o1.Content() + NL
#--> bla bla <<>> bla bla <<noword>> bla <<word>>

# EXAMPLE 2
#                             11                              43
o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("word", :AtPositions = [ 11, 43 ])
? o1.Content()
#--> bla bla <<>> bla bla <<noword>> bla <<>>

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17
