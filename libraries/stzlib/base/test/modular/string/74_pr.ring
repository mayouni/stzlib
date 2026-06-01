# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #74.

load "../../../stzBase.ring"


o1 = new stzString( "a + b - c / d = 0")
o1.Replace( [ "+", "-", "/" ], :By = "*" ) # Or ReplaceMany()
 ? o1.Content()
	
#--> "a * b * c * d = 0"
	
pf()
# Executed in 0.05 second(s)
