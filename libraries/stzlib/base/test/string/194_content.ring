# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #194.
#ERR Error (R14) : Calling Method without definition: replacext

load "../../stzBase.ring"

pr()

o1 = new stzString("bla bla <<♥♥♥>> and bla!")
o1.ReplaceXT( [], :BoundedBy = ["<<",">>"], :With = "bla" )
#--> bla bla <<bla>> and bla!

? o1.Content()

pf()
#--> Executed in 0.04 second(s)
