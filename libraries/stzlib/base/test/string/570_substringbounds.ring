# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #570.
#ERR Error (R14) : Calling Method without definition: substringbounds

load "../../stzBase.ring"

pr()

o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.SubStringBounds("word") )
#--> [ "<<", ">>", "<<", ">>", "<<", ">>" ]

o1.RemoveBoundedSubStringIB("word")
? o1.Content()
#--> bla word bla  bla bla  bla  word

pf()
# Executed in 0.07 second(s) in Ring 1.22
