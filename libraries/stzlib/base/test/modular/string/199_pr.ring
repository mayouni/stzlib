# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #199.

load "../../../stzBase.ring"


o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
? o1.Content()
#--> bla bla /bla/ and bla!

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedByIB = '/', :With = "bla" )
? o1.Content()
#--> bla bla bla and bla!

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.19
