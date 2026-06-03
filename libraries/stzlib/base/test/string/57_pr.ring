# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #57.

load "../../stzBase.ring"


o1 = new stzString( "a + b - c / d = 0")

o1.ReplaceMany( ["+", "-", "/" ], :By = "*" )
? o1.Content()	
#--> "a * b * c * d = 0"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.17
