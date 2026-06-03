# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #198.

load "../../stzBase.ring"


o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedBy(["/", "/"], "bla")
? o1.Content()
#--> bla bla /bla/ and /bla/!

o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedByIB(["/", "/"], "bla")
? o1.Content()
#--> bla bla bla and bla!

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19
