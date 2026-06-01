# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #592.

load "../../../stzBase.ring"


o1 = new stzString("<<word>>")

? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.LeftBound() + NL
#--> "<<"

? o1.RightBound()
#--> ">>"

# And also FirstBound() and LastBound() for general
# use with left-to-right and right-toleft strings

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.13 second(s) in Ring 1.20
