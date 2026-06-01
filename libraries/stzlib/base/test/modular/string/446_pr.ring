# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #446.

load "../../../stzBase.ring"


o1 = new stzString("---4---8---")

? @@( o1.SplitAroundPositions([ 4, 8 ]) ) + NL
#--> [ "---", "---", "---" ]

? @@( o1.SplitWXT(:AroundPositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---", "---", "---" ]

pf()
# Executed in 0.13 second(s) in Ring 1.21
